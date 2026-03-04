class TimeTable {
  late String id;
  late String subject;
  late String instructor;
  late String room;
  late String dayOfWeek;
  late String startTime;
  late String endTime;

  TimeTable({
    required this.id,
    required this.subject,
    required this.instructor,
    required this.room,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });
}

/// Stores a timetable image (base64) for a specific branch+section.
class TimetableImage {
  final String id;
  final String branch;
  final String section;
  final String imageBase64; // dart:convert base64 encoded PNG/JPG bytes
  final DateTime updatedAt;

  TimetableImage({
    required this.id,
    required this.branch,
    required this.section,
    required this.imageBase64,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        '_id': id,
        'branch': branch,
        'section': section,
        'imageBase64': imageBase64,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory TimetableImage.fromJson(Map<String, dynamic> json) => TimetableImage(
        id: json['_id'] as String? ?? json['id'] as String,
        branch: json['branch'] as String,
        section: json['section'] as String,
        imageBase64: json['imageBase64'] as String,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
