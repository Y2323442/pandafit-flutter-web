import 'package:flutter/material.dart';
import 'app_controller.dart';
import 'models/trainquest_models.dart';

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

  // 🔥 核心：这里会自动返回【按时间排序好】的任务
  List<AppTask> get _dailyTasks {
    final tasks = AppController.instance.tasks.where((t) => t.category == 'daily').toList();
    _sortTasksByTime(tasks); // 自动排序
    return tasks;
  }

  List<AppTask> get _projects =>
      AppController.instance.tasks.where((t) => t.category == 'project').toList();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  // 🔥 任务时间排序方法（正确稳定版）
  void _sortTasksByTime(List<AppTask> tasks) {
    tasks.sort((a, b) {
      final time1 = _getTimeMinutes(a.timeSlot);
      final time2 = _getTimeMinutes(b.timeSlot);
      return time1.compareTo(time2);
    });
  }

  // 把时间字符串转为分钟数（用于排序）
  int _getTimeMinutes(String timeStr) {
    try {
      final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(timeStr.trim());
      if (match == null) return 9999;
      final h = int.parse(match.group(1)!);
      final m = int.parse(match.group(2)!);
      return h * 60 + m;
    } catch (_) {
      return 9999;
    }
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
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

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

                  final cat = _selectedTab == 0 ? 'daily' : 'project';
                  await AppController.instance.addNewTask(title, timeStr, category: cat);

                  if (!mounted) return;
                  Navigator.pop(context);
                  setState(() {});
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
    await AppController.instance.toggleTask(task);
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          task.isCompleted ? 'Completed canceled' : 'Marked as completed',
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
    await AppController.instance.deleteTask(task);
    setState(() {});
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
    final done = task.isCompleted;
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
    final done = task.isCompleted;
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