import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_services.dart';
import '../theme/app_theme.dart';

class SavedRemediesScreen extends StatefulWidget {
  const SavedRemediesScreen({super.key});

  @override
  State<SavedRemediesScreen> createState() => _SavedRemediesScreenState();
}

class _SavedRemediesScreenState extends State<SavedRemediesScreen> {
  bool _isLoading = true;
  List<dynamic> _historyRecords = [];
  String _error = "";

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getInt('patient_id');
      if (patientId == null) throw Exception("Please log in to view history.");

      final data = await ApiService.getHistory(patientId);
      setState(() {
        _historyRecords = data['history'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if(mounted) {
        setState(() {
          _error = e.toString().replaceAll("Exception: ", "");
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 40, left: 24, right: 24),
            decoration: const BoxDecoration(
              gradient: AppTheme.premiumGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Icon(Icons.history_rounded, color: Colors.white, size: 28),
                    const SizedBox(width: 48), // Spacer
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Medical History",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              : _historyRecords.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: _historyRecords.length,
                      itemBuilder: (context, index) {
                        return _buildHistoryCard(_historyRecords[index]);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today_outlined, size: 80, color: Color(0xFFE8E5F0)),
          const SizedBox(height: 16),
          const Text("No records yet", style: TextStyle(fontSize: 18, color: AppTheme.primaryDark, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text("Start an analysis to see your history.", style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/symptoms'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text("Analyze Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> record) {
    String remedy = record['remedy_name'] ?? "No Remedy";
    String condition = record['condition'] ?? "General Support";
    String symptoms = record['symptom'] ?? "N/A";
    String date = "Unknown Date";

    try {
      if (record['created_at'] != null) {
        DateTime dt = DateTime.parse(record['created_at']);
        date = "${dt.day}/${dt.month}/${dt.year} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
      }
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Upper Area
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F0FF),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppTheme.primary, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      remedy,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppTheme.primaryDark),
                    ),
                  ],
                ),
                Text(
                  date,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),

          // Card Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("AI Recommended Profile", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF5D5D7E))),
                const SizedBox(height: 4),
                Text(condition, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                
                const SizedBox(height: 20),
                const Text("Reported Symptoms", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 12),
                
                // Symptom Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: symptoms.split(", ").map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F0F7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(s, style: const TextStyle(fontSize: 12, color: AppTheme.primaryDark, fontWeight: FontWeight.w700)),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
