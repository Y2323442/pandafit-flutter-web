import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'app_controller.dart';
import 'local_report.dart';
import 'models/trainquest_models.dart';

class AwardPageScreen extends StatefulWidget {
  final VoidCallback refresh;
  const AwardPageScreen({
    super.key,
    required this.refresh,
  });

  @override
  State<AwardPageScreen> createState() => _AwardPageScreenState();
}

class _AwardPageScreenState extends State<AwardPageScreen> {
  static const Color mainGreen = Color(0xFFD1E683);
  static const int levelExp = 10;
  static const int maxLevel = 3;

  final List<Map<String, dynamic>> _buddyForms = [
    {'name': 'Baby Panda', 'asset': 'assets/images/panda1.png', 'unlockLevel': 1},
    {'name': 'Advanced Panda', 'asset': 'assets/images/panda2.png', 'unlockLevel': 2},
    {'name': 'Final Panda', 'asset': 'assets/images/panda3.png', 'unlockLevel': 3},
  ];

  late List<Map<String, dynamic>> _dailyTasks;
  String? _lastCheckInDate;

  VideoPlayerController? videoController;
  bool showVideoPopup = false;

  bool _loading = true;
  AppUser? get user => AppController.instance.user;

  final PageController _pageController = PageController();
  final TextEditingController _frequencyController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDailyTasks();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  // 🔥 去掉了All daily tasks completed，XP调整为刚好满级
  void _initDailyTasks() {
    _dailyTasks = [
      {'text': 'Accumulate ≤ 0.5h', 'exp': 5, 'done': false},
      {'text': 'Accumulate 0.5–2h', 'exp': 5, 'done': false},
      {'text': 'Accumulate ≥ 2h', 'exp': 10, 'done': false},
      {'text': 'Daily check-in', 'exp': 5, 'done': false},
    ];
  }

  Future<void> _doCheckIn() async {
    if (user == null) return;
    final now = DateTime.now();
    final todayKey = "${now.year}-${now.month}-${now.day}";

    if (_lastCheckInDate == todayKey) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Today already checked in!')),
      );
      return;
    }

    setState(() {
      _lastCheckInDate = todayKey;
      for (var t in _dailyTasks) {
        if (t['text'] == 'Daily check-in') t['done'] = true;
      }
      _updateTaskCompletion();
      _addXp(5);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Check-in success! +5 EXP')),
    );
  }

  void _saveFitnessData() {
    if (user == null) return;
    final freq = int.tryParse(_frequencyController.text) ?? 0;
    final accumulateHours = double.tryParse(_durationController.text) ?? 0.0;

    if (freq < 0 || accumulateHours < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numbers')),
      );
      return;
    }

    setState(() {
      final updated = user!.copyWith(
        weeklyWorkoutCount: freq,
        dailyWorkoutMinutes: (accumulateHours * 60).round(),
      );
      AppController.instance.updateUser(updated);
      _updateWorkoutTaskByHour(accumulateHours);
      _updateTaskCompletion();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitness data saved!')),
    );
  }

  // 🔥 累积时长判断，自动完成低档任务并加对应XP
  void _updateWorkoutTaskByHour(double h) {
    // 先重置
    for (var t in _dailyTasks) {
      if (t['text'].contains('Accumulate')) {
        t['done'] = false;
      }
    }

    // 逐级判定并加经验
    if (h > 0 && h < 0.5) {
      _dailyTasks[0]['done'] = true;
      _addXp(_dailyTasks[0]['exp']);
    } else if (h >= 0.5 && h < 2) {
      _dailyTasks[0]['done'] = true;
      _dailyTasks[1]['done'] = true;
      _addXp(_dailyTasks[0]['exp']);
      _addXp(_dailyTasks[1]['exp']);
    } else if (h >= 2) {
      _dailyTasks[0]['done'] = true;
      _dailyTasks[1]['done'] = true;
      _dailyTasks[2]['done'] = true;
      _addXp(_dailyTasks[0]['exp']);
      _addXp(_dailyTasks[1]['exp']);
      _addXp(_dailyTasks[2]['exp']);
    }
  }

  void _updateTaskCompletion() {
    if (user == null) return;
    int total = _dailyTasks.length;
    int done = _dailyTasks.where((t) => t['done'] == true).length;
    double rate = done / total;

    final updated = user!.copyWith(taskCompletionRate: rate);
    AppController.instance.updateUser(updated);
  }

  void _addXp(int exp) {
    if (user == null) return;
    int newXp = user!.xp + exp;
    int newLevel = user!.level;

    while (newXp >= levelExp && newLevel < maxLevel) {
      newXp -= levelExp;
      newLevel++;
    }

    final updated = user!.copyWith(
      xp: newXp,
      level: newLevel,
    );
    AppController.instance.updateUser(updated);
    setState(() {});
    widget.refresh(); // 同步通知HomePage更新
  }

  String _getVideoButtonImage(int level) {
    if (level == 1) return 'assets/images/panda1.png';
    if (level == 2) return 'assets/images/panda2.png';
    return 'assets/images/panda3.png';
  }

  Future<void> _initVideo() async {
    if (user == null) return;
    int level = user!.level;
    String videoPath;

    if (level == 1) {
      videoPath = 'assets/videos/video_under15.mp4';
    } else if (level == 2) {
      videoPath = 'assets/videos/video_15to30.mp4';
    } else {
      videoPath = 'assets/videos/video_max30.mp4';
    }

    videoController = VideoPlayerController.asset(videoPath);
    await videoController!.initialize();
    videoController!.play();
    videoController!.setLooping(true);
    setState(() {});
  }

  Future<void> _loadData() async {
    if (user == null) return;
    setState(() {
      _frequencyController.text = user!.weeklyWorkoutCount.toString();
      _durationController.text = (user!.dailyWorkoutMinutes / 60).toStringAsFixed(1);
      _updateWorkoutTaskByHour(user!.dailyWorkoutMinutes / 60);
      _updateTaskCompletion();
      _loading = false;
    });
  }

  @override
  void dispose() {
    _frequencyController.dispose();
    _durationController.dispose();
    _pageController.dispose();
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'AWARD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                _buildProgressCard(),
                const SizedBox(height: 20),
                _buildSportsBuddyCarousel(),
                const SizedBox(height: 20),
                _buildDailyTaskBar(),
                const SizedBox(height: 20),
                _buildFitnessStats(),
                const SizedBox(height: 30),
              ],
            ),
          ),
          if (showVideoPopup) _buildVideoPopupWidget(),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    int level = user!.level;
    int currentXp = user!.xp;
    int maxXp = levelExp;

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [mainGreen, Color(0xFF89C15B)]),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.black,
                radius: 25,
                child: Icon(Icons.star, color: mainGreen),
              ),
              const SizedBox(width: 15),
              Text(
                'Lv.$level',
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              Text(
                level == maxLevel ? 'MAX' : '$currentXp / $maxXp EXP',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: level == maxLevel ? 1.0 : (currentXp / maxXp).clamp(0.0, 1.0),
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSportsBuddyCarousel() {
    int userLevel = user!.level;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          const Text(
            'Sports Buddy',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _buddyForms.length,
              itemBuilder: (context, index) {
                final form = _buddyForms[index];
                bool unlocked = userLevel >= form['unlockLevel'];

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    ColorFiltered(
                      colorFilter: unlocked
                          ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                          : const ColorFilter.matrix([
                        0.2126, 0.7152, 0.722, 0, 0,
                        0.2126, 0.7152, 0.722, 0, 0,
                        0.2126, 0.7152, 0.722, 0, 0,
                        0, 0, 0, 1, 0,
                      ]),
                      child: Image.asset(
                        form['asset'],
                        height: 140,
                        errorBuilder: (_, __, ___) => const Icon(Icons.pets, size: 80),
                      ),
                    ),
                    if (!unlocked)
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.lock, color: Colors.white, size: 40),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buddyForms.map((form) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  children: [
                    Text(
                      form['name'],
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Lv.${form['unlockLevel']}',
                      style: TextStyle(fontSize: 11, color: mainGreen),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTaskBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Task Bar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _doCheckIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('Check-in', style: TextStyle(color: Colors.black, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._dailyTasks.map((task) {
            bool done = task['done'] == true;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    '• ${task['text']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: done ? mainGreen : Colors.black,
                      fontWeight: done ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const Spacer(),
                  Text('+${task['exp']} EXP', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFitnessStats() {
    final labels = ['Frequency', 'Duration', 'Vitality', 'Completion', 'Growth'];

    List<double> radarValues = [
      user!.weeklyWorkoutCount.toDouble(),
      (user!.dailyWorkoutMinutes / 60),
      user!.level.toDouble(),
      user!.taskCompletionRate * 100,
      user!.level.toDouble(),
    ];

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          children: [
            const Text(
              'Fitness Stats',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _frequencyController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        labelText: 'Weekly Frequency',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) {
                        _saveFitnessData();
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _durationController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        labelText: 'Accumulate Hour',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) {
                        _saveFitnessData();
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      _saveFitnessData();
                      FocusScope.of(context).unfocus();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: mainGreen),
                    child: const Text('SAVE', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 260,
                    child: CustomPaint(
                      painter: _RadarPainter(
                        values: radarValues,
                        labels: labels,
                        maxValues: const [7, 5, 3, 100, 3],
                        color: mainGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () async {
                    await _initVideo();
                    setState(() => showVideoPopup = true);
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(_getVideoButtonImage(user!.level), fit: BoxFit.cover),
                          const Center(
                            child: Text(
                              'Press me 🥰',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPopupWidget() {
    return Stack(
      children: [
        ModalBarrier(
          color: Colors.black54,
          dismissible: true,
          onDismiss: () {
            videoController?.pause();
            setState(() => showVideoPopup = false);
          },
        ),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 320,
                height: 400,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white30),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: videoController != null && videoController!.value.isInitialized
                            ? AspectRatio(
                          aspectRatio: videoController!.value.aspectRatio,
                          child: VideoPlayer(videoController!),
                        )
                            : const CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            const BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(1, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Hello! 🥰',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF444444),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          videoController?.pause();
                          setState(() => showVideoPopup = false);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RadarPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final List<double> maxValues;
  final Color color;

  const _RadarPainter({
    required this.values,
    required this.labels,
    required this.maxValues,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;
    const sides = 5;
    final angleStep = 2 * pi / sides;

    final normalized = List.generate(
      sides,
      (i) => values[i] / maxValues[i].clamp(0.1, double.infinity),
    );

    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int i = 1; i <= 3; i++) {
      final r = radius * i / 3;
      final path = Path();
      for (int j = 0; j < sides; j++) {
        final a = angleStep * j - pi / 2;
        final x = center.dx + r * cos(a);
        final y = center.dy + r * sin(a);
        j == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    final axisPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;
    for (int i = 0; i < sides; i++) {
      final a = angleStep * i - pi / 2;
      canvas.drawLine(
        center,
        Offset(center.dx + radius * cos(a), center.dy + radius * sin(a)),
        axisPaint,
      );
    }

    final dataPath = Path();
    for (int i = 0; i < sides; i++) {
      final a = angleStep * i - pi / 2;
      final r = radius * normalized[i];
      final x = center.dx + r * cos(a);
      final y = center.dy + r * sin(a);
      i == 0 ? dataPath.moveTo(x, y) : dataPath.lineTo(x, y);
    }
    dataPath.close();

    canvas.drawPath(
      dataPath,
      Paint()..color = color.withOpacity(0.3)..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      dataPath,
      Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.5,
    );

    for (int i = 0; i < sides; i++) {
      final a = angleStep * i - pi / 2;
      final r = radius * normalized[i];
      canvas.drawCircle(
        Offset(center.dx + r * cos(a), center.dy + r * sin(a)),
        4,
        Paint()..color = color,
      );
    }

    for (int i = 0; i < sides; i++) {
      final a = angleStep * i - pi / 2;
      final pos = Offset(
        center.dx + (radius + 30) * cos(a),
        center.dy + (radius + 30) * sin(a),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, pos.translate(-tp.width / 2, -tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.labels != labels ||
        oldDelegate.maxValues != maxValues ||
        oldDelegate.color != color;
  }
}