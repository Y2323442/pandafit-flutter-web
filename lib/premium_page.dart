import 'package:flutter/material.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  static const Color bgColor = Color(0xFFF1F8E9);
  static const Color mainGreen = Color(0xFFD1E683);
  static const Color darkCard = Color(0xFF1A1C1E);
  static const Color goldAccent = Color(0xFFE2C48E); // 尊贵金点缀

  int selectedPlan = 1; // 默认选中年度方案

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _buildIconButton(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
        title: const Text("Premium", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 22)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 1. 尊贵 VIP 会员卡 (带渐变效果)
            _animatedEntrance(delay: 0, child: _buildVipCard()),
            const SizedBox(height: 30),

            // 2. 特权展示区 (网格布局)
            _animatedEntrance(
              delay: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10, bottom: 15),
                    child: Text("Exclusive Features", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  _buildFeatureGrid(),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 3. 方案选择 (点击切换状态)
            _animatedEntrance(delay: 400, child: _buildPlanSelection()),
            const SizedBox(height: 30),

            // 4. 底部行动按钮
            _animatedEntrance(
              delay: 600,
              child: _ScaleTap(
                onTap: () {},
                child: _buildSubscribeButton(),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- 高级组件：VIP 会员卡 ---
  Widget _buildVipCard() {
    return Container(
      width: double.infinity,
      height: 210,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [darkCard, Color(0xFF323639)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Stack(
        children: [
          // 右上角装饰图标
          Positioned(
            right: -20, top: -20,
            child: Icon(Icons.workspace_premium, size: 150, color: Colors.white.withValues(alpha: 0.05)),
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: goldAccent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                      child: const Text("PRO MEMBER", style: TextStyle(color: goldAccent, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 10)),
                    ),
                    const SizedBox(height: 15),
                    const Text("Unlock Your\nElite Potential", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, height: 1.1)),
                  ],
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Valid until 2025.12.31", style: TextStyle(color: Colors.white38, fontSize: 12)),
                    Icon(Icons. diamond_outlined, color: goldAccent, size: 28),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- 高级组件：特权网格 ---
  Widget _buildFeatureGrid() {
    final List<Map<String, dynamic>> features = [
      {"icon": Icons.bolt, "label": "AI Coaching"},
      {"icon": Icons.analytics_outlined, "label": "Deep Insights"},
      {"icon": Icons.block, "label": "No Ads"}, 
      {"icon": Icons.cloud_done_outlined, "label": "Cloud Sync"},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 2.2,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) => _ScaleTap(
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(features[index]['icon'], color: mainGreen, size: 24),
              const SizedBox(width: 10),
              Text(features[index]['label'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  // --- 高级组件：方案选择器 ---
  Widget _buildPlanSelection() {
    return Column(
      children: [
        _buildPlanTile("Monthly Plan", "\$9.99 / mo", 0),
        const SizedBox(height: 15),
        _buildPlanTile("Yearly Plan", "\$79.99 / yr", 1, isBest: true),
      ],
    );
  }

  Widget _buildPlanTile(String title, String price, int index, {bool isBest = false}) {
    bool isSelected = selectedPlan == index;
    return _ScaleTap(
      onTap: () => setState(() => selectedPlan = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isSelected ? mainGreen : Colors.transparent, width: 2.5),
          boxShadow: isSelected ? [BoxShadow(color: mainGreen.withValues(alpha: 0.2), blurRadius: 15)] : [],
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? mainGreen : Colors.black12),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                Text(price, style: const TextStyle(color: Colors.black38, fontSize: 13)),
              ],
            ),
            const Spacer(),
            if (isBest)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: mainGreen, borderRadius: BorderRadius.circular(10)),
                child: const Text("Save 30%", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              )
          ],
        ),
      ),
    );
  }

  // --- 订阅按钮 ---
  Widget _buildSubscribeButton() {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      alignment: Alignment.center,
      child: const Text("Start 7-Day Free Trial", style: TextStyle(color: mainGreen, fontSize: 18, fontWeight: FontWeight.bold)),
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

// Q弹交互组件
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
      child: AnimatedScale(scale: _scale, duration: const Duration(milliseconds: 100), child: widget.child),
    );
  }
}