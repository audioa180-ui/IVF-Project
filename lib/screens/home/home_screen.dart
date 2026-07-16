import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ivf_patient_app/providers/app_provider.dart';
import 'package:ivf_patient_app/components/appointment_card.dart';
import 'package:ivf_patient_app/components/blog_card.dart';
import 'package:ivf_patient_app/components/custom_button.dart';
import 'package:ivf_patient_app/theme/app_theme.dart';
import 'package:ivf_patient_app/models/blog.dart';
import 'package:ivf_patient_app/screens/appointments/booking_screen.dart';
import 'package:ivf_patient_app/screens/advice/advice_screen.dart';
import 'package:ivf_patient_app/screens/help/help_support_screen.dart';
import 'package:ivf_patient_app/screens/treatment/treatment_journey_screen.dart';
import 'package:ivf_patient_app/screens/blogs/blogs_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onNavigate});
  final ValueChanged<int>? onNavigate;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Blog> _blogs = [];
  List<Map<String, dynamic>> _treatmentSteps = [];
  List<Map<String, dynamic>> _dailyTips = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = context.read<AppProvider>().api;
      final results = await Future.wait([
        api.getBlogs(),
        api.getTreatmentSteps(),
        api.getDailyTips(),
      ]);
      final blogs = results[0] as List<Blog>;
      final steps = List<Map<String, dynamic>>.from(results[1]);
      final tips = List<Map<String, dynamic>>.from(results[2]);
      setState(() {
        _blogs = blogs.take(3).toList();
        _treatmentSteps = steps;
        _dailyTips = tips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildLoading();
    if (_error != null) return _buildError();
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final upcomingAppointment = provider.upcomingAppointments.isNotEmpty
            ? provider.upcomingAppointments.first
            : null;
        final tipOfDay = _dailyTips.isNotEmpty
            ? _dailyTips[DateTime.now().weekday % _dailyTips.length]
            : null;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHero(context, provider),
              const SizedBox(height: AppSpacing.lg),
              _buildTreatmentProgress(context),
              const SizedBox(height: AppSpacing.lg),
              if (upcomingAppointment != null) ...[
                _buildSectionHeader(
                  context,
                  'Upcoming Appointment',
                  onTap: () => _navigateToTab(context, 1),
                ),
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: AppointmentCard(appointment: upcomingAppointment),
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideX(begin: -0.1, end: 0),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (tipOfDay != null) _buildDailyTip(context, tipOfDay),
              const SizedBox(height: AppSpacing.lg),
              _buildQuickActions(context),
              const SizedBox(height: AppSpacing.lg),
              _buildSectionHeader(
                context,
                'Latest Blogs',
                onTap: () => _navigateToTab(context, 3),
              ),
              const SizedBox(height: AppSpacing.sm),
              ..._blogs.asMap().entries.map((entry) {
                final index = entry.key;
                final blog = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: BlogCard(
                    blog: blog,
                    isSaved: provider.savedBlogs.contains(blog.id),
                    isLiked: provider.likedBlogs.contains(blog.id),
                    onTap: () => _navigateToBlogDetail(context, blog.id),
                    onSave: () => provider.toggleSaveBlog(blog.id),
                    onLike: () => provider.toggleLikeBlog(blog.id),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: (300 + (index * 100)).ms).slideY(begin: 0.1, end: 0);
              }),
              const SizedBox(height: AppSpacing.lg),
              _buildEmergencyContact(context),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Loading your journey...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: AppColors.textLight),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            CustomButton(
              title: 'Retry',
              onPressed: _loadData,
              icon: const Icon(Icons.refresh, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, AppProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppBorderRadius.xl),
          bottomRight: Radius.circular(AppBorderRadius.xl),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${provider.user.name.split(' ')[0]} 👋',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                      shadows: [
                        Shadow(
                          color: Color(0x40000000),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Your fertility journey, simplified',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFFE8F4FD),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  onPressed: () => _navigateToHelpSupport(context),
                  icon: const Icon(Icons.notifications_outlined),
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          CustomButton(
            title: 'Book Appointment',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BookingScreen()),
            ),
            variant: ButtonVariant.secondary,
            width: double.infinity,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (onTap != null)
            GestureDetector(
              onTap: onTap,
              child: const Text(
                'See All',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDailyTip(BuildContext context, Map<String, dynamic> tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  tip['icon'] ?? '💡',
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(AppBorderRadius.full),
                  ),
                  child: Text(
                    'Tip of the Day',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              tip['title'] ?? '',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              tip['description'] ?? '',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: () => _navigateToAdvice(context),
              child: Row(
                children: [
                  Text(
                    'View all tips',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentProgress(BuildContext context) {
    if (_treatmentSteps.isEmpty) return const SizedBox.shrink();

    final completed = _treatmentSteps.where((s) => s['status'] == 'completed').length;
    final total = _treatmentSteps.length;
    final currentStep = _treatmentSteps.isNotEmpty
        ? _treatmentSteps.firstWhere(
            (s) => s['status'] == 'inProgress' || s['status'] == 'active',
            orElse: () => _treatmentSteps.last,
          )
        : null;
    final progress = total > 0 ? completed / total : 0.0;
    final stepTitle = currentStep?['title'] ?? '';
    final stepSubtitle = currentStep?['subtitle'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: GestureDetector(
        onTap: () => _navigateToTreatmentJourney(context),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            border: Border.all(color: AppColors.accent),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Treatment Journey',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stepSubtitle.isNotEmpty ? stepSubtitle : 'Track your IVF progress step by step',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        widthFactor: progress.clamp(0.0, 1.0),
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Step $completed of $total — $stepTitle',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                '🌱',
                style: TextStyle(fontSize: 48),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.calendar_month,
        label: 'Book Appointment',
        color: AppColors.primary,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BookingScreen()),
        ),
      ),
      _QuickAction(
        icon: Icons.route,
        label: 'Treatment Journey',
        color: AppColors.secondary,
        onTap: () => _navigateToTreatmentJourney(context),
      ),
      _QuickAction(
        icon: Icons.lightbulb_outline,
        label: 'Daily Advice',
        color: AppColors.accent,
        onTap: () => _navigateToAdvice(context),
      ),
      _QuickAction(
        icon: Icons.headset_mic,
        label: 'Help & Support',
        color: AppColors.mauve,
        onTap: () => _navigateToHelpSupport(context),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.3,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) => _buildActionCard(context, actions[index], index),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, _QuickAction action, int index) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      elevation: 0,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: 22,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: (index * 100).ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildEmergencyContact(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.call,
              color: AppColors.error,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emergency Contact',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Text(
                    '+91 1800-123-4567',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.call,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTab(BuildContext context, int index) {
    widget.onNavigate?.call(index);
  }

  void _navigateToBlogDetail(BuildContext context, String blogId) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => BlogDetailScreen(blogId: blogId)));
  }

  void _navigateToTreatmentJourney(BuildContext context) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const TreatmentJourneyScreen()));
  }

  void _navigateToAdvice(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const AdviceScreen()));
  }

  void _navigateToHelpSupport(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const HelpSupportScreen()));
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
