import 'package:flutter/material.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  static const Color bgColor = Color(0xFFF1F8E9);
  static const Color mainGreen = Color(0xFFD1E683);
  static const Color darkCard = Color(0xFF1A1C1E);

  int _selectedTab = 0;
  bool _loading = false;
  String? _error;

  // 本地任务数据
  List<Map<String, dynamic>> _dailyTasks = [
    {"id": "1", "title": "晨间拉伸", "timeSlot": "07:00", "status": "completed"},
    {"id": "2", "title": "3公里跑步", "timeSlot": "18:00", "status": "active"},
    {"id": "3", "title": "睡前放松", "timeSlot": "21:00", "status": "active"},
  ];

  List<Map<String, dynamic>> _projects = [
    {"id": "10", "title": "减脂计划", "description": "每月目标4公里", "status": "active"},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData({bool showLoader = true}) async {
    setState(() => _loading = showLoader);
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() => _loading = false);
  }

  TimeOfDay _parseTimeOfDay(String timeStr) {
    try {
      final s = timeStr.trim().toLowerCase();
      final match = RegExp(r'(\d{1,2}):?(\d{0,2})\s*(am|pm)?', caseSensitive: false)
          .firstMatch(s);
      if (match == null) return const TimeOfDay(hour: 23, minute: 59);

      var hour = int.parse(match.group(1)!);
      final minute = int.tryParse(match.group(2) ?? '0') ?? 0;
      final period = match.group(3);

      if (period == 'pm') {
        if (hour < 12) hour += 12;
      } else if (period == 'am') {
        if (hour == 12) hour = 0;
      }
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return const TimeOfDay(hour: 23, minute: 59);
    }
  }

  Future<void> _showAddDialog() async {
    final titleController = TextEditingController();
    TimeOfDay? selectedTime = TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: bgColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(_selectedTab == 0 ? '添加每日任务' : '添加项目'),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: '标题',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              if (_selectedTab == 0)
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime ?? TimeOfDay.now(),
                    );
                    if (picked != null) setStateDialog(() => selectedTime = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(selectedTime?.format(context) ?? '选择时间'),
                        const Icon(Icons.access_time),
                      ],
                    ),
                  ),
                ),
            ]),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: () {
                  final title = titleController.text.trim();
                  if (title.isEmpty) return;

                  final timeStr = selectedTime?.format(context) ?? '';
                  setState(() {
                    if (_selectedTab == 0) {
                      _dailyTasks.add({
                        "id": DateTime.now().toString(),
                        "title": title,
                        "timeSlot": timeStr,
                        "status": "active",
                      });
                    } else {
                      _projects.add({
                        "id": DateTime.now().toString(),
                        "title": title,
                        "description": "",
                        "status": "active",
                      });
                    }
                  });
                  Navigator.pop(context);
                },
                child: Text('添加', style: TextStyle(color: mainGreen)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _toggleComplete(Map<String, dynamic> task) async {
    setState(() {
      task["status"] = task["status"] == "completed" ? "active" : "completed";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(task["status"] == "completed" ? "已完成" : "已取消完成")),
    );
  }

  Future<void> _deleteTask(Map<String, dynamic> task) async {
    final confirm = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('删除任务？'),
            content: Text('确定删除 "${task["title"]}"？'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('取消')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: () => Navigator.pop(c, true),
                child: Text('删除', style: TextStyle(color: mainGreen)),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;
    setState(() {
      _dailyTasks.removeWhere((e) => e["id"] == task["id"]);
      _projects.removeWhere((e) => e["id"] == task["id"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () => _loadData(showLoader: false),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    '任务',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '管理你的每日任务和项目',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  _buildTabs(),
                  const SizedBox(height: 24),
                  if (_loading)
                    const Padding(padding: EdgeInsets.only(top: 60), child: CircularProgressIndicator())
                  else if (_error != null)
                    _buildErrorCard()
                  else
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: _selectedTab == 0 ? _buildDailyList() : _buildProjectList(),
                    ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _ScaleTap(
                onTap: _showAddDialog,
                child: Container(
                  height: 66,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded, color: mainGreen, size: 26),
                      SizedBox(width: 10),
                      Text(
                        '添加新任务',
                        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        _tabButton('每日任务', 0),
        const SizedBox(width: 14),
        _tabButton('项目', 1),
      ],
    );
  }

  Widget _tabButton(String label, int index) {
    final active = _selectedTab == index;
    return _ScaleTap(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? mainGreen : Colors.black54,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildDailyList() {
    if (_dailyTasks.isEmpty) {
      return _buildEmptyCard('暂无每日任务', '添加你的第一个任务吧');
    }
    return Column(
      key: const ValueKey(0),
      children: [for (final task in _dailyTasks) _buildDailyItem(task)],
    );
  }

  Widget _buildDailyItem(Map<String, dynamic> task) {
    final done = task["status"] == "completed";
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: done ? mainGreen : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: done ? mainGreen : Colors.black12, width: 3),
                ),
              ),
              Expanded(child: Container(width: 2, color: Colors.black12)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _ScaleTap(
              onTap: () => _toggleComplete(task),
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: done ? Colors.black12 : darkCard,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task["timeSlot"].isNotEmpty ? task["timeSlot"] : '任意时间',
                            style: TextStyle(color: done ? Colors.black45 : mainGreen, fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            task["title"],
                            style: TextStyle(color: done ? Colors.black38 : Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _deleteTask(task),
                      icon: Icon(Icons.delete_outline, color: done ? Colors.black45 : Colors.white54),
                    ),
                    if (done) const Icon(Icons.check_circle, color: mainGreen, size: 26),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectList() {
    if (_projects.isEmpty) {
      return _buildEmptyCard('暂无项目', '创建项目来跟踪长期目标');
    }
    return Column(key: const ValueKey(1), children: [for (final task in _projects) _buildProjectCard(task)]);
  }

  Widget _buildProjectCard(Map<String, dynamic> task) {
    final done = task["status"] == "completed";
    final progress = done ? 1.0 : 0.35;

    return _ScaleTap(
      onTap: () => _toggleComplete(task),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(task["title"], style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
                IconButton(onPressed: () => _deleteTask(task), icon: const Icon(Icons.delete_outline, color: Colors.black38)),
              ],
            ),
            if (task["description"].isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(task["description"], style: const TextStyle(color: Colors.black54)),
            ],
            const SizedBox(height: 18),
            Stack(
              children: [
                Container(height: 10, decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8))),
                FractionallySizedBox(widthFactor: progress, child: Container(height: 10, decoration: BoxDecoration(color: mainGreen, borderRadius: BorderRadius.circular(8)))),
              ],
            ),
            const SizedBox(height: 8),
            Text(done ? '已完成' : '进行中', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: mainGreen)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 44, color: Colors.black38),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 6),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 44, color: Colors.redAccent),
          const SizedBox(height: 16),
          const Text('加载失败', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 18),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: _loadData,
            child: Text('重试', style: TextStyle(color: mainGreen)),
          ),
        ],
      ),
    );
  }
}

class _ScaleTap extends StatefulWidget {
  const _ScaleTap({super.key, required this.child, required this.onTap});
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
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(scale: _scale, duration: const Duration(milliseconds: 120), child: widget.child),
    );
  }
}