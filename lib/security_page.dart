import 'package:flutter/material.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
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
        title: const Text("Security Center", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 22)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // 1. 安全评分仪表盘
            _animatedEntrance(delay: 0, child: _buildSecurityDashboard()),
            const SizedBox(height: 30),

            // 2. 核心保护模块（大卡片）
            Row(
              children: [
                Expanded(child: _animatedEntrance(delay: 200, child: _buildBigActionCard("Password", "Update now", Icons.lock_outline, Colors.orangeAccent))),
                const SizedBox(width: 15),
                Expanded(child: _animatedEntrance(delay: 300, child: _buildBigActionCard("2FA Auth", "Enabled", Icons.verified_user_outlined, mainGreen))),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- 高级组件：安全仪表盘 ---
  Widget _buildSecurityDashboard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(45),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120, height: 120,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 0.85),
                  duration: const Duration(milliseconds: 2000),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) => CircularProgressIndicator(
                    value: value,
                    strokeWidth: 15,
                    color: mainGreen,
                    backgroundColor: Colors.white10,
                    strokeCap: StrokeCap.round,
                  ),
                ),
              ),
              const Column(
                children: [
                  Text("85", style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  Text("Safe Score", style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              )
            ],
          ),
          const SizedBox(height: 25),
          const Text("Your account is highly protected", style: TextStyle(color: mainGreen, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- 高级组件：大动作卡片 (带缩放反馈) ---
  Widget _buildBigActionCard(String title, String status, IconData icon, Color accentColor) {
    return _ScaleTap(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: accentColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: accentColor, size: 24),
            ),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(status, style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
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
          scale: isDone ? 1.0 : 0.8,
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

// --- 高级交互：Q弹缩放反馈包装器 ---
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