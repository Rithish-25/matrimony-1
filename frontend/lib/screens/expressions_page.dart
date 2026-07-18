import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/person_model.dart';
import '../theme/app_theme.dart';
import 'profile_details_page.dart';

class ExpressionsPage extends StatelessWidget {
  final VoidCallback? onExplorePressed;

  const ExpressionsPage({
    super.key,
    this.onExplorePressed,
  });

  Widget _buildImagePlaceholder(PersonModel person) {
    final initials = person.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join('');
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: person.gender == 'Female'
              ? [const Color(0xFFFFD180), AppTheme.primary]
              : [const Color(0xFFB2DFDB), const Color(0xFF00796B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<List<PersonModel>>(
        valueListenable: AppState().expressions,
        builder: (context, expressions, _) {
          if (expressions.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: expressions.length,
            itemBuilder: (context, index) {
              final person = expressions[index];
              return _buildExpressionTile(context, person);
            },
          );
        },
      ),
    );
  }

  Widget _buildExpressionTile(BuildContext context, PersonModel person) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: AppTheme.primary.withOpacity(0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.primary.withOpacity(0.05), width: 0.8),
      ),
      child: InkWell(
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
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Photo Thumbnail
              Hero(
                tag: 'photo-expression-${person.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 76,
                    height: 76,
                    child: Image.network(
                      person.photoUrl,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder(person);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              
              // Name and basic stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            person.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (person.isVerified)
                          const Icon(
                            Icons.verified,
                            color: Color(0xFF1D9BF0),
                            size: 15,
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${person.age} Yrs • ${person.profession}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${person.city}, ${person.state}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Status Chip (Pending)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGoldLight,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.accentGold.withOpacity(0.4), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.hourglass_empty, color: AppTheme.accentGold, size: 10),
                          SizedBox(width: 4),
                          Text(
                            'Pending Response',
                            style: TextStyle(
                              color: AppTheme.accentGold,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 8),

              // Delete Button
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppTheme.textSecondary, size: 20),
                onPressed: () {
                  _showWithdrawConfirmation(context, person);
                },
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(duration: 300.ms).slideX(begin: 0.05, end: 0.0);
  }

  void _showWithdrawConfirmation(BuildContext context, PersonModel person) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Withdraw Interest?'),
          content: Text('Are you sure you want to withdraw your expressed interest for ${person.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            TextButton(
              onPressed: () {
                AppState().removeExpression(person);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Interest withdrawn for ${person.name}'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Withdraw', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Floating Heart Envelope/Letter
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.mail_outline_outlined,
                  color: AppTheme.primary,
                  size: 46,
                ),
              ),
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.12, 1.12),
              duration: 900.ms,
              curve: Curves.easeInOut,
            ),
            const SizedBox(height: 24),
            Text(
              'No Interests Sent Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Profiles where you click "Express Interest" will be tracked here. Take the first step toward your partner.',
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
                  Icon(Icons.search_outlined, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Find Matches',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ).animate().scale(delay: 150.ms, duration: 400.ms, curve: Curves.easeOutBack),
          ],
        ),
      ),
    );
  }
}
