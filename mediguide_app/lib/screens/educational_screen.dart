import 'package:flutter/material.dart';

class EducationalScreen extends StatefulWidget {
  const EducationalScreen({super.key});

  @override
  State<EducationalScreen> createState() => _EducationalScreenState();
}

class _EducationalScreenState extends State<EducationalScreen> {
  final List<Map<String, dynamic>> _topics = [
    {
      "title": "What is Homeopathy?",
      "icon": Icons.info_outline_rounded,
      "color": const Color(0xFF8B78E6),
      "content": "Homeopathy is a system of alternative medicine developed in 1796 by Samuel Hahnemann. It is based on the doctrine of 'like cures like' (similia similibus curentur), which states that a substance that causes symptoms of a disease in healthy people can cure similar symptoms in sick people. It aims to stimulate the body's own healing mechanisms."
    },
    {
      "title": "The Law of Minimum Dose",
      "icon": Icons.water_drop_outlined,
      "color": const Color(0xFFFFB3B3),
      "content": "A core principle of homeopathy is the 'minimum dose'. Remedies are prepared through a process of serial dilution and succussion (vigorous shaking). Common potencies include 6C, 30C, and 200C. Paradoxically, homeopaths believe that the more a substance is diluted in this specific manner, the greater its medicinal power and safety."
    },
    {
      "title": "A Holistic Approach",
      "icon": Icons.psychology_outlined,
      "color": const Color(0xFFD6C8FF),
      "content": "Homeopathy treats the individual as a whole, not just the isolated disease. A homeopathic practitioner will consider all aspects of a patient's physical, mental, and emotional state when prescribing a remedy. This is why two people with the same physical illness might receive completely different homeopathic prescriptions."
    },
    {
      "title": "Common Remedies Overview",
      "icon": Icons.medication_liquid_outlined,
      "color": const Color(0xFFA1D9E7),
      "content": "• Arnica Montana: Excellent for shock, trauma, and bruising.\n• Belladonna: Often used for sudden onset of high fever and inflammation.\n• Nux Vomica: Known for aiding digestion issues and treating overindulgence.\n• Ignatia: Used for grief, emotional shock, and hypersensitivity."
    },
    {
      "title": "Safety and Limitations",
      "icon": Icons.health_and_safety_outlined,
      "color": const Color(0xFFFFD1A9),
      "content": "Because homeopathic remedies are highly diluted, they are generally considered safe and free from serious adverse chemical side effects. However, homeopathy should not be used as a replacement for emergency care or proven conventional treatments for life-threatening illnesses. It is best used as a complementary practice."
    },
    {
      "title": "How are Remedies Made?",
      "icon": Icons.science_outlined,
      "color": const Color(0xFFFFD1A9),
      "content": "Remedies start as a tincture from a plant, mineral, or animal source. One drop of this tincture is mixed with 99 drops of water/alcohol and vigorously shaken (succussed) to create a '1C' potency. Taking 1 drop of that 1C mixture into 99 drops of water makes 2C. The common 30C remedy means this process was repeated 30 times."
    },
    {
      "title": "The Ongoing Scientific Debate",
      "icon": Icons.biotech_outlined,
      "color": const Color(0xFFA1D9E7),
      "content": "Conventional science heavily debates homeopathy because remedies diluted beyond 12C mathematically contain zero original molecules (passing Avogadro's limit). Proponents suggest water retains a 'memory' of the structure holding a resonant energetic frequency, though empirical studies show mixed results often attributed to the placebo effect."
    },
    {
      "title": "Consulting a Homeopath",
      "icon": Icons.support_agent_outlined,
      "color": const Color(0xFFD6C8FF),
      "content": "Professional homeopathic intake sessions usually last an hour or more. Practitioners document everything including physical characteristics, emotional state, food preferences, and sensitivity to weather, enabling them to perfectly match the 'simillimum' – the single remedy perfectly mirroring your entire state."
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2FA),
      appBar: AppBar(
        title: const Text("Learn Homeopathy", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3B3B58))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF3B3B58)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF3B3B58),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B3B58).withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ]
              ),
              child: Row(
                children: [
                   const Icon(Icons.school_rounded, color: Colors.white, size: 40),
                   const SizedBox(width: 16),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: const [
                         Text("Educational Module", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                         SizedBox(height: 4),
                         Text("Discover the core principles, practices, and medicines behind Homeopathy.", style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                       ],
                     ),
                   )
                ],
              ),
            ),
            const SizedBox(height: 32),

            ..._topics.map((topic) => _buildTopicCard(topic)),
            
            const SizedBox(height: 40),
          ],
        ),
      )
    );
  }

  Widget _buildTopicCard(Map<String, dynamic> topic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: topic['color'].withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(topic['icon'], color: topic['color'], size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  topic['title'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3B3B58)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            topic['content'],
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8B8B9E),
              height: 1.6,
            ),
          )
        ],
      )
    );
  }
}
