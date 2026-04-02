import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_services.dart';

class MedicalHistoryScreen extends StatefulWidget {
  const MedicalHistoryScreen({super.key});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  final List<String> _commonConditions = [
    "Diabetes / High Sugar",
    "Hypertension / BP",
    "Thyroid Issues",
    "Asthma / Breathing Issues",
    "Heart Condition",
    "Allergies",
    "Kidney Issues",
    "Liver Issues"
  ];

  final Map<String, bool> _selectedConditions = {};
  final TextEditingController _otherController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    for (var condition in _commonConditions) {
      _selectedConditions[condition] = false;
    }
    _loadExistingConditions();
  }

  Future<void> _loadExistingConditions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getInt('patient_id');
      if (patientId == null) return;

      final info = await ApiService.getPatientInfo(patientId);
      final String conditionsStr = info['medical_conditions'] ?? "";
      if (conditionsStr.isNotEmpty) {
        final List<String> conditions = conditionsStr.split(", ");
        setState(() {
          for (var condition in conditions) {
            if (_selectedConditions.containsKey(condition)) {
              _selectedConditions[condition] = true;
            } else if (condition.isNotEmpty) {
              _otherController.text = _otherController.text.isEmpty 
                  ? condition 
                  : "${_otherController.text}, $condition";
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading conditions: $e");
    }
  }

  Future<void> _saveConditions() async {
    setState(() => _isSaving = true);
    try {
      final List<String> selected = [];
      _selectedConditions.forEach((condition, isSelected) {
        if (isSelected) selected.add(condition);
      });
      if (_otherController.text.trim().isNotEmpty) {
        selected.add(_otherController.text.trim());
      }

      final String conditionsStr = selected.join(", ");
      
      final prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getInt('patient_id');
      if (patientId == null) throw Exception("User not logged in");

      await ApiService.updatePatientConditions(patientId, conditionsStr);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Medical history updated successfully!"), backgroundColor: Colors.green),
      );
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text("Medical History", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3B3B58))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Health Profile",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3B3B58)),
            ),
            const SizedBox(height: 8),
            const Text(
              "Please select any existing health conditions you have. This helps us provide more accurate suggestions.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ..._commonConditions.map((condition) {
                    return CheckboxListTile(
                      title: Text(condition, style: const TextStyle(fontWeight: FontWeight.w500)),
                      value: _selectedConditions[condition],
                      activeColor: const Color(0xFF8B78E6),
                      onChanged: (bool? value) {
                        setState(() {
                          _selectedConditions[condition] = value ?? false;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                  const Divider(),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _otherController,
                    decoration: InputDecoration(
                      labelText: "Other conditions (optional)",
                      hintText: "Enter other conditions...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.add_circle_outline, color: Color(0xFF8B78E6)),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveConditions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B78E6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                  shadowColor: const Color(0xFF8B78E6).withOpacity(0.4),
                ),
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("Save & Continue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                child: const Text("Skip for now", style: TextStyle(color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
