import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:admin_app/providers/admin_provider.dart';
import 'package:admin_app/theme/admin_theme.dart';
import 'package:admin_app/models/appointment.dart';
import 'package:intl/intl.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<Appointment>? _appointments;
  Map<String, dynamic>? _stats;
  String? _selectedDoctor;
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  final List<String> _statusOptions = ['All', 'upcoming', 'completed', 'cancelled'];

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
        adminProvider.getAllAppointments(
          doctorId: _selectedDoctor,
          status: _selectedStatus == 'All' ? null : _selectedStatus,
          startDate: _startDate?.toIso8601String(),
          endDate: _endDate?.toIso8601String(),
        ),
        adminProvider.getAppointmentStats(),
      ]);

      if (mounted) {
        setState(() {
          _appointments = (results[0] as List).map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList();
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
      _selectedDoctor = null;
      _selectedStatus = null;
      _startDate = null;
      _endDate = null;
    });
    _loadData();
  }

  void _showStatusDialog(Appointment appointment) {
    String selectedStatus = appointment.status;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Update Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusOption(
                'Upcoming',
                'upcoming',
                selectedStatus,
                () => setDialogState(() => selectedStatus = 'upcoming'),
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
                _updateStatus(appointment.id, selectedStatus);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
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

  Future<void> _updateStatus(String appointmentId, String status) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    try {
      await adminProvider.updateAppointmentStatus(appointmentId, status);
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
        title: const Text('Appointments'),
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
          : _appointments == null
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
            'Failed to load appointments',
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
          if (_appointments!.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final appointment = _appointments![index];
                    return _buildAppointmentCard(appointment, index);
                  },
                  childCount: _appointments!.length,
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
                    'Upcoming',
                    _stats!['upcoming'].toString(),
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
                    'Completed',
                    _stats!['completed'].toString(),
                    AdminTheme.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Cancelled',
                    _stats!['cancelled'].toString(),
                    AdminTheme.error,
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
    if (_selectedDoctor == null && _selectedStatus == null && _startDate == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          if (_selectedDoctor != null)
            _buildFilterChip(_selectedDoctor!, () {
              setState(() => _selectedDoctor = null);
              _loadData();
            }),
          if (_selectedStatus != null)
            _buildFilterChip(_selectedStatus!, () {
              setState(() => _selectedStatus = null);
              _loadData();
            }),
          if (_startDate != null && _endDate != null)
            _buildFilterChip(
              '${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd').format(_endDate!)}',
              () {
                setState(() {
                  _startDate = null;
                  _endDate = null;
                });
                _loadData();
              },
            ),
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
          Icon(Icons.event_busy, size: 64, color: AdminTheme.textLight),
          const SizedBox(height: 16),
          Text(
            'No appointments found',
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

  Widget _buildAppointmentCard(Appointment appointment, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getStatusColor(appointment.status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('dd').format(appointment.date),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(appointment.status),
                ),
              ),
              Text(
                DateFormat('MMM').format(appointment.date).substring(0, 3),
                style: TextStyle(
                  fontSize: 10,
                  color: AdminTheme.textMedium,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          appointment.doctorName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appointment.userName ?? 'Unknown Patient'),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: AdminTheme.textMedium),
                const SizedBox(width: 4),
                Text(
                  appointment.time,
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminTheme.textMedium,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.location_on, size: 14, color: AdminTheme.textMedium),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    appointment.clinic.isEmpty ? 'Main Clinic' : appointment.clinic,
                    style: TextStyle(
                      fontSize: 12,
                      color: AdminTheme.textMedium,
                    ),
                    overflow: TextOverflow.ellipsis,
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
                color: _getStatusColor(appointment.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                appointment.statusDisplay,
                style: TextStyle(
                  fontSize: 10,
                  color: _getStatusColor(appointment.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (appointment.isUpcoming)
              InkWell(
                onTap: () => _showStatusDialog(appointment),
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
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'upcoming':
        return AdminTheme.info;
      case 'completed':
        return AdminTheme.success;
      case 'cancelled':
        return AdminTheme.error;
      default:
        return AdminTheme.textMedium;
    }
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
                'Filter Appointments',
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
              
              // Date Range Filter
              Text(
                'Date Range',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    initialDateRange: _startDate != null && _endDate != null
                        ? DateTimeRange(start: _startDate!, end: _endDate!)
                        : null,
                  );
                  if (picked != null) {
                    setSheetState(() {
                      _startDate = picked.start;
                      _endDate = picked.end;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AdminTheme.navyPale),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: AdminTheme.navyPrimary),
                      const SizedBox(width: 12),
                      Text(
                        _startDate != null && _endDate != null
                            ? '${DateFormat('MMM dd, yyyy').format(_startDate!)} - ${DateFormat('MMM dd, yyyy').format(_endDate!)}'
                            : 'Select Date Range',
                        style: TextStyle(
                          color: _startDate != null
                              ? AdminTheme.textDark
                              : AdminTheme.textMedium,
                        ),
                      ),
                      const Spacer(),
                      if (_startDate != null)
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setSheetState(() {
                              _startDate = null;
                              _endDate = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setSheetState(() {
                          _selectedStatus = null;
                          _startDate = null;
                          _endDate = null;
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
