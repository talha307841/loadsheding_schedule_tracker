class OutageReportSubmission {
  final String userId;
  final String discoId;
  final String areaId;
  final DateTime reportedAt;
  final DateTime reportedOutageTime;
  final String? reason;
  final String systemStatusAtReport;
  final String appVersion;
  final String platform;

  const OutageReportSubmission({
    required this.userId,
    required this.discoId,
    required this.areaId,
    required this.reportedAt,
    required this.reportedOutageTime,
    required this.systemStatusAtReport,
    required this.appVersion,
    required this.platform,
    this.reason,
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'discoId': discoId,
        'areaId': areaId,
        'reportedAt': reportedAt,
        'reportedOutageTime': reportedOutageTime,
        'reason': reason,
        'systemStatusAtReport': systemStatusAtReport,
        'appVersion': appVersion,
        'platform': platform,
      };
}
