import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'auth_page.dart';
import 'award_page.dart';
import 'grow.dart';
import 'home_page_content.dart';
import 'me.dart';
import 'task_page.dart';

bool isChinese = false;

void main() {
  // 纯本地控制器，无API、无数据库
  final controller = AppController();
  runApp(TrainQuestRoot(controller: controller));
}

class TrainQuestRoot extends StatefulWidget {
  const TrainQuestRoot({super.key, required this.controller});
  final AppController controller;

  @override
  State<TrainQuestRoot> createState() => TrainQuestRootState();
}

class TrainQuestRootState extends State<TrainQuestRoot> {
  @override
  void initState() {
    super.initState();
    widget.controller.bootstrap();
  }

  void refreshLang() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(fontFamily: 'Georgia'),
          home: _buildHome(),
        );
      },
    );
  }

  Widget _buildHome() {
    if (widget.controller.isBootstrapping) return const SplashPage();
    if (!widget.controller.isAuthenticated) {
      return AuthPage(controller: widget.controller);
    }
    return MainScreen(refresh: refreshLang);
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF1F8E9),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: Color(0xFF1A1C1E),
              child: Icon(Icons.fitness_center, color: Color(0xFFD1E683), size: 28),
            ),
            SizedBox(height: 18),
            Text('Loading TrainQuest...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.refresh});
  final VoidCallback refresh;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int? _pressingIndex;

  List<Widget> get _pages {
    return [
      HomePageContent(
        key: const PageStorageKey('home'),
        onGoToTask: () => setState(() => _currentIndex = 1),
        onGoToAward: () => setState(() => _currentIndex = 2),
      ),
      const TaskPage(key: PageStorageKey('task')),
      AwardPageScreen(
        key: const PageStorageKey('award'),
        refresh: () {
          setState(() {});
        },
      ),
      const GrowPage(key: PageStorageKey('grow')),
      const MePage(key: PageStorageKey('me')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    const Color mainGreen = Color(0xFFD1E683);
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        height: 90,
        color: mainGreen,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(isChinese ? "首页" : "Home", Icons.home, 0),
            _buildNavItem(isChinese ? "任务" : "Task", Icons.list, 1),
            _buildNavItem(isChinese ? "奖励" : "Award", Icons.emoji_events, 2),
            _buildNavItem(isChinese ? "成长" : "Grow", Icons.trending_up, 3),
            _buildNavItem(isChinese ? "我的" : "Me", Icons.person, 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressingIndex = index),
      onTapUp: (_) => setState(() {
        _pressingIndex = null;
        _currentIndex = index;
      }),
      onTapCancel: () => setState(() => _pressingIndex = null),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedScale(
          scale: _pressingIndex == index ? 1.3 : (isActive ? 1.1 : 1.0),
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _pressingIndex == index
                      ? Colors.black
                      : (isActive ? Colors.black.withOpacity(0.1) : Colors.transparent),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: _pressingIndex == index ? Colors.white : (isActive ? Colors.black : Colors.black45),
                  size: 28,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: (isActive || _pressingIndex == index) ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}