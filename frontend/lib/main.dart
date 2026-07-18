import 'package:flutter/material.dart';
import 'app.dart';
import 'models/person_model.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppState().loadFromPrefs();
  await ApiService().loadProfiles();
  runApp(const SoulmateApp());
}
