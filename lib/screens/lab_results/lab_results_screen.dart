import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ivf_patient_app/theme/app_theme.dart';
import 'package:ivf_patient_app/services/api_service.dart';
import 'package:provider/provider.dart';

class LabResultsScreen extends StatefulWidget {
  const LabResultsScreen({super.key});

  @override
  State<LabResultsScreen> createState() => _LabResultsScreenState();
}

class _LabResultsScreenState extends State<LabResultsScreen> {
  List<dynamic> _labResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLabResults();
  }

  Future<void> _loadLabResults() async {
    setState(() => _isLoading = true);
    
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final results = await apiService.getPatientLabResults();
      
      if (mounted) {
        setState(() {
          _labResults = results;
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
        title: const Text('Lab Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLabResults,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _labResults.isEmpty
              ? _buildEmptyState()
              : _buildContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.biotech_outlined, size: 64, color: AppColors.textLight),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No Lab Results Yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your lab results will appear here once available',
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
      onRefresh: _loadLabResults,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _labResults.length,
        itemBuilder: (context, index) {
          final result = _labResults[index];
          return _buildResultCard(result, index);
        },
      ),
    );
  }

  Widget _buildResultCard(dynamic result, int index) {
    final isAbnormal = result['isAbnormal'] ?? false;
    final testType = result['testType'] ?? 'Unknown Test';
    final testCategory = result['testCategory'] ?? 'General';
    final testDate = result['testDate'] != null 
        ? DateTime.parse(result['testDate']) 
        : DateTime.now();
    final reviewed = result['reviewedBy'] != null;
    
    final statusColor = isAbnormal ? AppColors.error : AppColors.success;
    final statusIcon = isAbnormal ? Icons.warning : Icons.check_circle;

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
          testType,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(testCategory),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  _formatDate(testDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                if (reviewed)
                  Icon(Icons.verified, size: 14, color: AppColors.success),
                if (reviewed)
                  const SizedBox(width: 4),
                if (reviewed)
                  Text(
                    'Reviewed',
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
            isAbnormal ? 'Abnormal' : 'Normal',
            style: TextStyle(
              fontSize: 10,
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () => _showResultDetails(result),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX();
  }

  void _showResultDetails(dynamic result) {
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
                            color: (result['isAbnormal'] ?? false)
                                ? AppColors.error.withValues(alpha: 0.1)
                                : AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            (result['isAbnormal'] ?? false) ? Icons.warning : Icons.check_circle,
                            color: (result['isAbnormal'] ?? false) ? AppColors.error : AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result['testType'] ?? 'Unknown Test',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                result['testCategory'] ?? 'General',
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
                    _buildDetailSection('Test Information', [
                      _buildDetailRow('Test Date', _formatFullDate(result['testDate'])),
                      _buildDetailRow('Category', result['testCategory'] ?? 'N/A'),
                      _buildDetailRow('Status', (result['isAbnormal'] ?? false) ? 'Abnormal' : 'Normal'),
                      _buildDetailRow('Reviewed', (result['reviewedBy'] != null) ? 'Yes' : 'No'),
                    ]),
                    const SizedBox(height: 24),
                    if (result['singleResults'] != null && result['singleResults'].isNotEmpty)
                      _buildDetailSection('Single Results', [
                        ...result['singleResults'].map((r) => ListTile(
                          leading: const Icon(Icons.science),
                          title: Text(r['testName'] ?? 'Unknown'),
                          subtitle: Text('Value: ${r['value'] ?? 'N/A'}'),
                          trailing: Text(r['unit'] ?? ''),
                        )),
                      ]),
                    const SizedBox(height: 24),
                    if (result['multipleResults'] != null && result['multipleResults'].isNotEmpty)
                      _buildDetailSection('Multiple Results', [
                        ...result['multipleResults'].map((r) => ListTile(
                          leading: const Icon(Icons.list),
                          title: Text(r['testName'] ?? 'Unknown'),
                          subtitle: Text('Count: ${r['count'] ?? 0}'),
                        )),
                      ]),
                    const SizedBox(height: 24),
                    if (result['reviewNotes'] != null && result['reviewNotes'].isNotEmpty)
                      _buildDetailSection('Review Notes', [
                        Text(result['reviewNotes']),
                      ]),
                    const SizedBox(height: 24),
                    if (result['requiresFollowUp'] ?? false)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: AppColors.warning),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'This result requires follow-up. Please contact your doctor.',
                                style: TextStyle(color: AppColors.warning),
                              ),
                            ),
                          ],
                        ),
                      ),
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
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
