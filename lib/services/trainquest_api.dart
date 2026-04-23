import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/trainquest_models.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class TrainQuestApi {
  TrainQuestApi({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final json = await _sendJson(
      'POST',
      '/api/auth/login',
      body: <String, dynamic>{
        'email': email,
        'password': password,
      },
    );

    return AuthSession.fromJson(json);
  }

  Future<AuthSession> register({
    required String username,
    required String email,
    required String password,
  }) async {
    await _sendJson(
      'POST',
      '/api/auth/register',
      body: <String, dynamic>{
        'username': username,
        'email': email,
        'password': password,
      },
    );

    return login(email: email, password: password);
  }

  Future<DashboardData> fetchHome(String token) async {
    final json = await _sendJson(
      'GET',
      '/api/dashboard/home',
      token: token,
    );
    return DashboardData.fromJson(json);
  }

  Future<List<AppTask>> fetchTasks(
    String token, {
    String? category,
  }) async {
    final jsonList = await _sendJsonList(
      'GET',
      '/api/tasks',
      token: token,
      query: <String, String>{
        if (category != null && category.isNotEmpty) 'category': category,
      },
    );

    return jsonList.map(AppTask.fromJson).toList();
  }

  Future<AppTask> createTask(
    String token, {
    required String title,
    required String category,
    String description = '',
    String difficulty = 'easy',
    String timeSlot = '',
  }) async {
    final json = await _sendJson(
      'POST',
      '/api/tasks',
      token: token,
      body: <String, dynamic>{
        'title': title,
        'description': description,
        'category': category,
        'difficulty': difficulty,
        'time_slot': timeSlot,
      },
    );

    return AppTask.fromJson(
      json['task'] as Map<String, dynamic>? ?? <String, dynamic>{},
    );
  }

  Future<AppTask> completeTask(String token, int taskId) async {
    final json = await _sendJson(
      'PATCH',
      '/api/tasks/$taskId/complete',
      token: token,
    );

    return AppTask.fromJson(
      json['task'] as Map<String, dynamic>? ?? <String, dynamic>{},
    );
  }
  // 取消完成任务（变回未完成）
Future<AppTask> uncompleteTask(String token, int taskId) async {
  final json = await _sendJson(
    'PATCH',
    '/api/tasks/$taskId/uncomplete',
    token: token,
  );

  return AppTask.fromJson(
    json['task'] as Map<String, dynamic>? ?? <String, dynamic>{},
  );
}

  Future<void> deleteTask(String token, int taskId) async {
    await _sendJson(
      'DELETE',
      '/api/tasks/$taskId',
      token: token,
    );
  }

  Future<ProgressRecordModel> fetchTodayProgress(String token) async {
    final json = await _sendJson(
      'GET',
      '/api/progress/today',
      token: token,
    );
    return ProgressRecordModel.fromJson(json);
  }

  Future<ProgressRecordModel> updateTodayProgress(
    String token, {
    required int steps,
    required int workoutMinutes,
    required int calories,
    required double distanceKm,
  }) async {
    final json = await _sendJson(
      'POST',
      '/api/progress/today',
      token: token,
      body: <String, dynamic>{
        'steps': steps,
        'workout_minutes': workoutMinutes,
        'calories': calories,
        'distance_km': distanceKm,
      },
    );

    return ProgressRecordModel.fromJson(
      json['record'] as Map<String, dynamic>? ?? <String, dynamic>{},
    );
  }

  Future<SignInResult> signInToday(String token) async {
    final json = await _sendJson(
      'POST',
      '/api/progress/sign-in',
      token: token,
    );

    final newBadges = (json['new_badges'] as List<dynamic>? ?? <dynamic>[])
        .map((dynamic item) => item.toString())
        .toList();

    return SignInResult(
      record: ProgressRecordModel.fromJson(
        json['record'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      user: AppUser.fromJson(
        json['user'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      newBadges: newBadges,
    );
  }

  Future<List<WorkoutPhotoModel>> fetchPhotos(String token) async {
    final jsonList = await _sendJsonList(
      'GET',
      '/api/photos',
      token: token,
    );

    return jsonList.map(WorkoutPhotoModel.fromJson).toList();
  }

  Future<WorkoutPhotoModel> uploadPhoto(
    String token,
    File file, {
    String caption = '',
  }) async {
    final request = http.MultipartRequest(
      'POST',
      _buildUri('/api/photos'),
    );
    request.headers.addAll(_headers(token: token, isJson: false));
    request.files.add(await http.MultipartFile.fromPath('photo', file.path));
    request.fields['caption'] = caption;

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final json = _decodeJson(body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_messageFromJson(json));
    }

    return WorkoutPhotoModel.fromJson(
      json['photo'] as Map<String, dynamic>? ?? <String, dynamic>{},
    );
  }

  Future<List<BadgeModel>> fetchBadges(String token) async {
    final jsonList = await _sendJsonList(
      'GET',
      '/api/badges',
      token: token,
    );

    return jsonList.map(BadgeModel.fromUserBadgeJson).toList();
  }

  Future<Map<String, dynamic>> _sendJson(
    String method,
    String path, {
    String? token,
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    final response = await _send(
      method,
      path,
      token: token,
      body: body,
      query: query,
    );

    final json = _decodeJson(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_messageFromJson(json));
    }

    return json;
  }

  Future<List<Map<String, dynamic>>> _sendJsonList(
    String method,
    String path, {
    String? token,
    Map<String, String>? query,
  }) async {
    final response = await _send(
      method,
      path,
      token: token,
      query: query,
    );

    final decoded = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final json = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      throw ApiException(_messageFromJson(json));
    }

    if (decoded is! List<dynamic>) {
      throw const ApiException('Unexpected response from server.');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map((Map<String, dynamic> item) => item)
        .toList();
  }

  Future<http.Response> _send(
    String method,
    String path, {
    String? token,
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) {
    final uri = _buildUri(path, query: query);
    final headers = _headers(token: token);

    switch (method.toUpperCase()) {
      case 'GET':
        return _client.get(uri, headers: headers);
      case 'POST':
        return _client.post(
          uri,
          headers: headers,
          body: jsonEncode(body ?? <String, dynamic>{}),
        );
      case 'PATCH':
        return _client.patch(
          uri,
          headers: headers,
          body: jsonEncode(body ?? <String, dynamic>{}),
        );
      case 'DELETE':
        return _client.delete(uri, headers: headers);
      default:
        throw ApiException('Unsupported request method: $method');
    }
  }

  Uri _buildUri(String path, {Map<String, String>? query}) {
    final uri = Uri.parse('$baseUrl$path');
    if (query == null || query.isEmpty) {
      return uri;
    }
    return uri.replace(
      queryParameters: <String, String>{
        ...uri.queryParameters,
        ...query,
      },
    );
  }

  Map<String, String> _headers({
    String? token,
    bool isJson = true,
  }) {
    return <String, String>{
      if (isJson) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decodeJson(String body) {
    if (body.isEmpty) {
      return <String, dynamic>{};
    }
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return <String, dynamic>{};
  }

  String _messageFromJson(Map<String, dynamic> json) {
    return json['message']?.toString() ?? 'Request failed. Please try again.';
  }
}
