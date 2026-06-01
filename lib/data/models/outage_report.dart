import 'package:cloud_firestore/cloud_firestore.dart';

class OutageReport {
  final String id;
  final String discoId;
  final String areaId;
  final String areaName;
  final bool wasAccurate;
  final String? note;
  final DateTime createdAt;
  final String kind;

  const OutageReport({
    required this.id,
    required this.discoId,
    required this.areaId,
    required this.areaName,
    required this.wasAccurate,
    required this.createdAt,
    this.note,
    this.kind = 'accuracy_check',
  });

  Map<String, dynamic> toMap() => {
        'discoId': discoId,
        'areaId': areaId,
        'areaName': areaName,
        'wasAccurate': wasAccurate,
        'note': note,
        'kind': kind,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
