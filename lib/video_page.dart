import 'package:flutter/material.dart';

class VideoPage extends StatelessWidget {
  const VideoPage({super.key});

  static const Color bgColor = Color(0xFFF1F8E9);
  static const Color mainGreen = Color(0xFFD1E683);
  static const Color darkCard = Color(0xFF1A1C1E);

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
        title: const Text("Workout Video", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 模拟视频播放区域
            _animatedEntrance(
              delay: 0,
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/running.jpg'), // 使用你的本地图片作为封面
                    fit: BoxFit.cover,
                    opacity: 0.6,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.play_circle_fill, color: mainGreen, size: 80),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // 2. 视频信息
            _animatedEntrance(
              delay: 200,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Morning Fat Burning", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("25 Minutes • High Intensity • 350 Kcal", style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 3. 训练步骤列表
            _animatedEntrance(
              delay: 400,
              child: const Text("Workout Steps", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 15),
            _buildStepItem(1, "Dynamic Stretching", "3 Minutes", 400),
            _buildStepItem(2, "High Intensity Interval", "15 Minutes", 500),
            _buildStepItem(3, "Core Strengthening", "5 Minutes", 600),
            _buildStepItem(4, "Cool Down & Stretch", "2 Minutes", 700),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // 训练步骤条目组件
  Widget _buildStepItem(int num, String title, String time, int delay) {
    return _animatedEntrance(
      delay: delay,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: mainGreen, borderRadius: BorderRadius.circular(15)),
              child: Text("$num", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(time, style: const TextStyle(color: Colors.black38, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.check_circle_outline, color: Colors.black12),
          ],
        ),
      ),
    );
  }

  // 动画包装器
  Widget _animatedEntrance({required Widget child, required int delay}) {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: delay)),
      builder: (context, snapshot) {
        bool isDone = snapshot.connectionState == ConnectionState.done;
        return AnimatedScale(
          scale: isDone ? 1.0 : 0.9,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
          child: AnimatedOpacity(
            opacity: isDone ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 600),
            child: child,
          ),
        );
      },
    );
  }
}