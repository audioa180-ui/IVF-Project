import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:admin_app/providers/admin_provider.dart';
import 'package:admin_app/theme/admin_theme.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _dashboardData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final data = await adminProvider.getDashboardData();
    if (data != null) {
      setState(() {
        _dashboardData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: Consumer<AdminProvider>(
          builder: (context, adminProvider, child) {
            if (adminProvider.isLoading && _dashboardData == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (_dashboardData == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: AdminTheme.textLight),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load dashboard',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      adminProvider.errorMessage ?? 'Unknown error',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AdminTheme.textMedium,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadDashboardData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final stats = _dashboardData!['stats'] as Map<String, dynamic>;
            final recentUsers = _dashboardData!['recentUsers'] as List<dynamic>;
            final upcomingAppointments = _dashboardData!['upcomingAppointments'] as List<dynamic>;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(Icons.dashboard, color: AdminTheme.lavenderPrimary),
                      const SizedBox(width: 12),
                      Text(
                        'Dashboard',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ],
                  ).animate().fadeIn().slideX(),
                  
                  const SizedBox(height: 24),
                  
                  // Stats Cards
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.3,
                    children: [
                      _buildStatCard(
                        'Total Users',
                        stats['totalUsers'].toString(),
                        Icons.people_outline,
                        AdminTheme.lavenderPrimary,
                      ).animate().fadeIn(delay: 100.ms).scale(),
                      _buildStatCard(
                        'Total Doctors',
                        stats['totalDoctors'].toString(),
                        Icons.local_hospital_outlined,
                        AdminTheme.success,
                      ).animate().fadeIn(delay: 200.ms).scale(),
                      _buildStatCard(
                        'Appointments',
                        stats['totalAppointments'].toString(),
                        Icons.calendar_today_outlined,
                        AdminTheme.info,
                      ).animate().fadeIn(delay: 300.ms).scale(),
                      _buildStatCard(
                        'Blog Posts',
                        stats['totalBlogs'].toString(),
                        Icons.article_outlined,
                        AdminTheme.warning,
                      ).animate().fadeIn(delay: 400.ms).scale(),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Recent Users Section
                  _buildSectionHeader('Recent Users', Icons.people_outline),
                  const SizedBox(height: 16),
                  
                  ...recentUsers.take(5).map((user) => _buildUserTile(user)),
                  
                  const SizedBox(height: 32),
                  
                  // Upcoming Appointments Section
                  _buildSectionHeader('Upcoming Appointments', Icons.calendar_today_outlined),
                  const SizedBox(height: 16),
                  
                  if (upcomingAppointments.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AdminTheme.lavenderPale.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.event_busy, color: AdminTheme.textLight, size: 48),
                            const SizedBox(height: 8),
                            Text(
                              'No upcoming appointments',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AdminTheme.textMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...upcomingAppointments.take(5).map((apt) => _buildAppointmentTile(apt)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
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
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AdminTheme.lavenderPrimary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }

  Widget _buildUserTile(dynamic user) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AdminTheme.lavenderPale,
          child: Text(
            user['name'][0].toString().toUpperCase(),
            style: TextStyle(
              color: AdminTheme.lavenderDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(user['name']),
        subtitle: Text(user['email']),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: user['profileComplete']
                ? AdminTheme.success.withValues(alpha: 0.1)
                : AdminTheme.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            user['profileComplete'] ? 'Complete' : 'Incomplete',
            style: TextStyle(
              fontSize: 10,
              color: user['profileComplete'] ? AdminTheme.success : AdminTheme.warning,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentTile(dynamic appointment) {
    final date = DateTime.parse(appointment['date']);
    final formattedDate = DateFormat('MMM dd, yyyy').format(date);
    
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AdminTheme.lavenderPale,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.calendar_today, color: AdminTheme.lavenderDark, size: 20),
        ),
        title: Text(appointment['doctorName']),
        subtitle: Text('$formattedDate at ${appointment['time']}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AdminTheme.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            appointment['status'].toString().toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color: AdminTheme.info,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
