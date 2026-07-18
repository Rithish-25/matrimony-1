import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/person_model.dart';
import '../theme/app_theme.dart';

class FavoriteButton extends StatefulWidget {
  final PersonModel person;
  final double size;

  const FavoriteButton({
    super.key,
    required this.person,
    this.size = 28,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _isLiked = AppState().isFavorite(widget.person);
  }

  void _onTap() {
    AppState().toggleFavorite(widget.person);
    setState(() {
      _isLiked = !_isLiked;
    });
    if (_isLiked) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<PersonModel>>(
      valueListenable: AppState().favorites,
      builder: (context, favorites, _) {
        final currentlyLiked = favorites.any((p) => p.id == widget.person.id);
        if (currentlyLiked != _isLiked) {
          _isLiked = currentlyLiked;
        }

        return GestureDetector(
          onTap: _onTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? AppTheme.primary : AppTheme.textSecondary,
              size: widget.size,
            )
            .animate(
              controller: _controller,
              autoPlay: false,
            )
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.4, 1.4),
              duration: 120.ms,
              curve: Curves.easeOut,
            )
            .then()
            .scale(
              begin: const Offset(1.4, 1.4),
              end: const Offset(1.0, 1.0),
              duration: 150.ms,
              curve: Curves.bounceOut,
            ),
          ),
        );
      },
    );
  }
}
