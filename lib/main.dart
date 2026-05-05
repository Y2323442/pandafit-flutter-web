import 'package:flutter/material.dart';
import 'app_controller.dart';
import 'award_page.dart';
import 'grow.dart';
import 'home_page_content.dart';
import 'me.dart';
import 'task_page.dart';
import 'local_report.dart';

bool isChinese = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalReport.init();
  runApp(const MyApp());
}

// 全局刷新用的key（重点）
GlobalKey<_TrainQuestRootState> trainQuestRootKey = GlobalKey();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Georgia'),
      home: TrainQuestRoot(key: trainQuestRootKey),
    );
  }
}

class TrainQuestRoot extends StatefulWidget {
  const TrainQuestRoot({super.key});

  @override
  State<TrainQuestRoot> createState() => _TrainQuestRootState();
}

class _TrainQuestRootState extends State<TrainQuestRoot> {
  final AppController controller = AppController.instance;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await controller.bootstrap();
  }

  void refreshLang() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MainScreen(refresh: refreshLang);
      },
    );
  }
}

// 下面 MainScreen 代码你原样保留，不用改
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