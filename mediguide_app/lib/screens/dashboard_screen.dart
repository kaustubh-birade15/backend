import 'package:flutter/material.dart';
import 'package:mediguide_app/screens/all_categories_screen.dart';
import 'package:mediguide_app/screens/result_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_services.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  String _patientName = "User";
  bool _needsHistory = false;
  late AnimationController _mainController;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _loadPatientData();
    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
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
    if (hour < 12) return "Good Morning, ☀️";
    if (hour < 17) return "Good Afternoon, 🌤️";
    if (hour < 21) return "Good Evening, 🌜";
    return "Good Night, 🌙";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStaggered(0, _buildHeader()),
              const SizedBox(height: 32),
              if (_needsHistory) _buildStaggered(1, _buildSafetyWarning()),
              const SizedBox(height: 24),
              _buildStaggered(2, _buildMainActionCard()),
              const SizedBox(height: 48),
              _buildStaggered(3, _buildCategoriesHeader()),
              const SizedBox(height: 16),
              _buildStaggered(4, _buildCategoriesGrid()),
              const SizedBox(height: 40),
              _buildStaggered(5, _buildInsightsSection()),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildStaggered(int index, Widget child) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 150)),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getGreeting(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
            const SizedBox(height: 4),
            Text(_patientName, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.primaryDark)),
          ],
        ),
        _buildAvatar(),
      ],
    );
  }

  Widget _buildAvatar() {
    return Hero(
      tag: 'profile_avatar',
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 2)),
        child: CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFFE8E5FF),
          child: const Icon(Icons.person_rounded, color: AppTheme.primary, size: 30),
        ),
      ),
    );
  }

  Widget _buildSafetyWarning() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAEE),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFE0B2).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_rounded, color: Color(0xFFFFA726), size: 32),
          const SizedBox(width: 16),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Complete Health Profile", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF3B3B58))),
            SizedBox(height: 4),
            Text("Unlock safer remedy matching.", style: TextStyle(fontSize: 12, color: Color(0xFF8B8B9E))),
          ])),
          IconButton(onPressed: () => Navigator.pushNamed(context, '/medical_history').then((_) => _loadPatientData()), icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFFFA726))),
        ],
      ),
    );
  }

  Widget _buildMainActionCard() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/symptoms'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: AppTheme.premiumGradient,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 12))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.auto_fix_high_rounded, color: Colors.white, size: 30)),
            const SizedBox(height: 24),
            const Text("Analyze New Symptoms", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 8),
            Text("Smart AI-driven homeopathic diagnosis.", style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Explore Categories", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.primaryDark)),
        TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AllCategoriesScreen())), child: const Text("See All", style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w800))),
      ],
    );
  }

  Widget _buildCategoriesGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCatItem(context, Icons.ac_unit_rounded, "Cold & Flu", const Color(0xFFF3F0FF)),
        _buildCatItem(context, Icons.psychology_rounded, "Anxiety", const Color(0xFFE8E5FF)),
        _buildCatItem(context, Icons.restaurant_rounded, "Digestive", const Color(0xFFFFF7EE)),
      ],
    );
  }

  Widget _buildInsightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Learn Homeopathy", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.primaryDark)),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildLearnTile("Holistic Healing", "Understanding dynamic force.", Icons.eco_rounded, const Color(0xFFF1FDF5)),
              const SizedBox(width: 16),
              _buildLearnTile("Potency Guide", "What 30C vs 200C means.", Icons.auto_graph_rounded, const Color(0xFFF3F0FF)),
              const SizedBox(width: 16),
              _buildLearnTile("Safety First", "Homeopathy & other drugs.", Icons.health_and_safety_rounded, const Color(0xFFFFF1F1)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLearnTile(String title, String sub, IconData icon, Color color) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFF1F0F7))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color, shape: BoxShape.circle), child: Icon(icon, color: AppTheme.primary, size: 20)),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.primaryDark)),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary), maxLines: 2),
        ],
      ),
    );
  }

  Widget _buildCatItem(BuildContext context, IconData icon, String title, Color color) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ResultScreen(symptoms: [title]))),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.28,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Column(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color, shape: BoxShape.circle), child: Icon(icon, color: AppTheme.primary, size: 24)),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.primaryDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navIcon(Icons.home_rounded, "Home", true),
          _navIcon(Icons.search_rounded, "Find", false, onTap: () => Navigator.pushNamed(context, '/symptoms')),
          _navIcon(Icons.bookmark_rounded, "Saved", false, onTap: () => Navigator.pushNamed(context, '/saved')),
          _navIcon(Icons.school_rounded, "Learn", false, onTap: () => Navigator.pushNamed(context, '/learn')),
          _navIcon(Icons.person_rounded, "Profile", false, onTap: () => Navigator.pushNamed(context, '/profile')),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, String label, bool isSelected, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? AppTheme.primary : const Color(0xFFBDBDBD), size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppTheme.primary : const Color(0xFFBDBDBD))),
        ],
      ),
    );
  }
}
