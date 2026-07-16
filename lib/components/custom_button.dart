import 'package:flutter/material.dart';
import 'package:ivf_patient_app/theme/app_theme.dart';

enum ButtonVariant {
  primary,
  secondary,
  outline,
  accent,
}

enum ButtonSize {
  sm,
  md,
  lg,
}

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool loading;
  final bool disabled;
  final Widget? icon;
  final double? width;

  const CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.loading = false,
    this.disabled = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: (disabled || loading) ? null : onPressed,
        style: buttonStyle,
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(title),
                ],
              ),
      ),
    );
  }

  ButtonStyle _getButtonStyle() {
    final padding = _getPadding();
    final backgroundColor = _getBackgroundColor();
    final foregroundColor = _getForegroundColor();

    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor: backgroundColor?.withValues(alpha: 0.5),
      padding: padding,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      side: variant == ButtonVariant.outline
          ? const BorderSide(color: AppColors.primary, width: 1.5)
          : null,
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.sm:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        );
      case ButtonSize.md:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md - 2,
        );
      case ButtonSize.lg:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md + 2,
        );
    }
  }

  Color? _getBackgroundColor() {
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.primary;
      case ButtonVariant.secondary:
        return AppColors.secondary;
      case ButtonVariant.outline:
        return Colors.transparent;
      case ButtonVariant.accent:
        return AppColors.accent;
    }
  }

  Color _getForegroundColor() {
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.white;
      case ButtonVariant.secondary:
        return AppColors.text;
      case ButtonVariant.outline:
        return AppColors.primary;
      case ButtonVariant.accent:
        return AppColors.text;
    }
  }
}
