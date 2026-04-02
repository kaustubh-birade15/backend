import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/symptom_screen.dart';
import 'screens/result_screen.dart';
import 'screens/dashboard_screen.dart'; // ✅ FIXED
import 'screens/profile_screen.dart';
import 'screens/educational_screen.dart';
import 'screens/saved_remedies_screen.dart';
import 'screens/medical_history_screen.dart';

void main() {
  runApp(const MediGuideApp());
}

class MediGuideApp extends StatelessWidget {
  const MediGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediGuide AI',
      debugShowCheckedModeBanner: false,

    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF4F2FA), // Soft beige background
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFD6C8FF), // Pastel green primary
        primary: const Color(0xFF8B78E6), // Darker pastel green for contrast
        secondary: const Color(0xFFFFB3B3), // Soft orange
        surface: Colors.white,
        background: const Color(0xFFF4F2FA),
        brightness: Brightness.light,
      ),
      primaryColor: const Color(0xFFD6C8FF),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Color(0xFF3B3B58)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B78E6),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
      ),
    ),

      initialRoute: '/login',

     routes: {
  '/login': (context) => LoginScreen(),
  '/signup': (context) => SignupScreen(),
  '/dashboard': (context) => const DashboardScreen(),
  '/symptoms': (context) => const SymptomScreen(),
  '/profile': (context) => const ProfileScreen(),
  '/learn': (context) => const EducationalScreen(),
  '/saved': (context) => const SavedRemediesScreen(),
  '/medical_history': (context) => const MedicalHistoryScreen(),
},

      onGenerateRoute: (settings) {
        if (settings.name == '/result') {

          // ✅ SAFE extraction
          final args = settings.arguments;

          if (args is List<String>) {
            return MaterialPageRoute(
              builder: (context) => ResultScreen(symptoms: args),
            );
          }

          // ❌ fallback if wrong data
          return MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(child: Text("Invalid data passed")),
            ),
          );
        }

        // ❌ unknown route fallback
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text("Page not found")),
          ),
        );
      },
    );
  }
}