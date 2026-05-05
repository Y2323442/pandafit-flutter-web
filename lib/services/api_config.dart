import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _envBaseUrl =
      String.fromEnvironment('TRAINQUEST_API_BASE_URL', defaultValue: '');

  static String get baseUrl {
  
    return '';
  }
}