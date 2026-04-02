import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_services.dart';

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
      if (patientId == null) throw Exception("Please log in to view saved history.");

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
      backgroundColor: const Color(0xFFF4F2FA),
      appBar: AppBar(
        title: const Text("Medical History", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3B3B58))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF3B3B58)),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B78E6)))
        : _error.isNotEmpty
            ? Center(child: Text(_error, style: const TextStyle(color: Colors.red)))
            : _historyRecords.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.history_rounded, size: 80, color: Color(0xFFE8E5F0)),
                        SizedBox(height: 16),
                        Text("No analysis history found.", style: TextStyle(fontSize: 16, color: Color(0xFFA6A6C1), fontWeight: FontWeight.bold)),
                        Text("Search for symptoms to build your record.", style: TextStyle(fontSize: 13, color: Color(0xFFA6A6C1))),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _historyRecords.length,
                    itemBuilder: (context, index) {
                      final record = _historyRecords[index];
                      return _buildRecordCard(record);
                    },
                  ),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> record) {
    final List<dynamic> symptoms = record['symptoms'] ?? [];
    final List<dynamic> predictions = record['predictions'] ?? [];
    String topRemedy = "No Remedy Found";
    String description = "";
    if (predictions.isNotEmpty) {
      topRemedy = predictions[0]['remedy'] ?? topRemedy;
      description = predictions[0]['condition'] ?? "";
    }

    // Format Timestamp
    String formattedTime = "Unknown Date";
    try {
      if (record['timestamp'] != null) {
        DateTime dt = DateTime.parse(record['timestamp']);
        formattedTime = "${dt.day}/${dt.month}/${dt.year} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
      }
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF3EFFF),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.water_drop_rounded, color: Color(0xFF8B78E6), size: 20),
                    const SizedBox(width: 8),
                    Text(topRemedy, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3B3B58))),
                  ],
                ),
                Text(formattedTime, style: const TextStyle(fontSize: 12, color: Color(0xFF8B8B9E), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (description.isNotEmpty) ...[
                  Text(description, style: const TextStyle(fontSize: 13, color: Color(0xFF8B8B9E))),
                  const SizedBox(height: 12),
                ],
                const Text("Reported Symptoms:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF3B3B58))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: symptoms.map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F2FA),
                      border: Border.all(color: const Color(0xFFE8E5F0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(s.toString(), style: const TextStyle(fontSize: 12, color: Color(0xFF4C4C6D))),
                  )).toList(),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
