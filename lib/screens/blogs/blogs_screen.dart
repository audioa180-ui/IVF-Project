import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ivf_patient_app/providers/app_provider.dart';
import 'package:ivf_patient_app/components/blog_card.dart';
import 'package:ivf_patient_app/data/mock_data.dart';
import 'package:ivf_patient_app/models/blog.dart';
import 'package:ivf_patient_app/theme/app_theme.dart';

class BlogsScreen extends StatefulWidget {
  const BlogsScreen({super.key});

  @override
  State<BlogsScreen> createState() => _BlogsScreenState();
}

class _BlogsScreenState extends State<BlogsScreen> {
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, child) {
            final filteredBlogs = MockData.blogs.where((blog) {
              final matchesSearch = blog.title
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ||
                  blog.excerpt
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase());
              final matchesCategory = _selectedCategory == null ||
                  blog.category == _selectedCategory;
              return matchesSearch && matchesCategory;
            }).toList();

            return Column(
              children: [
                _buildHeader(context),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm + 2,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(
                                text: _searchQuery)
                              ..selection = TextSelection.fromPosition(
                                  TextPosition(offset: _searchQuery.length)),
                            onChanged: (value) =>
                                setState(() => _searchQuery = value),
                            decoration: const InputDecoration(
                              hintText: 'Search blogs...',
                              hintStyle: TextStyle(
                                color: AppColors.textLight,
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty) ...[
                          const SizedBox(width: AppSpacing.sm),
                          GestureDetector(
                            onTap: () => setState(() => _searchQuery = ''),
                            child: const Icon(
                              Icons.cancel,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: AppSpacing.md),
                _buildCategoryChips(context),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    itemCount: filteredBlogs.length,
                    itemBuilder: (context, index) {
                      final blog = filteredBlogs[index];
                      return BlogCard(
                        blog: blog,
                        isSaved: provider.savedBlogs.contains(blog.id),
                        isLiked: provider.likedBlogs.contains(blog.id),
                        onTap: () => _navigateToBlogDetail(context, blog.id),
                        onSave: () => provider.toggleSaveBlog(blog.id),
                        onLike: () => provider.toggleLikeBlog(blog.id),
                      ).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms).slideY(begin: 0.05, end: 0);
                    },
                  ),
                ),
              ],
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
            'IVF Knowledge Hub',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 2),
          Text(
            'Learn & stay informed',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: MockData.blogCategories.length + 1,
        itemBuilder: (context, index) {
          final category =
              index == 0 ? null : MockData.blogCategories[index - 1];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(category ?? 'All'),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? category : null;
                });
              },
              backgroundColor: AppColors.card,
              selectedColor: AppColors.primary,
              labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        isSelected ? AppColors.white : AppColors.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.full),
                side: const BorderSide(color: AppColors.border),
              ),
              checkmarkColor: AppColors.white,
            ),
          );
        },
      ),
    );
  }

  void _navigateToBlogDetail(BuildContext context, String blogId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlogDetailScreen(blogId: blogId),
      ),
    );
  }
}

class BlogDetailScreen extends StatelessWidget {
  final String blogId;

  const BlogDetailScreen({super.key, required this.blogId});

  @override
  Widget build(BuildContext context) {
    final blog = MockData.blogs.firstWhere(
      (b) => b.id == blogId,
      orElse: () => MockData.blogs.first,
    );

    return Scaffold(
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, child) {
            final isSaved = provider.savedBlogs.contains(blog.id);
            final isLiked = provider.likedBlogs.contains(blog.id);

            return Column(
              children: [
                _buildHeader(context, provider, blog, isSaved, isLiked),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHero(context, blog),
                        const SizedBox(height: AppSpacing.md),
                        _buildCategoryBadge(context, blog.category),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          blog.title,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                fontSize: 24,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _buildMeta(context, blog),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          blog.content,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    height: 1.6,
                                  ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _buildLikeSection(context, provider, blog, isLiked),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppProvider provider,
    Blog blog,
    bool isSaved,
    bool isLiked,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => provider.toggleLikeBlog(blog.id),
            icon: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? AppColors.error : AppColors.text,
            ),
          ),
          IconButton(
            onPressed: () => provider.toggleSaveBlog(blog.id),
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: isSaved ? AppColors.primary : AppColors.text,
            ),
          ),
          IconButton(
            onPressed: () => _shareBlog(context, blog),
            icon: const Icon(Icons.share),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, Blog blog) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      ),
      child: Center(
        child: Text(
          blog.image,
          style: const TextStyle(fontSize: 64),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(BuildContext context, String category) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
      ),
      child: Text(
        category,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildMeta(BuildContext context, Blog blog) {
    return Wrap(
      spacing: 6,
      children: [
        Text(
          'By ${blog.author}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
        ),
        const Text('•', style: TextStyle(color: AppColors.textLight)),
        Text(
          '${blog.date.day} ${_getMonthName(blog.date.month)} ${blog.date.year}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const Text('•', style: TextStyle(color: AppColors.textLight)),
        const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          '${blog.readTime} min read',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildLikeSection(
    BuildContext context,
    AppProvider provider,
    Blog blog,
    bool isLiked,
  ) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: AppSpacing.lg),
        GestureDetector(
          onTap: () => provider.toggleLikeBlog(blog.id),
          child: Row(
            children: [
              Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? AppColors.error : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${blog.likes + (isLiked ? 1 : 0)} likes',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  void _shareBlog(BuildContext context, Blog blog) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share: ${blog.title}')),
    );
  }
}
