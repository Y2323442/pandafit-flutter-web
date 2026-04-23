import 'package:flutter/foundation.dart';

// 简易翻译（中英双语）
class AppLocalization {
  static Map<String, String> en = {
    "Language": "Language",
    "Apply Changes": "Apply Changes",
    "Search language...": "Search language...",
    "Home": "Home",
    "Task": "Task",
    "Award": "Award",
    "Grow": "Grow",
    "Me": "Me",
  };

  static Map<String, String> zh = {
    "Language": "语言",
    "Apply Changes": "应用",
    "Search language...": "搜索语言...",
    "Home": "首页",
    "Task": "任务",
    "Award": "奖励",
    "Grow": "成长",
    "Me": "我的",
  };

  static String translate(String key, String code) {
    if (code == "zh") return zh[key] ?? key;
    return en[key] ?? key;
  }
}

// 全局语言状态
class AppLang extends ChangeNotifier {
  String _code = "en";
  String get code => _code;

  void setLang(String newCode) {
    _code = newCode;
    notifyListeners();
  }
}