import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:admin_app/providers/admin_provider.dart';
import 'package:admin_app/theme/admin_theme.dart';
import 'package:admin_app/models/invoice.dart';
import 'package:intl/intl.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  List<Invoice>? _invoices;
  Map<String, dynamic>? _stats;
  String? _selectedStatus;
  bool _isLoading = false;

  final List<String> _statusOptions = ['All', 'pending', 'partial', 'paid', 'overdue', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    
    try {
      final results = await Future.wait([
        adminProvider.getAllInvoices(
          paymentStatus: _selectedStatus == 'All' ? null : _selectedStatus,
        ),
        adminProvider.getInvoiceStats(),
      ]);

      if (mounted) {
        setState(() {
          _invoices = (results[0] as List).map((e) => Invoice.fromJson(e as Map<String, dynamic>)).toList();
          _stats = results[1] as Map<String, dynamic>?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearFilters() {
    setState(() => _selectedStatus = null);
    _loadData();
  }

  void _showPaymentDialog(Invoice invoice) {
    String selectedStatus = invoice.paymentStatus;
    double paidAmount = invoice.paidAmount ?? 0.0;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Update Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusOption(
                'Pending',
                'pending',
                selectedStatus,
                () => setDialogState(() => selectedStatus = 'pending'),
              ),
              _buildStatusOption(
                'Partial',
                'partial',
                selectedStatus,
                () => setDialogState(() => selectedStatus = 'partial'),
              ),
              _buildStatusOption(
                'Paid',
                'paid',
                selectedStatus,
                () => setDialogState(() => selectedStatus = 'paid'),
              ),
              _buildStatusOption(
                'Overdue',
                'overdue',
                selectedStatus,
                () => setDialogState(() => selectedStatus = 'overdue'),
              ),
              const SizedBox(height: 16),
              if (selectedStatus == 'partial' || selectedStatus == 'paid')
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Paid Amount',
                    prefixText: '\$',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: paidAmount.toString()),
                  onChanged: (value) {
                    paidAmount = double.tryParse(value) ?? paidAmount;
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _updatePayment(invoice.id, selectedStatus, paidAmount);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updatePayment(String invoiceId, String status, double paidAmount) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    try {
      await adminProvider.updateInvoicePayment(invoiceId, status, paidAmount);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment updated successfully')),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update payment: $e')),
        );
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
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _invoices == null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AdminTheme.textLight),
          const SizedBox(height: 16),
          Text(
            'Failed to load invoices',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          if (_stats != null) _buildStatsSection(),
          SliverToBoxAdapter(
            child: _buildActiveFilters(),
          ),
          if (_invoices!.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final invoice = _invoices![index];
                    return _buildInvoiceCard(invoice, index);
                  },
                  childCount: _invoices!.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Revenue',
                    '\$${(_stats!['totalRevenue'] as num).toStringAsFixed(2)}',
                    AdminTheme.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Outstanding',
                    '\$${(_stats!['outstandingAmount'] as num).toStringAsFixed(2)}',
                    AdminTheme.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Pending',
                    _stats!['pending'].toString(),
                    AdminTheme.info,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Paid',
                    _stats!['paid'].toString(),
                    AdminTheme.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AdminTheme.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    if (_selectedStatus == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          if (_selectedStatus != null)
            _buildFilterChip(_selectedStatus!, () {
              setState(() => _selectedStatus = null);
              _loadData();
            }),
          TextButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Icons.clear_all, size: 16),
            label: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: onDeleted,
      backgroundColor: AdminTheme.lavenderPale,
      labelStyle: TextStyle(
        color: AdminTheme.lavenderDark,
        fontSize: 12,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: AdminTheme.textLight),
          const SizedBox(height: 16),
          Text(
            'No invoices found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AdminTheme.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(Invoice invoice, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getStatusColor(invoice.paymentStatus).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getStatusIcon(invoice.paymentStatus),
            color: _getStatusColor(invoice.paymentStatus),
          ),
        ),
        title: Text(
          invoice.invoiceNumber,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(invoice.patientName),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: AdminTheme.textMedium),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(invoice.invoiceDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminTheme.textMedium,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.attach_money, size: 14, color: AdminTheme.textMedium),
                const SizedBox(width: 4),
                Text(
                  '\$${invoice.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminTheme.textMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(invoice.paymentStatus).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                invoice.paymentStatusDisplay,
                style: TextStyle(
                  fontSize: 10,
                  color: _getStatusColor(invoice.paymentStatus),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (!invoice.isPaid)
              InkWell(
                onTap: () => _showPaymentDialog(invoice),
                child: Text(
                  'Update',
                  style: TextStyle(
                    fontSize: 11,
                    color: AdminTheme.lavenderPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => _showInvoiceDetails(invoice),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AdminTheme.warning;
      case 'partial':
        return AdminTheme.info;
      case 'paid':
        return AdminTheme.success;
      case 'overdue':
        return AdminTheme.error;
      case 'cancelled':
        return AdminTheme.textMedium;
      default:
        return AdminTheme.textMedium;
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

  Widget _buildStatusOption(String label, String value, String selectedStatus, VoidCallback onTap) {
    final isSelected = selectedStatus == value;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AdminTheme.lavenderPrimary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AdminTheme.lavenderPrimary : AdminTheme.textMedium,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AdminTheme.lavenderPrimary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AdminTheme.lavenderPrimary : AdminTheme.textDark,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInvoiceDetails(Invoice invoice) {
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
                        color: AdminTheme.textLight,
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
                            color: _getStatusColor(invoice.paymentStatus).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getStatusIcon(invoice.paymentStatus),
                            color: _getStatusColor(invoice.paymentStatus),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                invoice.invoiceNumber,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                invoice.patientName,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AdminTheme.textMedium,
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
                      _buildDetailRow('Invoice Date', DateFormat('MMM dd, yyyy').format(invoice.invoiceDate)),
                      _buildDetailRow('Due Date', DateFormat('MMM dd, yyyy').format(invoice.dueDate)),
                      _buildDetailRow('Status', invoice.paymentStatusDisplay),
                      _buildDetailRow('Payment Method', invoice.paymentMethod ?? 'N/A'),
                    ]),
                    const SizedBox(height: 24),
                    _buildDetailSection('Financial Summary', [
                      _buildDetailRow('Subtotal', '\$${invoice.subtotal.toStringAsFixed(2)}'),
                      _buildDetailRow('Tax', '\$${invoice.tax.toStringAsFixed(2)}'),
                      _buildDetailRow('Discount', '\$${invoice.discount.toStringAsFixed(2)}'),
                      _buildDetailRow('Total', '\$${invoice.total.toStringAsFixed(2)}'),
                      _buildDetailRow('Paid Amount', '\$${invoice.paidAmount.toStringAsFixed(2)}'),
                      _buildDetailRow('Remaining', '\$${invoice.remainingAmount.toStringAsFixed(2)}'),
                    ]),
                    const SizedBox(height: 24),
                    if (invoice.items.isNotEmpty)
                      _buildDetailSection('Items', [
                        ...invoice.items.map((item) => ListTile(
                          leading: const Icon(Icons.receipt_long),
                          title: Text(item.description),
                          subtitle: Text('${item.quantity} x \$${item.unitPrice.toStringAsFixed(2)}'),
                          trailing: Text('\$${item.total.toStringAsFixed(2)}'),
                        )),
                      ]),
                    const SizedBox(height: 24),
                    _buildDetailSection('Insurance', [
                      _buildDetailRow('Provider', invoice.insurance.provider.isEmpty ? 'N/A' : invoice.insurance.provider),
                      _buildDetailRow('Policy Number', invoice.insurance.policyNumber.isEmpty ? 'N/A' : invoice.insurance.policyNumber),
                      _buildDetailRow('Claim Number', invoice.insurance.claimNumber.isEmpty ? 'N/A' : invoice.insurance.claimNumber),
                      _buildDetailRow('Coverage', '\$${invoice.insurance.coverageAmount.toStringAsFixed(2)}'),
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
            color: AdminTheme.lavenderPrimary,
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
                color: AdminTheme.textMedium,
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

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Invoices',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              
              // Status Filter
              Text(
                'Payment Status',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _statusOptions.map((status) {
                  final isSelected = _selectedStatus == status;
                  return FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (selected) {
                      setSheetState(() {
                        _selectedStatus = selected ? status : null;
                      });
                    },
                    selectedColor: AdminTheme.lavenderPrimary.withValues(alpha: 0.2),
                    checkmarkColor: AdminTheme.lavenderPrimary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setSheetState(() {
                          _selectedStatus = null;
                        });
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _loadData();
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
