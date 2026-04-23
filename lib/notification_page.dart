import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  static const Color bgColor = Color(0xFFF1F8E9);
  static const Color mainGreen = Color(0xFFD1E683);
  static const Color darkCard = Color(0xFF1A1C1E);

  // 状态管理
  bool isMasterSwitchOn = true;
  bool activityAlerts = true;
  bool systemUpdates = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _buildIconButton(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
        title: const Text("Notifications", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 22)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 1. 高级感：通知状态 Hero 卡片
            _animatedEntrance(delay: 0, child: _buildNotificationHero()),
            const SizedBox(height: 30),

            // 2. 交互核心：大总开关卡片 (带按压反馈)
            _animatedEntrance(
              delay: 200,
              child: _ScaleTap(
                onTap: () => setState(() => isMasterSwitchOn = !isMasterSwitchOn),
                child: _buildMasterSwitchCard(),
              ),
            ),
            const SizedBox(height: 25),

            // 3. 细分通知列表
            _animatedEntrance(
              delay: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10, bottom: 15),
                    child: Text("Activity & Social", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  _buildSettingTile(Icons.directions_run, "Workout Reminders", "Get notified for daily goals", activityAlerts, (v) => setState(() => activityAlerts = v)),
                  _buildSettingTile(Icons.groups_outlined, "Community Updates", "New likes and comments", true, (v) {}),
                  _buildSettingTile(Icons.tips_and_updates_outlined, "Smart Coaching", "AI-based health tips", false, (v) {}),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- 高级组件：顶部 Hero 仪表盘 ---
  Widget _buildNotificationHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: mainGreen,
        borderRadius: BorderRadius.circular(45),
        boxShadow: [BoxShadow(color: mainGreen.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
            child: Icon(isMasterSwitchOn ? Icons.notifications_active : Icons.notifications_off, color: mainGreen, size: 40),
          ),
          const SizedBox(height: 20),
          Text(
            isMasterSwitchOn ? "Focus Mode Active" : "Notifications Muted",
            style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text("7 notifications filtered today", style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // --- 高级组件：总开关拟物化卡片 ---
  Widget _buildMasterSwitchCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isMasterSwitchOn ? darkCard : Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Allow Notifications", style: TextStyle(color: isMasterSwitchOn ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(isMasterSwitchOn ? "System is delivering alerts" : "All alerts are paused", style: TextStyle(color: isMasterSwitchOn ? Colors.white54 : Colors.black38, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: isMasterSwitchOn,
            onChanged: (v) => setState(() => isMasterSwitchOn = v),
            activeColor: mainGreen,
          )
        ],
      ),
    );
  }

  // --- 高级组件：设置条目 ---
  Widget _buildSettingTile(IconData icon, String title, String sub, bool val, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(15)),
              child: Icon(icon, color: Colors.black54, size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(sub, style: const TextStyle(color: Colors.black38, fontSize: 11)),
                ],
              ),
            ),
            Transform.scale(
              scale: 0.8, // 在这里设置缩放比例
              child: Switch(
                value: val,
                onChanged: onChanged,
                activeColor: mainGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 辅助方法 (复用 Security 逻辑) ---
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
          scale: isDone ? 1.0 : 0.85,
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

// Q弹缩放反馈包装器
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