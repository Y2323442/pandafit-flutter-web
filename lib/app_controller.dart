import 'package:flutter/foundation.dart';
import 'models/trainquest_models.dart';

class AppController extends ChangeNotifier {
  AppController();

  bool _bootstrapping = false;
  bool _authenticating = false;
  String? _token;
  AppUser? _user;
  String? _authError;

  bool get isBootstrapping => _bootstrapping;
  bool get isAuthenticating => _authenticating;
  bool get isAuthenticated => _token != null && _user != null;
  String get token => _token ?? '';
  AppUser? get user => _user;
  String? get authError => _authError;

  Future<void> bootstrap() async {
    _bootstrapping = false;
    notifyListeners();
  }

  // 纯本地模拟登录
  Future<void> login({
    required String email,
    required String password,
  }) async {
    _authenticating = true;
    _authError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 600));

      // ✅ 完全匹配你的 AppUser 构造函数
      _token = "local_demo_token";
      _user = AppUser(
        id: 1,
        username: email.split('@').first,
        email: email,
        level: 1,
        xp: 0,
        streakDays: 0,
        totalSignInDays: 0,
        weeklyWorkoutCount: 0,
        dailyWorkoutMinutes: 0,
        taskCompletionRate: 0.0,
        createdAt: DateTime.now(),
        signInDates: [],
      );
    } catch (error) {
      _authError = error.toString();
    } finally {
      _authenticating = false;
      notifyListeners();
    }
  }

  // 纯本地模拟注册
  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _authenticating = true;
    _authError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 600));

      // ✅ 完全匹配你的 AppUser
      _token = "local_demo_token";
      _user = AppUser(
        id: 1,
        username: username,
        email: email,
        level: 1,
        xp: 0,
        streakDays: 0,
        totalSignInDays: 0,
        weeklyWorkoutCount: 0,
        dailyWorkoutMinutes: 0,
        taskCompletionRate: 0.0,
        createdAt: DateTime.now(),
        signInDates: [],
      );
    } catch (error) {
      _authError = error.toString();
    } finally {
      _authenticating = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _authError = null;
    notifyListeners();
  }

  Future<void> updateUser(AppUser user) async {
    _user = user;
    notifyListeners();
  }

  Future<void> clearAuthError() async {
    _authError = null;
    notifyListeners();
  }

  Future<bool> autoSignInToday() async {
    return false;
  }

  // ✅ 你的签到逻辑完全不变
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

    await updateUser(updatedUser);
  }
}