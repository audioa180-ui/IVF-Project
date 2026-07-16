import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ivf_patient_app/models/appointment.dart';
import 'package:ivf_patient_app/theme/app_theme.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
    this.onCancel,
    this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final statusConfig = _getStatusConfig(appointment.status);
    final formattedDate = DateFormat('EEE, dd MMM yyyy').format(appointment.date);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            border: Border(
              left: BorderSide(
                color: statusConfig.color,
                width: 4,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusConfig.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusConfig.icon,
                            size: 14,
                            color: statusConfig.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusConfig.label,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: statusConfig.color,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  appointment.doctorName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  appointment.clinic,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formattedDate,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    const Icon(
                      Icons.access_time_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      appointment.time,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                if (appointment.status == AppointmentStatus.upcoming &&
                    (onCancel != null || onReschedule != null))
                  Column(
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      const Divider(height: 1),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          if (onReschedule != null) ...[
                            TextButton.icon(
                              onPressed: onReschedule,
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Reschedule'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                          ],
                          if (onCancel != null)
                            TextButton.icon(
                              onPressed: onCancel,
                              icon: const Icon(Icons.close, size: 16),
                              label: const Text('Cancel'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.error,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.upcoming:
        return _StatusConfig(
          color: AppColors.primary,
          label: 'Upcoming',
          icon: Icons.access_time,
        );
      case AppointmentStatus.completed:
        return _StatusConfig(
          color: AppColors.success,
          label: 'Completed',
          icon: Icons.check_circle_outline,
        );
      case AppointmentStatus.cancelled:
        return _StatusConfig(
          color: AppColors.error,
          label: 'Cancelled',
          icon: Icons.cancel_outlined,
        );
    }
  }
}

class _StatusConfig {
  final Color color;
  final String label;
  final IconData icon;

  _StatusConfig({
    required this.color,
    required this.label,
    required this.icon,
  });
}
