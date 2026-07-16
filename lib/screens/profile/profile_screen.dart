import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ivf_patient_app/providers/app_provider.dart';
import 'package:ivf_patient_app/components/blog_card.dart';
import 'package:ivf_patient_app/models/blog.dart';
import 'package:ivf_patient_app/theme/app_theme.dart';
import 'package:ivf_patient_app/screens/treatment/treatment_journey_screen.dart';
import 'package:ivf_patient_app/screens/tools/ivf_tools_screen.dart';
import 'package:ivf_patient_app/screens/advice/advice_screen.dart';
import 'package:ivf_patient_app/screens/help/help_support_screen.dart';
import 'package:ivf_patient_app/screens/blogs/blogs_screen.dart';
import 'package:ivf_patient_app/screens/profile/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.onNavigate});
  final ValueChanged<int>? onNavigate;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Blog> _blogs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBlogs();
    });
  }

  Future<void> _fetchBlogs() async {
    setState(() => _loading = true);
    try {
      final api = context.read<AppProvider>().api;
      final blogs = await api.getBlogs();
      if (mounted) {
        setState(() {
          _blogs = blogs;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, child) {
            final savedBlogItems = _blogs
                .where((blog) => provider.savedBlogs.contains(blog.id))
                .toList();

            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: AppSpacing.lg),
                  _buildProfileCard(context, provider),
                  const SizedBox(height: AppSpacing.lg),
                  _buildPersonalInfo(context, provider),
                  const SizedBox(height: AppSpacing.md),
                  _buildMedicalHistory(context, provider),
                  const SizedBox(height: AppSpacing.md),
                  _buildMenuSection(context, provider),
                  if (savedBlogItems.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    _buildSavedBlogs(context, savedBlogItems, provider),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  _buildLogoutButton(context, provider),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Profile',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 2),
          Text(
            'Manage your account',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, AppProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Center(
                  child: Text(
                    provider.user.photo,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                provider.user.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                provider.user.email,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfo(BuildContext context, AppProvider provider) {
    final infoItems = [
      {'label': 'Age', 'value': '${provider.user.age} years'},
      {'label': 'Gender', 'value': provider.user.gender},
      {'label': 'Marital Status', 'value': provider.user.maritalStatus.isNotEmpty ? provider.user.maritalStatus : '—'},
      {'label': 'Blood Group', 'value': provider.user.bloodGroup},
      {'label': 'Phone', 'value': provider.user.phone},
      {'label': 'Height / Weight', 'value': '${provider.user.height.isNotEmpty ? provider.user.height : '—'} / ${provider.user.weight.isNotEmpty ? provider.user.weight : '—'}'},
      {'label': 'Trying Since', 'value': provider.user.tryingSince.isNotEmpty ? provider.user.tryingSince : '—'},
      {'label': 'IVF Attempts', 'value': '${provider.user.previousIvfAttempts}'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Information',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              ...infoItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['label']!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        item['value']!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicalHistory(BuildContext context, AppProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Medical History',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                provider.user.medicalHistory,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1.5,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, AppProvider provider) {
    final menuItems = [
      {
        'icon': Icons.calendar_today,
        'label': 'Appointment History',
        'count': provider.appointments.length
      },
      {
        'icon': Icons.bookmark,
        'label': 'Saved Blogs',
        'count': provider.savedBlogs.length
      },
      {'icon': Icons.timeline, 'label': 'Treatment Journey', 'count': null},
      {'icon': Icons.auto_fix_high, 'label': 'IVF Tools', 'count': null},
      {'icon': Icons.lightbulb, 'label': 'Daily Advice & Tips', 'count': null},
      {'icon': Icons.help, 'label': 'Help & Support', 'count': null},
      {'icon': Icons.settings, 'label': 'Settings', 'count': null},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Card(
        child: Column(
          children: menuItems.map((item) {
            return Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(item['label'] as String),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item['count'] != null && (item['count'] as int) > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius:
                                BorderRadius.circular(AppBorderRadius.full),
                          ),
                          child: Text(
                            '${item['count']}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ),
                      const SizedBox(width: AppSpacing.sm),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textLight,
                      ),
                    ],
                  ),
                  onTap: () => _handleMenuTap(context, item['label'] as String),
                ),
                if (item != menuItems.last) const Divider(height: 1),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSavedBlogs(
      BuildContext context, List savedBlogItems, AppProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              'Saved Blogs',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...savedBlogItems.take(2).map((blog) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: BlogCard(
                blog: blog,
                isSaved: true,
                isLiked: provider.likedBlogs.contains(blog.id),
                onTap: () => _navigateToBlogDetail(context, blog.id),
                onSave: () => provider.toggleSaveBlog(blog.id),
                onLike: () => provider.toggleLikeBlog(blog.id),
                compact: true,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AppProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutDialog(context, provider),
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }

  void _handleMenuTap(BuildContext context, String label) {
    switch (label) {
      case 'Appointment History':
        widget.onNavigate?.call(1);
        break;
      case 'Saved Blogs':
        widget.onNavigate?.call(3);
        break;
      case 'Treatment Journey':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const TreatmentJourneyScreen()),
        );
        break;
      case 'IVF Tools':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const IvfToolsScreen()),
        );
        break;
      case 'Daily Advice & Tips':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdviceScreen()),
        );
        break;
      case 'Help & Support':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
        );
        break;
      case 'Settings':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
        break;
    }
  }

  void _navigateToBlogDetail(BuildContext context, String blogId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlogDetailScreen(blogId: blogId),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.logout();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
