import 'package:flutter/material.dart';
import 'package:ivf_patient_app/theme/app_theme.dart';

class CustomSearchBar extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final String placeholder;
  final VoidCallback? onClear;

  const CustomSearchBar({
    super.key,
    required this.value,
    required this.onChanged,
    this.placeholder = 'Search...',
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              controller: TextEditingController(text: value)..selection = TextSelection.fromPosition(TextPosition(offset: value.length)),
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: const TextStyle(
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
          if (value.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: onClear ?? () => onChanged(''),
              child: const Icon(
                Icons.cancel,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
