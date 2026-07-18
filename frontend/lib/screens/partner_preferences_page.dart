import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PartnerPreferencesPage extends StatefulWidget {
  final String initialAgeFilter;
  final String initialReligionFilter;
  final String initialProfessionFilter;

  const PartnerPreferencesPage({
    super.key,
    required this.initialAgeFilter,
    required this.initialReligionFilter,
    required this.initialProfessionFilter,
  });

  @override
  State<PartnerPreferencesPage> createState() => _PartnerPreferencesPageState();
}

class _PartnerPreferencesPageState extends State<PartnerPreferencesPage> {
  late RangeValues _ageRange;
  late String _religion;
  late String _profession;

  @override
  void initState() {
    super.initState();
    // Initialize state from current home screen filter settings
    double minAge = 20;
    double maxAge = 40;
    if (widget.initialAgeFilter == 'Under 26') {
      minAge = 20;
      maxAge = 25;
    } else if (widget.initialAgeFilter == '26 - 29') {
      minAge = 26;
      maxAge = 29;
    } else if (widget.initialAgeFilter == '30+') {
      minAge = 30;
      maxAge = 40;
    }
    _ageRange = RangeValues(minAge, maxAge);
    _religion = widget.initialReligionFilter;
    _profession = widget.initialProfessionFilter;
  }

  void _savePreferences() {
    // Map sliders back to home screen category filters
    String ageFilter = 'All';
    if (_ageRange.start >= 30) {
      ageFilter = '30+';
    } else if (_ageRange.start >= 26 && _ageRange.end <= 29) {
      ageFilter = '26 - 29';
    } else if (_ageRange.end <= 25) {
      ageFilter = 'Under 26';
    }

    Navigator.of(context).pop({
      'age': ageFilter,
      'religion': _religion,
      'profession': _profession,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFB),
      appBar: AppBar(
        title: const Text('Partner Preferences'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preference Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, Color(0xFFE91E63)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Refine Your Matchmaking',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'We use these configurations to tailor your Daily Match Suggestions.',
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Age Preference Section
            _buildSectionHeader('Preferred Age Range', '${_ageRange.start.round()} - ${_ageRange.end.round()} Years'),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: RangeSlider(
                  values: _ageRange,
                  min: 20,
                  max: 40,
                  divisions: 20,
                  activeColor: AppTheme.primary,
                  inactiveColor: AppTheme.primary.withOpacity(0.1),
                  labels: RangeLabels(
                    '${_ageRange.start.round()}',
                    '${_ageRange.end.round()}',
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _ageRange = values;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Religion Dropdown Section
            _buildSectionHeader('Religion / Beliefs', ''),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _religion,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primary),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All Religions')),
                      DropdownMenuItem(value: 'Hindu', child: Text('Hinduism')),
                      DropdownMenuItem(value: 'Sikh', child: Text('Sikhism')),
                    ],
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          _religion = value;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Profession Dropdown Section
            _buildSectionHeader('Profession / Career Sector', ''),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _profession,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primary),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All Professions')),
                      DropdownMenuItem(value: 'Tech', child: Text('Technology & Engineering')),
                      DropdownMenuItem(value: 'Finance/MBA', child: Text('Finance, Business & Management')),
                      DropdownMenuItem(value: 'Doctor/Research', child: Text('Medical & Scientific Research')),
                    ],
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          _profession = value;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),

            // Save Preferences Button
            ElevatedButton(
              onPressed: _savePreferences,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 3,
                shadowColor: AppTheme.primary.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'Apply Preferences',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          if (value.isNotEmpty)
            Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
        ],
      ),
    );
  }
}
