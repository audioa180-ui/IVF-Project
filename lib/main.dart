import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ivf_patient_app/providers/app_provider.dart';
import 'package:ivf_patient_app/screens/auth/auth_screen.dart';
import 'package:ivf_patient_app/screens/auth/personal_details_screen.dart';
import 'package:ivf_patient_app/screens/home/home_screen.dart';
import 'package:ivf_patient_app/screens/appointments/appointments_screen.dart';
import 'package:ivf_patient_app/screens/doctors/doctors_screen.dart';
import 'package:ivf_patient_app/screens/blogs/blogs_screen.dart';
import 'package:ivf_patient_app/screens/profile/profile_screen.dart';
import 'package:ivf_patient_app/screens/startup/splash_screen.dart';
import 'package:ivf_patient_app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final provider = AppProvider();
  await provider.initialize();
  runApp(MyApp(provider: provider));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.provider});
  final AppProvider provider;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          title: 'Bloom IVF',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const AppEntry(),
        ),
      );
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});
  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool _showSplash = true;
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) return const SplashScreen();
    return Consumer<AppProvider>(
      builder: (_, provider, __) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: provider.isLoggedIn
            ? (provider.user.profileComplete
                ? const MainScreen(key: ValueKey('app'))
                : const PersonalDetailsScreen(key: ValueKey('onboarding')))
            : const AuthScreen(key: ValueKey('auth')),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  void _selectTab(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onNavigate: _selectTab),
      const AppointmentsScreen(),
      const DoctorsScreen(),
      const BlogsScreen(),
      ProfileScreen(onNavigate: _selectTab),
    ];
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
            child: child,
          ),
        ),
        child: KeyedSubtree(
            key: ValueKey(_currentIndex), child: screens[_currentIndex]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _selectTab,
        backgroundColor: AppColors.white,
        elevation: 8,
        indicatorColor: AppColors.primary.withValues(alpha: 0.1),
        animationDuration: const Duration(milliseconds: 300),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today),
              label: 'Appointments'),
          NavigationDestination(
              icon: Icon(Icons.local_hospital_outlined),
              selectedIcon: Icon(Icons.local_hospital),
              label: 'Doctors'),
          NavigationDestination(
              icon: Icon(Icons.article_outlined),
              selectedIcon: Icon(Icons.article),
              label: 'Library'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
    );
  }
}
