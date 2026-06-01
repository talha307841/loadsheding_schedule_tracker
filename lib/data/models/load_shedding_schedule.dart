import 'package:cloud_firestore/cloud_firestore.dart';

import 'load_shedding_slot.dart';

class LoadSheddingSchedule {
  final DateTime weekStartDate;
  final String areaId;
  final String discoId;
  final List<LoadSheddingSlot> slots;

  const LoadSheddingSchedule({
    required this.weekStartDate,
    required this.areaId,
    required this.discoId,
    required this.slots,
  });

  Map<String, dynamic> toMap() => {
        'weekStartDate': Timestamp.fromDate(weekStartDate),
        'areaId': areaId,
        'discoId': discoId,
        'slots': slots.map((slot) => slot.toMap()).toList(),
      };

  factory LoadSheddingSchedule.fromMap(Map<String, dynamic> map) {
    return LoadSheddingSchedule(
      weekStartDate: (map['weekStartDate'] as Timestamp).toDate(),
      areaId: map['areaId'] as String? ?? '',
      discoId: map['discoId'] as String? ?? '',
      slots: ((map['slots'] as List<dynamic>?) ?? const [])
          .map((dynamic item) => LoadSheddingSlot.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }

  static LoadSheddingSchedule empty(String discoId, String areaId) => LoadSheddingSchedule(
        weekStartDate: DateTime.now(),
        areaId: areaId,
        discoId: discoId,
        slots: const [],
      );
}
