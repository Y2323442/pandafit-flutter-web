import 'package:flutter/material.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  static const Color bgColor = Color(0xFFF1F8E9);
  static const Color mainGreen = Color(0xFFD1E683);

  final List<Map<String, String>> faqs = [
    
    {
      "q": "How to check in daily?",
      "a": "Tap the check-in button on the home page to get EXP."
    },
    {
      "q": "How to unlock panda skins?",
      "a": "Level up by completing tasks and workouts."
    },
    {
      "q": "Is my data stored safely?",
      "a": "All data is saved locally on your device only."
    },
  ];

  int? _openedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("FAQ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Frequently Asked Questions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...List.generate(faqs.length, (index) {
            bool isOpen = _openedIndex == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    ListTile(
                      onTap: () {
                        setState(() {
                          _openedIndex = isOpen ? null : index;
                        });
                      },
                      title: Text(faqs[index]["q"]!, style: const TextStyle(fontWeight: FontWeight.w600)),
                      trailing: Icon(isOpen ? Icons.expand_less : Icons.expand_more, color: mainGreen),
                    ),
                    if (isOpen)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                        child: Text(faqs[index]["a"]!, style: const TextStyle(color: Colors.black54)),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
