import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';

class SymptomScreen extends StatefulWidget {
  const SymptomScreen({super.key});

  @override
  State<SymptomScreen> createState() => _SymptomScreenState();
}

class _SymptomScreenState extends State<SymptomScreen> {
  final symptomController = TextEditingController();
  final List<String> symptoms = [];
  final ImagePicker _picker = ImagePicker();
  bool _isProcessingOCR = false;
  String _selectedSeverity = "moderate"; // Default

  final List<Map<String, dynamic>> _commonSymptoms = [
    {"name": "Headache", "icon": Icons.sentiment_dissatisfied_outlined, "color": const Color(0xFFFDE8E8)},
    {"name": "Cold", "icon": Icons.ac_unit_rounded, "color": const Color(0xFFF3F0FF)},
    {"name": "Anxiety", "icon": Icons.favorite_border_rounded, "color": const Color(0xFFE8EAF6)},
    {"name": "Digestion", "icon": Icons.restaurant_menu_rounded, "color": const Color(0xFFFFF3E0)},
  ];

  Future<void> scanSymptomWithOCR() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) return;
      setState(() => _isProcessingOCR = true);

      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      String scannedText = recognizedText.text.trim();
      if (scannedText.isNotEmpty) {
        setState(() {
          final s = scannedText.replaceAll('\n', ', ');
          symptomController.text = symptomController.text.isEmpty ? s : "${symptomController.text}, $s";
        });
      }
      textRecognizer.close();
    } catch (e) {
      debugPrint("OCR Error: $e");
    } finally {
      if (mounted) setState(() => _isProcessingOCR = false);
    }
  }

  void addSymptom(String symptomString) {
    if (symptomString.isEmpty || symptoms.contains(symptomString)) return;
    setState(() {
      symptoms.add(symptomString);
      symptomController.clear();
    });
  }

  void getResult() {
    final text = symptomController.text.trim();
    List<String> finalSymptoms = List.from(symptoms);
    if (text.isNotEmpty && !finalSymptoms.contains(text)) finalSymptoms.add(text);

    if (finalSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please describe symptoms.")));
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => ResultScreen(symptoms: finalSymptoms, severity: _selectedSeverity)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnimatedTile(0, const Text("Common Searches", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primaryDark))),
                  const SizedBox(height: 16),
                  _buildAnimatedTile(1, _buildCommonList()),

                  const SizedBox(height: 32),
                  _buildAnimatedTile(2, const Text("Symptom Severity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primaryDark))),
                  const SizedBox(height: 12),
                  _buildAnimatedTile(3, _buildSeveritySelector()),

                  const SizedBox(height: 32),
                  _buildAnimatedTile(4, _buildSearchCard()),

                  const SizedBox(height: 24),
                  if (symptoms.isNotEmpty) _buildAnimatedTile(5, _buildSelectedList()),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAnimatedTile(int index, Widget child) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 120)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(opacity: value, child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child)),
      child: child,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 40, left: 16, right: 16),
      decoration: const BoxDecoration(gradient: AppTheme.premiumGradient, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40))),
      child: Column(
        children: [
          Row(children: [IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)), const Spacer(), const Icon(Icons.medication_rounded, color: Colors.white), const SizedBox(width: 48)]),
          const Text("Describe Symptoms", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildCommonList() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _commonSymptoms.length,
        itemBuilder: (context, index) {
          final item = _commonSymptoms[index];
          return GestureDetector(
            onTap: () => addSymptom(item["name"]),
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), border: Border.all(color: const Color(0xFFF1F0F7))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: item["color"], shape: BoxShape.circle), child: Icon(item["icon"], color: AppTheme.primary, size: 24)),
                  const SizedBox(height: 8),
                  Text(item["name"], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.primaryDark)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeveritySelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: const Color(0xFFF8F8FD), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: ["low", "moderate", "high"].map((v) {
          bool isSelected = _selectedSeverity == v;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedSeverity = v),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: isSelected ? AppTheme.primary : Colors.transparent, borderRadius: BorderRadius.circular(15)),
                child: Text(v.toUpperCase(), textAlign: TextAlign.center, style: TextStyle(color: isSelected ? Colors.white : AppTheme.textSecondary, fontWeight: FontWeight.w800, fontSize: 12)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)]),
      child: Column(
        children: [
          TextField(
            controller: symptomController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "E.g. splitting headache, slight dry cough...",
              hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14), border: InputBorder.none,
              prefixIcon: const Icon(Icons.edit_rounded, color: AppTheme.primary),
              suffixIcon: IconButton(icon: Icon(Icons.camera_alt_rounded, color: _isProcessingOCR ? Colors.grey : AppTheme.primary), onPressed: _isProcessingOCR ? null : scanSymptomWithOCR),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () => addSymptom(symptomController.text.trim()), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D2D44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text("Add to List", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)))),
        ],
      ),
    );
  }

  Widget _buildSelectedList() {
    return Wrap(spacing: 8, children: symptoms.map((s) => Chip(
      label: Text(s, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryDark)),
      onDeleted: () => setState(() => symptoms.remove(s)),
      backgroundColor: AppTheme.primary.withOpacity(0.1),
      deleteIconColor: AppTheme.primary,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    )).toList());
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      child: SizedBox(width: double.infinity, height: 60, child: ElevatedButton(
        onPressed: getResult,
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        child: const Text("Analyze Now", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
      )),
    );
  }
}