import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_services.dart';
import '../theme/app_theme.dart';

class ResultScreen extends StatefulWidget {
  final List<String> symptoms;
  final String severity;

  const ResultScreen({super.key, required this.symptoms, this.severity = "moderate"});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with TickerProviderStateMixin {
  Map<String, dynamic>? remedy;
  Map<String, dynamic>? safety;
  bool isLoading = true;
  String error = "";
  String disclaimer = "";
  bool urgent = false;
  String urgentMessage = "";
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    fetchResults();
  }

  Future<void> fetchResults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getInt('patient_id');

      final data = await ApiService.getPrediction(
        widget.symptoms, 
        patientId: patientId,
        severity: widget.severity,
      );
      
      setState(() {
        remedy = data["remedy"] != null ? Map<String, dynamic>.from(data["remedy"]) : null;
        safety = data["patient_safety"] != null ? Map<String, dynamic>.from(data["patient_safety"]) : null;
        disclaimer = data["disclaimer"] ?? "";
        urgent = data["urgent"] ?? false;
        urgentMessage = data["urgent_message"] ?? "";
        isLoading = false;
      });
    } catch (e) {
      if(mounted) setState(() { error = e.toString(); isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24), onPressed: () => Navigator.pop(context)),
        title: const Text("Analysis Result", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(_isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: Colors.white), onPressed: () => setState(() => _isSaved = !_isSaved)),
        ],
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 10),
        decoration: const BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(45), topRight: Radius.circular(45)),
        ),
        child: isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : error.isNotEmpty 
            ? _buildErrorView() 
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (remedy == null) return const Center(child: Text("No remedy found."));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Align items to center
        children: [
          if (urgent) _buildStaggered(0, _buildUrgentBadge()),
          
          _buildStaggered(1, _buildMainRemedyCard()),
          
          const SizedBox(height: 32),
          _buildStaggered(2, _buildSafetyAnalysis()),

          const SizedBox(height: 32),
          _buildStaggered(3, _buildInfoBlock("Why this Remedy?", remedy!["why_this_remedy"], Icons.lightbulb_outline_rounded)),

          const SizedBox(height: 24),
          _buildStaggered(4, _buildInfoBlock("Key Indications", remedy!["keynote"], Icons.list_alt_rounded)),

          const SizedBox(height: 32),
          Center(
            child: Text(
              "Source: ${remedy!["source_book"]}",
              style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Return to Dashboard", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildStaggered(int index, Widget child) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 700 + (index * 120)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.8 + (0.2 * value),
            alignment: Alignment.topCenter,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildMainRemedyCard() {
    return Column(
      children: [
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.12), blurRadius: 40, offset: const Offset(0, 10))]),
                child: const Icon(Icons.water_drop_rounded, size: 65, color: AppTheme.primary),
              ),
            );
          }
        ),
        const SizedBox(height: 24),
        Text(remedy!["name"], style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.primaryDark)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Text(remedy!["potency"], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primary)),
        ),
        const SizedBox(height: 12),
        Text(remedy!["possible_condition"], style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildSafetyAnalysis() {
    bool isSafe = safety?["is_safe"] ?? true;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isSafe ? const Color(0xFFE8F5E9).withOpacity(0.5) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: isSafe ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isSafe ? Icons.check_circle_rounded : Icons.health_and_safety_rounded, color: isSafe ? Colors.green : Colors.red),
              const SizedBox(width: 12),
              Text(isSafe ? "Safety Profile: Perfect" : "Safety Alert", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isSafe ? Colors.green[900] : Colors.red[900])),
            ],
          ),
          const SizedBox(height: 16),
          ...(safety?["warnings"] as List<dynamic>? ?? []).map((w) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(w.toString(), style: TextStyle(fontSize: 14, height: 1.5, color: isSafe ? Colors.green[800] : Colors.red[900], fontWeight: FontWeight.w500)),
          )),
          const Divider(height: 32),
          _safetyRow("BP Consideration", safety?["bp_note"]),
          const SizedBox(height: 8),
          _safetyRow("Sugar Consideration", safety?["diabetes_note"]),
        ],
      ),
    );
  }

  Widget _safetyRow(String label, String? val) {
    if (val == null || val.isEmpty) return const SizedBox.shrink();
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppTheme.primaryDark)),
      Expanded(child: Text(val, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary))),
    ]);
  }

  Widget _buildInfoBlock(String title, String? text, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Keep titles to the start of the section
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primaryDark)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Text(
            text ?? "No information available.",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, height: 1.7, color: AppTheme.textMain, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildUrgentBadge() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.red[800], borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.2), blurRadius: 15)]),
      child: Row(children: [const Icon(Icons.medical_services_rounded, color: Colors.white), const SizedBox(width: 16), Expanded(child: Text(urgentMessage, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)))]),
    );
  }

  Widget _buildErrorView() {
    return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.cloud_off_rounded, size: 80, color: Color(0xFFFFCCBC)), const SizedBox(height: 24), Text(error, textAlign: TextAlign.center), const SizedBox(height: 32), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary), onPressed: fetchResults, child: const Text("Retry"))])));
  }
}