import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_services.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final List<bool> _genderSelections = [true, false]; // Male, Female

  void completeIntake() async {
    if (nameController.text.isEmpty ||
        ageController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all sections")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final gender = _genderSelections[0] ? "M" : "F";
      int age = int.tryParse(ageController.text) ?? 0;

      final patientData = {
        "full_name": nameController.text.trim(),
        "age": age,
        "gender": gender,
        "email": emailController.text.trim(),
        "password": passwordController.text,
      };

      final response = await ApiService.register(patientData);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('patient_id', response['id']);
      await prefs.setString('full_name', response['full_name']);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/medical_history');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine layout based on screen width
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Left side (Image and Branding) - Only visible on wider screens
          if (isDesktop)
            Expanded(
              flex: 1,
              child: Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: Image.asset(
                      'assets/doctor.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.blueGrey,
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 50, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Color(0xBB8B78E6), // Semi-transparent blue
                            Color(0xFF8B78E6), // Solid blue at the bottom
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Branding Text at the bottom left
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(48.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Custom Logo representation
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white, width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.medication, color: Colors.white, size: 24),
                                    const SizedBox(width: 4),
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        color: Colors.orangeAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        color: Colors.lightBlueAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Smart Homeo Advisor",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "Empowering Healthcare, One Click at a Time:\nYour Health, Your Records, Your Control.",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),

          // Right side (Signup Form)
          Expanded(
            flex: 1,
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 80.0 : 32.0,
                  vertical: 24.0,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!isDesktop) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: BackButton(
                            color: const Color(0xFF3B3B58),
                            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Small Logo at the top for the form
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF8B78E6), width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.medication, color: Color(0xFF8B78E6), size: 20),
                              const SizedBox(width: 4),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.orangeAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.lightBlueAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Headers
                      const Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF3B3B58), // Dark slate
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Create your new account",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8B8B9E),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Name Field
                      const Text(
                        "Full Name",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4C4C6D)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        decoration: _inputDecoration("Enter your full name"),
                      ),
                      const SizedBox(height: 20),

                      // Age and Gender
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Age",
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4C4C6D)),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: ageController,
                                  keyboardType: TextInputType.number,
                                  decoration: _inputDecoration("Age"),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Gender",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4C4C6D)),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFFE8E5F0)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ToggleButtons(
                                  isSelected: _genderSelections,
                                  onPressed: (int index) {
                                    setState(() {
                                      for (int i = 0; i < _genderSelections.length; i++) {
                                        _genderSelections[i] = i == index;
                                      }
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  selectedColor: Colors.white,
                                  fillColor: const Color(0xFF8B78E6),
                                  color: const Color(0xFF8B8B9E),
                                  constraints: const BoxConstraints(minHeight: 52, minWidth: 60),
                                  children: const [
                                    Text("M", style: TextStyle(fontWeight: FontWeight.w600)),
                                    Text("F", style: TextStyle(fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Email Field
                      const Text(
                        "Email",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4C4C6D)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        decoration: _inputDecoration("Enter your email"),
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      const Text(
                        "Password",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4C4C6D)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        decoration: _inputDecoration("Create a password").copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: const Color(0xFFA6A6C1),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Sign Up Button
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: completeIntake,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B78E6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Log In Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(
                              color: Color(0xFF8B8B9E),
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: const Text(
                              "Log In",
                              style: TextStyle(
                                color: Color(0xFF8B78E6),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFA6A6C1)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE8E5F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE8E5F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF8B78E6), width: 2),
      ),
    );
  }
}