import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ivf_patient_app/components/doctor_card.dart';
import 'package:ivf_patient_app/data/mock_data.dart';
import 'package:ivf_patient_app/theme/app_theme.dart';
import 'package:ivf_patient_app/screens/appointments/booking_screen.dart';
import 'package:ivf_patient_app/screens/doctors/doctor_detail_screen.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredDoctors = MockData.doctors.where((doctor) {
      final query = _searchQuery.toLowerCase();
      return doctor.name.toLowerCase().contains(query) ||
          doctor.specialization.toLowerCase().contains(query) ||
          doctor.clinic.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + 2,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: _searchQuery)
                          ..selection = TextSelection.fromPosition(
                              TextPosition(offset: _searchQuery.length)),
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        decoration: const InputDecoration(
                          hintText: 'Search by name, specialty, clinic...',
                          hintStyle: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty) ...[
                      const SizedBox(width: AppSpacing.sm),
                      GestureDetector(
                        onTap: () => setState(() => _searchQuery = ''),
                        child: const Icon(
                          Icons.cancel,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: filteredDoctors.length,
                itemBuilder: (context, index) {
                  final doctor = filteredDoctors[index];
                  return DoctorCard(
                    doctor: doctor,
                    onTap: () => _navigateToDoctorDetail(context, doctor.id),
                    onBook: () => _navigateToBooking(context, doctor.id),
                  ).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms).slideY(begin: 0.05, end: 0);
                },
              ),
            ),
          ],
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
            'Our Doctors',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 2),
          Text(
            '${MockData.doctors.length} fertility specialists',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _navigateToDoctorDetail(BuildContext context, String doctorId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorDetailScreen(doctorId: doctorId),
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
