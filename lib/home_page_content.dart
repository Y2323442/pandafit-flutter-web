import 'package:flutter/material.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({
    super.key,
    required this.onGoToTask,
    required this.onGoToAward,
  });

  final VoidCallback onGoToTask;
  final VoidCallback onGoToAward;

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  static const Color bgColor = Color(0xFFF1F8E9);
  static const Color mainGreen = Color(0xFFD1E683);
  static const Color darkCard = Color(0xFF1A1C1E);

  // 纯前端假数据
  final Map<String, dynamic> userData = {
    "username": "Panda",
    "level": 5,
    "xp": 120,
    "streakDays": 7,
    "totalSignInDays": 30,
    "signInDates": [
      "2025-12-01",
      "2025-12-02",
      "2025-12-03",
      "2025-12-04",
      "2025-12-05",
    ],
  };

  final List<Map<String, dynamic>> demoTasks = [
    {"title": "Morning Workout", "timeSlot": "07:00", "isCompleted": true},
    {"title": "Running 3km", "timeSlot": "18:00", "isCompleted": false},
    {"title": "Stretching", "timeSlot": "21:00", "isCompleted": false},
  ];

  final Map<String, dynamic> weeklySummary = {
    "totalMinutes": 180,
    "totalDistance": 12.5,
  };

  double _getMaxExpForLevel(int level) {
    return (level * 30).toDouble();
  }

  Future<void> _refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              _animatedEntrance(
                delay: 0,
                child: _buildHeroHeader(),
              ),
              const SizedBox(height: 20),
              _animatedEntrance(delay: 120, child: _buildWeeklySignInGoal()),
              const SizedBox(height: 20),
              _animatedEntrance(
                delay: 240,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildTotalCheckIns(),
                          const SizedBox(height: 20),
                          _buildExpProgress(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildDailyTaskCard(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _animatedEntrance(
                delay: 600,
                child: _buildStartCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              color: mainGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "P",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Welcome back, ${userData["username"]}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Level ${userData["level"]} • ${userData["xp"]} XP',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.72),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySignInGoal() {
    final weekDays = const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final signedDays = [1, 2, 3, 4, 5];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Sign-in Goal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${signedDays.length} / 7 days',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              bool isChecked = signedDays.contains(index);
              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isChecked ? mainGreen : Colors.white12,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.black, size: 18),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    weekDays[index],
                    style: TextStyle(
                      color: isChecked ? Colors.white : Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTaskCard() {
    return Container(
      height: 345,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: mainGreen,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily Task',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: widget.onGoToTask,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, size: 16, color: Color(0xFFD1E683)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Expanded(
            child: demoTasks.isEmpty
                ? const Center(
                    child: Text(
                      'No tasks yet',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  )
                : ListView(
                    padding: EdgeInsets.zero,
                    children: demoTasks.map((t) => _taskItem(t)).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _taskItem(Map<String, dynamic> task) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(
              task["isCompleted"] ? Icons.check_circle : Icons.circle,
              size: 14,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  task["title"],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                if (task["timeSlot"].isNotEmpty)
                  Text(
                    task["timeSlot"],
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCheckIns() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signed in successfully (offline)")),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Check-ins',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Click to sign in',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${userData["totalSignInDays"]}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpProgress() {
    final int level = userData["level"];
    final int xp = userData["xp"];
    final double maxExp = _getMaxExpForLevel(level);
    final double progress = (xp / maxExp).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: widget.onGoToAward,
      child: Container(
        width: double.infinity,
        height: 190,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'EXP Progress',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: progress),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeInOutCubic,
                    builder: (context, value, child) {
                      return SizedBox(
                        width: 84,
                        height: 84,
                        child: CircularProgressIndicator(
                          value: value,
                          strokeWidth: 10,
                          color: mainGreen,
                          backgroundColor: Colors.white10,
                          strokeCap: StrokeCap.round,
                        ),
                      );
                    },
                  ),
                  Text(
                    '${xp}/${maxExp.toInt()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildStartCard() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: mainGreen.withOpacity(0.2),
        borderRadius: BorderRadius.circular(40),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${weeklySummary["totalMinutes"]} mins • ${weeklySummary["totalDistance"].toStringAsFixed(1)} km this week',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: _ScaleTap(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Exercise mode (offline demo)")),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.directions_run, color: Color(0xFFD1E683), size: 20),
                    SizedBox(width: 8),
                    Text(
                      ' Exercise',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _animatedEntrance({required Widget child, required int delay}) {
    return FutureBuilder<void>(
      future: Future<void>.delayed(Duration(milliseconds: delay)),
      builder: (context, snapshot) {
        final isDone = snapshot.connectionState == ConnectionState.done;
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: isDone ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutBack,
          builder: (context, value, childWidget) {
            return Opacity(
              opacity: value.clamp(0.0, 1.0).toDouble(),
              child: Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
    );
  }
}

class _ScaleTap extends StatefulWidget {
  const _ScaleTap({
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final VoidCallback onTap;

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
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}