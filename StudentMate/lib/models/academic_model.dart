class Subject {
  final String id;
  final String name;
  final String branch;
  final int semester;
  final int credits;

  Subject({
    required this.id,
    required this.name,
    required this.branch,
    required this.semester,
    required this.credits,
  });

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'branch': branch,
      'semester': semester,
      'credits': credits,
    };
  }

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['_id'] as String? ?? json['id'] as String,
      name: json['name'] as String,
      branch: json['branch'] as String,
      semester: json['semester'] as int,
      credits: json['credits'] as int,
    );
  }
}

class StudentMarks {
  final String id;
  final String studentId;
  final String subjectId;
  final String subjectName;
  final int semester;
  final double marksObtained;
  final int credits;

  StudentMarks({
    required this.id,
    required this.studentId,
    required this.subjectId,
    required this.subjectName,
    required this.semester,
    required this.marksObtained,
    required this.credits,
  });

  double get gradePoint {
    if (marksObtained >= 90) return 4.0;
    if (marksObtained >= 80) return 3.5;
    if (marksObtained >= 70) return 3.0;
    if (marksObtained >= 60) return 2.5;
    if (marksObtained >= 50) return 2.0;
    return 0.0;
  }

  String get grade {
    if (marksObtained >= 90) return 'A+';
    if (marksObtained >= 80) return 'A';
    if (marksObtained >= 70) return 'B';
    if (marksObtained >= 60) return 'C';
    if (marksObtained >= 50) return 'D';
    return 'F';
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'studentId': studentId,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'semester': semester,
      'marksObtained': marksObtained,
      'credits': credits,
    };
  }

  factory StudentMarks.fromJson(Map<String, dynamic> json) {
    return StudentMarks(
      id: json['_id'] as String? ?? json['id'] as String,
      studentId: json['studentId'] as String,
      subjectId: json['subjectId'] as String,
      subjectName: json['subjectName'] as String,
      semester: json['semester'] as int,
      marksObtained: (json['marksObtained'] as num).toDouble(),
      credits: json['credits'] as int,
    );
  }
}

class TimeTableEntry {
  final String id;
  final String branch;
  final String section;
  final String subject;
  final String instructor;
  final String room;
  final String dayOfWeek;
  final String startTime;
  final String endTime;

  TimeTableEntry({
    required this.id,
    required this.branch,
    required this.section,
    required this.subject,
    required this.instructor,
    required this.room,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'branch': branch,
      'section': section,
      'subject': subject,
      'instructor': instructor,
      'room': room,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  factory TimeTableEntry.fromJson(Map<String, dynamic> json) {
    return TimeTableEntry(
      id: json['_id'] as String? ?? json['id'] as String,
      branch: json['branch'] as String,
      section: json['section'] as String,
      subject: json['subject'] as String,
      instructor: json['instructor'] as String,
      room: json['room'] as String,
      dayOfWeek: json['dayOfWeek'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
    );
  }
}
