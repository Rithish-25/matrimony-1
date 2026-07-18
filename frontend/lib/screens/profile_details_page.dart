import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/person_model.dart';
import '../theme/app_theme.dart';
import '../widgets/favorite_button.dart';
import '../widgets/expression_button.dart';
import '../widgets/horoscope_card.dart';

class ProfileDetailsPage extends StatelessWidget {
  final PersonModel person;

  const ProfileDetailsPage({
    super.key,
    required this.person,
  });

  Widget _buildImagePlaceholder() {
    final initials = person.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join('');
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: person.gender == 'Female'
              ? [const Color(0xFFFFD180), AppTheme.primary]
              : [const Color(0xFFB2DFDB), const Color(0xFF00796B)],
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
                fontSize: 64,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Opacity(
              opacity: 0.3,
              child: Icon(
                person.gender == 'Female' ? Icons.spa : Icons.favorite_border,
                color: Colors.white,
                size: 64,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: SafeArea(
          top: true,
          bottom: false,
          child: Stack(
            children: [
          // Scrollable Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Stack containing Image and Overlapping Card
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Blurred background + Centered square photo container
                    SizedBox(
                      height: size.height * 0.42,
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Blurred Background Photo
                          Positioned.fill(
                            child: Image.network(
                              person.photoUrl,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: AppTheme.primary.withOpacity(0.08),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Container(
                                color: Colors.black.withOpacity(0.32),
                              ),
                            ),
                          ),
                          // Centered Square Photo Frame
                          Hero(
                            tag: 'photo-${person.id}',
                            child: Container(
                              width: size.width * 0.52,
                              height: size.width * 0.52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white, width: 3.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.28),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  person.photoUrl,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildImagePlaceholder();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Top gradient for back button visibility
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 100,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.transparent,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    // Back Button floating top left
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppTheme.primary,
                            size: 18,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                    // Glassmorphic Quick Info Overlay Card (Positioned overlapping the bottom)
                    Positioned(
                      bottom: -30,
                      left: 16,
                      right: 16,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withOpacity(0.06),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
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
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (person.isVerified) ...[
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.verified,
                                              color: Color(0xFF1D9BF0),
                                              size: 20,
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${person.age} Yrs • ${person.height} • ${person.city}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: AppTheme.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [AppTheme.primary, Color(0xFFE91E63)],
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        '${person.compatibilityScore}%',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        'Match',
                                        style: TextStyle(
                                          color: Colors.white70,
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
                        ),
                      ),
                    ),
                  ],
                ),

                // Spacing for the overlapping card
                const SizedBox(height: 48),

                // Detail Sections
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Basic Info Section
                      _buildSectionTitle(context, 'Basic Information', Icons.person_outline),
                      _buildSectionCard(
                        [
                          _buildDetailRow(Icons.face_unlock_outlined, 'Age / Height', '${person.age} years / ${person.height}'),
                          _buildDetailRow(Icons.church_outlined, 'Religion / Caste', '${person.religion} / ${person.caste}'),
                          _buildDetailRow(Icons.translate, 'Mother Tongue', person.languagesKnown.isNotEmpty ? person.languagesKnown.first : 'Not Specified'),
                          _buildDetailRow(Icons.school_outlined, 'Education', person.education),
                          _buildDetailRow(Icons.work_outline, 'Occupation', person.profession),
                          _buildDetailRow(Icons.currency_rupee, 'Annual Income', person.salary),
                          _buildDetailRow(Icons.location_on_outlined, 'Location', '${person.city}, ${person.state}'),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Horoscope Details Section
                      _buildSectionTitle(context, 'Horoscope Compatibility', Icons.auto_awesome_outlined),
                      const SizedBox(height: 8),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 2.3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        children: [
                          HoroscopeCard(icon: Icons.star_border, label: 'Star (Nakshatra)', value: person.star),
                          HoroscopeCard(icon: Icons.brightness_3_outlined, label: 'Rasi', value: person.rasi),
                          HoroscopeCard(icon: Icons.hourglass_empty, label: 'Lagna', value: person.lagna),
                          HoroscopeCard(icon: Icons.warning_amber_outlined, label: 'Dosham', value: person.dosham),
                          HoroscopeCard(icon: Icons.cake_outlined, label: 'Birth Date', value: person.birthDate),
                          HoroscopeCard(icon: Icons.access_time, label: 'Birth Time', value: person.birthTime),
                          HoroscopeCard(icon: Icons.map_outlined, label: 'Birth Place', value: person.birthPlace),
                          HoroscopeCard(icon: Icons.fingerprint, label: 'Gothram', value: person.gothram),
                          HoroscopeCard(icon: Icons.nightlight_round, label: 'Moon Sign', value: person.moonSign),
                          HoroscopeCard(icon: Icons.wb_sunny_outlined, label: 'Sun Sign', value: person.sunSign),
                          HoroscopeCard(icon: Icons.history, label: 'Dasa Balance', value: person.dasaBalance),
                          HoroscopeCard(icon: Icons.info_outline, label: 'Chevvai Dosham', value: person.chevvaiDosham),
                          HoroscopeCard(icon: Icons.linear_scale, label: 'Nadi', value: person.nadi),
                          HoroscopeCard(icon: Icons.people_outline, label: 'Ganam', value: person.ganam),
                          HoroscopeCard(icon: Icons.pets, label: 'Yoni', value: person.yoni),
                          HoroscopeCard(icon: Icons.link, label: 'Rajju', value: person.rajju),
                          HoroscopeCard(icon: Icons.check_circle_outline, label: 'Mahendra Porutham', value: person.mahendraPorutham),
                          HoroscopeCard(icon: Icons.done_all, label: 'Dina Porutham', value: person.dinaPorutham),
                          HoroscopeCard(icon: Icons.done, label: 'Rasi Porutham', value: person.rasiPorutham),
                          HoroscopeCard(icon: Icons.stars, label: 'Overall Match', value: person.overallCompatibility),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Family Details Section
                      _buildSectionTitle(context, 'Family Details', Icons.people_outline),
                      _buildSectionCard(
                        [
                          _buildDetailRow(Icons.work_outline, "Father's Profession", person.fatherOccupation),
                          _buildDetailRow(Icons.work_outline, "Mother's Profession", person.motherOccupation),
                          _buildDetailRow(Icons.group_outlined, 'Siblings Detail', person.siblings),
                          _buildDetailRow(Icons.home_outlined, 'Family Type', person.familyType),
                          _buildDetailRow(Icons.trending_up, 'Family Status', person.familyStatus),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Lifestyle Section
                      _buildSectionTitle(context, 'Lifestyle & Hobbies', Icons.restaurant_menu_outlined),
                      _buildSectionCard(
                        [
                          _buildDetailRow(Icons.restaurant, 'Dietary Preference', person.foodPreference),
                          _buildDetailRow(Icons.smoke_free, 'Smoking Preference', person.smoking == 'No' ? 'Non-Smoker' : person.smoking),
                          _buildDetailRow(Icons.local_bar_outlined, 'Drinking Preference', person.drinking == 'No' ? 'Non-Drinker' : person.drinking),
                          _buildDetailRow(Icons.sports_esports_outlined, 'Hobbies & Interests', person.hobbies.join(', ')),
                          _buildDetailRow(Icons.language, 'Languages Spoken', person.languagesKnown.join(', ')),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Glassmorphic Premium Bottom Actions Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    border: Border(
                      top: BorderSide(
                        color: AppTheme.primary.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Favorite Button
                      FavoriteButton(person: person, size: 22),
                      const SizedBox(width: 16),
                      // Express Interest Button
                      Expanded(
                        child: ExpressionButton(person: person),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    )));
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 22),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 3,
      shadowColor: AppTheme.primary.withOpacity(0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.primary.withOpacity(0.05), width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary.withOpacity(0.6), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 130,
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
