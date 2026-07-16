import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ivf_patient_app/models/blog.dart';
import 'package:ivf_patient_app/theme/app_theme.dart';

class BlogCard extends StatelessWidget {
  final Blog blog;
  final bool isSaved;
  final bool isLiked;
  final VoidCallback onTap;
  final VoidCallback? onSave;
  final VoidCallback? onLike;
  final bool compact;

  const BlogCard({
    super.key,
    required this.blog,
    required this.isSaved,
    required this.isLiked,
    required this.onTap,
    this.onSave,
    this.onLike,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: compact ? 80 : 100,
                height: compact ? 80 : 100,
                decoration: BoxDecoration(
                  color: AppColors.lavender.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Center(
                  child: Text(
                    blog.image,
                    style: TextStyle(fontSize: compact ? 32 : 40),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        blog.category,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      blog.title,
                      style: GoogleFonts.inter(
                        fontSize: compact ? 14 : 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                        height: 1.3,
                      ),
                      maxLines: compact ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 4),
                      Text(
                        blog.excerpt,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 12, color: AppColors.textLight),
                        const SizedBox(width: 4),
                        Text(
                          '${blog.readTime} min',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.favorite_outline,
                            size: 12, color: AppColors.textLight),
                        const SizedBox(width: 4),
                        Text(
                          '${blog.likes}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textLight,
                          ),
                        ),
                        const Spacer(),
                        if (onLike != null)
                          GestureDetector(
                            onTap: onLike,
                            child: Icon(
                              isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 18,
                              color: isLiked
                                  ? AppColors.error
                                  : AppColors.textLight,
                            ),
                          ),
                        if (onSave != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          GestureDetector(
                            onTap: onSave,
                            child: Icon(
                              isSaved
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              size: 18,
                              color: isSaved
                                  ? AppColors.primary
                                  : AppColors.textLight,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
