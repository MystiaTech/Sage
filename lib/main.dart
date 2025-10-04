import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants/app_theme.dart';
import 'data/local/hive_database.dart';
import 'features/home/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (gracefully handle if not configured)
  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('⚠️ Firebase initialization failed: $e');
    print('Household sharing will not work without Firebase configuration.');
    print('See FIREBASE_SETUP.md for setup instructions.');
  }

  // Initialize Hive database
  await HiveDatabase.init();

  runApp(
    const ProviderScope(
      child: SageApp(),
    ),
  );
}

class SageApp extends StatelessWidget {
  const SageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sage 🌿',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // We'll make this dynamic later
      home: const HomeScreen(),
    );
  }
}
