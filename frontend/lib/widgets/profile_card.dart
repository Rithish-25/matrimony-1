import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/person_model.dart';
import '../theme/app_theme.dart';
import 'favorite_button.dart';

class ProfileCard extends StatelessWidget {
  final PersonModel person;
  final VoidCallback onTap;

  const ProfileCard({
    super.key,
    required this.person,
    required this.onTap,
  });

  Widget _buildImagePlaceholder() {
    final initials = person.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join('');
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: person.gender == 'Female'
              ? [const Color(0xFFFFD180), AppTheme.primary] // Warm orange to pink/rose
              : [const Color(0xFFB2DFDB), const Color(0xFF00796B)], // Sage green to teal
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Opacity(
              opacity: 0.35,
              child: Icon(
                person.gender == 'Female' ? Icons.bubble_chart : Icons.favorite_border,
                color: Colors.white,
                size: 42,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      clipBehavior: Clip.antiAlias,
      elevation: 5,
      shadowColor: AppTheme.primary.withOpacity(0.08),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Stack(
              children: [
                Hero(
                  tag: 'photo-${person.id}',
                  child: SizedBox(
                    height: 320,
                    width: double.infinity,
                    child: Image.network(
                      person.photoUrl,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder();
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 320,
                          color: AppTheme.primary.withOpacity(0.05),
                          child: const Center(
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
                // Match compatibility badge
                Positioned(
                  left: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, Color(0xFFE91E63)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.favorite, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '${person.compatibilityScore}% Match',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Favorite Button
                Positioned(
                  right: 12,
                  top: 12,
                  child: FavoriteButton(person: person, size: 20),
                ),
              ],
            ),
            // Info Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Verification
                  Row(
                    children: [
                      Text(
                        person.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 6),
                      if (person.isVerified)
                        const Tooltip(
                          message: 'Verified Matrimonial Profile',
                          child: Icon(
                            Icons.verified,
                            color: Color(0xFF1D9BF0),
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Age, Height, City
                  Text(
                    '${person.age} Yrs • ${person.height} • ${person.city}, ${person.state}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 12),
                  // Grid of Chips (caste, religion, education, profession)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildInfoChip(context, person.religion, Icons.church_outlined),
                      _buildInfoChip(context, person.caste, Icons.account_tree_outlined),
                      _buildInfoChip(context, person.profession, Icons.work_outline),
                      _buildInfoChip(context, person.salary, Icons.currency_rupee),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Action Footer
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onTap,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            side: const BorderSide(color: AppTheme.primary, width: 1.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.auto_awesome, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'View Horoscope',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0.0, curve: Curves.easeOutCubic);
  }

  Widget _buildInfoChip(BuildContext context, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primary.withOpacity(0.08), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textPrimary.withOpacity(0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
