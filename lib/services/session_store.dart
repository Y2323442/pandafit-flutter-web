import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/trainquest_models.dart';

class SessionStore {
  static const String _sessionKey = 'trainquest_session';

  Future<AuthSession?> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final rawValue = prefs.getString(_sessionKey);

    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    try {
      final json = jsonDecode(rawValue) as Map<String, dynamic>;
      return AuthSession.fromJson(json);
    } catch (_) {
      await prefs.remove(_sessionKey);
      return null;
    }
  }

  Future<void> save(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
