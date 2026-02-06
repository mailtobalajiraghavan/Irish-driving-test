import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // Singleton pattern
  static final AnalyticsService _instance = AnalyticsService._internal();

  factory AnalyticsService() {
    return _instance;
  }

  AnalyticsService._internal();

  FirebaseAnalyticsObserver getAnalyticsObserver() {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }

  // ===== ANALYTICS EVENTS =====

  // Log a quiz start event
  Future<void> logQuizStart({
    required String mode,
    String? category,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'quiz_start',
        parameters: {
          'mode': mode,
          if (category != null) 'category': category,
        },
      );
    } catch (e) {
      debugPrint('Analytics Error: $e');
    }
  }

  // Log a quiz completion event
  Future<void> logQuizComplete({
    required String mode,
    required int score,
    required int totalQuestions,
    String? category,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'quiz_complete',
        parameters: {
          'mode': mode,
          'score': score,
          'total_questions': totalQuestions,
          'percentage': (score / totalQuestions * 100).toStringAsFixed(1),
          if (category != null) 'category': category,
        },
      );
    } catch (e) {
      debugPrint('Analytics Error: $e');
    }
  }

  // Log level up event
  Future<void> logLevelUp({required int level}) async {
    try {
      await _analytics.logLevelUp(
        level: level,
      );
    } catch (e) {
      debugPrint('Analytics Error: $e');
    }
  }

  // Log custom event
  Future<void> logEvent(String name, Map<String, Object>? parameters) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      debugPrint('Analytics Error: $e');
    }
  }

  // ===== USER PROPERTIES (Module Tracking) =====

  /// Set user properties based on module completion
  /// Use for segmenting users by their learning progress
  Future<void> setModuleUserProperties({
    required int completedModules,
    required int totalModules,
    String? favoriteMode,  // Most-used quiz mode
  }) async {
    try {
      // Calculate completion tier
      final completionPercentage = (completedModules / totalModules * 100).round();
      String completionTier;
      if (completionPercentage < 25) {
        completionTier = 'beginner';
      } else if (completionPercentage < 75) {
        completionTier = 'intermediate';
      } else {
        completionTier = 'advanced';
      }

      await _analytics.setUserProperty(
        name: 'module_completion_tier',
        value: completionTier,
      );

      await _analytics.setUserProperty(
        name: 'modules_completed',
        value: completedModules.toString(),
      );

      if (favoriteMode != null) {
        await _analytics.setUserProperty(
          name: 'favorite_quiz_mode',
          value: favoriteMode,
        );
      }
    } catch (e) {
      debugPrint('Analytics Error: $e');
    }
  }

  /// Set user properties for quiz activity level
  Future<void> setQuizActivityLevel({
    required int totalQuizzesTaken,
  }) async {
    try {
      String activityTier;
      if (totalQuizzesTaken < 10) {
        activityTier = 'new';
      } else if (totalQuizzesTaken < 50) {
        activityTier = 'active';
      } else {
        activityTier = 'power_user';
      }

      await _analytics.setUserProperty(
        name: 'quiz_activity_tier',
        value: activityTier,
      );
    } catch (e) {
      debugPrint('Analytics Error: $e');
    }
  }

  // ===== CRASHLYTICS =====

  /// Log non-fatal error to Crashlytics
  Future<void> recordError(dynamic exception, StackTrace? stack, {String? reason}) async {
    try {
      await _crashlytics.recordError(exception, stack, reason: reason);
    } catch (e) {
      debugPrint('Crashlytics Error: $e');
    }
  }

  /// Set custom key for crash context
  Future<void> setCrashlyticsKey(String key, dynamic value) async {
    try {
      await _crashlytics.setCustomKey(key, value);
    } catch (e) {
      debugPrint('Crashlytics Error: $e');
    }
  }

  /// Log message to Crashlytics
  void logCrashMessage(String message) {
    try {
      _crashlytics.log(message);
    } catch (e) {
      debugPrint('Crashlytics Error: $e');
    }
  }

  // ===== REMOTE CONFIG (A/B Testing) =====

  /// Get boolean config value
  bool getConfigBool(String key) {
    try {
      return _remoteConfig.getBool(key);
    } catch (e) {
      debugPrint('Remote Config Error: $e');
      return false;
    }
  }

  /// Get integer config value
  int getConfigInt(String key) {
    try {
      return _remoteConfig.getInt(key);
    } catch (e) {
      debugPrint('Remote Config Error: $e');
      return 0;
    }
  }

  /// Get string config value
  String getConfigString(String key) {
    try {
      return _remoteConfig.getString(key);
    } catch (e) {
      debugPrint('Remote Config Error: $e');
      return '';
    }
  }

  /// Fetch latest config from Firebase (call sparingly)
  Future<bool> fetchAndActivateConfig() async {
    try {
      return await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Remote Config Error: $e');
      return false;
    }
  }
}
