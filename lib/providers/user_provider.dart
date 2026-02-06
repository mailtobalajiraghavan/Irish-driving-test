import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/test_result.dart';
import '../services/analytics_service.dart';

class UserProvider with ChangeNotifier {
  int _totalXp = 0;
  int _currentStreak = 0;
  List<String> _badges = [];
  List<String> _wrongQuestions = [];
  List<TestResult> _testHistory = [];
  Map<String, bool> _moduleCompleted = {
    'fines': false,
    'numbers': false,
    'roadSigns': false,
    'mockTest': false,
    'wrongAnswers': false,
  };
  Map<String, bool> _moduleAttempted = {
    'fines': false,
    'numbers': false,
    'roadSigns': false,
    'mockTest': false,
    'wrongAnswers': false,
  };
  int _perfectScoreCount = 0;

  int get totalXp => _totalXp;
  int get currentStreak => _currentStreak;
  List<String> get badges => _badges;
  List<String> get wrongQuestions => _wrongQuestions;
  List<TestResult> get testHistory => _testHistory;
  Map<String, bool> get moduleCompleted => _moduleCompleted;
  Map<String, bool> get moduleAttempted => _moduleAttempted;
  int get perfectScoreCount => _perfectScoreCount;

  int get level => _totalXp ~/ 100;
  
  // Progress to next level: (XP % 100) / 100
  double get levelProgress => (_totalXp % 100) / 100.0;

  // Shortcut method progress (0-5 steps)
  int get shortcutProgress {
    int progress = 0;
    if (_moduleCompleted['fines'] == true) progress++;
    if (_moduleCompleted['numbers'] == true) progress++;
    if (_moduleCompleted['roadSigns'] == true) progress++;
    if (_moduleCompleted['mockTest'] == true) progress++;
    if (_moduleCompleted['wrongAnswers'] == true) progress++;
    return progress;
  }

  // Get next logical step in the shortcut
  String? getNextStep() {
    // Priority: Find first UNATTEMPTED module
    if (_moduleAttempted['fines'] != true) return 'fines';
    if (_moduleAttempted['numbers'] != true) return 'numbers';
    if (_moduleAttempted['roadSigns'] != true) return 'roadSigns';
    if (_moduleAttempted['mockTest'] != true) return 'mockTest';
    
    // If all attempted, find first UNCOMPLETED module (to re-play)
    if (_moduleCompleted['fines'] != true) return 'fines';
    if (_moduleCompleted['numbers'] != true) return 'numbers';
    if (_moduleCompleted['roadSigns'] != true) return 'roadSigns';
    if (_moduleCompleted['mockTest'] != true) return 'mockTest';

    // Only suggest wrong answers if there are any
    if (_moduleCompleted['wrongAnswers'] != true && _wrongQuestions.isNotEmpty) return 'wrongAnswers';
    
    // If all done (or no wrong answers to review), return null
    return null;
  }
  
  bool isModuleComplete(String key) => _moduleCompleted[key] == true;
  bool isModuleAttempted(String key) => _moduleAttempted[key] == true;

  // Best mock test score
  int get bestMockScore {
    final mockTests = _testHistory.where((t) => t.mode == 'standard').toList();
    if (mockTests.isEmpty) return 0;
    return mockTests.map((t) => t.score).reduce((a, b) => a > b ? a : b);
  }

  UserProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _totalXp = prefs.getInt('totalXp') ?? 0;
    _currentStreak = prefs.getInt('currentStreak') ?? 0;
    _badges = prefs.getStringList('badges') ?? [];
    _wrongQuestions = prefs.getStringList('wrongQuestions') ?? [];
    _perfectScoreCount = prefs.getInt('perfectScoreCount') ?? 0;
    
    // Load test history
    final historyJson = prefs.getStringList('testHistory') ?? [];
    _testHistory = historyJson
        .map((json) => TestResult.fromJson(jsonDecode(json)))
        .toList();
    
    // Load module completion
    final moduleJson = prefs.getString('moduleCompleted');
    if (moduleJson != null) {
      final decoded = jsonDecode(moduleJson) as Map<String, dynamic>;
      _moduleCompleted = decoded.map((k, v) => MapEntry(k, v as bool));
    }
    
    // Load module attempts
    final attemptJson = prefs.getString('moduleAttempted');
    if (attemptJson != null) {
      final decoded = jsonDecode(attemptJson) as Map<String, dynamic>;
      _moduleAttempted = decoded.map((k, v) => MapEntry(k, v as bool));
    }
    
    notifyListeners();
  }

  Future<void> addXp(int amount) async {
    final oldLevel = level;
    _totalXp += amount;
    
    // Check for level up
    if (level > oldLevel) {
      AnalyticsService().logLevelUp(level: level);
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalXp', _totalXp);
    notifyListeners();
  }

  Future<void> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    _currentStreak++;
    await prefs.setInt('currentStreak', _currentStreak);
    notifyListeners();
  }

  Future<void> recordWrongAnswer(int questionId) async {
    final idStr = questionId.toString();
    if (!_wrongQuestions.contains(idStr)) {
      _wrongQuestions.add(idStr);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('wrongQuestions', _wrongQuestions);
      notifyListeners();
    }
  }

  Future<void> removeWrongAnswer(int questionId) async {
    final idStr = questionId.toString();
    if (_wrongQuestions.contains(idStr)) {
      _wrongQuestions.remove(idStr);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('wrongQuestions', _wrongQuestions);
      notifyListeners();
    }
  }

  Future<void> clearAllWrongQuestions() async {
    _wrongQuestions.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('wrongQuestions', _wrongQuestions);
    notifyListeners();
  }

  // Record a test result
  Future<void> recordTestResult(TestResult result) async {
    _testHistory.add(result);
    
    // Check for perfect score
    if (result.isPerfect) {
      _perfectScoreCount++;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('perfectScoreCount', _perfectScoreCount);
    }
    
    // Save history
    final prefs = await SharedPreferences.getInstance();
    final historyJson = _testHistory.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList('testHistory', historyJson);
    
    notifyListeners();
  }

  // Mark a module as completed
  Future<void> markModuleComplete(String moduleKey) async {
    _moduleCompleted[moduleKey] = true;
    _moduleAttempted[moduleKey] = true; // Completing implies attempting
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('moduleCompleted', jsonEncode(_moduleCompleted));
    await prefs.setString('moduleAttempted', jsonEncode(_moduleAttempted));
    
    notifyListeners();
  }
  
  // Mark a module as attempted (played but maybe not passed)
  Future<void> markModuleAttempted(String moduleKey) async {
    _moduleAttempted[moduleKey] = true;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('moduleAttempted', jsonEncode(_moduleAttempted));
    
    notifyListeners();
  }

  // Reset shortcut method progress
  Future<void> resetShortcutProgress() async {
    _moduleCompleted = {
      'fines': false,
      'numbers': false,
      'roadSigns': false,
      'mockTest': false,
      'wrongAnswers': false,
    };
    _moduleAttempted = {
      'fines': false,
      'numbers': false,
      'roadSigns': false,
      'mockTest': false,
      'wrongAnswers': false,
    };
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('moduleCompleted', jsonEncode(_moduleCompleted));
    await prefs.setString('moduleAttempted', jsonEncode(_moduleAttempted));
    
    notifyListeners();
  }

  // Get recent test scores for graph (last 10)
  List<TestResult> get recentTests {
    final sorted = List<TestResult>.from(_testHistory)
      ..sort((a, b) => a.date.compareTo(b.date));
    return sorted.length > 10 ? sorted.sublist(sorted.length - 10) : sorted;
  }
}
