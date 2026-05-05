import 'package:flutter/material.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
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
        leading: _buildIconButton(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
        title: const Text("About Us", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 22)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            // 1. 动态呼吸 Logo
            _animatedEntrance(
              delay: 0,
              child: _buildAnimatedLogo(),
            ),
            const SizedBox(height: 10),
            const Text("FitGrow v2.4.0", style: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),

            // 2. 品牌故事卡片
            _animatedEntrance(
              delay: 200,
              child: _buildStoryCard(),
            ),
            const SizedBox(height: 30),

            // 3. 成就/里程碑
            _animatedEntrance(
              delay: 400,
              child: _buildMilestones(),
            ),

            const SizedBox(height: 50),
            const Text("Made with ❤️ for a better life", style: TextStyle(color: Colors.black26, fontSize: 12)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- 带呼吸效果的 Logo ---
  Widget _buildAnimatedLogo() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1.05),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOutSine,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: darkCard,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: mainGreen.withOpacity(0.2), blurRadius: 20)],
            ),
            child: const Icon(Icons.bolt, color: mainGreen, size: 50),
          ),
        );
      },
      onEnd: () {},
    );
  }

  // --- 品牌故事卡片 ---
  Widget _buildStoryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(40),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Our Mission", style: TextStyle(color: mainGreen, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          SizedBox(height: 15),
          Text(
            "We believe that fitness should be fun, intuitive, and deeply rewarding.",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.3),
          ),
          SizedBox(height: 15),
          Text(
            "FitGrow was born to help you track every heartbeat and every step on your journey to a better self.",
            style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  // --- 里程碑（已按你的要求修改）---
  Widget _buildMilestones() {
    final milestones = [
      {"year": "2026.03", "event": "Project Started"},
      {"year": "2026.05", "event": "Project Completed"},
    ];

    double screenWidth = MediaQuery.of(context).size.width;
    double itemWidth = (screenWidth - 40 - 15) / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10, bottom: 15),
          child: Text("Milestones", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Wrap(
          spacing: 15,
          runSpacing: 15,
          children: milestones.map((item) {
            return _ScaleTap(
              onTap: () {},
              child: Container(
                width: itemWidth,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                decoration: BoxDecoration(
                  color: mainGreen,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: mainGreen.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        item['year']!,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['event']!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- 辅助方法 ---
  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _ScaleTap(
        onTap: onTap,
        child: Container(
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.black, size: 20),
        ),
      ),
    );
  }

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

// Q弹交互
class _ScaleTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _ScaleTap({required this.child, required this.onTap});

  @override
  State<_ScaleTap> createState() => _ScaleTapState();
}

class _ScaleTapState extends State<_ScaleTap> {
  double _scale = 1.0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.94),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}