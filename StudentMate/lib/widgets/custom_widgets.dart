import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/logo_data.dart';

/// App logo widget — large/centred for sign-in, small leading icon for other pages.
/// Tapping navigates back to home (pops all routes to root).
/// Uses base64 data from logo_data.dart when available, falls back to asset file,
/// then to a school icon.
class AppLogo extends StatelessWidget {
  final bool isLarge;
  const AppLogo({Key? key, this.isLarge = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = isLarge ? 150.0 : 48.0;

    Widget logo;
    if (kLogoBase64.isNotEmpty) {
      logo = Image.memory(
        base64Decode(kLogoBase64),
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    } else {
      logo = Image.asset(
        'assets/images/student_mate_logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(
          Icons.school,
          size: size * 0.7,
          color: AppColors.purpleDark,
        ),
      );
    }

    if (isLarge) return logo;
    return GestureDetector(
      onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: logo,
      ),
    );
  }
}

/// A circular profile avatar with gradient border.
/// Shows base64 image if provided, otherwise a letter/icon fallback.
/// Tapping it calls [onTap].
class ProfileAvatar extends StatelessWidget {
  final String? base64Photo;
  final String name;
  final double size;
  final VoidCallback? onTap;

  const ProfileAvatar({
    Key? key,
    this.base64Photo,
    required this.name,
    this.size = 96,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasPhoto = base64Photo != null && base64Photo!.isNotEmpty;
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((w) => w[0].toUpperCase()).take(2).join()
        : '?';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size + 6,
        height: size + 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.purpleDark.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: ClipOval(
            child: hasPhoto
                ? Image.memory(
                    base64Decode(base64Photo!),
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: size,
                    height: size,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.secondaryGradient,
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size * 0.32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class GradientButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final double? width;
  final double height;
  final TextStyle? textStyle;

  const GradientButton({
    Key? key,
    required this.onPressed,
    required this.label,
    this.width,
    this.height = 56,
    this.textStyle,
  }) : super(key: key);

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: _isHovered
                ? AppColors.primaryDarkGradient
                : AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              if (_isHovered) AppShadow.heavy else AppShadow.medium,
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: widget.textStyle ??
                  Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
            ),
          ),
        ),
      ),
    );
  }
}

class GradientCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double? elevation;
  final EdgeInsetsGeometry padding;

  const GradientCard({
    Key? key,
    required this.child,
    this.onTap,
    this.elevation,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  }) : super(key: key);

  @override
  State<GradientCard> createState() => _GradientCardState();
}

class _GradientCardState extends State<GradientCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              if (_isHovered) AppShadow.heavy else AppShadow.medium,
            ],
          ),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            elevation: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: _isHovered
                      ? AppColors.purpleDark.withOpacity(0.3)
                      : AppColors.purpleDark.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: widget.padding,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;

  const CustomTextField({
    Key? key,
    required this.label,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.validator,
    this.onChanged,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimaryColor,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: AppColors.purpleDark,
                  )
                : null,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.purpleDark,
                    ),
                    onPressed: () {
                      setState(() => _obscureText = !_obscureText);
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: AppColors.purpleDark.withOpacity(0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: AppColors.purpleDark.withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.purpleDark,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
      ],
    );
  }
}

class ModuleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const ModuleCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
          ),
        ],
      ),
    );
  }
}
