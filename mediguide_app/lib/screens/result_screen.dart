import 'package:flutter/material.dart';
import 'package:mediguide_app/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResultScreen extends StatefulWidget {
  final List<String> symptoms;

  const ResultScreen({super.key, required this.symptoms});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List<Map<String, dynamic>> results = [];
  bool isLoading = true;
  String error = "";
  String disclaimer = "";

  bool urgent = false;
  String urgentMessage = "";
  List<String> urgentSymptoms = [];
  bool _isSaved = false;
  String medicalConditions = "";

  @override
  void initState() {
    super.initState();
    fetchResults();
  }

  Future<void> fetchResults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getInt('patient_id');

      final Map<String, dynamic> data = await ApiService.getPrediction(widget.symptoms, patientId: patientId);
      
      final List<dynamic> predictionsRaw = data["predictions"] as List<dynamic>? ?? [];
      final List<Map<String, dynamic>> parsedResults = predictionsRaw
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

      setState(() {
        results = parsedResults;
        disclaimer = data["disclaimer"] as String? ?? "";
        urgent = data["urgent"] as bool? ?? false;
        urgentMessage = data["urgent_message"] as String? ?? "";
        
        final List<dynamic> urgentSymptomsRaw = data["urgent_symptoms"] as List<dynamic>? ?? [];
        urgentSymptoms = urgentSymptomsRaw.map((item) => item.toString()).toList();
        medicalConditions = data["medical_conditions"] as String? ?? "";
        
        isLoading = false;
      });
    } catch (e) {
      if(mounted) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F2FA),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF8B78E6))),
      );
    }
    if (error.isNotEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F2FA),
        appBar: AppBar(title: const Text("Error", style: TextStyle(color: Color(0xFF3B3B58)))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 60),
                const SizedBox(height: 16),
                Text(error, style: const TextStyle(color: Color(0xFFEF5350)), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                      error = "";
                    });
                    fetchResults();
                  },
                  child: const Text("Retry Connection"),
                )
              ]
            ),
          )
        ),
      );
    }

    if (results.isEmpty && !urgent) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F2FA),
        appBar: AppBar(title: const Text("Results")),
        body: const Center(child: Text("No specific remedies found for your input.")),
      );
    }

    final topResult = results.isNotEmpty ? results.first : null;
    final alternatives = results.length > 1 ? results.sublist(1) : [];

    return Scaffold(
      backgroundColor: const Color(0xFF8B78E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const CloseButton(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {
              setState(() => _isSaved = !_isSaved);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_isSaved ? "Remedy saved to Profile!" : "Removed from saved.")),
              );
            },
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 15),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        decoration: const BoxDecoration(
          color: Color(0xFFF4F2FA),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(36),
            topRight: Radius.circular(36),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (urgent) _buildUrgentCard(),
              if (medicalConditions.isNotEmpty) _buildMedicalContextCard(),

              if (topResult != null) ...[
                // Big Icon centered
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF3EFFF),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B78E6).withValues(alpha: 0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    // Adding a friendly illustration look
                    child: const Icon(Icons.medication_liquid_rounded, size: 70, color: Color(0xFF8B78E6)),
                  ),
                ),

                const SizedBox(height: 30),

                // Title
                Center(
                  child: Text(
                    topResult["remedy"]?.toString() ?? "Unknown",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF3B3B58),
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 4),
                // Subtitle
                Center(
                  child: Text(
                    topResult["condition"]?.toString() ?? "Homeopathic Protocol",
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF8B8B9E),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 30),

                // Two Info Cards
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 4))
                          ]
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.analytics_rounded, color: Color(0xFF8B78E6), size: 22),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${topResult["score"]?.toString() ?? "0"}%",
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF3B3B58)),
                                ),
                                const Text("Confidence Level", style: TextStyle(color: Color(0xFF8B8B9E), fontSize: 12, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 4))
                          ]
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.water_drop_rounded, color: Color(0xFFFFB3B3), size: 22),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "30C",
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF3B3B58)),
                                ),
                                const Text("Standard Dilution", style: TextStyle(color: Color(0xFF8B8B9E), fontSize: 12, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                // Remedy Detail Page content
                const Text(
                  "Remedy Overview",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF3B3B58)),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topResult["description"]?.toString() ?? "A gentle homeopathic remedy.",
                        style: const TextStyle(fontSize: 15, color: Color(0xFF5D6D7E), height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.psychology_outlined, color: Color(0xFFC44D7C), size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Matched symptom: ${topResult["matched_symptoms"]?.first ?? "Unknown"}",
                                style: const TextStyle(fontSize: 13, color: Color(0xFF9B3A60), fontWeight: FontWeight.w600),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Check Alternatives
                if (alternatives.isNotEmpty) ...[
                  const Text(
                    "Related Remedies",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF3B3B58)),
                  ),
                  const SizedBox(height: 16),
                  ...alternatives.map((alt) => _buildAlternativeCard(alt)),
                ],

                const SizedBox(height: 25),
                if (disclaimer.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE8E5F0)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFF8B8B9E), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            disclaimer,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8B8B9E),
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 35),

                // Bottom Action Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B3B58), // High contrast dark for primary finish button
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Return to Home",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUrgentCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFB3B3))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.report_problem_rounded, color: Color(0xFFEF5350), size: 28),
              SizedBox(width: 10),
              Text(
                "Immediate Attention Needed",
                style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            urgentMessage.isNotEmpty ? urgentMessage : "Please consult a medical professional immediately.",
            style: const TextStyle(color: Color(0xFFEF5350), fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalContextCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD6C8FF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF8B78E6), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Based on your Medical History:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF3B3B58)),
                ),
                const SizedBox(height: 4),
                Text(
                  medicalConditions,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF5D6D7E)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeCard(Map<String, dynamic> alt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF3EFFF),
            ),
            child: const Icon(Icons.eco_rounded, color: Color(0xFF8B78E6), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alt["remedy"]?.toString() ?? "Alternative",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF3B3B58)),
                ),
                const SizedBox(height: 4),
                Text(
                  "${alt["score"]}% match confidence",
                  style: const TextStyle(fontSize: 13, color: Color(0xFF8B8B9E), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFE8E5F0), size: 16)
        ],
      ),
    );
  }
}