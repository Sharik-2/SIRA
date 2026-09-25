import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

const supabaseUrl = 'https://cjmcclkbsdejskzusnld.supabase.co';
const supabasePublishableKey = 'sb_publishable_yKWeeXBzJvg8A-BH-lApEQ_KXrvSiV8';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  runApp(const SiraApp());
}

final supabase = Supabase.instance.client;

class SiraApp extends StatelessWidget {
  const SiraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIRA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
        scaffoldBackgroundColor: const Color(0xFFF6F8FA),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0F766E), width: 2),
          ),
        ),
      ),
      home: supabase.auth.currentSession == null
          ? const LoginScreen()
          : const HomeScreen(),
    );
  }
}
