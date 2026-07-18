import 'package:flutter/material.dart';
import '../models/person_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class CompatibilityCheckerPage extends StatefulWidget {
  const CompatibilityCheckerPage({super.key});

  @override
  State<CompatibilityCheckerPage> createState() => _CompatibilityCheckerPageState();
}

class _CompatibilityCheckerPageState extends State<CompatibilityCheckerPage> {
  // User input details
  final _gothraController = TextEditingController(text: 'Kashyapa');
  String _userRasi = 'Mesha (Aries)';
  String _userStar = 'Aswini';

  // Target partner selection
  late PersonModel _selectedPartner;
  bool _hasChecked = false;
  double _calculatedMatch = 0.0;
  List<String> _compatibilityDetails = [];

  // Star Nakshatras list
  final List<String> _stars = [
    'Aswini', 'Bharani', 'Krithika', 'Rohini', 'Mrigasira', 'Ardra', 'Punarvasu',
    'Pushya', 'Ashlesha', 'Magha', 'Poorva Phalguni', 'Uttara Phalguni', 'Hasta',
    'Chitra', 'Swati', 'Visakha', 'Anuradha', 'Jyeshta', 'Moola', 'Poorvashada',
    'Uttarashada', 'Shravana', 'Dhanishta', 'Shatabhisha', 'Poorvabhadra',
    'Uttarabhadra', 'Revati'
  ];

  // Rasis list
  final List<String> _rasis = [
    'Mesha (Aries)', 'Vrishabha (Taurus)', 'Mithuna (Gemini)', 'Kataka (Cancer)',
    'Simha (Leo)', 'Kanya (Virgo)', 'Tula (Libra)', 'Vrischika (Scorpio)',
    'Dhanus (Sagittarius)', 'Makara (Capricorn)', 'Kumbha (Aquarius)', 'Meena (Pisces)'
  ];

  @override
  void initState() {
    super.initState();
    final list = ApiService().profiles;
    if (list.isNotEmpty) {
      _selectedPartner = list.first;
    } else {
      _selectedPartner = PersonModel(
        id: -1,
        name: 'No candidates registered yet',
        photoUrl: '',
        gender: 'Male',
        age: 0,
        height: '',
        religion: 'None',
        caste: 'None',
        education: 'None',
        profession: 'None',
        salary: 'None',
        city: 'None',
        state: 'None',
        compatibilityScore: 0,
        star: 'None',
        rasi: 'None',
        lagna: 'None',
        dosham: 'None',
        birthDate: 'None',
        birthTime: 'None',
        birthPlace: 'None',
        gothram: 'None',
        moonSign: 'None',
        sunSign: 'None',
        dasaBalance: 'None',
        chevvaiDosham: 'None',
        nadi: 'None',
        ganam: 'None',
        yoni: 'None',
        rajju: 'None',
        mahendraPorutham: 'None',
        dinaPorutham: 'None',
        rasiPorutham: 'None',
        overallCompatibility: 'None',
        fatherOccupation: 'None',
        motherOccupation: 'None',
        siblings: 'None',
        familyType: 'None',
        familyStatus: 'None',
        foodPreference: 'None',
        smoking: 'None',
        drinking: 'None',
        hobbies: [],
        languagesKnown: [],
      );
    }
  }

  @override
  void dispose() {
    _gothraController.dispose();
    super.dispose();
  }

  void _runAstrologyMatch() {
    setState(() {
      _hasChecked = true;
      
      // Calculate a realistic but deterministic match score based on base score
      int baseScore = _selectedPartner.compatibilityScore;
      
      // Gothra check: Same gothram is considered incompatible in Hindu Kundli match
      bool sameGothra = _gothraController.text.trim().toLowerCase() == _selectedPartner.gothram.toLowerCase();
      
      int finalScore = baseScore;
      _compatibilityDetails = [];

      if (sameGothra) {
        finalScore = (finalScore - 25).clamp(30, 100);
        _compatibilityDetails.add('⚠️ Gothra Dosham: Same Gothra detected! Traditional matchmaking advises against this.');
      } else {
        finalScore = (finalScore + 5).clamp(30, 100);
        _compatibilityDetails.add('✅ Gothra Porutham: Perfect (Different Gothrams: ${_gothraController.text} & ${_selectedPartner.gothram})');
      }

      // Rasi matching simulation
      if (_selectedPartner.rasi.toLowerCase().contains(_userRasi.split(' ').first.toLowerCase())) {
        _compatibilityDetails.add('✅ Rasi Porutham: Excellent (Harmonious moon signs)');
        finalScore = (finalScore + 6).clamp(30, 100);
      } else {
        _compatibilityDetails.add('✅ Rasi Porutham: Compatible (Moderate elemental agreement)');
      }

      // Star matching simulation
      if (_userStar == _selectedPartner.star) {
        _compatibilityDetails.add('✅ Dina Porutham: Star match indicates deep mental affinity');
        finalScore = (finalScore + 8).clamp(30, 100);
      } else {
        _compatibilityDetails.add('✅ Dina Porutham: Good agreement of birth stars');
      }

      _compatibilityDetails.add('✨ Nadi Porutham: Healthy balance of energies (Vatha/Pitha/Kapha)');
      _calculatedMatch = finalScore.toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFB),
      appBar: AppBar(
        title: const Text('Kundli Matchmaker'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Image card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF880E4F), Color(0xFF3E1F29)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_purple500, color: AppTheme.accentGold, size: 40),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kundli Compatibility',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select a profile and configure your birth variables to calculate Porutham matching.',
                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Left Box: Your Details
            const Text(
              'Your Birth Info',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _gothraController,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      decoration: const InputDecoration(
                        labelText: 'Your Gothra',
                        prefixIcon: Icon(Icons.bookmark_outline, color: AppTheme.primary, size: 20),
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _userRasi,
                      style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                      decoration: const InputDecoration(
                        labelText: 'Your Rasi (Moon Sign)',
                        prefixIcon: Icon(Icons.brightness_2_outlined, color: AppTheme.primary, size: 20),
                      ),
                      items: _rasis.map((rasi) {
                        return DropdownMenuItem(value: rasi, child: Text(rasi));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _userRasi = val);
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _userStar,
                      style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                      decoration: const InputDecoration(
                        labelText: 'Your Star (Nakshatra)',
                        prefixIcon: Icon(Icons.star_outline_rounded, color: AppTheme.primary, size: 20),
                      ),
                      items: _stars.map((star) {
                        return DropdownMenuItem(value: star, child: Text(star));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _userStar = val);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Right Box: Target Partner Selection
            const Text(
              'Select Partner Profile',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                     DropdownButtonFormField<PersonModel>(
                       value: _selectedPartner,
                       style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                       decoration: const InputDecoration(
                         labelText: 'Select Match Candidate',
                         prefixIcon: Icon(Icons.person_search_outlined, color: AppTheme.primary, size: 20),
                       ),
                       items: (ApiService().profiles.isEmpty ? [_selectedPartner] : ApiService().profiles).map((person) {
                         return DropdownMenuItem(value: person, child: Text(person.name));
                       }).toList(),
                       onChanged: ApiService().profiles.isEmpty ? null : (val) {
                         if (val != null) {
                           setState(() {
                             _selectedPartner = val;
                             _hasChecked = false; // Reset calculation when profile changes
                           });
                         }
                       },
                     ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: Image.network(
                              _selectedPartner.photoUrl,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              errorBuilder: (context, error, stackTrace) => Container(color: AppTheme.primary.withOpacity(0.08)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_selectedPartner.name} (${_selectedPartner.age} Yrs)',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Star: ${_selectedPartner.star}  |  Rasi: ${_selectedPartner.rasi}',
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Match Action button
             ElevatedButton(
               onPressed: ApiService().profiles.isEmpty ? null : _runAstrologyMatch,
               style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('Calculate Kundli Score', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),

            // Matching results card
            if (_hasChecked) ...[
              Card(
                color: const Color(0xFFFAF0F3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppTheme.primary, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        'Compatibility Results',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
                      ),
                      const SizedBox(height: 16),
                      // Progress circle
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(
                              value: _calculatedMatch / 100.0,
                              strokeWidth: 8,
                              backgroundColor: Colors.white,
                              color: AppTheme.primary,
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                '${_calculatedMatch.round()}%',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primary),
                              ),
                              const Text('Match', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 10),
                      // Compatibility bullet points
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _compatibilityDetails.map((detail) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              detail,
                              style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary, height: 1.4),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}
