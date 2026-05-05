import 'package:flutter/foundation.dart';
import 'models/trainquest_models.dart';
import 'local_report.dart';

class AppController extends ChangeNotifier {
  static final AppController instance = AppController();
  AppController();

  bool _bootstrapping = false;
  AppUser? _user;
  List<AppTask> _tasks = [];

  List<AppTask> get tasks => _tasks;
  bool get isBootstrapping => _bootstrapping;
  bool get isAuthenticated => true;
  AppUser? get user => _user;

  Future<void> bootstrap() async {
    _bootstrapping = true;
    notifyListeners();

    _tasks = LocalReport.loadTasks();

    _user = const AppUser(
      id: 1,
      username: "User",
      email: "User@pandafit.com",
      level: 1,
      xp: 0,
      streakDays: 0,
      totalSignInDays: 0,
      weeklyWorkoutCount: 0,
      dailyWorkoutMinutes: 0,
      taskCompletionRate: 0.0,
      createdAt: null,
      signInDates: [],
    );

    _bootstrapping = false;
    notifyListeners();
  }

  Future<void> toggleTask(AppTask task) async {
    final newStatus = task.isCompleted ? "pending" : "completed";

    final updated = AppTask(
      id: task.id,
      userId: task.userId,
      title: task.title,
      description: task.description,
      category: task.category,
      status: newStatus,
      difficulty: task.difficulty,
      timeSlot: task.timeSlot,
      createdAt: task.createdAt,
      completedAt: newStatus == "completed" ? DateTime.now() : null,
      order: task.order,
    );

    await LocalReport.updateTask(updated);
    _tasks = LocalReport.loadTasks();
    notifyListeners();
  }

  Future<void> addNewTask(String title, String timeSlot, {String category = "daily"}) async {
    final newTask = AppTask(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      userId: user?.id ?? 1,
      title: title,
      description: "",
      category: category,
      status: "pending",
      difficulty: "easy",
      timeSlot: timeSlot,
      createdAt: DateTime.now(),
      completedAt: null,
      order: tasks.length,
    );

    await LocalReport.addTask(newTask);
    _tasks = LocalReport.loadTasks();
    notifyListeners();
  }

  Future<void> deleteTask(AppTask task) async {
    await LocalReport.deleteTask(task.id);
    _tasks = LocalReport.loadTasks();
    notifyListeners();
  }

  Future<void> userSignIn() async {
    if (_user == null) return;
    final now = DateTime.now();
    final today = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final currentDates = _user!.signInDates ?? [];
    if (currentDates.contains(today)) return;

    final updatedUser = _user!.copyWith(
      signInDates: [...currentDates, today],
      totalSignInDays: currentDates.length + 1,
    );

    _user = updatedUser;
    notifyListeners();
    await LocalReport.saveUser(_user!);
  }

  Future<void> updateUser(AppUser user) async {
    _user = user;
    notifyListeners();
    await LocalReport.saveUser(user);
  }
}