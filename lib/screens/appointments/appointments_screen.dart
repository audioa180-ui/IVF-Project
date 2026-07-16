import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ivf_patient_app/providers/app_provider.dart';
import 'package:ivf_patient_app/components/appointment_card.dart';
import 'package:ivf_patient_app/components/custom_button.dart';
import 'package:ivf_patient_app/theme/app_theme.dart';
import 'package:ivf_patient_app/models/appointment.dart';
import 'package:ivf_patient_app/screens/appointments/booking_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  AppointmentTab _activeTab = AppointmentTab.upcoming;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, child) {
            final upcoming = provider.upcomingAppointments;
            final history = [
              ...provider.completedAppointments,
              ...provider.cancelledAppointments
            ];
            final displayed =
                _activeTab == AppointmentTab.upcoming ? upcoming : history;

            return Column(
              children: [
                _buildHeader(context),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: CustomButton(
                    title: 'Book New Appointment',
                    onPressed: () => _navigateToBooking(context),
                    width: double.infinity,
                  ),
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: AppSpacing.md),
                _buildTabs(context, upcoming.length, history.length),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: displayed.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md),
                          itemCount: displayed.length,
                          itemBuilder: (context, index) {
                            final appointment = displayed[index];
                            return AppointmentCard(
                              appointment: appointment,
                              onCancel: appointment.status ==
                                      AppointmentStatus.upcoming
                                  ? () => _showCancelDialog(
                                      context, provider, appointment)
                                  : null,
                              onReschedule: appointment.status ==
                                      AppointmentStatus.upcoming
                                  ? () => _navigateToReschedule(
                                      context, appointment.id)
                                  : null,
                            ).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms).slideY(begin: 0.05, end: 0);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appointments',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 2),
          Text(
            'Manage your visits',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context, int upcomingCount, int historyCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () =>
                    setState(() => _activeTab = AppointmentTab.upcoming),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
                  decoration: BoxDecoration(
                    color: _activeTab == AppointmentTab.upcoming
                        ? AppColors.white
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                  child: Text(
                    'Upcoming ($upcomingCount)',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _activeTab == AppointmentTab.upcoming
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: _activeTab == AppointmentTab.upcoming
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () =>
                    setState(() => _activeTab = AppointmentTab.history),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
                  decoration: BoxDecoration(
                    color: _activeTab == AppointmentTab.history
                        ? AppColors.white
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                  child: Text(
                    'History ($historyCount)',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _activeTab == AppointmentTab.history
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: _activeTab == AppointmentTab.history
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final message = _activeTab == AppointmentTab.upcoming
        ? 'No upcoming appointments'
        : 'No appointment history';
    final subMessage = _activeTab == AppointmentTab.upcoming
        ? 'Book an appointment with our expert doctors'
        : 'Your past appointments will appear here';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '📅',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subMessage,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(
    BuildContext context,
    AppProvider provider,
    Appointment appointment,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: Text(
          'Are you sure you want to cancel your appointment with ${appointment.doctorName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              provider.cancelAppointment(appointment.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Appointment cancelled')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _navigateToBooking(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BookingScreen(),
      ),
    );
  }

  void _navigateToReschedule(BuildContext context, String appointmentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingScreen(rescheduleId: appointmentId),
      ),
    );
  }
}

enum AppointmentTab {
  upcoming,
  history,
}
