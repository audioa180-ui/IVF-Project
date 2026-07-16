import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ivf_patient_app/theme/app_theme.dart';
import 'package:ivf_patient_app/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:ivf_patient_app/providers/user_provider.dart';

class TreatmentJourneyScreen extends StatefulWidget {
  const TreatmentJourneyScreen({super.key});

  @override
  State<TreatmentJourneyScreen> createState() => _TreatmentJourneyScreenState();
}

class _TreatmentJourneyScreenState extends State<TreatmentJourneyScreen> {
  List<dynamic> _treatmentCycles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTreatmentCycles();
  }

  Future<void> _loadTreatmentCycles() async {
    setState(() => _isLoading = true);
    
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final cycles = await apiService.getPatientTreatmentCycles();
      
      if (mounted) {
        setState(() {
          _treatmentCycles = cycles;
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
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _treatmentCycles.isEmpty
                ? _buildEmptyState()
                : _buildContent(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_services_outlined, size: 64, color: AppColors.textLight),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No Treatment Cycles Yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your treatment journey will appear here once started by your doctor',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadTreatmentCycles,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSpacing.lg),
            ..._treatmentCycles.asMap().entries.map((entry) {
              final index = entry.key;
              final cycle = entry.value;
              return _buildCycleCard(cycle, index);
            }),
          ],
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Treatment Journey',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Track your IVF progress step by step',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildCycleCard(dynamic cycle, int index) {
    final status = cycle['status'] ?? 'unknown';
    final cycleType = cycle['cycleType'] ?? 'IVF';
    final startDate = cycle['startDate'] != null 
        ? DateTime.parse(cycle['startDate']) 
        : DateTime.now();
    
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cycle ${index + 1} - $cycleType',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusDisplay(status),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildCycleDetails(cycle),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideX();
  }

  Widget _buildCycleDetails(dynamic cycle) {
    final startDate = cycle['startDate'] != null 
        ? DateTime.parse(cycle['startDate']) 
        : null;
    final endDate = cycle['endDate'] != null 
        ? DateTime.parse(cycle['endDate']) 
        : null;
    final doctorName = cycle['doctorName'] ?? 'Not assigned';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Doctor', doctorName),
        if (startDate != null) _buildDetailRow('Start Date', _formatDate(startDate)),
        if (endDate != null) _buildDetailRow('End Date', _formatDate(endDate)),
        if (cycle['notes'] != null && cycle['notes'].isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Notes: ${cycle['notes']}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getStatusDisplay(String status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'completed':
        return 'Completed';
      case 'pregnant':
        return 'Pregnant';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.primary;
      case 'completed':
        return AppColors.success;
      case 'pregnant':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'active':
        return Icons.play_circle;
      case 'completed':
        return Icons.check_circle;
      case 'pregnant':
        return Icons.favorite;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}
