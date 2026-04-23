import 'package:flutter/material.dart';

class VideoDetailPage extends StatelessWidget {
  final String title;
  final String img;
  const VideoDetailPage({super.key, required this.title, required this.img});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: CustomScrollView(
        slivers: [
          // 沉浸式大图顶部
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF1A1C1E),
            leading: IconButton(
              icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black)),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(img, fit: BoxFit.cover),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text("Instructional Steps", style: TextStyle(fontSize: 18, color: Color(0xFFD1E683), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _stepItem("01", "Warm-up Stretching", "3:00"),
                  _stepItem("02", "Main Workout Phase", "15:00"),
                  _stepItem("03", "Cool Down session", "5:00"),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _stepItem(String num, String text, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Row(
        children: [
          Text(num, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(width: 20),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600))),
          Text(time, style: const TextStyle(color: Colors.black38)),
        ],
      ),
    );
  }
}