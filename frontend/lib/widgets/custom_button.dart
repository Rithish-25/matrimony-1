import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isSecondary;
  final double? width;
  final Widget? icon;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isSecondary = false,
    this.width,
    this.icon,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusValue - 4),
            gradient: widget.isSecondary
                ? null
                : const LinearGradient(
                    colors: [AppTheme.primary, Color(0xFFC2185B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: widget.isSecondary ? Colors.white.withOpacity(0.6) : null,
            border: widget.isSecondary ? Border.all(color: AppTheme.primary, width: 1.5) : null,
            boxShadow: widget.isSecondary
                ? null
                : [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  widget.icon!,
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.text,
                  style: TextStyle(
                    color: widget.isSecondary ? AppTheme.primary : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
