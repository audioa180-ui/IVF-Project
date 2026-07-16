import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:admin_app/providers/admin_provider.dart';
import 'package:admin_app/theme/admin_theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Map<String, dynamic>? _dashboardStats;
  Map<String, dynamic>? _appointmentStats;
  Map<String, dynamic>? _patientStats;
  Map<String, dynamic>? _cycleStats;
  Map<String, dynamic>? _labStats;
  Map<String, dynamic>? _medicationStats;
  Map<String, dynamic>? _invoiceStats;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAllStats();
  }

  Future<void> _loadAllStats() async {
    setState(() => _isLoading = true);
    
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    
    try {
      final results = await Future.wait([
        adminProvider.getDashboardData(),
        adminProvider.getAppointmentStats(),
        adminProvider.getPatientStats(),
        adminProvider.getTreatmentCycleStats(),
        adminProvider.getLabResultStats(),
        adminProvider.getMedicationStats(),
        adminProvider.getInvoiceStats(),
      ]);

      if (mounted) {
        setState(() {
          _dashboardStats = results[0];
          _appointmentStats = results[1];
          _patientStats = results[2];
          _cycleStats = results[3];
          _labStats = results[4];
          _medicationStats = results[5];
          _invoiceStats = results[6];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadAllStats,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewSection(),
            const SizedBox(height: 24),
            _buildAppointmentsSection(),
            const SizedBox(height: 24),
            _buildPatientsSection(),
            const SizedBox(height: 24),
            _buildTreatmentCyclesSection(),
            const SizedBox(height: 24),
            _buildLabResultsSection(),
            const SizedBox(height: 24),
            _buildMedicationsSection(),
            const SizedBox(height: 24),
            _buildInvoicesSection(),
            const SizedBox(height: 24),
            _buildKeyMetricsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection() {
    return _buildSection(
      'Overview',
      [
        if (_dashboardStats != null) ...[
          _buildStatCard('Total Users', _dashboardStats!['totalUsers']?.toString() ?? '0', AdminTheme.navyPrimary),
          _buildStatCard('Total Doctors', _dashboardStats!['totalDoctors']?.toString() ?? '0', AdminTheme.info),
          _buildStatCard('Total Appointments', _dashboardStats!['totalAppointments']?.toString() ?? '0', AdminTheme.success),
          _buildStatCard('Total Admins', _dashboardStats!['totalAdmins']?.toString() ?? '0', AdminTheme.warning),
        ],
      ],
    );
  }

  Widget _buildAppointmentsSection() {
    return _buildSection(
      'Appointments',
      [
        if (_appointmentStats != null) ...[
          _buildStatCard('Total', _appointmentStats!['total']?.toString() ?? '0', AdminTheme.navyPrimary),
          _buildStatCard('Upcoming', _appointmentStats!['upcoming']?.toString() ?? '0', AdminTheme.info),
          _buildStatCard('Completed', _appointmentStats!['completed']?.toString() ?? '0', AdminTheme.success),
          _buildStatCard('Cancelled', _appointmentStats!['cancelled']?.toString() ?? '0', AdminTheme.error),
        ],
      ],
    );
  }

  Widget _buildPatientsSection() {
    return _buildSection(
      'Patients',
      [
        if (_patientStats != null) ...[
          _buildStatCard('Total', _patientStats!['total']?.toString() ?? '0', AdminTheme.navyPrimary),
          _buildStatCard('Active', _patientStats!['active']?.toString() ?? '0', AdminTheme.success),
          _buildStatCard('Active Cycles', _patientStats!['activeCycles']?.toString() ?? '0', AdminTheme.info),
          _buildStatCard('Profile Complete', _patientStats!['profileComplete']?.toString() ?? '0', AdminTheme.warning),
        ],
      ],
    );
  }

  Widget _buildTreatmentCyclesSection() {
    return _buildSection(
      'Treatment Cycles',
      [
        if (_cycleStats != null) ...[
          _buildStatCard('Total', _cycleStats!['total']?.toString() ?? '0', AdminTheme.navyPrimary),
          _buildStatCard('Active', _cycleStats!['active']?.toString() ?? '0', AdminTheme.info),
          _buildStatCard('Pregnant', _cycleStats!['pregnant']?.toString() ?? '0', AdminTheme.success),
          _buildStatCard('Success Rate', '${_cycleStats!['successRate']?.toString() ?? '0'}%', AdminTheme.warning),
        ],
      ],
    );
  }

  Widget _buildLabResultsSection() {
    return _buildSection(
      'Lab Results',
      [
        if (_labStats != null) ...[
          _buildStatCard('Total', _labStats!['total']?.toString() ?? '0', AdminTheme.navyPrimary),
          _buildStatCard('Abnormal', _labStats!['abnormal']?.toString() ?? '0', AdminTheme.error),
          _buildStatCard('Follow-up', _labStats!['requiresFollowUp']?.toString() ?? '0', AdminTheme.warning),
          _buildStatCard('Reviewed', _labStats!['reviewed']?.toString() ?? '0', AdminTheme.success),
        ],
      ],
    );
  }

  Widget _buildMedicationsSection() {
    return _buildSection(
      'Medications',
      [
        if (_medicationStats != null) ...[
          _buildStatCard('Total', _medicationStats!['total']?.toString() ?? '0', AdminTheme.navyPrimary),
          _buildStatCard('Active', _medicationStats!['active']?.toString() ?? '0', AdminTheme.success),
          _buildStatCard('Low Stock', _medicationStats!['lowStock']?.toString() ?? '0', AdminTheme.error),
          _buildStatCard('Expiring Soon', _medicationStats!['expiringSoon']?.toString() ?? '0', AdminTheme.warning),
        ],
      ],
    );
  }

  Widget _buildInvoicesSection() {
    return _buildSection(
      'Invoices',
      [
        if (_invoiceStats != null) ...[
          _buildStatCard('Total', _invoiceStats!['total']?.toString() ?? '0', AdminTheme.navyPrimary),
          _buildStatCard('Pending', _invoiceStats!['pending']?.toString() ?? '0', AdminTheme.warning),
          _buildStatCard('Paid', _invoiceStats!['paid']?.toString() ?? '0', AdminTheme.success),
          _buildStatCard('Overdue', _invoiceStats!['overdue']?.toString() ?? '0', AdminTheme.error),
        ],
      ],
    );
  }

  Widget _buildKeyMetricsSection() {
    return _buildSection(
      'Key Financial Metrics',
      [
        if (_invoiceStats != null) ...[
          _buildLargeStatCard('Total Revenue', '\$${(_invoiceStats!['totalRevenue'] as num?)?.toStringAsFixed(2) ?? '0.00'}', AdminTheme.success),
          _buildLargeStatCard('Outstanding Amount', '\$${(_invoiceStats!['outstandingAmount'] as num?)?.toStringAsFixed(2) ?? '0.00'}', AdminTheme.warning),
        ],
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AdminTheme.navyPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: children,
        ),
      ],
    ).animate().fadeIn().slideY();
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
        mainAxisAlignment: MainAxisAlignment.center,
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

  Widget _buildLargeStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AdminTheme.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}
