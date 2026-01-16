import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_hike/core/services/hive/hive_service.dart';
import 'package:just_hike/core/services/storage/user_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService().init();

  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
      child: const App(),
    ),
  );
}
