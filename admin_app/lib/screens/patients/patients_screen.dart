import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:admin_app/providers/admin_provider.dart';
import 'package:admin_app/theme/admin_theme.dart';
import 'package:admin_app/models/patient.dart';
import 'package:intl/intl.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  List<Patient>? _patients;
  Map<String, dynamic>? _stats;
  String? _searchQuery;
  String? _selectedStatus;
  bool _isLoading = false;

  final List<String> _statusOptions = ['All', 'active', 'inactive', 'archived'];

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
        adminProvider.getAllPatients(
          search: _searchQuery,
          status: _selectedStatus == 'All' ? null : _selectedStatus,
        ),
        adminProvider.getPatientStats(),
      ]);

      if (mounted) {
        setState(() {
          _patients = (results[0] as List).map((e) => Patient.fromJson(e as Map<String, dynamic>)).toList();
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
      _searchQuery = null;
      _selectedStatus = null;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
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
          : _patients == null
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
            'Failed to load patients',
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
          if (_patients!.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final patient = _patients![index];
                    return _buildPatientCard(patient, index);
                  },
                  childCount: _patients!.length,
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
                    'Active',
                    _stats!['active'].toString(),
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
                    'Active Cycles',
                    _stats!['activeCycles'].toString(),
                    AdminTheme.info,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Profile Complete',
                    _stats!['profileComplete'].toString(),
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
    if (_searchQuery == null && _selectedStatus == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          if (_searchQuery != null)
            _buildFilterChip('Search: $_searchQuery', () {
              setState(() => _searchQuery = null);
              _loadData();
            }),
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
          Icon(Icons.search_off, size: 64, color: AdminTheme.textLight),
          const SizedBox(height: 16),
          Text(
            'No patients found',
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

  Widget _buildPatientCard(Patient patient, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: patient.hasActiveCycle
              ? AdminTheme.success
              : AdminTheme.navyPale,
          child: Text(
            patient.name[0].toUpperCase(),
            style: TextStyle(
              color: patient.hasActiveCycle
                  ? Colors.white
                  : AdminTheme.navyDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          patient.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(patient.email),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.phone, size: 14, color: AdminTheme.textMedium),
                const SizedBox(width: 4),
                Text(
                  patient.phone.isEmpty ? 'No phone' : patient.phone,
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminTheme.textMedium,
                  ),
                ),
                const SizedBox(width: 12),
                if (patient.hasActiveCycle) ...[
                  Icon(Icons.medical_services, size: 14, color: AdminTheme.success),
                  const SizedBox(width: 4),
                  Text(
                    'Active Cycle - Day ${patient.activeCycle?.currentDay}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AdminTheme.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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
                color: _getStatusColor(patient.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                patient.statusDisplay,
                style: TextStyle(
                  fontSize: 10,
                  color: _getStatusColor(patient.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (!patient.profileComplete)
              Text(
                'Incomplete',
                style: TextStyle(
                  fontSize: 10,
                  color: AdminTheme.warning,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        onTap: () => _showPatientDetails(patient),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return AdminTheme.success;
      case 'inactive':
        return AdminTheme.warning;
      case 'archived':
        return AdminTheme.textMedium;
      default:
        return AdminTheme.textMedium;
    }
  }

  void _showPatientDetails(Patient patient) {
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
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AdminTheme.navyPale,
                          child: Text(
                            patient.name[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 24,
                              color: AdminTheme.navyDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patient.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                patient.email,
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
                    _buildDetailSection('Contact Information', [
                      _buildDetailRow('Phone', patient.phone.isEmpty ? 'N/A' : patient.phone),
                      _buildDetailRow('Address', patient.address.isEmpty ? 'N/A' : patient.address),
                      _buildDetailRow('Blood Type', patient.bloodType.isEmpty ? 'N/A' : patient.bloodType),
                    ]),
                    const SizedBox(height: 24),
                    _buildDetailSection('Partner Information', [
                      _buildDetailRow('Name', patient.partner.name.isEmpty ? 'N/A' : patient.partner.name),
                      _buildDetailRow('Email', patient.partner.email.isEmpty ? 'N/A' : patient.partner.email),
                      _buildDetailRow('Phone', patient.partner.phone.isEmpty ? 'N/A' : patient.partner.phone),
                    ]),
                    const SizedBox(height: 24),
                    if (patient.hasActiveCycle)
                      _buildDetailSection('Active Treatment Cycle', [
                        _buildDetailRow('Protocol', patient.activeCycle!.protocol),
                        _buildDetailRow('Current Day', 'Day ${patient.activeCycle!.currentDay}'),
                        _buildDetailRow('Status', patient.activeCycle!.status),
                        _buildDetailRow('Start Date', DateFormat('MMM dd, yyyy').format(patient.activeCycle!.startDate)),
                      ]),
                    const SizedBox(height: 24),
                    _buildDetailSection('Fertility Profile', [
                      _buildDetailRow('AMH Level', patient.fertilityProfile.amhLevel?.toString() ?? 'N/A'),
                      _buildDetailRow('AFC Count', patient.fertilityProfile.afcCount?.toString() ?? 'N/A'),
                      _buildDetailRow('FSH Level', patient.fertilityProfile.fshLevel?.toString() ?? 'N/A'),
                    ]),
                    const SizedBox(height: 24),
                    _buildDetailSection('Medical History', [
                      _buildDetailRow('Previous Treatments', patient.medicalHistory.previousTreatments.isEmpty ? 'None' : patient.medicalHistory.previousTreatments.join(', ')),
                      _buildDetailRow('Allergies', patient.medicalHistory.allergies.isEmpty ? 'None' : patient.medicalHistory.allergies.join(', ')),
                      _buildDetailRow('Chronic Conditions', patient.medicalHistory.chronicConditions.isEmpty ? 'None' : patient.medicalHistory.chronicConditions.join(', ')),
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
                'Filter Patients',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              
              // Search
              Text(
                'Search',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search by name, email, or phone',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setSheetState(() => _searchQuery = value.isEmpty ? null : value);
                },
              ),
              const SizedBox(height: 24),
              
              // Status Filter
              Text(
                'Status',
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
                    selectedColor: AdminTheme.navyPrimary.withValues(alpha: 0.2),
                    checkmarkColor: AdminTheme.navyPrimary,
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
                          _searchQuery = null;
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
