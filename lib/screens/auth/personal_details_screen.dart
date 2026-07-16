import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ivf_patient_app/components/custom_button.dart';
import 'package:ivf_patient_app/providers/app_provider.dart';
import 'package:ivf_patient_app/theme/app_theme.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  bool _busy = false;

  final _age = TextEditingController();
  final _phone = TextEditingController();
  final _bloodGroup = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _partnerName = TextEditingController();
  final _tryingSince = TextEditingController();
  final _ivfAttempts = TextEditingController(text: '0');
  final _cycleDays = TextEditingController(text: '28');
  final _allergies = TextEditingController();
  final _medications = TextEditingController();
  final _medicalHistory = TextEditingController();

  String _gender = 'Female';
  String _maritalStatus = 'Married';

  @override
  void initState() {
    super.initState();
    final user = context.read<AppProvider>().user;
    _age.text = user.age > 0 ? '${user.age}' : '';
    _phone.text = user.phone;
    _bloodGroup.text = user.bloodGroup;
    _height.text = user.height;
    _weight.text = user.weight;
    _partnerName.text = user.partnerName;
    _tryingSince.text = user.tryingSince;
    _ivfAttempts.text = '${user.previousIvfAttempts}';
    _cycleDays.text = '${user.menstrualCycleDays}';
    _allergies.text = user.allergies;
    _medications.text = user.currentMedications;
    _medicalHistory.text = user.medicalHistory;
    _gender = user.gender.isNotEmpty ? user.gender : 'Female';
    _maritalStatus =
        user.maritalStatus.isNotEmpty ? user.maritalStatus : 'Married';
  }

  @override
  void dispose() {
    _pageController.dispose();
    _age.dispose();
    _phone.dispose();
    _bloodGroup.dispose();
    _height.dispose();
    _weight.dispose();
    _partnerName.dispose();
    _tryingSince.dispose();
    _ivfAttempts.dispose();
    _cycleDays.dispose();
    _allergies.dispose();
    _medications.dispose();
    _medicalHistory.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_validateCurrentStep()) return;

    setState(() => _busy = true);
    final provider = context.read<AppProvider>();
    final existing = provider.user;

    await provider.completeProfile(existing.copyWith(
      profileComplete: true,
      age: int.tryParse(_age.text.trim()) ?? 0,
      gender: _gender,
      bloodGroup: _bloodGroup.text.trim(),
      phone: _phone.text.trim(),
      height: _height.text.trim(),
      weight: _weight.text.trim(),
      partnerName: _partnerName.text.trim(),
      tryingSince: _tryingSince.text.trim(),
      previousIvfAttempts: int.tryParse(_ivfAttempts.text.trim()) ?? 0,
      menstrualCycleDays: int.tryParse(_cycleDays.text.trim()) ?? 28,
      allergies: _allergies.text.trim().isEmpty ? 'None' : _allergies.text.trim(),
      currentMedications: _medications.text.trim(),
      medicalHistory: _medicalHistory.text.trim(),
      maritalStatus: _maritalStatus,
      photo: '👩',
    ));

    if (mounted) setState(() => _busy = false);
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_age.text.trim().isEmpty || int.tryParse(_age.text) == null) {
          _showError('Please enter a valid age');
          return false;
        }
        if (_phone.text.trim().length < 10) {
          _showError('Please enter a valid phone number');
          return false;
        }
        if (_bloodGroup.text.trim().isEmpty) {
          _showError('Please enter your blood group');
          return false;
        }
        return true;
      case 1:
        if (_tryingSince.text.trim().isEmpty) {
          _showError('Please tell us how long you have been trying');
          return false;
        }
        return true;
      case 2:
        return true;
      default:
        return true;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _nextStep() {
    if (!_validateCurrentStep()) return;
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.blush],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.favorite, color: Colors.white),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${provider.user.name.split(' ').first}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              'Let\'s personalize your IVF care profile',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildStepIndicator(),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _busy ? null : _prevStep,
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      title: _currentStep == 2
                          ? 'Complete Profile'
                          : 'Continue',
                      onPressed: _nextStep,
                      loading: _busy,
                      width: double.infinity,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    const labels = ['Personal', 'Fertility', 'Health'];
    return Row(
      children: List.generate(3, (index) {
        final active = index <= _currentStep;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: active ? AppColors.primary : AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      labels[index],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            index == _currentStep ? FontWeight.w700 : FontWeight.w500,
                        color: active
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (index < 2) const SizedBox(width: 8),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Personal Details', 'Required for your IVF consultation'),
          const SizedBox(height: AppSpacing.md),
          _field(_age, 'Age', keyboard: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          const SizedBox(height: AppSpacing.md),
          _dropdown('Gender', _gender, ['Female', 'Male', 'Other'],
              (v) => setState(() => _gender = v!)),
          const SizedBox(height: AppSpacing.md),
          _dropdown('Marital Status', _maritalStatus,
              ['Married', 'Single', 'In a relationship'],
              (v) => setState(() => _maritalStatus = v!)),
          const SizedBox(height: AppSpacing.md),
          _field(_phone, 'Phone Number', keyboard: TextInputType.phone),
          const SizedBox(height: AppSpacing.md),
          _field(_bloodGroup, 'Blood Group', hint: 'e.g. B+'),
          const SizedBox(height: AppSpacing.md),
          _field(_height, 'Height', hint: 'e.g. 162 cm'),
          const SizedBox(height: AppSpacing.md),
          _field(_weight, 'Weight', hint: 'e.g. 58 kg'),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Fertility History', 'Helps doctors plan your treatment'),
          const SizedBox(height: AppSpacing.md),
          _field(_partnerName, 'Partner Name (optional)'),
          const SizedBox(height: AppSpacing.md),
          _field(_tryingSince, 'Trying to conceive since',
              hint: 'e.g. 2 years'),
          const SizedBox(height: AppSpacing.md),
          _field(_ivfAttempts, 'Previous IVF attempts',
              keyboard: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          const SizedBox(height: AppSpacing.md),
          _field(_cycleDays, 'Average menstrual cycle (days)',
              keyboard: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.blush.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              border: Border.all(color: AppColors.blush.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'This information is kept private and shared only with your fertility specialist.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Health Information', 'Important for safe IVF treatment'),
          const SizedBox(height: AppSpacing.md),
          _field(_allergies, 'Allergies', hint: 'None if not applicable'),
          const SizedBox(height: AppSpacing.md),
          _field(_medications, 'Current Medications',
              hint: 'e.g. Metformin, Folic acid'),
          const SizedBox(height: AppSpacing.md),
          _field(_medicalHistory, 'Medical History',
              hint: 'PCOS, surgeries, conditions...',
              maxLines: 4),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hint,
    TextInputType? keyboard,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
