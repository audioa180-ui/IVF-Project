import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ivf_patient_app/data/mock_data.dart';
import 'package:ivf_patient_app/theme/app_theme.dart';

class TreatmentJourneyScreen extends StatelessWidget {
  const TreatmentJourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = MockData.treatmentSteps;
    final completedCount =
        steps.where((s) => s.status == TreatmentStatus.completed).length;
    final inProgressCount =
        steps.where((s) => s.status == TreatmentStatus.inProgress).length;
    final totalSteps = steps.length;
    final progress = (completedCount + inProgressCount * 0.5) / totalSteps;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: AppSpacing.lg),
              _buildProgressCard(context, progress, completedCount,
                  inProgressCount, totalSteps),
              const SizedBox(height: AppSpacing.lg),
              _buildTimeline(context, steps),
              const SizedBox(height: AppSpacing.xl),
            ],
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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

  Widget _buildProgressCard(
    BuildContext context,
    double progress,
    int completedCount,
    int inProgressCount,
    int totalSteps,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overall Progress',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(6),
              ),
              child: FractionallySizedBox(
                widthFactor: progress,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                    context, 'Completed', completedCount, AppColors.success),
                _buildStatItem(
                    context, 'In Progress', inProgressCount, AppColors.warning),
                _buildStatItem(
                    context,
                    'Remaining',
                    totalSteps - completedCount - inProgressCount,
                    AppColors.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildTimeline(BuildContext context, List steps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Treatment Steps',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        ...steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isLast = index == steps.length - 1;

          return Column(
            children: [
              _buildTimelineItem(context, step, isLast),
              if (!isLast) _buildTimelineConnector(context, step.status),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildTimelineItem(
      BuildContext context, TreatmentStep step, bool isLast) {
    final icon = _getStatusIcon(step.status);
    final iconColor = _getStatusColor(step.status);
    final backgroundColor = _getStatusBackgroundColor(step.status);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: iconColor,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        step.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      _buildStatusBadge(context, step.status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    step.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  if (step.date != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          step.date!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineConnector(BuildContext context, TreatmentStatus status) {
    final color = _getStatusColor(status);

    return Padding(
      padding: const EdgeInsets.only(left: 19),
      child: Container(
        width: 2,
        height: 20,
        decoration: BoxDecoration(
          color: status == TreatmentStatus.locked
              ? AppColors.border
              : color.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, TreatmentStatus status) {
    final config = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
      ),
      child: Text(
        config.label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: config.color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  IconData _getStatusIcon(TreatmentStatus status) {
    switch (status) {
      case TreatmentStatus.completed:
        return Icons.check;
      case TreatmentStatus.inProgress:
        return Icons.hourglass_top;
      case TreatmentStatus.locked:
        return Icons.lock;
    }
  }

  Color _getStatusColor(TreatmentStatus status) {
    switch (status) {
      case TreatmentStatus.completed:
        return AppColors.success;
      case TreatmentStatus.inProgress:
        return AppColors.primary;
      case TreatmentStatus.locked:
        return AppColors.textLight;
    }
  }

  Color _getStatusBackgroundColor(TreatmentStatus status) {
    switch (status) {
      case TreatmentStatus.completed:
        return AppColors.success.withValues(alpha: 0.1);
      case TreatmentStatus.inProgress:
        return AppColors.primary.withValues(alpha: 0.1);
      case TreatmentStatus.locked:
        return AppColors.card;
    }
  }

  _StatusConfig _getStatusConfig(TreatmentStatus status) {
    switch (status) {
      case TreatmentStatus.completed:
        return _StatusConfig(color: AppColors.success, label: 'Completed');
      case TreatmentStatus.inProgress:
        return _StatusConfig(color: AppColors.primary, label: 'In Progress');
      case TreatmentStatus.locked:
        return _StatusConfig(color: AppColors.textSecondary, label: 'Locked');
    }
  }
}

class _StatusConfig {
  final Color color;
  final String label;

  _StatusConfig({required this.color, required this.label});
}
