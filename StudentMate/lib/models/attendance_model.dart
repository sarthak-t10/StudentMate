class Attendance {
  late String id;
  late String userId;
  late String subject;
  late String section;
  late String branch;
  late int totalClasses;
  late int presentClasses;
  late List<String> absentDates; // ISO date strings e.g. "2026-03-12"
  late DateTime lastUpdated;

  Attendance({
    required this.id,
    required this.userId,
    required this.subject,
    required this.section,
    required this.branch,
    required this.totalClasses,
    required this.presentClasses,
    required this.absentDates,
    required this.lastUpdated,
  });

  double get percentage =>
      totalClasses == 0 ? 100.0 : (presentClasses / totalClasses) * 100;

  bool get isLowAttendance => totalClasses > 0 && percentage < 75;

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'subject': subject,
      'section': section,
      'branch': branch,
      'totalClasses': totalClasses,
      'presentClasses': presentClasses,
      'absentDates': absentDates,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['_id'] as String? ?? json['id'] as String,
      userId: json['userId'] as String? ?? '',
      subject: json['subject'] as String,
      section: json['section'] as String? ?? '',
      branch: json['branch'] as String? ?? '',
      totalClasses: json['totalClasses'] as int? ?? json['total'] as int? ?? 0,
      presentClasses:
          json['presentClasses'] as int? ?? json['present'] as int? ?? 0,
      absentDates:
          (json['absentDates'] as List?)?.map((e) => e.toString()).toList() ??
              [],
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}
