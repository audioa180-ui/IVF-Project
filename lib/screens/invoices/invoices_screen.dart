import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ivf_patient_app/theme/app_theme.dart';
import 'package:ivf_patient_app/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  List<dynamic> _invoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() => _isLoading = true);
    
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final invoices = await apiService.getPatientInvoices();
      
      if (mounted) {
        setState(() {
          _invoices = invoices;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInvoices,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _invoices.isEmpty
              ? _buildEmptyState()
              : _buildContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textLight),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No Invoices Yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your invoices will appear here once generated',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadInvoices,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _invoices.length,
        itemBuilder: (context, index) {
          final invoice = _invoices[index];
          return _buildInvoiceCard(invoice, index);
        },
      ),
    );
  }

  Widget _buildInvoiceCard(dynamic invoice, int index) {
    final paymentStatus = invoice['paymentStatus'] ?? 'pending';
    final invoiceNumber = invoice['invoiceNumber'] ?? 'N/A';
    final invoiceDate = invoice['invoiceDate'] != null 
        ? DateTime.parse(invoice['invoiceDate']) 
        : DateTime.now();
    final total = invoice['total']?.toDouble() ?? 0.0;
    final paidAmount = invoice['paidAmount']?.toDouble() ?? 0.0;
    
    final statusColor = _getStatusColor(paymentStatus);
    final statusIcon = _getStatusIcon(paymentStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            statusIcon,
            color: statusColor,
          ),
        ),
        title: Text(
          invoiceNumber,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatDate(invoiceDate)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.attach_money, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                if (paidAmount > 0)
                  Text(
                    'Paid: \$${paidAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getStatusDisplay(paymentStatus),
            style: TextStyle(
              fontSize: 10,
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () => _showInvoiceDetails(invoice),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX();
  }

  void _showInvoiceDetails(dynamic invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _getStatusColor(invoice['paymentStatus']).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getStatusIcon(invoice['paymentStatus']),
                            color: _getStatusColor(invoice['paymentStatus']),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                invoice['invoiceNumber'] ?? 'N/A',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                invoice['patientName'] ?? 'Patient',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildDetailSection('Invoice Information', [
                      _buildDetailRow('Invoice Date', _formatFullDate(invoice['invoiceDate'])),
                      _buildDetailRow('Due Date', _formatFullDate(invoice['dueDate'])),
                      _buildDetailRow('Status', _getStatusDisplay(invoice['paymentStatus'])),
                      _buildDetailRow('Payment Method', invoice['paymentMethod'] ?? 'N/A'),
                    ]),
                    const SizedBox(height: 24),
                    _buildDetailSection('Financial Summary', [
                      _buildDetailRow('Subtotal', '\$${(invoice['subtotal'] ?? 0).toStringAsFixed(2)}'),
                      _buildDetailRow('Tax', '\$${(invoice['tax'] ?? 0).toStringAsFixed(2)}'),
                      _buildDetailRow('Discount', '\$${(invoice['discount'] ?? 0).toStringAsFixed(2)}'),
                      _buildDetailRow('Total', '\$${(invoice['total'] ?? 0).toStringAsFixed(2)}'),
                      _buildDetailRow('Paid Amount', '\$${(invoice['paidAmount'] ?? 0).toStringAsFixed(2)}'),
                      _buildDetailRow('Remaining', '\$${((invoice['total'] ?? 0) - (invoice['paidAmount'] ?? 0)).toStringAsFixed(2)}'),
                    ]),
                    const SizedBox(height: 24),
                    if (invoice['items'] != null && invoice['items'].isNotEmpty)
                      _buildDetailSection('Items', [
                        ...invoice['items'].map((item) => ListTile(
                          leading: const Icon(Icons.receipt_long),
                          title: Text(item['description'] ?? 'Item'),
                          subtitle: Text('${item['quantity'] ?? 1} x \$${(item['unitPrice'] ?? 0).toStringAsFixed(2)}'),
                          trailing: Text('\$${(item['total'] ?? 0).toStringAsFixed(2)}'),
                        )),
                      ]),
                    const SizedBox(height: 24),
                    if (invoice['insurance'] != null && invoice['insurance']['provider'] != null)
                      _buildDetailSection('Insurance', [
                        _buildDetailRow('Provider', invoice['insurance']['provider'] ?? 'N/A'),
                        _buildDetailRow('Policy Number', invoice['insurance']['policyNumber'] ?? 'N/A'),
                        _buildDetailRow('Claim Number', invoice['insurance']['claimNumber'] ?? 'N/A'),
                        _buildDetailRow('Coverage', '\$${(invoice['insurance']['coverageAmount'] ?? 0).toStringAsFixed(2)}'),
                      ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatFullDate(String? dateString) {
    if (dateString == null) return 'N/A';
    final date = DateTime.parse(dateString);
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _getStatusDisplay(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'partial':
        return 'Partial';
      case 'paid':
        return 'Paid';
      case 'overdue':
        return 'Overdue';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'partial':
        return AppColors.info;
      case 'paid':
        return AppColors.success;
      case 'overdue':
        return AppColors.error;
      case 'cancelled':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'partial':
        return Icons.hourglass_empty;
      case 'paid':
        return Icons.check_circle;
      case 'overdue':
        return Icons.warning;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.receipt;
    }
  }
}
