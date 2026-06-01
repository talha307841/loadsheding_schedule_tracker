import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../models/app_preferences.dart';

class LocalStorageService {
  final SharedPreferences preferences;

  LocalStorageService(this.preferences);

  static Future<LocalStorageService> create() async {
    final preferences = await SharedPreferences.getInstance();
    return LocalStorageService(preferences);
  }

  AppPreferences loadPreferences() {
    final raw = preferences.getString(AppConstants.sharedPreferencesKey);
    if (raw == null || raw.isEmpty) {
      return AppPreferences.defaults();
    }
    return AppPreferences.fromMap(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> savePreferences(AppPreferences appPreferences) async {
    await preferences.setString(AppConstants.sharedPreferencesKey, jsonEncode(appPreferences.toMap()));
    await preferences.setBool(AppConstants.onboardingCompleteKey, appPreferences.onboardingComplete);
    await preferences.setBool(AppConstants.notificationsEnabledKey, appPreferences.notificationsEnabled);
    await preferences.setBool(AppConstants.darkModeEnabledKey, appPreferences.darkModeEnabled);
    if (appPreferences.selection != null) {
      await preferences.setString(AppConstants.lastSelectedDiscoKey, appPreferences.selection!.discoId);
      await preferences.setString(AppConstants.lastSelectedAreaKey, appPreferences.selection!.areaId);
    }
  }

  bool get onboardingComplete => preferences.getBool(AppConstants.onboardingCompleteKey) ?? false;

  String? get lastSelectedDiscoId => preferences.getString(AppConstants.lastSelectedDiscoKey);
  String? get lastSelectedAreaId => preferences.getString(AppConstants.lastSelectedAreaKey);
  bool get notificationsEnabled => preferences.getBool(AppConstants.notificationsEnabledKey) ?? true;
  bool get darkModeEnabled => preferences.getBool(AppConstants.darkModeEnabledKey) ?? false;

  DateTime? lastOutageReportTimestamp(String areaId) {
    final raw = preferences.getInt('${AppConstants.lastOutageReportPrefix}$areaId');
    if (raw == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(raw);
  }

  Future<void> setLastOutageReportTimestamp(String areaId, DateTime timestamp) async {
    await preferences.setInt('${AppConstants.lastOutageReportPrefix}$areaId', timestamp.millisecondsSinceEpoch);
  }
}
