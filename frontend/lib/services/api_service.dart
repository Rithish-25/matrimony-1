import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/person_model.dart';

import 'package:flutter/foundation.dart';

class ApiService {
  // Use localhost for web browsers (Chrome/Edge), and 10.0.2.2 loopback for Android emulators
  static const String baseUrl = kIsWeb
      ? 'http://localhost:5000/api'
      : 'http://10.0.2.2:5000/api';

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;
  String? get token => _token;
  List<PersonModel> profiles = [];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
  }

  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // --- AUTH APIS ---

  Future<Map<String, dynamic>> login(String emailOrPhone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'emailOrPhone': emailOrPhone,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        await _saveToken(data['token']);
        return {'success': true, 'user': data['user']};
      }
      return {'success': false, 'message': data['message'] ?? 'Login failed'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> signup({
    required String fullName,
    String? email,
    required String mobile,
    required String password,
    String? role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          if (email != null && email.isNotEmpty) 'email': email,
          'mobile': mobile,
          'password': password,
          if (role != null) 'role': role,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data['success'] == true) {
        await _saveToken(data['token']);
        return {'success': true, 'user': data['user']};
      }
      return {'success': false, 'message': data['message'] ?? 'Signup failed'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: ${e.toString()}'};
    }
  }

  // --- PROFILE APIS ---

  Future<List<PersonModel>> fetchProfiles({
    String? gender,
    String? religion,
    String? profession,
    String? age,
  }) async {
    try {
      final queryParams = <String, String>{
        if (gender != null) 'gender': gender,
        if (religion != null && religion != 'All') 'religion': religion,
        if (profession != null && profession != 'All') 'profession': profession,
        if (age != null && age != 'All') 'age': age,
      };

      final uri = Uri.parse('$baseUrl/profiles').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _getHeaders());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          final list = data['data'] as List;
          return list.map((item) => PersonModel.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Fetch profiles error: $e');
      return [];
    }
  }

  // --- ADMIN CRUD APIS ---

  Future<Map<String, dynamic>> fetchAdminStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/dashboard'),
        headers: _getHeaders(),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'stats': data['data']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to load statistics'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> createProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/profile'),
        headers: _getHeaders(),
        body: jsonEncode(profileData),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data['success'] == true) {
        return {'success': true, 'data': PersonModel.fromJson(data['data'])};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to create profile'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateProfile(int id, Map<String, dynamic> profileData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/profile/$id'),
        headers: _getHeaders(),
        body: jsonEncode(profileData),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': PersonModel.fromJson(data['data'])};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to update profile'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteProfile(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/profile/$id'),
        headers: _getHeaders(),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to delete profile'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<List<String>> uploadImages(List<File> images) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/admin/upload'));
      request.headers.addAll(_getHeaders());

      for (var file in images) {
        request.files.add(
          await http.MultipartFile.fromPath('images', file.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true && data['urls'] is List) {
        return List<String>.from(data['urls']);
      }
      return [];
    } catch (e) {
      print('Upload images error: $e');
      return [];
    }
  }

  Future<void> loadProfiles() async {
    try {
      await init();
      final list = await fetchProfiles();
      profiles = list;
      print('Successfully loaded ${profiles.length} profiles from MongoDB.');
    } catch (e) {
      print('Failed to load profiles from Node.js backend. Error: $e');
      profiles = [];
    }
  }
}
