import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/trainquest_models.dart';

class LocalReport {
  static late SharedPreferences prefs;

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveUser(AppUser user) async {
    await prefs.setString('user', jsonEncode(user.toJson()));
  }

  static AppUser? loadUser() {
    final str = prefs.getString('user');
    if (str == null) return null;
    return AppUser.fromJson(jsonDecode(str));
  }

  static Future<void> clearUser() async {
    await prefs.remove('user');
  }

  static Future<void> saveTasks(List<AppTask> tasks) async {
    final list = tasks.map((t) => t.toJson()).toList();
    await prefs.setString('tasks', jsonEncode(list));
  }

  static List<AppTask> loadTasks() {
    final str = prefs.getString('tasks');
    if (str == null) return [];
    final list = jsonDecode(str) as List;
    return list.map((t) => AppTask.fromJson(t)).toList();
  }

  static Future<void> addTask(AppTask task) async {
    final tasks = loadTasks();
    tasks.add(task);
    await saveTasks(tasks);
  }

  static Future<void> updateTask(AppTask updated) async {
    final tasks = loadTasks();
    final index = tasks.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      tasks[index] = updated;
      await saveTasks(tasks);
    }
  }

  static Future<void> deleteTask(int id) async {
    final tasks = loadTasks();
    tasks.removeWhere((t) => t.id == id);
    await saveTasks(tasks);
  }
}