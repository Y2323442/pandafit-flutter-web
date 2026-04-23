import 'package:flutter/foundation.dart';

import 'models/trainquest_models.dart';
import 'services/session_store.dart';
import 'services/trainquest_api.dart';

class AppController extends ChangeNotifier {
  AppController({
    required TrainQuestApi api,
    required SessionStore sessionStore,
  })  : _api = api,
        _sessionStore = sessionStore;

  final TrainQuestApi _api;
  final SessionStore _sessionStore;

  bool _bootstrapping = true;
  bool _authenticating = false;
  String? _token;
  AppUser? _user;
  String? _authError;

  bool get isBootstrapping => _bootstrapping;
  bool get isAuthenticating => _authenticating;
  bool get isAuthenticated => _token != null && _user != null;
  String get baseUrl => _api.baseUrl;
  String get token => _token ?? '';
  AppUser? get user => _user;
  String? get authError => _authError;
  TrainQuestApi get api => _api;

  Future<void> bootstrap() async {
    if (!_bootstrapping) {
      return;
    }

    final session = await _sessionStore.restore();
    if (session != null && session.token.isNotEmpty) {
      _token = session.token;
      _user = session.user;

      try {
        final dashboard = await _api.fetchHome(session.token);
        _user = dashboard.user;
        await _sessionStore.save(AuthSession(token: session.token, user: dashboard.user));
      } catch (_) {
        await _sessionStore.clear();
        _token = null;
        _user = null;
      }
    }

    _bootstrapping = false;
    notifyListeners();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _authenticating = true;
    _authError = null;
    notifyListeners();

    try {
      final session = await _api.login(email: email, password: password);
      await _setSession(session);
    } catch (error) {
      _authError = error.toString();
    } finally {
      _authenticating = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _authenticating = true;
    _authError = null;
    notifyListeners();

    try {
      final session = await _api.register(
        username: username,
        email: email,
        password: password,
      );
      await _setSession(session);
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
    await _sessionStore.clear();
    notifyListeners();
  }

  Future<void> updateUser(AppUser user) async {
    _user = user;
    if (_token != null && _token!.isNotEmpty) {
      await _sessionStore.save(AuthSession(token: _token!, user: user));
    }
    notifyListeners();
  }

  Future<void> clearAuthError() async {
    _authError = null;
    notifyListeners();
  }

  Future<void> _setSession(AuthSession session) async {
    _token = session.token;
    _user = session.user;
    await _sessionStore.save(session);
  }

  // ✅ 自动签到（你原来就有，我保留）
  Future<bool> autoSignInToday() async {
    return false;
  }

  // ==============================
  // ✅【添加：userSignIn —— 完全不爆红】
 Future<void> userSignIn() async {
  if (_user == null) return;

  final now = DateTime.now();
  final today = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

  // 安全读取可空字段
  final currentDates = _user!.signInDates ?? [];
  if (currentDates.contains(today)) return;

  // ⬇️⬇️⬇️ 关键：用 copyWith 创建新对象，不修改原对象
  final updatedUser = _user!.copyWith(
    signInDates: [...currentDates, today],
    totalSignInDays: currentDates.length + 1,
  );

  await updateUser(updatedUser);
}
}