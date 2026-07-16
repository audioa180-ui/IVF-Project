import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:admin_app/providers/admin_provider.dart';
import 'package:admin_app/theme/admin_theme.dart';
import 'package:admin_app/models/treatment_cycle.dart';
import 'package:intl/intl.dart';

class TreatmentCyclesScreen extends StatefulWidget {
  const TreatmentCyclesScreen({super.key});

  @override
  State<TreatmentCyclesScreen> createState() => _TreatmentCyclesScreenState();
}

class _TreatmentCyclesScreenState extends State<TreatmentCyclesScreen> {
  List<TreatmentCycle>? _cycles;
  Map<String, dynamic>? _stats;
  String? _selectedStatus;
  String? _selectedType;
  bool _isLoading = false;

  final List<String> _statusOptions = ['All', 'planned', 'active', 'paused', 'completed', 'cancelled', 'pregnant'];
  final List<String> _typeOptions = ['All', 'IVF', 'IUI', 'ICSI', 'FET', 'Egg Freezing'];

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
        adminProvider.getAllTreatmentCycles(
          status: _selectedStatus == 'All' ? null : _selectedStatus,
          cycleType: _selectedType == 'All' ? null : _selectedType,
        ),
        adminProvider.getTreatmentCycleStats(),
      ]);

      if (mounted) {
        setState(() {
          _cycles = (results[0] as List).map((e) => TreatmentCycle.fromJson(e as Map<String, dynamic>)).toList();
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
      _selectedStatus = null;
      _selectedType = null;
    });
    _loadData();
  }

  void _showStatusDialog(TreatmentCycle cycle) {
    String selectedStatus = cycle.status;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Update Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusOption(
                'Planned',
                'planned',
                selectedStatus,
                () => setDialogState(() => selectedStatus = 'planned'),
              ),
              _buildStatusOption(
                'Active',
                'active',
                selectedStatus,
                () => setDialogState(() => selectedStatus = 'active'),
              ),
              _buildStatusOption(
                'Paused',
                'paused',
                selectedStatus,
                () => setDialogState(() => selectedStatus = 'paused'),
              ),
              _buildStatusOption(
                'Completed',
                'completed',
                selectedStatus,
                () => setDialogState(() => selectedStatus = 'completed'),
              ),
              _buildStatusOption(
                'Cancelled',
                'cancelled',
                selectedStatus,
                () => setDialogState(() => selectedStatus = 'cancelled'),
              ),
              _buildStatusOption(
                'Pregnant',
                'pregnant',
                selectedStatus,
                () => setDialogState(() => selectedStatus = 'pregnant'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _updateStatus(cycle.id, selectedStatus);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(String cycleId, String status) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    try {
      await adminProvider.updateTreatmentCycleStatus(cycleId, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status updated successfully')),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treatment Cycles'),
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
          : _cycles == null
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
            'Failed to load treatment cycles',
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
          if (_cycles!.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final cycle = _cycles![index];
                    return _buildCycleCard(cycle, index);
                  },
                  childCount: _cycles!.length,
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
                    AdminTheme.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Pregnant',
                    _stats!['pregnant'].toString(),
                    AdminTheme.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Success Rate',
                    '${_stats!['successRate']}%',
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
    if (_selectedStatus == null && _selectedType == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          if (_selectedStatus != null)
            _buildFilterChip(_selectedStatus!, () {
              setState(() => _selectedStatus = null);
              _loadData();
            }),
          if (_selectedType != null)
            _buildFilterChip(_selectedType!, () {
              setState(() => _selectedType = null);
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
          Icon(Icons.medical_services_outlined, size: 64, color: AdminTheme.textLight),
          const SizedBox(height: 16),
          Text(
            'No treatment cycles found',
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

  Widget _buildCycleCard(TreatmentCycle cycle, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getStatusColor(cycle.status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Day ${cycle.currentDay}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(cycle.status),
                ),
              ),
              Text(
                cycle.cycleTypeDisplay,
                style: TextStyle(
                  fontSize: 10,
                  color: AdminTheme.textMedium,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          cycle.patientName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(cycle.doctorName),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: AdminTheme.textMedium),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(cycle.startDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminTheme.textMedium,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.science, size: 14, color: AdminTheme.textMedium),
                const SizedBox(width: 4),
                Text(
                  cycle.protocol,
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminTheme.textMedium,
                  ),
                ),
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
                color: _getStatusColor(cycle.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                cycle.statusDisplay,
                style: TextStyle(
                  fontSize: 10,
                  color: _getStatusColor(cycle.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (cycle.isActive)
              InkWell(
                onTap: () => _showStatusDialog(cycle),
                child: Text(
                  'Update',
                  style: TextStyle(
                    fontSize: 11,
                    color: AdminTheme.navyPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => _showCycleDetails(cycle),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'planned':
        return AdminTheme.textMedium;
      case 'active':
        return AdminTheme.info;
      case 'paused':
        return AdminTheme.warning;
      case 'completed':
        return AdminTheme.textMedium;
      case 'cancelled':
        return AdminTheme.error;
      case 'pregnant':
        return AdminTheme.success;
      default:
        return AdminTheme.textMedium;
    }
  }

  Widget _buildStatusOption(String label, String value, String selectedStatus, VoidCallback onTap) {
    final isSelected = selectedStatus == value;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AdminTheme.navyPrimary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AdminTheme.navyPrimary : AdminTheme.textMedium,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AdminTheme.navyPrimary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AdminTheme.navyPrimary : AdminTheme.textDark,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCycleDetails(TreatmentCycle cycle) {
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
                            color: _getStatusColor(cycle.status).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Day ${cycle.currentDay}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(cycle.status),
                                ),
                              ),
                              Text(
                                cycle.cycleTypeDisplay,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AdminTheme.textMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cycle.patientName,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                cycle.doctorName,
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
                    _buildDetailSection('Cycle Information', [
                      _buildDetailRow('Type', cycle.cycleTypeDisplay),
                      _buildDetailRow('Protocol', cycle.protocol),
                      _buildDetailRow('Start Date', DateFormat('MMM dd, yyyy').format(cycle.startDate)),
                      _buildDetailRow('Current Day', 'Day ${cycle.currentDay}'),
                      _buildDetailRow('Status', cycle.statusDisplay),
                    ]),
                    const SizedBox(height: 24),
                    if (cycle.stimulation.startDate != null)
                      _buildDetailSection('Stimulation Phase', [
                        _buildDetailRow('Start Date', DateFormat('MMM dd, yyyy').format(cycle.stimulation.startDate!)),
                        _buildDetailRow('Medications', cycle.stimulation.medications.isEmpty ? 'None' : cycle.stimulation.medications.map((m) => m.name).join(', ')),
                        _buildDetailRow('Monitoring Scans', '${cycle.stimulation.monitoringScans.length} scans'),
                      ]),
                    const SizedBox(height: 24),
                    if (cycle.trigger.date != null)
                      _buildDetailSection('Trigger', [
                        _buildDetailRow('Date', DateFormat('MMM dd, yyyy').format(cycle.trigger.date!)),
                        _buildDetailRow('Medication', cycle.trigger.medication),
                        _buildDetailRow('Dosage', cycle.trigger.dosage),
                      ]),
                    const SizedBox(height: 24),
                    if (cycle.opu.date != null)
                      _buildDetailSection('OPU', [
                        _buildDetailRow('Date', DateFormat('MMM dd, yyyy').format(cycle.opu.date!)),
                        _buildDetailRow('Eggs Retrieved', cycle.opu.eggsRetrieved?.toString() ?? 'N/A'),
                        _buildDetailRow('Mature Eggs', cycle.opu.matureEggs?.toString() ?? 'N/A'),
                      ]),
                    const SizedBox(height: 24),
                    if (cycle.embryology.fertilized != null)
                      _buildDetailSection('Embryology', [
                        _buildDetailRow('Fertilization Method', cycle.embryology.fertilizationMethod),
                        _buildDetailRow('Fertilized', cycle.embryology.fertilized?.toString() ?? 'N/A'),
                        _buildDetailRow('Day 3 Embryos', cycle.embryology.day3Embryos?.toString() ?? 'N/A'),
                        _buildDetailRow('Day 5 Blastocysts', cycle.embryology.day5Blastocysts?.toString() ?? 'N/A'),
                        _buildDetailRow('Cryopreserved', cycle.embryology.cryopreserved?.toString() ?? 'N/A'),
                      ]),
                    const SizedBox(height: 24),
                    if (cycle.transfer.date != null)
                      _buildDetailSection('Transfer', [
                        _buildDetailRow('Date', DateFormat('MMM dd, yyyy').format(cycle.transfer.date!)),
                        _buildDetailRow('Type', cycle.transfer.type),
                        _buildDetailRow('Embryos Transferred', cycle.transfer.embryosTransferred?.toString() ?? 'N/A'),
                        _buildDetailRow('Embryo Quality', cycle.transfer.embryoQuality),
                      ]),
                    const SizedBox(height: 24),
                    if (cycle.outcome.pregnancyTestDate != null)
                      _buildDetailSection('Outcome', [
                        _buildDetailRow('Test Date', DateFormat('MMM dd, yyyy').format(cycle.outcome.pregnancyTestDate!)),
                        _buildDetailRow('Result', cycle.outcome.pregnancyTestResult),
                        _buildDetailRow('HCG Level', cycle.outcome.hcgLevel?.toString() ?? 'N/A'),
                        _buildDetailRow('Heartbeat Detected', cycle.outcome.heartbeatDetected?.toString() ?? 'N/A'),
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
            width: 140,
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
                'Filter Cycles',
                style: Theme.of(context).textTheme.titleLarge,
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
              
              // Type Filter
              Text(
                'Cycle Type',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _typeOptions.map((type) {
                  final isSelected = _selectedType == type;
                  return FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      setSheetState(() {
                        _selectedType = selected ? type : null;
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
                          _selectedStatus = null;
                          _selectedType = null;
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
