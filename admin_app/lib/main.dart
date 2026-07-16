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

  void _select(int index) {
    setState(() => _currentIndex = index);
    if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) Navigator.pop(context);
  }

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

        final destinations = _destinations(adminProvider.isMasterAdmin);
        if (_currentIndex >= screens.length) _currentIndex = 0;
        return LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          return Scaffold(
            appBar: wide ? null : AppBar(
              title: const Text('Bloom IVF · Clinic workspace'),
              actions: [IconButton(onPressed: adminProvider.logout, icon: const Icon(Icons.logout_outlined), tooltip: 'Sign out')],
            ),
            drawer: wide ? null : Drawer(child: _NavigationPanel(
              destinations: destinations, selectedIndex: _currentIndex, onSelect: _select, onLogout: adminProvider.logout,
            )),
            body: Row(children: [
              if (wide) SizedBox(width: 270, child: _NavigationPanel(
                destinations: destinations, selectedIndex: _currentIndex, onSelect: _select, onLogout: adminProvider.logout,
              )),
              Expanded(child: IndexedStack(index: _currentIndex, children: screens)),
            ]),
          );
        });
      },
    );
  }

  List<_NavItem> _destinations(bool master) => [
    const _NavItem('Overview', Icons.space_dashboard_outlined),
    const _NavItem('Appointments', Icons.calendar_month_outlined),
    const _NavItem('Patients', Icons.groups_outlined),
    const _NavItem('Care team', Icons.medical_services_outlined),
    const _NavItem('Treatment cycles', Icons.timeline_outlined),
    const _NavItem('Lab results', Icons.biotech_outlined),
    const _NavItem('Medications', Icons.medication_outlined),
    const _NavItem('Billing', Icons.receipt_long_outlined),
    const _NavItem('Reports', Icons.insights_outlined),
    if (master) const _NavItem('Access control', Icons.admin_panel_settings_outlined),
  ];
}

class _NavItem {
  final String label; final IconData icon;
  const _NavItem(this.label, this.icon);
}

class _NavigationPanel extends StatelessWidget {
  final List<_NavItem> destinations; final int selectedIndex; final ValueChanged<int> onSelect; final VoidCallback onLogout;
  const _NavigationPanel({required this.destinations, required this.selectedIndex, required this.onSelect, required this.onLogout});
  @override
  Widget build(BuildContext context) => Container(
    color: AdminTheme.lavenderDark,
    child: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(padding: EdgeInsets.fromLTRB(24, 28, 16, 24), child: Row(children: [
        CircleAvatar(backgroundColor: AdminTheme.beige, child: Icon(Icons.spa_outlined, color: AdminTheme.lavenderDark)),
        SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('BLOOM IVF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1.4)),
          SizedBox(height: 3), Text('CLINIC WORKSPACE', style: TextStyle(color: AdminTheme.lavenderPale, fontSize: 10, letterSpacing: 1.1)),
        ])),
      ])),
      Expanded(child: ListView.builder(itemCount: destinations.length, itemBuilder: (context, index) {
        final item = destinations[index]; final selected = index == selectedIndex;
        return Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2), child: ListTile(
          selected: selected, selectedTileColor: AdminTheme.lavenderLight.withValues(alpha: .32), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: Icon(item.icon, color: selected ? AdminTheme.beige : AdminTheme.lavenderPale),
          title: Text(item.label, style: TextStyle(color: selected ? Colors.white : AdminTheme.lavenderPale, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
          onTap: () => onSelect(index),
        ));
      })),
      Padding(padding: const EdgeInsets.all(12), child: ListTile(
        leading: const Icon(Icons.logout_outlined, color: AdminTheme.beige), title: const Text('Sign out', style: TextStyle(color: AdminTheme.beige)), onTap: onLogout,
      )),
    ])),
  );
}
