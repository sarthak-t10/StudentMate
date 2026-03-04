enum UserType { student, faculty, admin }

class AttendanceRecord {
  final DateTime date;
  final bool isPresent;
  final String? remarks;
  final String? source; // 'manual', 'auto_event', 'qr_scan', etc.

  AttendanceRecord({
    required this.date,
    required this.isPresent,
    this.remarks,
    this.source,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'isPresent': isPresent,
      'remarks': remarks,
      'source': source,
    };
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      date: DateTime.parse(json['date'] as String),
      isPresent: json['isPresent'] as bool,
      remarks: json['remarks'] as String?,
      source: json['source'] as String?,
    );
  }
}

class ActivityPointRecord {
  final String sourceEventId;
  final String eventName;
  final int points;
  final DateTime awardedDate;

  ActivityPointRecord({
    required this.sourceEventId,
    required this.eventName,
    required this.points,
    required this.awardedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'sourceEventId': sourceEventId,
      'eventName': eventName,
      'points': points,
      'awardedDate': awardedDate.toIso8601String(),
    };
  }

  factory ActivityPointRecord.fromJson(Map<String, dynamic> json) {
    return ActivityPointRecord(
      sourceEventId: json['sourceEventId'] as String,
      eventName: json['eventName'] as String,
      points: json['points'] as int,
      awardedDate: DateTime.parse(json['awardedDate'] as String),
    );
  }
}

class User {
  final String id;
  final String fullName;
  final String email;
  final String password;
  final String branch;
  final String section;
  final String? userPhotoUrl;
  final UserType userType;
  final DateTime createdAt;
  final int totalActivityPoints;
  final List<AttendanceRecord> attendanceRecords;
  final List<ActivityPointRecord> activityPointHistory;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    required this.branch,
    required this.section,
    this.userPhotoUrl,
    required this.userType,
    required this.createdAt,
    this.totalActivityPoints = 0,
    this.attendanceRecords = const [],
    this.activityPointHistory = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
      'password': password,
      'branch': branch,
      'section': section,
      'userPhotoUrl': userPhotoUrl,
      'userType': userType.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'totalActivityPoints': totalActivityPoints,
      'attendanceRecords': attendanceRecords.map((r) => r.toJson()).toList(),
      'activityPointHistory':
          activityPointHistory.map((r) => r.toJson()).toList(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String? ?? json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      branch: json['branch'] as String,
      section: json['section'] as String,
      userPhotoUrl: json['userPhotoUrl'] as String?,
      userType: UserType.values.firstWhere(
        (e) => e.toString().endsWith(json['userType'] as String),
        orElse: () => UserType.student,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      totalActivityPoints: json['totalActivityPoints'] as int? ?? 0,
      attendanceRecords: (json['attendanceRecords'] as List?)
              ?.map((r) => AttendanceRecord.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      activityPointHistory: (json['activityPointHistory'] as List?)
              ?.map((r) =>
                  ActivityPointRecord.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? password,
    String? branch,
    String? section,
    String? userPhotoUrl,
    UserType? userType,
    DateTime? createdAt,
    int? totalActivityPoints,
    List<AttendanceRecord>? attendanceRecords,
    List<ActivityPointRecord>? activityPointHistory,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      branch: branch ?? this.branch,
      section: section ?? this.section,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
      totalActivityPoints: totalActivityPoints ?? this.totalActivityPoints,
      attendanceRecords: attendanceRecords ?? this.attendanceRecords,
      activityPointHistory: activityPointHistory ?? this.activityPointHistory,
    );
  }

  /// Get attendance for a specific date
  bool? getAttendanceForDate(DateTime date) {
    try {
      final record = attendanceRecords.firstWhere(
        (r) =>
            r.date.year == date.year &&
            r.date.month == date.month &&
            r.date.day == date.day,
      );
      return record.isPresent;
    } catch (e) {
      return null; // No record for this date
    }
  }

  /// Get attendance percentage
  double getAttendancePercentage() {
    if (attendanceRecords.isEmpty) return 0.0;
    final presentCount = attendanceRecords.where((r) => r.isPresent).length;
    return (presentCount / attendanceRecords.length) * 100;
  }
}
