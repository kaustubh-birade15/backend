import 'package:flutter/material.dart';
import 'package:mediguide_app/screens/result_screen.dart';

class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {"title": "Cold & Flu", "icon": Icons.sick_outlined, "color": const Color(0xFFFFB3B3), "symptoms": ["cold", "flu", "fever", "cough"]},
      {"title": "Stress & Anxiety", "icon": Icons.spa_outlined, "color": const Color(0xFFD6C8FF), "symptoms": ["stress", "anxiety", "fear", "restlessness"]},
      {"title": "Digestive Issues", "icon": Icons.restaurant_outlined, "color": const Color(0xFFA1D9E7), "symptoms": ["stomach pain", "nausea", "digestion", "bloating"]},
      {"title": "Sleep Problems", "icon": Icons.bed_outlined, "color": const Color(0xFFFFD1A9), "symptoms": ["insomnia", "sleeplessness", "sleep trouble"]},
      {"title": "Skin Complaints", "icon": Icons.health_and_safety_outlined, "color": const Color(0xFFC1E1C1), "symptoms": ["rash", "itching", "eczema", "acne"]},
      {"title": "Headaches & Migraine", "icon": Icons.psychology_outlined, "color": const Color(0xFFF0E68C), "symptoms": ["headache", "migraine", "pulsating pain"]},
      {"title": "Joint & Muscle Pain", "icon": Icons.fitness_center_outlined, "color": const Color(0xFFE6B0AA), "symptoms": ["joint pain", "muscle ache", "stiffness"]},
      {"title": "Emotional Health", "icon": Icons.favorite_outline_rounded, "color": const Color(0xFFFFC0CB), "symptoms": ["sadness", "low mood", "emotional shock"]},
      {"title": "Women's Health", "icon": Icons.woman_rounded, "color": const Color(0xFFD7BDE2), "symptoms": ["menstrual pain", "hormonal balance", "cramps"]},
      {"title": "Children's Health", "icon": Icons.child_care_rounded, "color": const Color(0xFFAED6F1), "symptoms": ["teething", "colic", "mild fever in kids"]},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F2FA),
      appBar: AppBar(
        title: const Text(
          "All Categories",
          style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF3B3B58)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF3B3B58)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 0.85,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultScreen(symptoms: cat["symptoms"]),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cat["color"],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(cat["icon"], color: Colors.black54, size: 30),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      cat["title"],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3B3B58),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
