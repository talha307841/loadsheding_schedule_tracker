import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:package_info_plus/package_info_plus.dart';

import '../models/outage_report_submission.dart';
import '../models/outage_report.dart';
import 'firestore_service.dart';

class ReportRepository {
  final FirestoreService firestoreService;

  ReportRepository(this.firestoreService);

  Future<void> submitAccurateCheck({
    required String discoId,
    required String areaId,
    required String areaName,
    required bool wasAccurate,
    String? note,
  }) {
    return firestoreService.submitReport(
      OutageReport(
        id: '',
        discoId: discoId,
        areaId: areaId,
        areaName: areaName,
        wasAccurate: wasAccurate,
        createdAt: DateTime.now(),
        note: note,
      ),
    );
  }

  Future<void> submitElectricityGoneReport({
    required String discoId,
    required String areaId,
    required DateTime reportedOutageTime,
    required String? reason,
    required String systemStatusAtReport,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Anonymous auth is required before reporting an outage.');
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final platform = _platformName();
    await firestoreService.submitOutageReport(
      OutageReportSubmission(
        userId: user.uid,
        discoId: discoId,
        areaId: areaId,
        reportedAt: DateTime.now(),
        reportedOutageTime: reportedOutageTime,
        reason: reason,
        systemStatusAtReport: systemStatusAtReport,
        appVersion: '${packageInfo.version}+${packageInfo.buildNumber}',
        platform: platform,
      ),
    );
  }

  String _platformName() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'android';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ios';
    }
    return defaultTargetPlatform.name;
  }
}
