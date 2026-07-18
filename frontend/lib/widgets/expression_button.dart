import 'package:flutter/material.dart';
import '../models/person_model.dart';
import '../theme/app_theme.dart';

class ExpressionButton extends StatefulWidget {
  final PersonModel person;
  final double? width;

  const ExpressionButton({
    super.key,
    required this.person,
    this.width,
  });

  @override
  State<ExpressionButton> createState() => _ExpressionButtonState();
}

class _ExpressionButtonState extends State<ExpressionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPressed() {
    if (!AppState().hasSentExpression(widget.person)) {
      _controller.forward(from: 0.0).then((_) => _controller.reverse());
      AppState().sendExpression(widget.person);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.favorite, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                'Interest sent to ${widget.person.name} ❤️',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<PersonModel>>(
      valueListenable: AppState().expressions,
      builder: (context, expressions, _) {
        final hasSent = expressions.any((p) => p.id == widget.person.id);

        return GestureDetector(
          onTap: hasSent ? null : _onPressed,
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 0.94).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              width: widget.width,
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusValue - 4),
                gradient: hasSent
                    ? null
                    : const LinearGradient(
                        colors: [AppTheme.primary, Color(0xFFC2185B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: hasSent ? AppTheme.accentGoldLight : null,
                border: hasSent ? Border.all(color: AppTheme.accentGold, width: 1.5) : null,
                boxShadow: hasSent
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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: hasSent
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          key: const ValueKey('sent'),
                          children: const [
                            Icon(Icons.check_circle_outline, color: AppTheme.accentGold, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Interest Sent',
                              style: TextStyle(
                                color: AppTheme.accentGold,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          key: const ValueKey('send'),
                          children: const [
                            Icon(Icons.favorite, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Express Interest',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
