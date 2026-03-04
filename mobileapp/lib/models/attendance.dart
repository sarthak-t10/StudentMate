class Attendance {
  final String id;
  final String studentId;
  final String subjectId;
  final int totalClasses;
  final int attendedClasses;
  final double percentage;

  Attendance({
    required this.id,
    required this.studentId,
    required this.subjectId,
    required this.totalClasses,
    required this.attendedClasses,
    required this.percentage,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['_id'] ?? '',
      studentId: json['studentId'] ?? '',
      subjectId: json['subjectId'] ?? '',
      totalClasses: json['totalClasses'] ?? 0,
      attendedClasses: json['attendedClasses'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'studentId': studentId,
      'subjectId': subjectId,
      'totalClasses': totalClasses,
      'attendedClasses': attendedClasses,
      'percentage': percentage,
    };
  }
}
