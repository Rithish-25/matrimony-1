import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../models/person_model.dart';
import '../services/api_service.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  bool _isLoading = true;
  int _totalCount = 0;
  int _activeCount = 0;
  int _inactiveCount = 0;
  List<PersonModel> _allProfiles = [];
  List<PersonModel> _filteredProfiles = [];
  final _searchController = TextEditingController();
  String _genderFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final statsResult = await ApiService().fetchAdminStats();
      if (statsResult['success'] == true) {
        final stats = statsResult['stats'];
        _totalCount = stats['totalProfiles'] ?? 0;
        _activeCount = stats['activeProfiles'] ?? 0;
        _inactiveCount = stats['inactiveProfiles'] ?? 0;
      }

      // Load all active and inactive profiles
      // By calling fetchProfiles with empty query, we fetch active.
      // To get all (active/inactive) or manage them, we can get active ones,
      // and in a full system we list them all.
      final profiles = await ApiService().fetchProfiles();
      _allProfiles = profiles;
      _applyFilters();
    } catch (e) {
      print('Admin load error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredProfiles = _allProfiles.where((p) {
        final matchesSearch = p.name.toLowerCase().contains(query) ||
            p.profession.toLowerCase().contains(query) ||
            p.city.toLowerCase().contains(query);
        final matchesGender = _genderFilter == 'All' || p.gender == _genderFilter;
        return matchesSearch && matchesGender;
      }).toList();
    });
  }

  void _handleDelete(PersonModel person) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Profile'),
        content: Text('Are you sure you want to delete ${person.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final result = await ApiService().deleteProfile(person.id);
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile deleted successfully')));
        _loadData();
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Error deleting profile')));
      }
    }
  }

  void _openCreateOrEditForm({PersonModel? existingPerson}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ProfileFormSheet(
        person: existingPerson,
        onSaved: () {
          Navigator.of(ctx).pop();
          _loadData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () => _openCreateOrEditForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : Column(
              children: [
                // Stats Dashboard Row
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      _buildStatsCard('Total', _totalCount, Colors.blue),
                      const SizedBox(width: 8),
                      _buildStatsCard('Active', _activeCount, Colors.green),
                      const SizedBox(width: 8),
                      _buildStatsCard('Inactive', _inactiveCount, Colors.red),
                    ],
                  ),
                ),

                // Search and filters
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search profiles...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (_) => _applyFilters(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<String>(
                          value: _genderFilter,
                          underline: const SizedBox(),
                          items: ['All', 'Male', 'Female'].map((gender) {
                            return DropdownMenuItem(value: gender, child: Text(gender));
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _genderFilter = val ?? 'All';
                              _applyFilters();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Profiles List
                Expanded(
                  child: _filteredProfiles.isEmpty
                      ? const Center(child: Text('No profiles found matching details.'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _filteredProfiles.length,
                          itemBuilder: (ctx, index) {
                            final person = _filteredProfiles[index];
                            return Card(
                              elevation: 1,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: CircleAvatar(
                                  radius: 28,
                                  backgroundImage: NetworkImage(person.photoUrl),
                                  backgroundColor: AppTheme.secondary,
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        person.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    if (person.isVerified)
                                      const Icon(Icons.verified, color: Colors.blue, size: 16),
                                  ],
                                ),
                                subtitle: Text(
                                  '${person.age} Yrs • ${person.profession}\n${person.city}, ${person.state}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _openCreateOrEditForm(existingPerson: person),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _handleDelete(person),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsCard(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            Text(
              value.toString(),
              style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileFormSheet extends StatefulWidget {
  final PersonModel? person;
  final VoidCallback onSaved;

  const _ProfileFormSheet({this.person, required this.onSaved});

  @override
  State<_ProfileFormSheet> createState() => _ProfileFormSheetState();
}

class _ProfileFormSheetState extends State<_ProfileFormSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form Field Controllers
  // Basic Details & Location
  late TextEditingController _nameCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _religionCtrl;
  late TextEditingController _casteCtrl;
  late TextEditingController _educationCtrl;
  late TextEditingController _professionCtrl;
  late TextEditingController _salaryCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _photoUrlCtrl;
  
  // Horoscope & Astrology Details
  late TextEditingController _starCtrl;
  late TextEditingController _rasiCtrl;
  late TextEditingController _gothramCtrl;
  late TextEditingController _lagnaCtrl;
  late TextEditingController _doshamCtrl;
  late TextEditingController _birthDateCtrl;
  late TextEditingController _birthTimeCtrl;
  late TextEditingController _birthPlaceCtrl;
  late TextEditingController _moonSignCtrl;
  late TextEditingController _sunSignCtrl;
  late TextEditingController _dasaBalanceCtrl;
  late TextEditingController _chevvaiDoshamCtrl;
  
  // Family Details
  late TextEditingController _fatherOccCtrl;
  late TextEditingController _motherOccCtrl;
  late TextEditingController _siblingsCtrl;
  late TextEditingController _familyTypeCtrl;
  late TextEditingController _familyStatusCtrl;

  // Lifestyle & Hobbies
  late TextEditingController _foodPreferenceCtrl;
  late TextEditingController _smokingCtrl;
  late TextEditingController _drinkingCtrl;
  late TextEditingController _hobbiesCtrl;
  late TextEditingController _languagesCtrl;
  
  String _gender = 'Male';
  String _status = 'Active';
  bool _isVerified = true;
  Uint8List? _pickedFileBytes;

  @override
  void initState() {
    super.initState();
    final p = widget.person;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _ageCtrl = TextEditingController(text: p?.age.toString() ?? '');
    _heightCtrl = TextEditingController(text: p?.height ?? "5' 8\"");
    _religionCtrl = TextEditingController(text: p?.religion ?? 'Hindu');
    _casteCtrl = TextEditingController(text: p?.caste ?? '');
    _educationCtrl = TextEditingController(text: p?.education ?? '');
    _professionCtrl = TextEditingController(text: p?.profession ?? '');
    _salaryCtrl = TextEditingController(text: p?.salary ?? '');
    _cityCtrl = TextEditingController(text: p?.city ?? '');
    _stateCtrl = TextEditingController(text: p?.state ?? '');
    _photoUrlCtrl = TextEditingController(text: p?.photoUrl ?? '');
    
    // Astrology
    _starCtrl = TextEditingController(text: p?.star ?? '');
    _rasiCtrl = TextEditingController(text: p?.rasi ?? '');
    _gothramCtrl = TextEditingController(text: p?.gothram ?? '');
    _lagnaCtrl = TextEditingController(text: p?.lagna ?? '');
    _doshamCtrl = TextEditingController(text: p?.dosham ?? 'No Dosham');
    _birthDateCtrl = TextEditingController(text: p?.birthDate ?? '');
    _birthTimeCtrl = TextEditingController(text: p?.birthTime ?? '');
    _birthPlaceCtrl = TextEditingController(text: p?.birthPlace ?? '');
    _moonSignCtrl = TextEditingController(text: p?.moonSign ?? '');
    _sunSignCtrl = TextEditingController(text: p?.sunSign ?? '');
    _dasaBalanceCtrl = TextEditingController(text: p?.dasaBalance ?? '');
    _chevvaiDoshamCtrl = TextEditingController(text: p?.chevvaiDosham ?? 'None');
    
    // Family
    _fatherOccCtrl = TextEditingController(text: p?.fatherOccupation ?? '');
    _motherOccCtrl = TextEditingController(text: p?.motherOccupation ?? '');
    _siblingsCtrl = TextEditingController(text: p?.siblings ?? '');
    _familyTypeCtrl = TextEditingController(text: p?.familyType ?? 'Nuclear Family');
    _familyStatusCtrl = TextEditingController(text: p?.familyStatus ?? 'Middle Class');

    // Lifestyle
    _foodPreferenceCtrl = TextEditingController(text: p?.foodPreference ?? 'Pure Vegetarian');
    _smokingCtrl = TextEditingController(text: p?.smoking ?? 'No');
    _drinkingCtrl = TextEditingController(text: p?.drinking ?? 'No');
    _hobbiesCtrl = TextEditingController(text: p?.hobbies.join(', ') ?? '');
    _languagesCtrl = TextEditingController(text: p?.languagesKnown.join(', ') ?? 'English, Tamil');
    
    _gender = p?.gender ?? 'Male';
    _isVerified = p?.isVerified ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _religionCtrl.dispose();
    _casteCtrl.dispose();
    _educationCtrl.dispose();
    _professionCtrl.dispose();
    _salaryCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _photoUrlCtrl.dispose();
    
    // Astrology
    _starCtrl.dispose();
    _rasiCtrl.dispose();
    _gothramCtrl.dispose();
    _lagnaCtrl.dispose();
    _doshamCtrl.dispose();
    _birthDateCtrl.dispose();
    _birthTimeCtrl.dispose();
    _birthPlaceCtrl.dispose();
    _moonSignCtrl.dispose();
    _sunSignCtrl.dispose();
    _dasaBalanceCtrl.dispose();
    _chevvaiDoshamCtrl.dispose();
    
    // Family
    _fatherOccCtrl.dispose();
    _motherOccCtrl.dispose();
    _siblingsCtrl.dispose();
    _familyTypeCtrl.dispose();
    _familyStatusCtrl.dispose();

    // Lifestyle
    _foodPreferenceCtrl.dispose();
    _smokingCtrl.dispose();
    _drinkingCtrl.dispose();
    _hobbiesCtrl.dispose();
    _languagesCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_photoUrlCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or upload a candidate photo first!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final Map<String, dynamic> data = {
        'name': _nameCtrl.text.trim(),
        'age': int.parse(_ageCtrl.text.trim()),
        'gender': _gender,
        'height': _heightCtrl.text.trim(),
        'religion': _religionCtrl.text.trim(),
        'caste': _casteCtrl.text.trim(),
        'education': _educationCtrl.text.trim(),
        'profession': _professionCtrl.text.trim(),
        'salary': _salaryCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'state': _stateCtrl.text.trim(),
        'photoUrl': _photoUrlCtrl.text.trim(),
        'isVerified': _isVerified,
        'status': _status,
        
        // Astrology
        'star': _starCtrl.text.trim(),
        'rasi': _rasiCtrl.text.trim(),
        'gothram': _gothramCtrl.text.trim(),
        'lagna': _lagnaCtrl.text.trim(),
        'dosham': _doshamCtrl.text.trim(),
        'birthDate': _birthDateCtrl.text.trim(),
        'birthTime': _birthTimeCtrl.text.trim(),
        'birthPlace': _birthPlaceCtrl.text.trim(),
        'moonSign': _moonSignCtrl.text.trim(),
        'sunSign': _sunSignCtrl.text.trim(),
        'dasaBalance': _dasaBalanceCtrl.text.trim(),
        'chevvaiDosham': _chevvaiDoshamCtrl.text.trim(),
        
        // Fallbacks for unedited match indicators
        'nadi': widget.person?.nadi ?? 'Madhya',
        'ganam': widget.person?.ganam ?? 'Deva',
        'yoni': widget.person?.yoni ?? 'Aja',
        'rajju': widget.person?.rajju ?? 'Pada',
        'mahendraPorutham': widget.person?.mahendraPorutham ?? 'Good',
        'dinaPorutham': widget.person?.dinaPorutham ?? 'Matched',
        'rasiPorutham': widget.person?.rasiPorutham ?? 'Matched',
        'overallCompatibility': widget.person?.overallCompatibility ?? '8/10 Matched',
        
        // Family
        'fatherOccupation': _fatherOccCtrl.text.trim(),
        'motherOccupation': _motherOccCtrl.text.trim(),
        'siblings': _siblingsCtrl.text.trim(),
        'familyType': _familyTypeCtrl.text.trim(),
        'familyStatus': _familyStatusCtrl.text.trim(),
        
        // Lifestyle
        'foodPreference': _foodPreferenceCtrl.text.trim(),
        'smoking': _smokingCtrl.text.trim(),
        'drinking': _drinkingCtrl.text.trim(),
        'hobbies': _hobbiesCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        'languagesKnown': _languagesCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        
        'compatibilityScore': widget.person?.compatibilityScore ?? 85,
      };

      Map<String, dynamic> result;
      if (widget.person != null) {
        result = await ApiService().updateProfile(widget.person!.id, data);
      } else {
        result = await ApiService().createProfile(data);
      }

      setState(() => _isLoading = false);
      if (result['success'] == true) {
        widget.onSaved();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Error saving profile')),
        );
      }
    }
  }

  void _showCloudinaryConfigError(String originalError) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
            SizedBox(width: 8),
            Text('Cloudinary Config Needed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'We previewed your chosen image, but uploading it to Cloudinary returned an error:\n'
          '"$originalError"\n\n'
          'To save uploads to Cloudinary, configure your Cloud Name and Upload Preset at the top of:\n'
          'lib/screens/admin_panel_page.dart.\n\n'
          'We will save a default sample avatar URL to the database for now, so you can still successfully create this profile!',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // Populate fallback placeholder so form save is not blocked
              _photoUrlCtrl.text = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=500';
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
            child: const Text('Continue with Placeholder'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _pickedFileBytes = bytes;
          _isLoading = true;
        });

        // Direct unsigned Cloudinary upload
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('https://api.cloudinary.com/v1_1/djooa6hst/image/upload'),
        );
        
        request.fields['upload_preset'] = 'soulmate';

        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: file.name,
          ),
        );

        final response = await request.send();
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);

        setState(() => _isLoading = false);

        if (response.statusCode == 200 && data['secure_url'] != null) {
          final imageUrl = data['secure_url'].toString();
          _photoUrlCtrl.text = imageUrl;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image uploaded successfully!'), backgroundColor: Colors.green),
          );
        } else {
          final errMsg = data['error']?['message'] ?? 'Upload failed';
          _showCloudinaryConfigError(errMsg);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.person == null ? 'Create Profile' : 'Edit Profile',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              // Basic Fields
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name *'),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Age *'),
                      validator: (val) => (val == null || int.tryParse(val.trim()) == null) ? 'Enter valid age' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: const InputDecoration(labelText: 'Gender'),
                      items: ['Male', 'Female'].map((g) {
                        return DropdownMenuItem(value: g, child: Text(g));
                      }).toList(),
                      onChanged: (val) => setState(() => _gender = val ?? 'Male'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Premium Pick & Upload Image Preview Area
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Candidate Profile Photo *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.primary.withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (_pickedFileBytes != null)
                                Image.memory(_pickedFileBytes!, width: 130, height: 130, fit: BoxFit.cover)
                              else if (_photoUrlCtrl.text.isNotEmpty)
                                Image.network(
                                  _photoUrlCtrl.text,
                                  width: 130,
                                  height: 130,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, o, s) => const Icon(Icons.broken_image, size: 36, color: Colors.grey),
                                )
                              else
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo_rounded, size: 36, color: AppTheme.primary.withOpacity(0.8)),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Upload Photo',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
                                    ),
                                  ],
                                ),
                              if (_pickedFileBytes != null || _photoUrlCtrl.text.isNotEmpty)
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    color: Colors.black.withOpacity(0.5),
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.cached, color: Colors.white, size: 12),
                                        SizedBox(width: 4),
                                        Text(
                                          'Change Photo',
                                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Demographics
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _religionCtrl,
                      decoration: const InputDecoration(labelText: 'Religion *'),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter religion' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _casteCtrl,
                      decoration: const InputDecoration(labelText: 'Caste *'),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter caste' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityCtrl,
                      decoration: const InputDecoration(labelText: 'City *'),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter city' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stateCtrl,
                      decoration: const InputDecoration(labelText: 'State *'),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter state' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Job / Education
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _educationCtrl,
                      decoration: const InputDecoration(labelText: 'Education *'),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter education' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _professionCtrl,
                      decoration: const InputDecoration(labelText: 'Occupation *'),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter profession' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _salaryCtrl,
                decoration: const InputDecoration(labelText: 'Annual Income (e.g. 15 LPA) *'),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter salary' : null,
              ),
              const SizedBox(height: 12),

              // --- Horoscope & Astrology Section ---
              const SizedBox(height: 20),
              const Text(
                'Astrology & Horoscope Details',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
              const SizedBox(height: 6),
              const Divider(),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _starCtrl,
                      decoration: const InputDecoration(labelText: 'Nakshatra / Star'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _rasiCtrl,
                      decoration: const InputDecoration(labelText: 'Rasi / Moon Sign'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _lagnaCtrl,
                      decoration: const InputDecoration(labelText: 'Lagna (Ascendant)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _gothramCtrl,
                      decoration: const InputDecoration(labelText: 'Gothram'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _doshamCtrl,
                      decoration: const InputDecoration(labelText: 'Dosham Details'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _chevvaiDoshamCtrl,
                      decoration: const InputDecoration(labelText: 'Chevvai Dosham / Manglik'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _birthDateCtrl,
                      decoration: const InputDecoration(labelText: 'Birth Date (e.g. 12th April 1998)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _birthTimeCtrl,
                      decoration: const InputDecoration(labelText: 'Birth Time (e.g. 06:15 AM)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _birthPlaceCtrl,
                      decoration: const InputDecoration(labelText: 'Birth Place'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _dasaBalanceCtrl,
                      decoration: const InputDecoration(labelText: 'Dasa Balance (e.g. Ketu - 2 Yrs)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _moonSignCtrl,
                      decoration: const InputDecoration(labelText: 'Moon Sign'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _sunSignCtrl,
                      decoration: const InputDecoration(labelText: 'Sun Sign'),
                    ),
                  ),
                ],
              ),

              // --- Family & Lifestyle Section ---
              const SizedBox(height: 24),
              const Text(
                'Family Background & Lifestyle',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
              const SizedBox(height: 6),
              const Divider(),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fatherOccCtrl,
                      decoration: const InputDecoration(labelText: 'Father Occupation'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _motherOccCtrl,
                      decoration: const InputDecoration(labelText: 'Mother Occupation'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _siblingsCtrl,
                      decoration: const InputDecoration(labelText: 'Siblings Detail'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _familyTypeCtrl,
                      decoration: const InputDecoration(labelText: 'Family Type (e.g. Nuclear/Joint)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _familyStatusCtrl,
                      decoration: const InputDecoration(labelText: 'Family Status (e.g. Middle Class)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _foodPreferenceCtrl,
                      decoration: const InputDecoration(labelText: 'Dietary (e.g. Vegetarian/Non-Veg)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _smokingCtrl,
                      decoration: const InputDecoration(labelText: 'Smoking (Yes/No)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _drinkingCtrl,
                      decoration: const InputDecoration(labelText: 'Drinking (Yes/No/Socially)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hobbiesCtrl,
                decoration: const InputDecoration(labelText: 'Hobbies & Interests (comma separated)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _languagesCtrl,
                decoration: const InputDecoration(labelText: 'Languages Known (comma separated)'),
              ),
              const SizedBox(height: 20),

              // Status check
              Row(
                children: [
                  Checkbox(
                    value: _isVerified,
                    activeColor: AppTheme.primary,
                    onChanged: (val) => setState(() => _isVerified = val ?? true),
                  ),
                  const Text('Mark Profile as Verified ✔️', style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 24),

              // Form submit
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _submit,
                      child: const Text('Save Candidate Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
