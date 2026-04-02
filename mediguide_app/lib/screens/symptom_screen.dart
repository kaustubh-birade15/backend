import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

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

  final List<Map<String, dynamic>> _commonSymptoms = [
    {"name": "Headache", "icon": Icons.sentiment_dissatisfied_rounded, "color": const Color(0xFFFFB3B3)},
    {"name": "Cold", "icon": Icons.ac_unit_rounded, "color": const Color(0xFFD6C8FF)},
    {"name": "Anxiety", "icon": Icons.favorite_border_rounded, "color": const Color(0xFFA1D9E7)},
    {"name": "Digestion", "icon": Icons.restaurant_menu_rounded, "color": const Color(0xFFFFD1A9)},
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
          final currentText = symptomController.text;
          if(currentText.isEmpty) {
             symptomController.text = scannedText.replaceAll('\n', ', ');
          } else {
             symptomController.text = "$currentText, ${scannedText.replaceAll('\n', ', ')}";
          }
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No text recognized from the image")),
        );
      }
      textRecognizer.close();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error during OCR: $e")),
      );
    } finally {
      if (mounted) setState(() => _isProcessingOCR = false);
    }
  }

  @override
  void dispose() {
    symptomController.dispose();
    super.dispose();
  }

  void addSymptom(String symptomString) {
    if (symptomString.isEmpty) return;

    if (symptoms.contains(symptomString)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Already added to list")),
      );
      return;
    }

    setState(() {
      symptoms.add(symptomString);
      symptomController.clear();
    });
  }

  void getResult() {
    final text = symptomController.text.trim();
    List<String> finalSymptoms = List.from(symptoms);
    
    if (text.isNotEmpty && !finalSymptoms.contains(text)) {
      finalSymptoms.add(text);
    }

    if (finalSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please describe your symptoms before analyzing.")),
      );
      return;
    }

    Navigator.pushNamed(context, '/result', arguments: finalSymptoms);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF3B3B58)),
        title: const Text(
          "Describe Symptoms",
          style: TextStyle(color: Color(0xFF3B3B58), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "How are you feeling?",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF3B3B58),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "You can speak to our AI or type your symptoms. Add quick symptoms or scan your clinical report.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8B8B9E),
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick Symptom Cards
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _commonSymptoms.length,
                      separatorBuilder: (context, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final item = _commonSymptoms[index];
                        return GestureDetector(
                          onTap: () => addSymptom(item["name"]),
                          child: Container(
                            width: 80,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: item["color"],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(item["icon"], color: const Color(0xFF3B3B58), size: 28),
                                const SizedBox(height: 6),
                                Text(
                                  item["name"],
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3B3B58),
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Input Box
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: symptomController,
                          minLines: 3,
                          maxLines: 6,
                          style: const TextStyle(
                            color: Color(0xFF3B3B58),
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: "Search or describe symptoms (e.g. slight fever tonight)...",
                            hintStyle: const TextStyle(color: Color(0xFFA6A6C1)),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(bottom: 50.0),
                              child: Icon(Icons.mic_none_rounded, color: Color(0xFF8B8B9E)),
                            ),
                            suffixIcon: _isProcessingOCR 
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF8B78E6)),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.document_scanner_rounded),
                                  onPressed: scanSymptomWithOCR,
                                  tooltip: 'Scan text with OCR',
                                  color: const Color(0xFF8B78E6),
                                  iconSize: 26,
                                ),
                            filled: true,
                            fillColor: const Color(0xFFF4F2FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFE8E5F0), width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFF8B78E6), width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () => addSymptom(symptomController.text.trim()),
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text(
                              "Save Symptom to List",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Active Symptoms Listed
                  if (symptoms.isNotEmpty) ...[
                    const Text(
                      "Selected Symptoms",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF3B3B58),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: symptoms.map((s) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE8E5F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  s,
                                  style: const TextStyle(
                                    color: Color(0xFF4C4C6D),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => setState(() => symptoms.remove(s)),
                                child: const Icon(Icons.cancel, size: 20, color: Color(0xFFFFB3B3)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Analyze Button docked bottom
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, -10),
                )
              ]
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: getResult,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B78E6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Next Step: Find Remedy",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}