class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.level,
    required this.xp,
    required this.streakDays,
    required this.totalSignInDays,
    // 新增五边形数据字段
    required this.weeklyWorkoutCount,
    required this.dailyWorkoutMinutes,
    required this.taskCompletionRate,
    this.createdAt,
    this.signInDates,
  });

  final int id;
  final String username;
  final String email;
  final int level;
  final int xp;
  final int streakDays;
  final int totalSignInDays;
  final DateTime? createdAt;
  final List<String>? signInDates;

  // 五边形核心字段
  final int weeklyWorkoutCount;
  final int dailyWorkoutMinutes;
  final double taskCompletionRate;

  // 👇 修复：解析后端返回的新字段
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: _asInt(json['id']),
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      level: _asInt(json['level']),
      xp: _asInt(json['xp']),
      streakDays: _asInt(json['streakDays']),
      totalSignInDays: _asInt(json['totalSignInDays']),
      weeklyWorkoutCount: _asInt(json['weeklyWorkoutCount']),
      dailyWorkoutMinutes: _asInt(json['dailyWorkoutMinutes']),
      taskCompletionRate: _asDouble(json['taskCompletionRate']),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      signInDates: List<String>.from(json['sign_in_dates'] ?? []),
    );
  }

  // 👇 修复：序列化新增字段
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'username': username,
      'email': email,
      'level': level,
      'xp': xp,
      'streak_days': streakDays,
      'total_sign_in_days': totalSignInDays,
      'weeklyWorkoutCount': weeklyWorkoutCount,
      'dailyWorkoutMinutes': dailyWorkoutMinutes,
      'taskCompletionRate': taskCompletionRate,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // 👇 修复：copyWith 包含新字段
  AppUser copyWith({
    int? id,
    String? username,
    String? email,
    int? level,
    int? xp,
    int? streakDays,
    int? totalSignInDays,
    int? weeklyWorkoutCount,
    int? dailyWorkoutMinutes,
    double? taskCompletionRate,
    DateTime? createdAt,
    List<String>? signInDates,
  }) {
    return AppUser(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      streakDays: streakDays ?? this.streakDays,
      totalSignInDays: totalSignInDays ?? this.totalSignInDays,
      weeklyWorkoutCount: weeklyWorkoutCount ?? this.weeklyWorkoutCount,
      dailyWorkoutMinutes: dailyWorkoutMinutes ?? this.dailyWorkoutMinutes,
      taskCompletionRate: taskCompletionRate ?? this.taskCompletionRate,
      createdAt: createdAt ?? this.createdAt,
      signInDates: signInDates ?? this.signInDates,
    );
  }
}

// ======================
// 以下代码保持不变
// ======================
class AppTask {
  const AppTask({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.difficulty,
    required this.timeSlot,
    this.createdAt,
    this.completedAt,
    required this.order,
  });

  final int id;
  final int userId;
  final String title;
  final String description;
  final String category;
  final String status;
  final String difficulty;
  final String timeSlot;
  final DateTime? createdAt;
  final DateTime? completedAt;
  final int order;

  bool get isCompleted => status.toLowerCase() == 'completed';

  factory AppTask.fromJson(Map<String, dynamic> json) {
    return AppTask(
      id: _asInt(json['id']),
      userId: _asInt(json['user_id']),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'daily',
      status: json['status']?.toString() ?? 'pending',
      difficulty: json['difficulty']?.toString() ?? 'easy',
      timeSlot: json['time_slot']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      completedAt: DateTime.tryParse(json['completed_at']?.toString() ?? ''),
      order: _asInt(json['order']),
    );
  }
}

class WeeklySummary {
  const WeeklySummary({
    required this.totalSteps,
    required this.totalMinutes,
    required this.totalDistance,
    required this.signedDays,
    required this.completionRate,
  });

  final int totalSteps;
  final int totalMinutes;
  final double totalDistance;
  final int signedDays;
  final double completionRate;

  factory WeeklySummary.fromJson(Map<String, dynamic> json) {
    return WeeklySummary(
      totalSteps: _asInt(json['total_steps']),
      totalMinutes: _asInt(json['total_minutes']),
      totalDistance: _asDouble(json['total_distance']),
      signedDays: _asInt(json['signed_days']),
      completionRate: _asDouble(json['completion_rate']),
    );
  }
}

class DashboardData {
  const DashboardData({
    required this.user,
    required this.dailyTasks,
    required this.weeklySummary,
    required this.completionRate,
  });

  final AppUser user;
  final List<AppTask> dailyTasks;
  final WeeklySummary weeklySummary;
  final double completionRate;

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final rawTasks = json['daily_tasks'] as List<dynamic>? ?? <dynamic>[];

    return DashboardData(
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      dailyTasks: rawTasks
          .whereType<Map<String, dynamic>>()
          .map(AppTask.fromJson)
          .toList(),
      weeklySummary: WeeklySummary.fromJson(
        json['weekly_summary'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      completionRate: _asDouble(json['completionRate'] ?? 0.0),
    );
  }
}

class ProgressRecordModel {
  const ProgressRecordModel({
    required this.id,
    required this.userId,
    required this.recordDate,
    required this.steps,
    required this.workoutMinutes,
    required this.calories,
    required this.distanceKm,
    required this.signedIn,
  });

  final int id;
  final int userId;
  final DateTime? recordDate;
  final int steps;
  final int workoutMinutes;
  final int calories;
  final double distanceKm;
  final bool signedIn;

  factory ProgressRecordModel.fromJson(Map<String, dynamic> json) {
    return ProgressRecordModel(
      id: _asInt(json['id']),
      userId: _asInt(json['user_id']),
      recordDate: DateTime.tryParse(json['record_date']?.toString() ?? ''),
      steps: _asInt(json['steps']),
      workoutMinutes: _asInt(json['workout_minutes']),
      calories: _asInt(json['calories']),
      distanceKm: _asDouble(json['distance_km']),
      signedIn: json['signed_in'] == true,
    );
  }
}

class WorkoutPhotoModel {
  const WorkoutPhotoModel({
    required this.id,
    required this.userId,
    required this.filename,
    required this.caption,
    this.uploadedAt,
  });

  final int id;
  final int userId;
  final String filename;
  final String caption;
  final DateTime? uploadedAt;

  factory WorkoutPhotoModel.fromJson(Map<String, dynamic> json) {
    return WorkoutPhotoModel(
      id: _asInt(json['id']),
      userId: _asInt(json['user_id']),
      filename: json['filename']?.toString() ?? '',
      caption: json['caption']?.toString() ?? '',
      uploadedAt: DateTime.tryParse(json['uploaded_at']?.toString() ?? ''),
    );
  }

  String imageUrl(String baseUrl) => '$baseUrl/uploads/$filename';
}

class BadgeModel {
  const BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.threshold,
    required this.badgeType,
    this.earnedAt,
  });

  final int id;
  final String name;
  final String description;
  final int threshold;
  final String badgeType;
  final DateTime? earnedAt;

  factory BadgeModel.fromUserBadgeJson(Map<String, dynamic> json) {
    final badge = json['badge'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return BadgeModel(
      id: _asInt(badge['id']),
      name: badge['name']?.toString() ?? 'Badge',
      description: badge['description']?.toString() ?? '',
      threshold: _asInt(badge['threshold']),
      badgeType: badge['badge_type']?.toString() ?? 'streak',
      earnedAt: DateTime.tryParse(json['earned_at']?.toString() ?? ''),
    );
  }
}

class AuthSession {
  const AuthSession({
    required this.token,
    required this.user,
  });

  final String token;
  final AppUser user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: json['token']?.toString() ?? '',
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>? ?? <String, dynamic>{}),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'token': token,
      'user': user.toJson(),
    };
  }
}

class SignInResult {
  const SignInResult({
    required this.record,
    required this.user,
    required this.newBadges,
  });

  final ProgressRecordModel record;
  final AppUser user;
  final List<String> newBadges;
}

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.round();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}