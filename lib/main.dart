import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PrivacyQRApp());
}

class PrivacyQRApp extends StatelessWidget {
  const PrivacyQRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Privacy QR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8), // Light Blue
          secondary: Color(0xFF34D399), // Emerald
          surface: Color(0xFF1E293B), // Slate 800
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
