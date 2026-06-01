class DiscoSelection {
  final String discoId;
  final String discoName;
  final String divisionName;
  final String areaName;
  final String areaId;

  const DiscoSelection({
    required this.discoId,
    required this.discoName,
    required this.divisionName,
    required this.areaName,
    required this.areaId,
  });

  Map<String, dynamic> toMap() => {
        'discoId': discoId,
        'discoName': discoName,
        'divisionName': divisionName,
        'areaName': areaName,
        'areaId': areaId,
      };

  factory DiscoSelection.fromMap(Map<String, dynamic> map) {
    return DiscoSelection(
      discoId: map['discoId'] as String? ?? '',
      discoName: map['discoName'] as String? ?? '',
      divisionName: map['divisionName'] as String? ?? '',
      areaName: map['areaName'] as String? ?? '',
      areaId: map['areaId'] as String? ?? '',
    );
  }
}
