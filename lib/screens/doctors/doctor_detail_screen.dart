import 'package:flutter/material.dart';
import 'package:ivf_patient_app/components/custom_button.dart';
import 'package:ivf_patient_app/data/mock_data.dart';
import 'package:ivf_patient_app/models/doctor.dart';
import 'package:ivf_patient_app/screens/appointments/booking_screen.dart';
import 'package:ivf_patient_app/theme/app_theme.dart';

class DoctorDetailScreen extends StatelessWidget {
  final String doctorId;

  const DoctorDetailScreen({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    final doctor = MockData.doctors.firstWhere(
      (d) => d.id == doctorId,
      orElse: () => MockData.doctors.first,
    );
    final doctorReviews = MockData.reviews
        .where((review) => review.doctorId == doctorId)
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: Text(
                            doctor.photo,
                            style: const TextStyle(fontSize: 50),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(context, doctor),
                  const SizedBox(height: AppSpacing.lg),
                  _buildStatsRow(context, doctor),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSection(context, 'About', doctor.about),
                  const SizedBox(height: AppSpacing.lg),
                  _buildEducationSection(context, doctor),
                  const SizedBox(height: AppSpacing.lg),
                  _buildLanguagesSection(context, doctor),
                  const SizedBox(height: AppSpacing.lg),
                  _buildConsultationFee(context, doctor),
                  const SizedBox(height: AppSpacing.lg),
                  _buildAvailableSlots(context, doctor),
                  if (doctorReviews.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _buildReviewsSection(context, doctorReviews),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, doctor),
    );
  }

  Widget _buildProfileHeader(BuildContext context, Doctor doctor) {
    return Column(
      children: [
        Text(
          doctor.name,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontSize: 22,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          doctor.qualification,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          doctor.specialization,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context, Doctor doctor) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, size: 18, color: Color(0xFFF39C12)),
                    const SizedBox(width: 4),
                    Text(
                      doctor.rating.toString(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Rating',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.border,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '${doctor.experience}+',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Years Exp',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.border,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '${doctor.successRate}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Success Rate',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildEducationSection(BuildContext context, Doctor doctor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Education',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        ...doctor.education.map((edu) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                const Icon(
                  Icons.school_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    edu,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLanguagesSection(BuildContext context, Doctor doctor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Languages',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: doctor.languages
              .map((lang) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppBorderRadius.full),
                    ),
                    child: Text(
                      lang,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildConsultationFee(BuildContext context, Doctor doctor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Consultation Fee',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '₹${doctor.consultationFee}',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontSize: 24,
                color: AppColors.primary,
              ),
        ),
      ],
    );
  }

  Widget _buildAvailableSlots(BuildContext context, Doctor doctor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Slots',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: doctor.availableSlots
              .map((slot) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Text(
                      slot,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(BuildContext context, List reviews) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Patient Reviews',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        ...reviews.map((review) {
          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        review.patientName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Row(
                        children: List.generate(
                          review.rating,
                          (index) => const Icon(
                            Icons.star,
                            size: 12,
                            color: Color(0xFFF39C12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    review.comment,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, Doctor doctor) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Consultation',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '₹${doctor.consultationFee}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: CustomButton(
              title: 'Book Appointment',
              onPressed: () => _navigateToBooking(context, doctor.id),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToBooking(BuildContext context, String doctorId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingScreen(doctorId: doctorId),
      ),
    );
  }
}

// This older local flow is retained temporarily; navigation uses the shared
// booking flow imported from screens/appointments/booking_screen.dart.
class LegacyBookingScreen extends StatefulWidget {
  final String doctorId;

  const LegacyBookingScreen({super.key, required this.doctorId});

  @override
  State<LegacyBookingScreen> createState() => _LegacyBookingScreenState();
}

class _LegacyBookingScreenState extends State<LegacyBookingScreen> {
  DateTime? selectedDate;
  String? selectedTime;
  String? selectedClinic;

  @override
  Widget build(BuildContext context) {
    final doctor = MockData.doctors.firstWhere(
      (d) => d.id == widget.doctorId,
      orElse: () => MockData.doctors.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDoctorSummary(context, doctor),
            const SizedBox(height: AppSpacing.lg),
            _buildClinicSelection(context),
            const SizedBox(height: AppSpacing.lg),
            _buildDateSelection(context),
            const SizedBox(height: AppSpacing.lg),
            _buildTimeSelection(context, doctor),
            const SizedBox(height: AppSpacing.xl),
            CustomButton(
              title: 'Confirm Booking',
              onPressed: () => _confirmBooking(context, doctor),
              disabled: selectedDate == null ||
                  selectedTime == null ||
                  selectedClinic == null,
              width: double.infinity,
            ),
          ],
        ),
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
                ],
              ),
            ),
          ],
        ),
      ),
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
            final isSelected = selectedTime == slot;
            return FilterChip(
              label: Text(slot),
              selected: isSelected,
              onSelected: (selected) => setState(() => selectedTime = slot),
              backgroundColor: AppColors.card,
              selectedColor: AppColors.primary,
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? AppColors.white : AppColors.text,
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

  void _confirmBooking(BuildContext context, Doctor doctor) {
    // Here you would integrate with the provider to book the appointment
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Appointment booked with ${doctor.name} on ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} at $selectedTime',
        ),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }
}
