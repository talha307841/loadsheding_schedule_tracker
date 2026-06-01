import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../core/constants/app_environment.dart';
import '../../core/constants/firestore_collections.dart';
import '../../firebase_options.dart';
import '../models/app_user_profile.dart';
import '../models/disco_selection.dart';
import '../models/load_shedding_schedule.dart';
import '../models/load_shedding_slot.dart';
import '../models/outage_report.dart';
import '../models/outage_report_submission.dart';

class FirestoreService {
  FirestoreService._();

  static final FirestoreService instance = FirestoreService._();
  bool _configured = false;

  bool get isConfigured => _configured;

  Future<void> configureIfNeeded() async {
    if (!AppEnvironment.enableFirebase || _configured) {
      return;
    }
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    final firestore = FirebaseFirestore.instance;
    firestore.settings = const Settings(persistenceEnabled: true, cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
    _configured = true;
  }

  FirebaseFirestore? get _firestore => _configured ? FirebaseFirestore.instance : null;

  Future<LoadSheddingSchedule?> fetchSchedule(DiscoSelection selection) async {
    if (!_configured) {
      return _mockSchedule(selection);
    }

    final collection = _firestore!
        .collection(FirestoreCollections.discos)
        .doc(selection.discoId)
        .collection(FirestoreCollections.areas)
        .doc(selection.areaId)
        .collection(FirestoreCollections.schedules);

    final query = await collection.orderBy('weekStartDate', descending: true).limit(5).get(const GetOptions(source: Source.serverAndCache));
    if (query.docs.isEmpty) {
      return LoadSheddingSchedule.empty(selection.discoId, selection.areaId);
    }

    for (final doc in query.docs) {
      final data = doc.data();
      final status = data['status'] as String? ?? 'published';
      if (status == 'published') {
        return LoadSheddingSchedule.fromMap(data);
      }
    }

    return LoadSheddingSchedule.empty(selection.discoId, selection.areaId);
  }

  Future<void> upsertUserProfile(AppUserProfile profile) async {
    if (!_configured) {
      return;
    }
    await _firestore!.collection(FirestoreCollections.users).doc(profile.userId).set(profile.toMap(), SetOptions(merge: true));
  }

  Future<void> submitReport(OutageReport report) async {
    if (!_configured) {
      return;
    }
    await _firestore!.collection(FirestoreCollections.reports).add(report.toMap());
  }

  Future<void> submitOutageReport(OutageReportSubmission submission) async {
    if (!_configured) {
      return;
    }
    await _firestore!.collection('outage_reports').add(submission.toMap());
  }

  Future<ScheduleSnapshot> fetchScheduleSnapshot(DiscoSelection selection) async {
    final schedule = await fetchSchedule(selection) ?? LoadSheddingSchedule.empty(selection.discoId, selection.areaId);
    return ScheduleSnapshot(schedule: schedule);
  }

  LoadSheddingSchedule _mockSchedule(DiscoSelection selection) {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final slots = <LoadSheddingSlot>[];
    for (var dayOffset = 0; dayOffset < 7; dayOffset++) {
      final dayName = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day)
          .add(Duration(days: dayOffset));
      final weekday = _weekdayName(dayName.weekday);
      slots.addAll([
        LoadSheddingSlot(day: weekday, startTime: '08:00', endTime: '10:00'),
        LoadSheddingSlot(day: weekday, startTime: '18:30', endTime: '20:00'),
      ]);
    }
    return LoadSheddingSchedule(
      weekStartDate: startOfWeek,
      areaId: selection.areaId,
      discoId: selection.discoId,
      slots: slots,
    );
  }

  String _weekdayName(int weekday) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[weekday - 1];
  }
}

class ScheduleSnapshot {
  final LoadSheddingSchedule schedule;

  const ScheduleSnapshot({required this.schedule});
}
