import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_theme.dart';
import 'data/local/hive_database.dart';
import 'features/home/screens/home_screen.dart';
import 'features/settings/models/app_settings.dart';

// Provider to watch settings for dark mode
final settingsProvider = StreamProvider<AppSettings>((ref) async* {
  final settings = await HiveDatabase.getSettings();
  yield settings;
  // Listen for changes (this will update when settings change)
  while (true) {
    await Future.delayed(const Duration(milliseconds: 500));
    final updatedSettings = await HiveDatabase.getSettings();
    yield updatedSettings;
  }
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive database
  await HiveDatabase.init();

  // Initialize Supabase (FOSS Firebase alternative!)
  // Cloud-first with optional self-hosting!
  final settings = await HiveDatabase.getSettings();

  // Default to hosted Supabase, or use custom server if configured
  final supabaseUrl = settings.supabaseUrl ?? 'https://pxjvvduzlqediugxyasu.supabase.co';
  final supabaseKey = settings.supabaseAnonKey ??
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB4anZ2ZHV6bHFlZGl1Z3h5YXN1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk2MTUwNjQsImV4cCI6MjA3NTE5MTA2NH0.gPScm4q4PUDDqnFezYRQnVntiqq-glSIwzSWBhQyzwU';

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  if (settings.supabaseUrl != null) {
    print('✅ Using custom Supabase server: ${settings.supabaseUrl}');
  } else {
    print('✅ Using hosted Sage sync server (Supabase FOSS backend)');
  }

  runApp(
    const ProviderScope(
      child: SageApp(),
    ),
  );
}

class SageApp extends ConsumerWidget {
  const SageApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      data: (settings) => MaterialApp(
        title: 'Sage 🌿',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: settings.darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
        home: const HomeScreen(),
      ),
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: Text('Error loading settings')),
        ),
      ),
    );
  }
}
