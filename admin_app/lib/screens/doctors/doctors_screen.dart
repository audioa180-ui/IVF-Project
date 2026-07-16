import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:admin_app/providers/admin_provider.dart';
import 'package:admin_app/theme/admin_theme.dart';
import 'package:admin_app/models/doctor.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  List<Doctor>? _doctors;
  Map<String, dynamic>? _stats;
  String? _selectedSpecialization;
  bool? _availableOnly;
  bool _isLoading = false;

  final List<String> _specializationOptions = ['All', 'IVF Specialist', 'Gynecologist', 'Embryologist', 'Fertility Consultant', 'Reproductive Endocrinologist'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    
    try {
      final results = await Future.wait([
        adminProvider.getAllDoctors(
          specialization: _selectedSpecialization == 'All' ? null : _selectedSpecialization,
          availableToday: _availableOnly,
        ),
        adminProvider.getDoctorStats(),
      ]);

      if (mounted) {
        setState(() {
          _doctors = (results[0] as List).map((e) => Doctor.fromJson(e as Map<String, dynamic>)).toList();
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
    setState(() {
      _selectedSpecialization = null;
      _availableOnly = null;
    });
    _loadData();
  }

  void _showAddDoctorDialog() {
    _showDoctorDialog(null);
  }

  void _showDoctorDialog(Doctor? doctor) {
    final nameController = TextEditingController(text: doctor?.name ?? '');
    final specializationController = TextEditingController(text: doctor?.specialization ?? '');
    final qualificationController = TextEditingController(text: doctor?.qualification ?? '');
    final experienceController = TextEditingController(text: doctor?.experience.toString() ?? '');
    final clinicController = TextEditingController(text: doctor?.clinic ?? '');
    final consultationFeeController = TextEditingController(text: doctor?.consultationFee.toString() ?? '');
    final successRateController = TextEditingController(text: doctor?.successRate.toString() ?? '');
    final ratingController = TextEditingController(text: doctor?.rating.toString() ?? '');
    final aboutController = TextEditingController(text: doctor?.about ?? '');
    
    bool availableToday = doctor?.availableToday ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(doctor == null ? 'Add Doctor' : 'Edit Doctor'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: specializationController,
                  decoration: const InputDecoration(labelText: 'Specialization'),
                ),
                TextField(
                  controller: qualificationController,
                  decoration: const InputDecoration(labelText: 'Qualification'),
                ),
                TextField(
                  controller: experienceController,
                  decoration: const InputDecoration(labelText: 'Experience (years)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: clinicController,
                  decoration: const InputDecoration(labelText: 'Clinic'),
                ),
                TextField(
                  controller: consultationFeeController,
                  decoration: const InputDecoration(labelText: 'Consultation Fee'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: successRateController,
                  decoration: const InputDecoration(labelText: 'Success Rate (%)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: ratingController,
                  decoration: const InputDecoration(labelText: 'Rating (0-5)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: aboutController,
                  decoration: const InputDecoration(labelText: 'About'),
                  maxLines: 3,
                ),
                SwitchListTile(
                  title: const Text('Available Today'),
                  value: availableToday,
                  onChanged: (value) => setDialogState(() => availableToday = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final doctorData = {
                  'name': nameController.text,
                  'specialization': specializationController.text,
                  'qualification': qualificationController.text,
                  'experience': int.tryParse(experienceController.text) ?? 0,
                  'clinic': clinicController.text,
                  'consultationFee': int.tryParse(consultationFeeController.text) ?? 0,
                  'successRate': double.tryParse(successRateController.text) ?? 0.0,
                  'rating': double.tryParse(ratingController.text) ?? 0.0,
                  'about': aboutController.text,
                  'availableToday': availableToday,
                  'languages': [],
                  'education': [],
                  'availableSlots': [],
                  'reviews': [],
                };

                Navigator.pop(context);

                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final adminProvider = Provider.of<AdminProvider>(context, listen: false);
                bool success;
                if (doctor == null) {
                  success = await adminProvider.createDoctor(doctorData);
                } else {
                  success = await adminProvider.updateDoctor(doctor.id, doctorData);
                }

                if (!mounted) return;
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Doctor saved successfully' : 'Failed to save doctor'),
                    backgroundColor: success ? AdminTheme.success : AdminTheme.error,
                  ),
                );
                if (success) _loadData();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Doctor doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Doctor'),
        content: Text('Are you sure you want to delete ${doctor.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final adminProvider = Provider.of<AdminProvider>(context, listen: false);
              final success = await adminProvider.deleteDoctor(doctor.id);
              if (!mounted) return;
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(success ? 'Doctor deleted successfully' : 'Failed to delete doctor'),
                  backgroundColor: success ? AdminTheme.success : AdminTheme.error,
                ),
              );
              if (success) _loadData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctors'),
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
          : _doctors == null
              ? _buildErrorState()
              : _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDoctorDialog,
        child: const Icon(Icons.add),
      ),
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
            'Failed to load doctors',
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
          if (_doctors!.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final doctor = _doctors![index];
                    return _buildDoctorCard(doctor, index);
                  },
                  childCount: _doctors!.length,
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
                    'Total',
                    _stats!['total'].toString(),
                    AdminTheme.navyPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Available',
                    _stats!['available'].toString(),
                    AdminTheme.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Avg Rating',
                    _stats!['averageRating'].toString(),
                    AdminTheme.warning,
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
    if (_selectedSpecialization == null && _availableOnly == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          if (_selectedSpecialization != null)
            _buildFilterChip('Specialization: $_selectedSpecialization', () {
              setState(() => _selectedSpecialization = null);
              _loadData();
            }),
          if (_availableOnly == true)
            _buildFilterChip('Available Only', () {
              setState(() => _availableOnly = null);
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
      backgroundColor: AdminTheme.navyPale,
      labelStyle: TextStyle(
        color: AdminTheme.navyDark,
        fontSize: 12,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_outlined, size: 64, color: AdminTheme.textLight),
          const SizedBox(height: 16),
          Text(
            'No doctors found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Add a new doctor to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AdminTheme.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doctor, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: doctor.availableToday
                ? AdminTheme.success.withValues(alpha: 0.1)
                : AdminTheme.textLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            doctor.availableToday ? Icons.check_circle : Icons.circle_outlined,
            color: doctor.availableToday ? AdminTheme.success : AdminTheme.textMedium,
          ),
        ),
        title: Text(
          doctor.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(doctor.specialization),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.star, size: 14, color: AdminTheme.warning),
                const SizedBox(width: 4),
                Text(
                  doctor.rating.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminTheme.textMedium,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.work, size: 14, color: AdminTheme.textMedium),
                const SizedBox(width: 4),
                Text(
                  '${doctor.experience} years',
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminTheme.textMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _showDoctorDialog(doctor),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              color: AdminTheme.error,
              onPressed: () => _showDeleteConfirmation(doctor),
            ),
          ],
        ),
        onTap: () => _showDoctorDetails(doctor),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX();
  }

  void _showDoctorDetails(Doctor doctor) {
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
                            color: doctor.availableToday
                                ? AdminTheme.success.withValues(alpha: 0.1)
                                : AdminTheme.textLight.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            doctor.availableToday ? Icons.check_circle : Icons.circle_outlined,
                            color: doctor.availableToday ? AdminTheme.success : AdminTheme.textMedium,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                doctor.specialization,
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
                    _buildDetailSection('Basic Information', [
                      _buildDetailRow('Qualification', doctor.qualification),
                      _buildDetailRow('Experience', '${doctor.experience} years'),
                      _buildDetailRow('Clinic', doctor.clinic.isEmpty ? 'N/A' : doctor.clinic),
                      _buildDetailRow('Available Today', doctor.availableToday ? 'Yes' : 'No'),
                    ]),
                    const SizedBox(height: 24),
                    _buildDetailSection('Performance', [
                      _buildDetailRow('Rating', '${doctor.rating} (${doctor.reviewCount} reviews)'),
                      _buildDetailRow('Success Rate', '${doctor.successRate}%'),
                      _buildDetailRow('Consultation Fee', '\$${doctor.consultationFee}'),
                    ]),
                    const SizedBox(height: 24),
                    if (doctor.about.isNotEmpty)
                      _buildDetailSection('About', [
                        Text(doctor.about),
                      ]),
                    const SizedBox(height: 24),
                    if (doctor.education.isNotEmpty)
                      _buildDetailSection('Education', [
                        ...doctor.education.map((edu) => ListTile(
                          leading: const Icon(Icons.school),
                          title: Text(edu),
                        )),
                      ]),
                    const SizedBox(height: 24),
                    if (doctor.languages.isNotEmpty)
                      _buildDetailSection('Languages', [
                        Wrap(
                          spacing: 8,
                          children: doctor.languages.map((lang) => Chip(label: Text(lang))).toList(),
                        ),
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
            color: AdminTheme.navyPrimary,
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
                'Filter Doctors',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              
              // Specialization Filter
              Text(
                'Specialization',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _specializationOptions.map((spec) {
                  final isSelected = _selectedSpecialization == spec;
                  return FilterChip(
                    label: Text(spec),
                    selected: isSelected,
                    onSelected: (selected) {
                      setSheetState(() {
                        _selectedSpecialization = selected ? spec : null;
                      });
                    },
                    selectedColor: AdminTheme.navyPrimary.withValues(alpha: 0.2),
                    checkmarkColor: AdminTheme.navyPrimary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              
              // Available Only Filter
              SwitchListTile(
                title: const Text('Available Today Only'),
                value: _availableOnly ?? false,
                onChanged: (value) {
                  setSheetState(() => _availableOnly = value ? true : null);
                },
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setSheetState(() {
                          _selectedSpecialization = null;
                          _availableOnly = null;
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
