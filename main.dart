

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme.dart';
import 'pages/splash_page.dart';
import 'supabase/supabase_config.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase (non-blocking)
  try {
    await SupabaseConfig.initialize();
    print('App initialized successfully in demo mode');
  } catch (e) {
    print('Supabase initialization failed: $e');
    // Continue running the app anyway
  }
  
  runApp(const SoulSeerApp());
}

class SoulSeerApp extends StatelessWidget {
  const SoulSeerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoulSeer - Spiritual Guidance',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}