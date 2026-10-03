import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

enum ButtonVariant { primary, secondary, outline, text, outlined }
enum ButtonSize { small, medium, large }

/// Custom button component with consistent styling.
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool fullWidth;
  final Widget? icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.fullWidth = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? SizedBox(
            height: _getIconSize(),
            width: _getIconSize(),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _getForegroundColor(),
            ),
          )
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                SizedBox(width: AppSpacing.sm),
              ],
              Text(text),
            ],
          );

    final padding = EdgeInsets.symmetric(
      horizontal: _getHorizontalPadding(),
      vertical: _getVerticalPadding(),
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    );

    switch (variant) {
      case ButtonVariant.primary:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textInverse,
              padding: padding,
              shape: shape,
              textStyle: _getTextStyle(),
              elevation: 0,
            ),
            child: buttonChild,
          ),
        );

      case ButtonVariant.secondary:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceVariant,
              foregroundColor: AppColors.textPrimary,
              padding: padding,
              shape: shape,
              textStyle: _getTextStyle(),
              elevation: 0,
            ),
            child: buttonChild,
          ),
        );

      case ButtonVariant.outline:
      case ButtonVariant.outlined:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              padding: padding,
              shape: shape,
              textStyle: _getTextStyle(),
              side: const BorderSide(color: AppColors.border, width: 1.5),
            ),
            child: buttonChild,
          ),
        );

      case ButtonVariant.text:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: padding,
              shape: shape,
              textStyle: _getTextStyle(),
            ),
            child: buttonChild,
          ),
        );
    }
  }

  Color _getForegroundColor() {
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.textInverse;
      case ButtonVariant.secondary:
      case ButtonVariant.outline:
      case ButtonVariant.outlined:
        return AppColors.textPrimary;
      case ButtonVariant.text:
        return AppColors.primary;
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case ButtonSize.small:
        return AppTypography.buttonSmall;
      case ButtonSize.medium:
      case ButtonSize.large:
        return AppTypography.button;
    }
  }

  double _getHorizontalPadding() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 24;
      case ButtonSize.large:
        return 32;
    }
  }

  double _getVerticalPadding() {
    switch (size) {
      case ButtonSize.small:
        return 10;
      case ButtonSize.medium:
        return 14;
      case ButtonSize.large:
        return 18;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }
}
