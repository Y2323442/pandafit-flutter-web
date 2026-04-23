import 'package:flutter/material.dart';

// 本地数据模型
class AppTask {
  final String id;
  final String title;
  final String description;
  final String timeSlot;
  final String status;
  final String category;

  AppTask({
    required this.id,
    required this.title,
    required this.description,
    required this.timeSlot,
    required this.status,
    required this.category,
  });
}

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
  bool _loading = true;
  String? _error;

  List<AppTask> _dailyTasks = <AppTask>[];
  List<AppTask> _projects = <AppTask>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  // 统一排序方法：按时间从小到大
  void _sortDailyTasksByTime() {
    _dailyTasks.sort((a, b) {
      final t1 = _parseTimeOfDay(a.timeSlot);
      final t2 = _parseTimeOfDay(b.timeSlot);
      final time1 = t1.hour * 60 + t1.minute;
      final time2 = t2.hour * 60 + t2.minute;
      return time1.compareTo(time2);
    });
  }

  Future<void> _loadData({bool showLoader = true}) async {
    if (showLoader) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      await Future.delayed(const Duration(milliseconds: 200));

      final defaultDaily = [
        AppTask(
          id: "1",
          title: "Morning Run",
          description: "",
          timeSlot: "07:00",
          status: "active",
          category: "daily",
        ),
        AppTask(
          id: "2",
          title: "10min Stretch",
          description: "",
          timeSlot: "12:00",
          status: "completed",
          category: "daily",
        ),
      ];

      final defaultProjects = [
        AppTask(
          id: "10",
          title: "Fitness Plan",
          description: "Weekly workout schedule",
          timeSlot: "",
          status: "active",
          category: "project",
        ),
      ];

      _dailyTasks = defaultDaily;
      _projects = defaultProjects;
      _sortDailyTasksByTime();

      if (!mounted) return;
      setState(() => _loading = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  // 时间解析 24小时制 纯净解析
  TimeOfDay _parseTimeOfDay(String timeStr) {
    try {
      final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(timeStr.trim());
      if (match == null) return const TimeOfDay(hour: 23, minute: 59);
      final hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return const TimeOfDay(hour: 23, minute: 59);
    }
  }

  // 格式化 24小时制 时钟样式
  String _format24Time(TimeOfDay time) {
    String h = time.hour.toString().padLeft(2, '0');
    String m = time.minute.toString().padLeft(2, '0');
    return "$h:$m";
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              _selectedTab == 0 ? 'Add Daily Task' : 'Add Project',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'Title',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
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
                        // 🔹优化1：全局24小时制时钟
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: mainGreen,
                                onPrimary: Colors.black,
                                onSurface: Colors.black,
                              ),
                              timePickerTheme: const TimePickerThemeData(
                                hourMinuteTextStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                ),
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(foregroundColor: Colors.black),
                              ),
                            ),
                            child: MediaQuery(
                              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                              child: child!,
                            ),
                          );
                        },
                      );
                      if (picked != null) {
                        setStateDialog(() => selectedTime = picked);
                      }
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
                          Text(
                            selectedTime != null ? _format24Time(selectedTime!) : 'Select time',
                            style: const TextStyle(fontSize: 15, letterSpacing: 1.2),
                          ),
                          const Icon(Icons.access_time_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final title = titleController.text.trim();
                  if (title.isEmpty) return;

                  final timeStr = selectedTime != null ? _format24Time(selectedTime!) : '';
                  final newTask = AppTask(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: title,
                    description: '',
                    timeSlot: timeStr,
                    status: 'active',
                    category: _selectedTab == 0 ? 'daily' : 'project',
                  );

                  setState(() {
                    if (_selectedTab == 0) {
                      _dailyTasks.add(newTask);
                      // 🔹优化2：新增任务自动重新按时间排序
                      _sortDailyTasksByTime();
                    } else {
                      _projects.add(newTask);
                    }
                  });

                  if (!mounted) return;
                  Navigator.pop(context);
                },
                child: const Text(
                  'Add',
                  style: TextStyle(color: mainGreen),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _toggleComplete(AppTask task) async {
    setState(() {
      if (task.category == 'daily') {
        _dailyTasks = _dailyTasks.map((t) {
          if (t.id == task.id) {
            return AppTask(
              id: t.id,
              title: t.title,
              description: t.description,
              timeSlot: t.timeSlot,
              status: t.status == 'completed' ? 'active' : 'completed',
              category: t.category,
            );
          }
          return t;
        }).toList();
        _sortDailyTasksByTime();
      } else {
        _projects = _projects.map((t) {
          if (t.id == task.id) {
            return AppTask(
              id: t.id,
              title: t.title,
              description: t.description,
              timeSlot: t.timeSlot,
              status: t.status == 'completed' ? 'active' : 'completed',
              category: t.category,
            );
          }
          return t;
        }).toList();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          task.status == 'completed' ? 'Completed canceled' : 'Marked as completed',
        ),
        backgroundColor: Colors.black,
      ),
    );
  }

  Future<void> _deleteTask(AppTask task) async {
    final confirm = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Delete task?'),
            content: Text('Delete "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: () => Navigator.pop(c, true),
                child: const Text('Delete', style: TextStyle(color: mainGreen)),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    setState(() {
      if (task.category == 'daily') {
        _dailyTasks.removeWhere((t) => t.id == task.id);
        _sortDailyTasksByTime();
      } else {
        _projects.removeWhere((t) => t.id == task.id);
      }
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
                    'Task',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Manage your daily tasks and projects',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  _buildTabs(),
                  const SizedBox(height: 24),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Center(child: CircularProgressIndicator()),
                    )
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded, color: mainGreen, size: 26),
                      SizedBox(width: 10),
                      Text(
                        'Add New Record',
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
        _tabButton('Daily Task', 0),
        const SizedBox(width: 14),
        _tabButton('Project', 1),
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
          boxShadow: [
            if (active)
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
          ],
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
      return _buildEmptyCard('No daily tasks yet', 'Add your first task to get started');
    }
    return Column(
      key: const ValueKey(0),
      children: [for (final task in _dailyTasks) _buildDailyItem(task)],
    );
  }

  Widget _buildDailyItem(AppTask task) {
    final done = task.status == 'completed';
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
                            task.timeSlot.isNotEmpty ? task.timeSlot : 'Any time',
                            style: TextStyle(
                              color: done ? Colors.black45 : mainGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            task.title,
                            style: TextStyle(color: done ? Colors.black38 : Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _deleteTask(task),
                      icon: Icon(
                        Icons.delete_outline,
                        color: done ? Colors.black45 : Colors.white54,
                      ),
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
      return _buildEmptyCard('No projects yet', 'Create a project to track long-term goals');
    }
    return Column(
      key: const ValueKey(1),
      children: [for (final task in _projects) _buildProjectCard(task)],
    );
  }

  Widget _buildProjectCard(AppTask task) {
    final done = task.status == 'completed';
    final progress = done ? 1.0 : 0.35;

    return _ScaleTap(
      onTap: () => _toggleComplete(task),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 12)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(task.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  onPressed: () => _deleteTask(task),
                  icon: const Icon(Icons.delete_outline, color: Colors.black38),
                ),
              ],
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(task.description, style: const TextStyle(color: Colors.black54)),
            ],
            const SizedBox(height: 18),
            Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(color: mainGreen, borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              done ? 'Completed' : 'In progress',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: mainGreen),
            ),
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
          Icon(Icons.inbox_outlined, size: 44, color: Colors.black38.withOpacity(0.4)),
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
          Text(
            _error ?? 'Failed to load tasks',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () => _loadData(),
            child: const Text('Retry', style: TextStyle(color: mainGreen)),
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
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}