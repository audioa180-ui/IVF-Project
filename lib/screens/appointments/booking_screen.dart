import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ivf_patient_app/providers/app_provider.dart';
import 'package:ivf_patient_app/components/custom_button.dart';
import 'package:ivf_patient_app/data/mock_data.dart';
import 'package:ivf_patient_app/models/doctor.dart';
import 'package:ivf_patient_app/theme/app_theme.dart';

class BookingScreen extends StatefulWidget {
  final String? doctorId;
  final String? rescheduleId;

  const BookingScreen({
    super.key,
    this.doctorId,
    this.rescheduleId,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  Doctor? selectedDoctor;
  DateTime? selectedDate;
  String? selectedTime;
  String? selectedClinic;

  @override
  void initState() {
    super.initState();
    if (widget.doctorId != null) {
      selectedDoctor = MockData.doctors.firstWhere(
        (d) => d.id == widget.doctorId,
        orElse: () => MockData.doctors.first,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rescheduleId != null
            ? 'Reschedule Appointment'
            : 'Book Appointment'),
        elevation: 0,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.text,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selectedDoctor != null) ...[
              _buildDoctorSummary(context, selectedDoctor!),
              const SizedBox(height: AppSpacing.lg),
            ] else
              _buildDoctorSelection(context),
            if (selectedDoctor != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _buildClinicSelection(context),
              const SizedBox(height: AppSpacing.lg),
              _buildDateSelection(context),
              const SizedBox(height: AppSpacing.lg),
              _buildTimeSelection(context, selectedDoctor!),
              const SizedBox(height: AppSpacing.xl),
              CustomButton(
                title: widget.rescheduleId != null
                    ? 'Update Appointment'
                    : 'Confirm Booking',
                onPressed: () => _confirmBooking(context),
                disabled: !_canBook(),
                width: double.infinity,
              ),
            ],
          ],
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
      ),
    );
  }

  Widget _buildDoctorSummary(BuildContext context, Doctor doctor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  doctor.photo,
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doctor.specialization,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doctor.clinic,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Doctor',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        ...MockData.doctors.map((doctor) {
          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: RadioListTile<Doctor>(
              title: Text(doctor.name),
              subtitle: Text('${doctor.specialization} • ${doctor.clinic}'),
              value: doctor,
              groupValue: selectedDoctor,
              onChanged: (value) => setState(() => selectedDoctor = value),
              activeColor: AppColors.primary,
              secondary: Text(
                doctor.photo,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildClinicSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Clinic',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        ...MockData.clinics.map((clinic) {
          return RadioListTile<String>(
            title: Text(clinic),
            value: clinic,
            groupValue: selectedClinic,
            onChanged: (value) => setState(() => selectedClinic = value),
            activeColor: AppColors.primary,
          );
        }),
      ],
    );
  }

  Widget _buildDateSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                        : 'Select a date',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textLight),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelection(BuildContext context, Doctor doctor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Time Slot',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: doctor.availableSlots.map((slot) {
            return FilterChip(
              label: Text(slot),
              selected: selectedTime == slot,
              onSelected: (selected) => setState(() => selectedTime = slot),
              backgroundColor: AppColors.card,
              selectedColor: AppColors.primary,
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        selectedTime == slot ? AppColors.white : AppColors.text,
                  ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                side: const BorderSide(color: AppColors.border),
              ),
              checkmarkColor: AppColors.white,
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  bool _canBook() {
    return selectedDoctor != null &&
        selectedDate != null &&
        selectedTime != null &&
        selectedClinic != null;
  }

  void _confirmBooking(BuildContext context) {
    final provider = context.read<AppProvider>();

    if (widget.rescheduleId != null) {
      provider.rescheduleAppointment(
        appointmentId: widget.rescheduleId!,
        newDate: selectedDate!,
        newTime: selectedTime!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment rescheduled successfully'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      provider.bookAppointment(
        doctorId: selectedDoctor!.id,
        doctorName: selectedDoctor!.name,
        clinic: selectedClinic!,
        date: selectedDate!,
        time: selectedTime!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Appointment booked with ${selectedDoctor!.name} on ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} at $selectedTime',
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    Navigator.pop(context);
  }
}
