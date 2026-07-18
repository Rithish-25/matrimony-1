import 'package:flutter/material.dart';
import '../models/person_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/profile_card.dart';
import 'favorites_page.dart';
import 'expressions_page.dart';
import 'profile_details_page.dart';
import 'login_page.dart';
import 'partner_preferences_page.dart';
import 'compatibility_checker_page.dart';
import 'admin_panel_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  
  // Search & Filter state
  String _searchQuery = '';
  String _activeAgeFilter = 'All'; // 'All', 'Under 28', '28+'
  String _activeReligionFilter = 'All'; // 'All', 'Hindu', 'Sikh'
  String _activeProfessionFilter = 'All'; // 'All', 'Tech', 'Finance/MBA', 'Doctor/Research'
  String _activeLocationFilter = 'All'; // 'All', 'Mumbai', 'Bangalore', 'Delhi/North'

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  bool _isLoadingProfiles = false;

  void _loadProfiles() async {
    if (mounted) setState(() => _isLoadingProfiles = true);
    await ApiService().loadProfiles();
    if (mounted) setState(() => _isLoadingProfiles = false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter profiles based on search query & chips
  List<PersonModel> get _filteredProfiles {
    return ApiService().profiles.where((profile) {
      // 1. Gender filter: filter out self? We keep all matches of opposite genders or all available.
      // Usually you show opposite gender, here we have 15 diverse profiles, we show all of them.
      
      // 2. Search Query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = profile.name.toLowerCase().contains(query);
        final matchesProfession = profile.profession.toLowerCase().contains(query);
        final matchesCity = profile.city.toLowerCase().contains(query);
        if (!matchesName && !matchesProfession && !matchesCity) {
          return false;
        }
      }

      // 3. Age Filter
      if (_activeAgeFilter == 'Under 26' && profile.age >= 26) return false;
      if (_activeAgeFilter == '26 - 29' && (profile.age < 26 || profile.age > 29)) return false;
      if (_activeAgeFilter == '30+' && profile.age < 30) return false;

      // 4. Religion Filter
      if (_activeReligionFilter != 'All' && profile.religion != _activeReligionFilter) return false;

      // 5. Profession Filter
      if (_activeProfessionFilter == 'Tech') {
        final p = profile.profession.toLowerCase();
        if (!p.contains('software') && !p.contains('data') && !p.contains('product') && !p.contains('entrepreneur')) {
          return false;
        }
      } else if (_activeProfessionFilter == 'Finance/MBA') {
        final p = profile.profession.toLowerCase();
        final e = profile.education.toLowerCase();
        if (!p.contains('banker') && !p.contains('analyst') && !p.contains('audit') && !e.contains('mba') && !e.contains('ca')) {
          return false;
        }
      } else if (_activeProfessionFilter == 'Doctor/Research') {
        final p = profile.profession.toLowerCase();
        if (!p.contains('doctor') && !p.contains('scientist') && !p.contains('pediatrician')) {
          return false;
        }
      }

      // 6. Location Filter
      if (_activeLocationFilter != 'All' && profile.city != _activeLocationFilter) return false;

      return true;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _activeAgeFilter = 'All';
      _activeReligionFilter = 'All';
      _activeProfessionFilter = 'All';
      _activeLocationFilter = 'All';
    });
  }

  Widget _buildHomeTab() {
    final list = _filteredProfiles;

    return Column(
      children: [
        // Luxury Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Search by Name, City, or Profession...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.primary, size: 22),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : const Icon(Icons.tune_outlined, color: AppTheme.primary, size: 20),
              ),
            ),
          ),
        ),

        // Filter Chips Bar
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              // Age Filter Dropdown
              _buildFilterChip(
                label: _activeAgeFilter == 'All' ? 'Age' : 'Age: $_activeAgeFilter',
                isActive: _activeAgeFilter != 'All',
                options: const ['All', 'Under 26', '26 - 29', '30+'],
                currentValue: _activeAgeFilter,
                onSelected: (val) {
                  setState(() {
                    _activeAgeFilter = val;
                  });
                },
              ),
              // Religion Filter Dropdown
              _buildFilterChip(
                label: _activeReligionFilter == 'All' ? 'Religion' : 'Religion: $_activeReligionFilter',
                isActive: _activeReligionFilter != 'All',
                options: const ['All', 'Hindu', 'Sikh'],
                currentValue: _activeReligionFilter,
                onSelected: (val) {
                  setState(() {
                    _activeReligionFilter = val;
                  });
                },
              ),
              // Profession Filter Dropdown
              _buildFilterChip(
                label: _activeProfessionFilter == 'All' ? 'Profession' : 'Job: $_activeProfessionFilter',
                isActive: _activeProfessionFilter != 'All',
                options: const ['All', 'Tech', 'Finance/MBA', 'Doctor/Research'],
                currentValue: _activeProfessionFilter,
                onSelected: (val) {
                  setState(() {
                    _activeProfessionFilter = val;
                  });
                },
              ),
              // Location Filter Dropdown
              _buildFilterChip(
                label: _activeLocationFilter == 'All' ? 'Location' : 'City: $_activeLocationFilter',
                isActive: _activeLocationFilter != 'All',
                options: const ['All', 'Mumbai', 'Bangalore', 'Delhi', 'Chennai', 'Hyderabad', 'Kolkata', 'Pune'],
                currentValue: _activeLocationFilter,
                onSelected: (val) {
                  setState(() {
                    _activeLocationFilter = val;
                  });
                },
              ),
              // Clear All Filters Indicator
              if (_searchQuery.isNotEmpty || _activeAgeFilter != 'All' || _activeReligionFilter != 'All' || _activeProfessionFilter != 'All' || _activeLocationFilter != 'All')
                GestureDetector(
                  onTap: _clearFilters,
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    child: const Text(
                      'Clear All',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Profiles Scroll View
        Expanded(
          child: _isLoadingProfiles
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              : list.isEmpty
                  ? _buildNoResultsState()
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 6, bottom: 20),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final person = list[index];
                        return ProfileCard(
                          person: person,
                          onTap: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    ProfileDetailsPage(person: person),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                transitionDuration: const Duration(milliseconds: 500),
                              ),
                            );
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isActive,
    required List<String> options,
    required String currentValue,
    required ValueChanged<String> onSelected,
  }) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 42),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) {
        return options.map((option) {
          final isSelected = (option == currentValue);
          return PopupMenuItem<String>(
            value: option,
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 18,
                  color: isSelected ? AppTheme.primary : AppTheme.textSecondary.withOpacity(0.6),
                ),
                const SizedBox(width: 12),
                Text(
                  option == 'All' ? 'All' : option,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      onSelected: onSelected,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppTheme.primary : AppTheme.primary.withOpacity(0.15),
            width: 1.2,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : AppTheme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: isActive ? Colors.white : AppTheme.textSecondary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.04),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_outlined, size: 50, color: AppTheme.primary),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Matching Profiles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try widening your search terms or clearing selected filter chips to see more profiles.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.3),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _clearFilters,
              child: const Text(
                'Reset Filters',
                style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bonus User Profile Screen
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Banner Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.accentGold]),
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage('https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=500&auto=format&fit=crop&q=60'),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                        child: const Icon(Icons.edit, color: Colors.white, size: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ValueListenableBuilder<String>(
                    valueListenable: AppState().userName,
                    builder: (context, name, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: Colors.blue, size: 18),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  const Text('VIP Premium Match Member', style: TextStyle(color: AppTheme.accentGold, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 18),
                  const Divider(),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProfileStat(
                        '${_filteredProfiles.length}',
                        'Matches Active',
                      ),
                      ValueListenableBuilder<List<PersonModel>>(
                        valueListenable: AppState().favorites,
                        builder: (context, favList, _) {
                          return _buildProfileStat(
                            '${favList.length}',
                            'My Favorites',
                          );
                        },
                      ),
                      ValueListenableBuilder<List<PersonModel>>(
                        valueListenable: AppState().expressions,
                        builder: (context, expList, _) {
                          return _buildProfileStat(
                            '${expList.length}',
                            'Interests Sent',
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Menu Options
          _buildMenuTile(
            Icons.tune,
            'Partner Preferences',
            'Configure age, height, education requirements',
            onTap: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PartnerPreferencesPage(
                    initialAgeFilter: _activeAgeFilter,
                    initialReligionFilter: _activeReligionFilter,
                    initialProfessionFilter: _activeProfessionFilter,
                  ),
                ),
              );
              if (result != null && result is Map<String, String>) {
                setState(() {
                  _activeAgeFilter = result['age'] ?? 'All';
                  _activeReligionFilter = result['religion'] ?? 'All';
                  _activeProfessionFilter = result['profession'] ?? 'All';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Preferences applied! Matches updated.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          _buildMenuTile(
            Icons.favorite_outline,
            'Compatibility Checker',
            'Match Kundli / Gothra settings',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CompatibilityCheckerPage(),
                ),
              );
            },
          ),
          if (AppState().userRole == 'Admin') ...[
            const SizedBox(height: 12),
            _buildMenuTile(
              Icons.admin_panel_settings_outlined,
              'Admin Panel',
              'Manage profiles and dashboard stats',
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AdminPanelPage(),
                  ),
                );
                _loadProfiles();
              },
            ),
          ],
          const SizedBox(height: 24),
          
          // Log Out
          ElevatedButton(
            onPressed: () async {
              await AppState().logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primary,
              elevation: 1,
              side: const BorderSide(color: AppTheme.primary, width: 1.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text('Log Out Account', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String score, String label) {
    return Column(
      children: [
        Text(score, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildMenuTile(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        trailing: const Icon(Icons.chevron_right, size: 18),
        onTap: onTap ?? () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title settings opened (Demo mode)'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen title based on index
    String title = 'Soulmate';
    Widget body = Container();

    switch (_currentIndex) {
      case 0:
        title = 'Soulmate';
        body = _buildHomeTab();
        break;
      case 1:
        title = 'My Favorites';
        body = FavoritesPage(onExplorePressed: () {
          setState(() {
            _currentIndex = 0;
          });
        });
        break;
      case 2:
        title = 'Expressions Sent';
        body = ExpressionsPage(onExplorePressed: () {
          setState(() {
            _currentIndex = 0;
          });
        });
        break;
      case 3:
        title = 'My Profile';
        body = _buildProfileTab();
        break;
    }

    return Scaffold(
      appBar: CustomAppBar(
        leading: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(Icons.all_inclusive, color: AppTheme.primary, size: 24),
        ),
        title: title,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, size: 22),
            onPressed: () {
              setState(() {
                _currentIndex = 1;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.send_outlined, size: 20),
            onPressed: () {
              setState(() {
                _currentIndex = 2;
              });
            },
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textSecondary.withOpacity(0.7),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              activeIcon: Icon(Icons.search_rounded),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.send_outlined),
              activeIcon: Icon(Icons.send),
              label: 'Sent',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
