import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _patientInfo;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getInt('patient_id');
      if (patientId == null) throw Exception("User not logged in");

      final info = await ApiService.getPatientInfo(patientId);
      setState(() {
        _patientInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading profile: $e")));
        setState(() => _isLoading = false);
      }
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _showFeedbackDialog() {
    final feedbackController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Provide Feedback"),
        content: TextField(
          controller: feedbackController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "How can we improve Smart Homeo Advisor?",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Feedback submitted successfully!")));
            },
            child: const Text("Submit"),
          ),
        ],
      )
    );
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        bool isChanging = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Change Password"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: oldPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Old Password", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "New Password", border: OutlineInputBorder()),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isChanging ? null : () async {
                    if (oldPasswordController.text.isEmpty || newPasswordController.text.isEmpty) return;
                    setDialogState(() => isChanging = true);
                    try {
                      final prefs = await SharedPreferences.getInstance();
                      final patientId = prefs.getInt('patient_id') ?? 0;
                      await ApiService.changePassword(patientId, oldPasswordController.text.trim(), newPasswordController.text.trim());
                      if (!mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password changed successfully")));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                      );
                      setDialogState(() => isChanging = false);
                    }
                  },
                  child: isChanging ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Save"),
                ),
              ],
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3B3B58))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF3B3B58)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B78E6))) 
        : _patientInfo == null 
          ? const Center(child: Text("Could not load profile"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFFFFB3B3),
                      child: Text(
                        _patientInfo!['full_name'][0].toUpperCase(),
                        style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoTile("Full Name", _patientInfo!['full_name'], Icons.person_outline),
                  _buildInfoTile("Email", _patientInfo!['email'], Icons.email_outlined),
                  _buildInfoTile("Age", "${_patientInfo!['age']} Years", Icons.calendar_today_outlined),
                  _buildInfoTile("Gender", _patientInfo!['gender'] == 'M' ? "Male" : "Female", Icons.transgender_outlined),
                  const SizedBox(height: 24),
                  const Text("Medical History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3B3B58))),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EFFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (_patientInfo!['medical_conditions'] == null || _patientInfo!['medical_conditions'].isEmpty)
                            ? "No medical conditions listed."
                            : _patientInfo!['medical_conditions'],
                          style: const TextStyle(fontSize: 14, color: Color(0xFF3B3B58)),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/medical_history').then((_) => _loadProfile()),
                          icon: const Icon(Icons.edit_note, size: 18),
                          label: const Text("Edit History"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF8B78E6),
                            side: const BorderSide(color: Color(0xFF8B78E6)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text("Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3B3B58))),
                  const SizedBox(height: 16),
                  _buildActionTile("Change Password", Icons.lock_outline, _showChangePasswordDialog),
                  _buildActionTile("Provide Feedback", Icons.feedback_outlined, _showFeedbackDialog),
                  _buildActionTile("Logout", Icons.logout, _logout, isDestructive: true),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF8B78E6)),
      title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, color: Color(0xFF3B3B58), fontWeight: FontWeight.w600)),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionTile(String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.withOpacity(0.1) : const Color(0xFFF3EFFF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: isDestructive ? Colors.red : const Color(0xFF8B78E6)),
      ),
      title: Text(
        title, 
        style: TextStyle(
          color: isDestructive ? Colors.red : const Color(0xFF3B3B58), 
          fontWeight: FontWeight.w600
        )
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}
