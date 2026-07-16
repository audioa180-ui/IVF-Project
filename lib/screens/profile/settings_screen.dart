import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ivf_patient_app/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _reminders = true;
  bool _tips = true;
  bool _privateMode = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          elevation: 0,
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.text,
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text('YOUR EXPERIENCE',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: AppColors.primary, letterSpacing: .8, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.sm),
            Card(
                elevation: 2,
                child: Column(children: [
              SwitchListTile(
                  value: _reminders,
                  onChanged: (value) => setState(() => _reminders = value),
                  title: const Text('Appointment reminders'),
                  subtitle: const Text('Receive reminders before your visit'),
                  secondary: const Icon(Icons.notifications_outlined)),
              const Divider(height: 1),
              SwitchListTile(
                  value: _tips,
                  onChanged: (value) => setState(() => _tips = value),
                  title: const Text('Wellness tips'),
                  subtitle: const Text('Helpful guidance for your journey'),
                  secondary: const Icon(Icons.auto_awesome_outlined)),
            ])).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
            const SizedBox(height: AppSpacing.lg),
            Text('PRIVACY',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: AppColors.primary, letterSpacing: .8, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.sm),
            Card(
                elevation: 2,
                child: Column(children: [
              SwitchListTile(
                  value: _privateMode,
                  onChanged: (value) => setState(() => _privateMode = value),
                  title: const Text('Private app view'),
                  subtitle: const Text('Hide sensitive details in previews'),
                  secondary: const Icon(Icons.shield_outlined)),
              const Divider(height: 1),
              const ListTile(
                  leading: Icon(Icons.storage_outlined),
                  title: Text('Local data'),
                  subtitle: Text('Your demo data stays on this device'),
                  trailing:
                      Icon(Icons.check_circle, color: AppColors.success)),
            ])).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.05, end: 0),
            const SizedBox(height: AppSpacing.xl),
            Center(
                child: Text('Bloom IVF • Version 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary))),
          ],
        ),
      );
}
