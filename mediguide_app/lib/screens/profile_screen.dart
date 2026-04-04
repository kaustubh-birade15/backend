import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_services.dart';
import '../theme/app_theme.dart';

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
        _patientInfo = info['patient'];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Session Reset Needed"),
            content: const Text("Your local ID does not match the new cloud server. Please log in again to sync your data."),
            actions: [
              TextButton(onPressed: () => _logout(), child: const Text("Log In Now"))
            ],
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    String name = _patientInfo?['name'] ?? "User";
    String email = _patientInfo?['email'] ?? "user@example.com";
    String age = _patientInfo?['age']?.toString() ?? "0";
    String gender = _patientInfo?['gender'] == 'M' || _patientInfo?['gender'] == 'Male' ? "Male" : "Female";
    String conditions = _patientInfo?['medical_conditions'] ?? "No medical conditions listed.";

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Circle Avatar
            Container(
              width: double.infinity,
              height: 280,
              decoration: const BoxDecoration(
                gradient: AppTheme.premiumGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB3B3),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Center(
                      child: Text(
                        name[0].toUpperCase(),
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            
            // Name & Email
            Text(
              name,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.primaryDark),
            ),
            const SizedBox(height: 6),
            Text(
              email,
              style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Account Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryDark),
                  ),
                  const SizedBox(height: 16),
                  
                  // Age & Gender Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildDetailItem(Icons.calendar_month_rounded, "Age", "$age Years", const Color(0xFFF1F0F7)),
                        const Divider(color: Color(0xFFF5F5F5), height: 1),
                        _buildDetailItem(Icons.transgender_rounded, "Gender", gender, const Color(0xFFF1F0F7)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    "Medical Insights",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryDark),
                  ),
                  const SizedBox(height: 16),
                  
                  // Clinical Background Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.assignment_ind_rounded, color: AppTheme.primary, size: 24),
                            SizedBox(width: 12),
                            Text("Clinical Background", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.primaryDark)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          conditions,
                          style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/medical_history').then((_) => _loadProfile()),
                            icon: const Icon(Icons.edit_note_rounded, size: 20),
                            label: const Text("Refine History", style: TextStyle(fontWeight: FontWeight.w800)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primary,
                              side: const BorderSide(color: AppTheme.primary, width: 1.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    "Care Settings",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryDark),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildActionRow(Icons.history_rounded, "Consultation History", () => Navigator.pushNamed(context, '/saved')),
                  _buildActionRow(Icons.lock_rounded, "Change Password", () {}),
                  _buildActionRow(Icons.logout_rounded, "Logout", _logout, isDestructive: true),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String val, Color color) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primaryDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            Icon(icon, color: isDestructive ? Colors.redAccent : AppTheme.primary, size: 24),
            const SizedBox(width: 16),
            Text(title, style: TextStyle(color: isDestructive ? Colors.redAccent : AppTheme.primaryDark, fontWeight: FontWeight.w700, fontSize: 15)),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFE8E5F0)),
          ],
        ),
      ),
    );
  }
}
