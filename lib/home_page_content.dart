import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'app_controller.dart';
import 'models/trainquest_models.dart';
import 'video_detail_page.dart';

class DashboardData {
  final AppUser user;
  final List<AppTask> dailyTasks;
  final WeeklySummary weeklySummary;

  DashboardData({
    required this.user,
    required this.dailyTasks,
    required this.weeklySummary,
  });
}

class WeeklySummary {
  final int totalMinutes;
  final double totalDistance;

  WeeklySummary({
    required this.totalMinutes,
    required this.totalDistance,
  });
}

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

class _HomePageContentState extends State<HomePageContent> with WidgetsBindingObserver {
  static const Color bgColor = Color(0xFFF1F8E9);
  static const Color mainGreen = Color(0xFFD1E683);
  static const Color darkCard = Color(0xFF1A1C1E);

  late Future<DashboardData> _homeFuture;
  bool _initialized = false;

  static const int MAX_LEVEL = 3;
  static const int EXP_PER_LEVEL = 10;

  double _getMaxExpForLevel(int level) {
    return EXP_PER_LEVEL.toDouble();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppController.instance.addListener(_onDataChanged);
    _initData();
  }

  void _initData() {
    setState(() {
      _homeFuture = _loadLocalHomeData();
    });
  }

  void _onDataChanged() {
    if (mounted) {
      _initData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppController.instance.removeListener(_onDataChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _initData();
    }
  }

  Future<DashboardData> _loadLocalHomeData() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final globalTasks = AppController.instance.tasks;
    return DashboardData(
      user: AppController.instance.user!,
      dailyTasks: globalTasks,
      weeklySummary: WeeklySummary(totalMinutes: 145, totalDistance: 12.3),
    );
  }

  Future<void> _refresh() async {
    _initData();
  }

  List<AppTask> _sortTasksByTime(List<AppTask> tasks) {
    final sorted = List<AppTask>.from(tasks);
    sorted.sort((a, b) => a.timeSlot.compareTo(b.timeSlot));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      child: SafeArea(
        child: FutureBuilder<DashboardData>(
          future: _homeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _ErrorState(onRetry: _refresh, message: '${snapshot.error}');
            }

            final user = AppController.instance.user!;
            final tasks = _sortTasksByTime(snapshot.data!.dailyTasks);

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _animatedEntrance(delay: 0, child: _buildHeroHeader(user)),
                  const SizedBox(height: 20),
                  _animatedEntrance(delay: 120, child: _buildWeeklySignInGoal(user)),
                  const SizedBox(height: 20),
                  _animatedEntrance(
                    delay: 240,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Column(
                          children: [
                            _buildTotalCheckIns(user),
                            const SizedBox(height: 20),
                            _buildExpProgress(user),
                          ],
                        )),
                        const SizedBox(width: 20),
                        Expanded(child: _buildDailyTaskCard(tasks)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _animatedEntrance(delay: 600, child: _buildStartCard(snapshot.data!.weeklySummary)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroHeader(AppUser user) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(32)),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(color: mainGreen, shape: BoxShape.circle),
            child: Center(
              child: Text(
                user.username.isNotEmpty ? user.username.substring(0, 1).toUpperCase() : 'T',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back, ${user.username}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  user.level >= MAX_LEVEL ? 'Level MAX' : 'Level ${user.level} • ${user.xp} XP',
                  style: TextStyle(color: Colors.white.withOpacity(0.72)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySignInGoal(AppUser user) {
    final weekDays = const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final now = DateTime.now();
    final signed = user.signInDates;

    List<int> signedWeekDays = [];
    if (signed != null) {
      for (String d in signed) {
        try {
          final date = DateTime.parse(d);
          if (date.isAfter(now.subtract(const Duration(days: 7)))) {
            signedWeekDays.add(date.weekday % 7);
          }
        } catch (_) {}
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weekly Sign-in Goal', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('${signed?.length ?? 0} / 7 days', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              bool checked = signedWeekDays.contains(index);
              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: checked ? mainGreen : Colors.white12,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.black, size: 18),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    weekDays[index],
                    style: TextStyle(
                      color: checked ? Colors.white : Colors.white38,
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

  Widget _buildDailyTaskCard(List<AppTask> tasks) {
    return Container(
      height: 345,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: mainGreen, borderRadius: BorderRadius.circular(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daily Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: widget.onGoToTask,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                  child: const Icon(Icons.edit, size: 16, color: Color(0xFFD1E683)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Expanded(
            child: tasks.isEmpty
                ? const Center(child: Text('No tasks yet', style: TextStyle(color: Colors.black54, fontSize: 13)))
                : ListView(
                    padding: EdgeInsets.zero,
                    children: tasks.map((t) => _taskItem(t)).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _taskItem(AppTask task) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(
              task.isCompleted ? Icons.check_circle : Icons.circle,
              size: 14,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, height: 1.4),
                ),
                if (task.timeSlot.isNotEmpty)
                  Text(
                    task.timeSlot,
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCheckIns(AppUser user) {
    return GestureDetector(
      onTap: () async {
        await AppController.instance.userSignIn();
        _showCheckInCalendar(context, AppController.instance.user!);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          image: const DecorationImage(
            image: AssetImage("assets/images/fire.jpg"),
            fit: BoxFit.cover,
            opacity: 0.25,
          ),
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
              '${user.totalSignInDays}',
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

  Widget _buildExpProgress(AppUser user) {
    final maxExp = _getMaxExpForLevel(user.level);
    final progress = user.level >= MAX_LEVEL ? 1.0 : (user.xp / maxExp).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: widget.onGoToAward,
      child: Container(
        width: double.infinity,
        height: 190,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Level Progress', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const Spacer(),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: progress),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeInOutCubic,
                    builder: (_, val, __) => SizedBox(
                      width: 84,
                      height: 84,
                      child: CircularProgressIndicator(
                        value: val,
                        strokeWidth: 10,
                        color: mainGreen,
                        backgroundColor: Colors.white10,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                  ),
                  Text(
                    user.level >= MAX_LEVEL ? 'MAX' : '${user.xp}/${maxExp.toInt()}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

  void _showCheckInCalendar(BuildContext context, AppUser user) {
    DateTime now = DateTime.now();
    int selectedYear = now.year;
    int selectedMonth = now.month;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: StatefulBuilder(
          builder: (ctx, setStateDialog) {
            final freshUser = AppController.instance.user!;
            final firstDay = DateTime(selectedYear, selectedMonth, 1);
            final emptyCells = firstDay.weekday % 7;
            final totalDays = DateTime(selectedYear, selectedMonth + 1, 0).day;

            bool isSigned(int day) {
              final d = DateTime(selectedYear, selectedMonth, day);
              final fmt = "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
              return freshUser.signInDates?.contains(fmt) ?? false;
            }

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Check-in History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 70,
                        height: 80,
                        child: ListWheelScrollView(
                          itemExtent: 35,
                          useMagnifier: true,
                          magnification: 1.1,
                          physics: const FixedExtentScrollPhysics(),
                          controller: FixedExtentScrollController(initialItem: selectedYear - 2020),
                          onSelectedItemChanged: (i) => setStateDialog(() => selectedYear = 2020 + i),
                          children: List.generate(30, (i) => Center(child: Text("${2020 + i}"))),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 60,
                        height: 80,
                        child: ListWheelScrollView(
                          itemExtent: 35,
                          useMagnifier: true,
                          magnification: 1.1,
                          physics: const FixedExtentScrollPhysics(),
                          controller: FixedExtentScrollController(initialItem: selectedMonth - 1),
                          onSelectedItemChanged: (i) => setStateDialog(() => selectedMonth = i + 1),
                          children: List.generate(12, (i) => Center(child: Text("${i + 1}"))),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Sun"),
                      Text("Mon"),
                      Text("Tue"),
                      Text("Wed"),
                      Text("Thu"),
                      Text("Fri"),
                      Text("Sat")
                    ],
                  ),
                  const Divider(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 7,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    childAspectRatio: 1,
                    children: [
                      for (int i = 0; i < emptyCells; i++) const SizedBox(),
                      for (int d = 1; d <= totalDays; d++)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: isSigned(d)
                                ? const DecorationImage(
                                    image: AssetImage("assets/images/panda4.png"),
                                    fit: BoxFit.cover,
                                    opacity: 0.5,
                                  )
                                : null,
                            color: isSigned(d) ? mainGreen.withOpacity(0.3) : Colors.grey[100],
                          ),
                          child: Center(child: Text("$d")),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text("Total: ${freshUser.totalSignInDays} days", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close")),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStartCard(WeeklySummary summary) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        image: const DecorationImage(
          image: AssetImage("assets/images/running2.png"),
          fit: BoxFit.cover,
          opacity: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${summary.totalMinutes} mins • ${summary.totalDistance.toStringAsFixed(1)} km this week',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: _ScaleTap(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder<void>(
                    transitionDuration: const Duration(milliseconds: 600),
                    pageBuilder: (context, anim, _) => const VideoPage(),
                    transitionsBuilder: (context, anim, _, child) {
                      return FadeTransition(
                        opacity: anim,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.85, end: 1.0).animate(
                            CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                          ),
                          child: child,
                        ),
                      );
                    },
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(25)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.directions_run, color: Color(0xFFD1E683), size: 20),
                    SizedBox(width: 8),
                    Text(' Exercise', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: delay)),
      builder: (context, snapshot) {
        final done = snapshot.connectionState == ConnectionState.done;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: done ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutBack,
          builder: (_, val, __) => Opacity(
            opacity: val.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, 50 * (1 - val)),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry, required this.message});
  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 46, color: Colors.black45),
            const SizedBox(height: 14),
            const Text('Could not load data', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1A1C1E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: onRetry,
              child: const Text('Try Again', style: TextStyle(color: Color(0xFFD1E683))),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScaleTap extends StatefulWidget {
  const _ScaleTap({required this.child, required this.onTap});
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