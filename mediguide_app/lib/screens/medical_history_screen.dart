import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_services.dart';
import '../theme/app_theme.dart';

class MedicalHistoryScreen extends StatefulWidget {
  const MedicalHistoryScreen({super.key});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  final List<String> _commonConditions = [
    "Thyroid",
    "Asthma",
    "Heart Disease",
    "Arthritis",
    "Migraine",
    "Gastric Issues",
    "Anxiety",
    "Cholesterol",
    "Sinusitis",
    "Skin Issues",
    "Fatigue",
  ];

  final List<String> _bloodGroups = ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"];

  final Set<String> _selectedConditions = {};
  String _selectedBloodGroup = "O+";
  bool _isDiabetic = false;
  bool _hasHypertension = false;
  final TextEditingController _otherController = TextEditingController();
  final TextEditingController _allergyController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getInt('patient_id');
      if (patientId == null) return;

      final response = await ApiService.getPatientInfo(patientId);
      final patient = response['patient'] ?? {};
      
      setState(() {
        _selectedBloodGroup = patient['blood_group'] ?? "O+";
        _isDiabetic = patient['diabetic'] ?? false;
        _hasHypertension = patient['bp_high'] ?? false;
        _otherController.text = patient['medical_conditions'] ?? "";
        
        final List<dynamic> conditions = patient['existing_conditions'] ?? [];
        for (var c in conditions) {
          if (_commonConditions.contains(c)) _selectedConditions.add(c);
        }

        final List<dynamic> allergies = patient['allergies'] ?? [];
        _allergyController.text = allergies.join(", ");
      });
    } catch (e) {
      debugPrint("Error loading profile: $e");
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getInt('patient_id');
      final name = prefs.getString('full_name') ?? "Patient";
      final email = prefs.getString('user_email') ?? ""; 
      
      if (patientId == null) throw Exception("User not logged in");

      // Preparing payload as per user's requested Step 1 logic
      final List<String> allergyList = _allergyController.text.split(",").map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      final profileData = {
        "user_id": patientId.toString(),
        "name": name,
        "email": email,
        "age": 25, // Fallback if not stored, usually carried from signup
        "gender": "M", // Usually carried from signup
        "blood_group": _selectedBloodGroup,
        "bp_high": _hasHypertension || _selectedConditions.contains("Hypertension"),
        "diabetic": _isDiabetic || _selectedConditions.contains("Diabetes"),
        "sugar_level": _isDiabetic ? "elevated" : "normal",
        "bp_reading": "",
        "allergies": allergyList,
        "existing_conditions": _selectedConditions.toList(),
        "other_conditions": _otherController.text.trim(),
        "current_medications": []
      };

      // In real app, we use ApiService.register or specialized update
      await ApiService.register(profileData);

      if (!mounted) return;
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Blood Group"),
                  const SizedBox(height: 12),
                  _buildBloodGroupSelector(),
                  
                  const SizedBox(height: 32),
                  _buildSectionTitle("Quick Profile"),
                  const SizedBox(height: 12),
                  _buildSwitchTile("Diabetes", _isDiabetic, (v) => setState(() => _isDiabetic = v)),
                  _buildSwitchTile("Hypertension (High BP)", _hasHypertension, (v) => setState(() => _hasHypertension = v)),

                  const SizedBox(height: 32),
                  _buildSectionTitle("Existing Conditions"),
                  const SizedBox(height: 12),
                  _buildConditionChips(),

                  const SizedBox(height: 32),
                  _buildSectionTitle("Known Allergies"),
                  const SizedBox(height: 12),
                  _buildTextField(_allergyController, "E.g. Pollen, Penicillin, Dust", Icons.warning_amber_rounded),

                  const SizedBox(height: 32),
                  _buildSectionTitle("Additional Notes"),
                  const SizedBox(height: 12),
                  _buildTextField(_otherController, "Any other medical concerns...", Icons.edit_note_rounded, maxLines: 3),

                  const SizedBox(height: 48),
                  _buildSaveButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 40),
      decoration: const BoxDecoration(
        gradient: AppTheme.premiumGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.favorite_rounded, color: Colors.white, size: 60),
          const SizedBox(height: 16),
          const Text(
            "Medical History",
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            "Complete your health profile for better care",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryDark),
    );
  }

  Widget _buildBloodGroupSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _bloodGroups.map((group) {
        final isSelected = _selectedBloodGroup == group;
        return GestureDetector(
          onTap: () => setState(() => _selectedBloodGroup = group),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary : const Color(0xFFF8F8FD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? AppTheme.primary : const Color(0xFFEEEEEE)),
            ),
            child: Text(
              group,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.primaryDark,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FD),
        borderRadius: BorderRadius.circular(15),
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryDark)),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppTheme.primary,
      ),
    );
  }

  Widget _buildConditionChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _commonConditions.map((condition) {
        final isSelected = _selectedConditions.contains(condition);
        return FilterChip(
          label: Text(condition),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedConditions.add(condition);
              } else {
                _selectedConditions.remove(condition);
              }
            });
          },
          selectedColor: AppTheme.primary.withOpacity(0.2),
          checkmarkColor: AppTheme.primary,
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.primary : AppTheme.primaryDark,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
          backgroundColor: const Color(0xFFF8F8FD),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        );
      }).toList(),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8F8FD),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 4,
          shadowColor: AppTheme.primary.withOpacity(0.3),
        ),
        child: _isSaving 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text("Save & Complete", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
      ),
    );
  }
}
