import 'package:flutter/material.dart';
import 'home_page_content.dart';
import 'task_page.dart';
import 'grow.dart';
import 'me.dart';

bool isChinese = false;

void main() {
  runApp(const TrainQuestRoot());
}

class TrainQuestRoot extends StatefulWidget {
  const TrainQuestRoot({super.key});

  @override
  State<TrainQuestRoot> createState() => TrainQuestRootState();
}

class TrainQuestRootState extends State<TrainQuestRoot> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Georgia'),
      home: const AuthPageDemo(),
    );
  }
}

// 登录UI演示，点击即进主页，不验证
class AuthPageDemo extends StatelessWidget {
  const AuthPageDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFF1A1C1E),
                child: Icon(Icons.fitness_center, color: Color(0xFFD1E683), size: 32),
              ),
              const SizedBox(height: 30),
              const Text(
                "Welcome Back",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),
              TextField(
                decoration: InputDecoration(
                  hintText: "Email",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (c) => const MainScreen()),
                    );
                  },
                  child: const Text(
                    "Log In",
                    style: TextStyle(color: Color(0xFFD1E683), fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (c) => const MainScreen()),
                  );
                },
                child: const Text("Create Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

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
      // 占位容器，不加载你的 AwardPage，不报错
      Container(key: const PageStorageKey('award')),
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