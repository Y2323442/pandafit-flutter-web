import 'package:flutter/material.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
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
        title: const Text("Support & Help", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 22)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // 1. 搜索框
                _animatedEntrance(delay: 0, child: _buildSearchBar()),
                const SizedBox(height: 30),

                // 2. 快捷分类 (Grid)
                _animatedEntrance(
                  delay: 200,
                  child: _buildCategoryGrid(),
                ),
                const SizedBox(height: 35),

                // 3. 常见问题列表
                _animatedEntrance(
                  delay: 400,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 10, bottom: 15),
                    child: Text("Popular Questions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                _buildFaqList(),
                
                const SizedBox(height: 120), // 为底部按钮留空间
              ],
            ),
          ),

          // 4. 底部悬浮联系卡片
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: _animatedEntrance(
              delay: 600,
              child: _ScaleTap(
                onTap: () {}, // 点击启动在线聊天
                child: _buildContactCard(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 高级组件：搜索框 ---
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: const TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: mainGreen),
          hintText: "How can we help you?",
          border: InputBorder.none,
        ),
      ),
    );
  }

  // --- 高级组件：快捷分类网格 ---
  Widget _buildCategoryGrid() {
    final categories = [
      {"icon": Icons. payment, "label": "Payment", "color": Color(0xFFFFE0B2)},
      {"icon": Icons.fitness_center, "label": "Workout", "color": Color(0xFFC8E6C9)},
      {"icon": Icons.person_search, "label": "Account", "color": Color(0xFFD1C4E9)},
      {"icon": Icons.bug_report_outlined, "label": "App Issue", "color": Color(0xFFFFCDD2)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 1.4,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) => _ScaleTap(
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            color: categories[index]['color'] as Color,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(categories[index]['icon'] as IconData, size: 30, color: Colors.black87),
              const SizedBox(height: 8),
              Text(categories[index]['label'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  // --- 高级组件：FAQ 列表 ---
  Widget _buildFaqList() {
    final faqs = [
      "How to reset my workout progress?",
      "Can I sync data with Apple Health?",
      "How to cancel my subscription?",
      "Is my personal data safe?",
    ];
    return Column(
      children: List.generate(faqs.length, (index) => _animatedEntrance(
        delay: 500 + (index * 50),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: _ScaleTap(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(child: Text(faqs[index], style: const TextStyle(fontWeight: FontWeight.w600))),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black12),
                ],
              ),
            ),
          ),
        ),
      )),
    );
  }

  // --- 高级组件：联系客服卡片 ---
  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: mainGreen, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.headset_mic_outlined, color: Colors.black),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Contact Live Support", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Typically replies in 5 mins", style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: mainGreen),
        ],
      ),
    );
  }

  // --- 辅助方法 (保持全 App 动效风格统一) ---
  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _ScaleTap(onTap: onTap, child: Container(
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.black, size: 20),
      )),
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
      child: AnimatedScale(scale: _scale, duration: const Duration(milliseconds: 100), child: widget.child),
    );
  }
}