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
}
