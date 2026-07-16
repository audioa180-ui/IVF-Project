import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_app/providers/admin_provider.dart';
import 'package:admin_app/theme/admin_theme.dart';
import 'package:admin_app/screens/login/login_screen.dart';
import 'package:admin_app/screens/dashboard/dashboard_screen.dart';
import 'package:admin_app/screens/admin_management/admin_management_screen.dart';
import 'package:admin_app/screens/appointments/appointments_screen.dart';
import 'package:admin_app/screens/patients/patients_screen.dart';
import 'package:admin_app/screens/treatment_cycles/treatment_cycles_screen.dart';
import 'package:admin_app/screens/lab_results/lab_results_screen.dart';
import 'package:admin_app/screens/medications/medications_screen.dart';
import 'package:admin_app/screens/invoices/invoices_screen.dart';
import 'package:admin_app/screens/reports/reports_screen.dart';
import 'package:admin_app/screens/doctors/doctors_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final adminProvider = AdminProvider();
  await adminProvider.initialize();
  runApp(MyApp(provider: adminProvider));
}

class MyApp extends StatelessWidget {
  final AdminProvider provider;
  const MyApp({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: provider,
      child: MaterialApp(
        title: 'Bloom IVF Admin',
        debugShowCheckedModeBanner: false,
        theme: AdminTheme.lightTheme,
        home: const AppEntry(),
      ),
    );
  }
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        if (!adminProvider.isAuthenticated) {
          return const LoginScreen();
        }

        final screens = [
          const DashboardScreen(),
          const AppointmentsScreen(),
          const PatientsScreen(),
          const DoctorsScreen(),
          const TreatmentCyclesScreen(),
          const LabResultsScreen(),
          const MedicationsScreen(),
          const InvoicesScreen(),
          const ReportsScreen(),
          if (adminProvider.isMasterAdmin) const AdminManagementScreen(),
        ];

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            backgroundColor: AdminTheme.slatePale,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              const NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: 'Appointments',
              ),
              const NavigationDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: 'Patients',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Doctors',
              ),
              const NavigationDestination(
                icon: Icon(Icons.medical_services_outlined),
                selectedIcon: Icon(Icons.medical_services),
                label: 'Cycles',
              ),
              const NavigationDestination(
                icon: Icon(Icons.biotech_outlined),
                selectedIcon: Icon(Icons.biotech),
                label: 'Lab Results',
              ),
              const NavigationDestination(
                icon: Icon(Icons.medication_outlined),
                selectedIcon: Icon(Icons.medication),
                label: 'Medications',
              ),
              const NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: 'Invoices',
              ),
              const NavigationDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics),
                label: 'Reports',
              ),
              if (adminProvider.isMasterAdmin)
                const NavigationDestination(
                  icon: Icon(Icons.admin_panel_settings_outlined),
                  selectedIcon: Icon(Icons.admin_panel_settings),
                  label: 'Admins',
                ),
            ],
          ),
        );
      },
    );
  }
}
