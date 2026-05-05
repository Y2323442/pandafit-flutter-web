import 'package:flutter/material.dart';
import 'app_controller.dart';
import 'models/trainquest_models.dart';
import 'main.dart';

import 'security_page.dart';
import 'notification_page.dart';
import 'language_page.dart';
import 'premium_page.dart';
import 'support_page.dart';
import 'about_page.dart';

class MePage extends StatefulWidget {
  const MePage({super.key});

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> with WidgetsBindingObserver {
  static const Color bgColor = Color(0xFFF1F8E9);
  static const Color mainGreen = Color(0xFFD1E683);
  static const Color darkCard = Color(0xFF1A1C1E);

  int _customActiveDays = 0;
  int _customStreakDays = 0;

  AppUser? get user => AppController.instance.user;

  void _onUserUpdated() {
    setState(() {});
  }

  Future<void> _showInputDialog(String title, Function(int) onConfirm) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isChinese ? "设置$title" : "Set $title"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isChinese ? "取消" : "Cancel"),
          ),
          TextButton(
            onPressed: () {
              final val = int.tryParse(controller.text.trim());
              if (val != null) {
                onConfirm(val);
                setState(() {});
              }
              Navigator.pop(context);
            },
            child: Text(isChinese ? "确定" : "Confirm"),
          ),
        ],
      ),
    );
  }

  void _pushPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppController.instance.addListener(_onUserUpdated);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppController.instance.removeListener(_onUserUpdated);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _animatedEntrance(
                delay: 0,
                child: Text(
                  isChinese ? "我的" : "Me",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              _animatedEntrance(delay: 100, child: _buildProfileCard()),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _animatedEntrance(
                      delay: 200,
                      child: GestureDetector(
                        onTap: () => _showInputDialog("Active Days", (val) {
                          setState(() {
                            _customActiveDays = val;
                          });
                        }),
                        child: _buildStatItem(
                          isChinese ? "活跃" : "Active",
                          '$_customActiveDays',
                          isChinese ? "天" : "Days",
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _animatedEntrance(
                      delay: 300,
                      child: _buildStatItem(
                        isChinese ? "经验值" : "XP",
                        '${user!.xp}',
                        isChinese ? "分" : "Points",
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: _animatedEntrance(
                      delay: 350,
                      child: GestureDetector(
                        onTap: () => _showInputDialog("Streak Days", (val) {
                          setState(() {
                            _customStreakDays = val;
                          });
                        }),
                        child: _buildStatItem(
                          isChinese ? "连续" : "Streak",
                          '$_customStreakDays',
                          isChinese ? "天" : "Days",
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _animatedEntrance(
                      delay: 400,
                      child: _buildStatItem(
                        isChinese ? "等级" : "Level",
                        '${user!.level}',
                        isChinese ? "级" : "Rank",
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),
              _animatedEntrance(
                delay: 450,
                child: _buildMenuSection([
                  _menuItem(context, Icons.person_outline, isChinese ? "账号安全" : "Account Security", () => _pushPage(const SecurityPage())),
                  _menuItem(context, Icons.notifications_none, isChinese ? "消息通知" : "Notifications", () => _pushPage(const NotificationsPage())),
                  _menuItem(context, Icons.language, isChinese ? "语言设置" : "Language", () => _pushPage(const LanguagePage())),
                ]),
              ),
              const SizedBox(height: 15),
              _animatedEntrance(
                delay: 500,
                child: _buildMenuSection([
                  _menuItem(context, Icons.workspace_premium, isChinese ? "会员订阅" : "Premium Membership", () => _pushPage(const PremiumPage()), isPremium: true),
                  _menuItem(context, Icons.help_outline, isChinese ? "帮助与支持" : "Support & Help", () => _pushPage(const SupportPage())),
                  _menuItem(context, Icons.info_outline, isChinese ? "关于我们" : "About Us", () => _pushPage(const AboutUsPage())),
                ]),
              ),
              const SizedBox(height: 20),
              _animatedEntrance(
                delay: 560,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
                  child: Text(isChinese ? "当前模式：离线演示" : "Offline Demo Mode", style: const TextStyle(color: Colors.black54)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _animatedEntrance({required Widget child, required int delay}) {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: delay)),
      builder: (context, snapshot) {
        final isVisible = snapshot.connectionState == ConnectionState.done;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: isVisible ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut,
          builder: (context, value, childWidget) {
            return Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: Transform.translate(offset: Offset(0, 40 * (1 - value)), child: child),
            );
          },
          child: child,
        );
      },
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isPremium = false}) {
    double scale = 1.0;
    return StatefulBuilder(
      builder: (context, setInternalState) {
        return GestureDetector(
          onTapDown: (_) => setInternalState(() => scale = 0.94),
          onTapUp: (_) => setInternalState(() => scale = 1.0),
          onTapCancel: () => setInternalState(() => scale = 1.0),
          onTap: onTap,
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 100),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)), child: Icon(icon, size: 24, color: darkCard)),
                  const SizedBox(width: 12),
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  if (isPremium)
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: mainGreen, borderRadius: BorderRadius.circular(8)), child: Text(isChinese ? "会员" : "PRO", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black38),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(32)),
      child: Row(
        children: [
          CircleAvatar(radius: 36, backgroundColor: mainGreen, child: Text(user!.username.isNotEmpty ? user!.username.substring(0, 1).toUpperCase() : 'A', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black))),
          const SizedBox(width: 20),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user!.username, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text("user@fitapp.com", style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              Text(isChinese ? "等级 ${user!.level}" : "Level ${user!.level}", style: TextStyle(color: mainGreen, fontSize: 14, fontWeight: FontWeight.bold)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: mainGreen, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Text(unit, style: const TextStyle(fontSize: 12, color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
      child: Column(children: children),
    );
  }
}