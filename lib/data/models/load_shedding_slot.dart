class LoadSheddingSlot {
  final String day;
  final String startTime;
  final String endTime;

  const LoadSheddingSlot({required this.day, required this.startTime, required this.endTime});

  Map<String, dynamic> toMap() => {'day': day, 'startTime': startTime, 'endTime': endTime};

  factory LoadSheddingSlot.fromMap(Map<String, dynamic> map) {
    return LoadSheddingSlot(
      day: map['day'] as String? ?? '',
      startTime: map['startTime'] as String? ?? '',
      endTime: map['endTime'] as String? ?? '',
    );
  }
}
