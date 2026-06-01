import 'package:cloud_firestore/cloud_firestore.dart';

class AppUserProfile {
  final String userId;
  final String? email;
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final String? discoId;
  final String? areaId;
  final String? areaName;
  final String? divisionName;

  const AppUserProfile({
    required this.userId,
    this.email,
    required this.notificationsEnabled,
    required this.darkModeEnabled,
    this.discoId,
    this.areaId,
    this.areaName,
    this.divisionName,
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'email': email,
        'notificationsEnabled': notificationsEnabled,
        'darkModeEnabled': darkModeEnabled,
        'discoId': discoId,
        'areaId': areaId,
        'areaName': areaName,
        'divisionName': divisionName,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
