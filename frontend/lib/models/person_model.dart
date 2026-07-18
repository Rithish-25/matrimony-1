import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class PersonModel {
  final int id;
  final String name;
  final String photoUrl;
  final String gender;
  final int age;
  final String height;
  final String religion;
  final String caste;
  final String education;
  final String profession;
  final String salary;
  final String city;
  final String state;
  final bool isVerified;
  final int compatibilityScore;

  // Horoscope Details
  final String star;
  final String rasi;
  final String lagna;
  final String dosham;
  final String birthDate;
  final String birthTime;
  final String birthPlace;
  final String gothram;
  final String moonSign;
  final String sunSign;
  final String dasaBalance;
  final String chevvaiDosham;
  final String nadi;
  final String ganam;
  final String yoni;
  final String rajju;
  final String mahendraPorutham;
  final String dinaPorutham;
  final String rasiPorutham;
  final String overallCompatibility;

  // Family Details
  final String fatherOccupation;
  final String motherOccupation;
  final String siblings;
  final String familyType;
  final String familyStatus;

  // Lifestyle
  final String foodPreference;
  final String smoking;
  final String drinking;
  final List<String> hobbies;
  final List<String> languagesKnown;

  PersonModel({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.gender,
    required this.age,
    required this.height,
    required this.religion,
    required this.caste,
    required this.education,
    required this.profession,
    required this.salary,
    required this.city,
    required this.state,
    this.isVerified = true,
    required this.compatibilityScore,
    required this.star,
    required this.rasi,
    required this.lagna,
    required this.dosham,
    required this.birthDate,
    required this.birthTime,
    required this.birthPlace,
    required this.gothram,
    required this.moonSign,
    required this.sunSign,
    required this.dasaBalance,
    required this.chevvaiDosham,
    required this.nadi,
    required this.ganam,
    required this.yoni,
    required this.rajju,
    required this.mahendraPorutham,
    required this.dinaPorutham,
    required this.rasiPorutham,
    required this.overallCompatibility,
    required this.fatherOccupation,
    required this.motherOccupation,
    required this.siblings,
    required this.familyType,
    required this.familyStatus,
    required this.foodPreference,
    required this.smoking,
    required this.drinking,
    required this.hobbies,
    required this.languagesKnown,
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) {
    return PersonModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      gender: json['gender'] ?? '',
      age: json['age'] is int ? json['age'] : int.parse(json['age'].toString()),
      height: json['height'] ?? '',
      religion: json['religion'] ?? '',
      caste: json['caste'] ?? '',
      education: json['education'] ?? '',
      profession: json['profession'] ?? json['occupation'] ?? '',
      salary: json['salary'] ?? json['annualIncome'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      isVerified: json['isVerified'] ?? false,
      compatibilityScore: json['compatibilityScore'] ?? 80,
      star: json['star'] ?? '',
      rasi: json['rasi'] ?? '',
      lagna: json['lagna'] ?? '',
      dosham: json['dosham'] ?? '',
      birthDate: json['birthDate'] ?? '',
      birthTime: json['birthTime'] ?? '',
      birthPlace: json['birthPlace'] ?? '',
      gothram: json['gothram'] ?? '',
      moonSign: json['moonSign'] ?? '',
      sunSign: json['sunSign'] ?? '',
      dasaBalance: json['dasaBalance'] ?? '',
      chevvaiDosham: json['chevvaiDosham'] ?? '',
      nadi: json['nadi'] ?? '',
      ganam: json['ganam'] ?? '',
      yoni: json['yoni'] ?? '',
      rajju: json['rajju'] ?? '',
      mahendraPorutham: json['mahendraPorutham'] ?? '',
      dinaPorutham: json['dinaPorutham'] ?? '',
      rasiPorutham: json['rasiPorutham'] ?? '',
      overallCompatibility: json['overallCompatibility'] ?? '',
      fatherOccupation: json['fatherOccupation'] ?? '',
      motherOccupation: json['motherOccupation'] ?? '',
      siblings: json['siblings'] ?? '',
      familyType: json['familyType'] ?? '',
      familyStatus: json['familyStatus'] ?? '',
      foodPreference: json['foodPreference'] ?? '',
      smoking: json['smoking'] ?? '',
      drinking: json['drinking'] ?? '',
      hobbies: json['hobbies'] is List ? List<String>.from(json['hobbies']) : [],
      languagesKnown: json['languagesKnown'] is List ? List<String>.from(json['languagesKnown']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
      'gender': gender,
      'age': age,
      'height': height,
      'religion': religion,
      'caste': caste,
      'education': education,
      'profession': profession,
      'salary': salary,
      'city': city,
      'state': state,
      'isVerified': isVerified,
      'compatibilityScore': compatibilityScore,
      'star': star,
      'rasi': rasi,
      'lagna': lagna,
      'dosham': dosham,
      'birthDate': birthDate,
      'birthTime': birthTime,
      'birthPlace': birthPlace,
      'gothram': gothram,
      'moonSign': moonSign,
      'sunSign': sunSign,
      'dasaBalance': dasaBalance,
      'chevvaiDosham': chevvaiDosham,
      'nadi': nadi,
      'ganam': ganam,
      'yoni': yoni,
      'rajju': rajju,
      'mahendraPorutham': mahendraPorutham,
      'dinaPorutham': dinaPorutham,
      'rasiPorutham': rasiPorutham,
      'overallCompatibility': overallCompatibility,
      'fatherOccupation': fatherOccupation,
      'motherOccupation': motherOccupation,
      'siblings': siblings,
      'familyType': familyType,
      'familyStatus': familyStatus,
      'foodPreference': foodPreference,
      'smoking': smoking,
      'drinking': drinking,
      'hobbies': hobbies,
      'languagesKnown': languagesKnown,
    };
  }
}

class AppState {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  bool isLoggedIn = false;
  String userRole = 'User';
  final ValueNotifier<String> userName = ValueNotifier<String>('Profile User');
  final ValueNotifier<List<PersonModel>> favorites = ValueNotifier<List<PersonModel>>([]);
  final ValueNotifier<List<PersonModel>> expressions = ValueNotifier<List<PersonModel>>([]);

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    userName.value = prefs.getString('userName') ?? 'Profile User';
    userRole = prefs.getString('userRole') ?? 'User';
    
    // Load favorites by matching stored IDs with ApiService profiles
    final favIds = prefs.getStringList('favorites_ids') ?? [];
    favorites.value = ApiService().profiles.where((p) => favIds.contains(p.id.toString())).toList();
    
    // Load expressions by matching stored IDs with ApiService profiles
    final expIds = prefs.getStringList('expressions_ids') ?? [];
    expressions.value = ApiService().profiles.where((p) => expIds.contains(p.id.toString())).toList();
  }

  Future<void> login(String name, {String role = 'User'}) async {
    isLoggedIn = true;
    userRole = role;
    userName.value = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userName', name);
    await prefs.setString('userRole', role);
  }

  Future<void> logout() async {
    isLoggedIn = false;
    userRole = 'User';
    userName.value = 'Profile User';
    favorites.value = [];
    expressions.value = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = favorites.value.map((p) => p.id.toString()).toList();
    await prefs.setStringList('favorites_ids', ids);
  }

  Future<void> saveExpressions() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = expressions.value.map((p) => p.id.toString()).toList();
    await prefs.setStringList('expressions_ids', ids);
  }

  void toggleFavorite(PersonModel person) {
    final current = List<PersonModel>.from(favorites.value);
    if (current.any((p) => p.id == person.id)) {
      current.removeWhere((p) => p.id == person.id);
    } else {
      current.add(person);
    }
    favorites.value = current;
    saveFavorites();
  }

  bool isFavorite(PersonModel person) {
    return favorites.value.any((p) => p.id == person.id);
  }

  void sendExpression(PersonModel person) {
    final current = List<PersonModel>.from(expressions.value);
    if (!current.any((p) => p.id == person.id)) {
      current.add(person);
      expressions.value = current;
      saveExpressions();
    }
  }

  void removeExpression(PersonModel person) {
    final current = List<PersonModel>.from(expressions.value);
    current.removeWhere((p) => p.id == person.id);
    expressions.value = current;
    saveExpressions();
  }

  bool hasSentExpression(PersonModel person) {
    return expressions.value.any((p) => p.id == person.id);
  }
}
