import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mediguide_app/screens/all_categories_screen.dart';
import 'package:mediguide_app/screens/result_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_services.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String _patientName = "Guest";
  bool _needsHistory = false;

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    final prefs = await SharedPreferences.getInstance();
    final patientId = prefs.getInt('patient_id');
    
    setState(() {
      _patientName = prefs.getString('full_name')?.split(' ').first ?? "Guest";
    });

    if (patientId != null) {
      try {
        final info = await ApiService.getPatientInfo(patientId);
        if (info['medical_conditions'] == null || info['medical_conditions'].isEmpty) {
          setState(() => _needsHistory = true);
        } else {
          setState(() => _needsHistory = false);
        }
      } catch (e) {
        debugPrint("Error checking profile status: $e");
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning,";
    if (hour < 17) return "Good Afternoon,";
    if (hour < 21) return "Good Evening,";
    return "Good Night,";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Let content scroll behind the floating nav bar
      backgroundColor: const Color(0xFFF4F2FA), // Beige background
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: 100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8B8B9E),
                        ),
                      ),
                      Text(
                        _patientName,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF3B3B58),
                        ),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFFFFB3B3), // Soft Orange
                    child: Icon(
                      Icons.face_retouching_natural,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              if (_needsHistory)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7E6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFE0B2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Complete your health profile",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const Text(
                              "Adding medical conditions helps provide safer recommendations.",
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/medical_history').then((_) => _loadPatientData()),
                        child: const Text("Set Up"),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 10),

              // MAIN ACTION CARD
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/symptoms');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6C8FF), // Pastel Green
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD6C8FF).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF3B3B58),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Analyze Symptoms",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3B3B58),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Describe what you're feeling, let AI find the right remedy.",
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF4C4C6D),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 35),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Quick Categories",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF3B3B58),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllCategoriesScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "See All",
                      style: TextStyle(
                        color: Color(0xFF8B78E6),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // GRID CARDS with rounded friendly illustrations
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCategoryCard(
                    context,
                    Icons.sick_outlined,
                    "Cold &\nFlu",
                    const Color(0xFFFFB3B3),
                  ),
                  _buildCategoryCard(
                    context,
                    Icons.spa_outlined,
                    "Stress &\nAnxiety",
                    const Color(0xFFD6C8FF),
                  ),
                  _buildCategoryCard(
                    context,
                    Icons.restaurant_outlined,
                    "Digestive\nIssues",
                    const Color(0xFFA1D9E7),
                  ),
                  _buildCategoryCard(
                    context,
                    Icons.bed_outlined,
                    "Sleep\nProblems",
                    const Color(0xFFFFD1A9),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              const Text(
                "Homeopathy Basics",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3B3B58),
                ),
              ),

              const SizedBox(height: 16),

              // Educational Card Mockup
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/learn');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F2FA),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.book_rounded,
                          color: Color(0xFFE6B0AA),
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "What is Homeopathy?",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF3B3B58),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Learn the core principles of alternative gentle medicine.",
                              style: TextStyle(
                                color: Color(0xFF8B8B9E),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                if (index == 1) {
                  Navigator.pushNamed(context, '/symptoms');
                } else if (index == 2) {
                  Navigator.pushNamed(context, '/saved');
                } else if (index == 3) {
                  Navigator.pushNamed(context, '/learn');
                } else if (index == 4) {
                  Navigator.pushNamed(context, '/profile');
                } else {
                  setState(() => _selectedIndex = index);
                }
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF8B78E6),
              unselectedItemColor: const Color(0xFFA6A6C1),
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded, size: 26),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search_rounded, size: 26),
                  label: "Symptoms",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bookmark_rounded, size: 26),
                  label: "Saved",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.school_rounded, size: 26),
                  label: "Learn",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded, size: 26),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        final Map<String, List<String>> categorySymptoms = {
          "Cold &\nFlu": ["cold", "flu", "fever", "cough"],
          "Stress &\nAnxiety": ["stress", "anxiety", "fear", "restlessness"],
          "Digestive\nIssues": ["stomach pain", "nausea", "digestion", "bloating"],
          "Sleep\nProblems": ["insomnia", "sleeplessness", "sleep trouble"],
        };

        final symptoms = categorySymptoms[title] ?? [title.replaceAll('\n', ' ')];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(symptoms: symptoms),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.black54, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3B3B58),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
