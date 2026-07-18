import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final String title;
  final List<Widget>? actions;
  final bool showDivider;

  const CustomAppBar({
    super.key,
    this.leading,
    required this.title,
    this.actions,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            border: showDivider
                ? Border(
                    bottom: BorderSide(
                      color: AppTheme.primary.withOpacity(0.08),
                      width: 1,
                    ),
                  )
                : null,
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: leading,
            title: Text(
              title,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: 24,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
            ),
            actions: actions,
            centerTitle: true,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
