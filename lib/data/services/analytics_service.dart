import 'package:firebase_analytics/firebase_analytics.dart';

import '../../core/constants/app_environment.dart';

class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics? get _analytics => AppEnvironment.enableFirebase ? FirebaseAnalytics.instance : null;

  Future<void> logSelectionChange({required String discoId, required String areaId}) async {
    await _analytics?.logEvent(name: 'change_area', parameters: {'disco_id': discoId, 'area_id': areaId});
  }

  Future<void> logReportSubmitted({required bool wasAccurate, required String areaId}) async {
    await _analytics?.logEvent(name: 'submit_report', parameters: {'was_accurate': wasAccurate ? 1 : 0, 'area_id': areaId});
  }

  Future<void> logScreenView(String screenName) async {
    await _analytics?.logScreenView(screenName: screenName);
  }
}
