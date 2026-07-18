import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/person_model.dart';
import '../theme/app_theme.dart';
import '../widgets/profile_card.dart';
import 'profile_details_page.dart';

class FavoritesPage extends StatelessWidget {
  final VoidCallback? onExplorePressed;

  const FavoritesPage({
    super.key,
    this.onExplorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<List<PersonModel>>(
        valueListenable: AppState().favorites,
        builder: (context, favorites, _) {
          if (favorites.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 10, bottom: 24),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final person = favorites[index];
              return ProfileCard(
                person: person,
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          ProfileDetailsPage(person: person),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      transitionDuration: const Duration(milliseconds: 500),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pulse Heart Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.favorite_border,
                  color: AppTheme.primary,
                  size: 50,
                ),
              ),
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.12, 1.12),
              duration: 1000.ms,
              curve: Curves.easeInOut,
            ),
            const SizedBox(height: 24),
            Text(
              'No Favorites Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Browse matrimonial matches and tap the heart icon to save your preferred profiles here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary.withOpacity(0.85),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: onExplorePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                shadowColor: AppTheme.primary.withOpacity(0.3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.explore_outlined, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Explore Profiles',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
          ],
        ),
      ),
    );
  }
}
