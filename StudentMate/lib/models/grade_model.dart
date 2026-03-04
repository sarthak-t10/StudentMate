/// A single internal assessment component (e.g. Assignment, Quiz, Mid-term).
class InternalComponent {
  final String label;
  final double marks; // marks obtained by the student
  final double maxMarks; // maximum marks for this component
  final bool includeInTotal; // whether to include this component in total /50
  final bool isAbsent; // whether the student was absent for this test

  const InternalComponent({
    required this.label,
    required this.marks,
    required this.maxMarks,
    this.includeInTotal = true,
    this.isAbsent = false,
  });

  Map<String, dynamic> toJson() => {
        'label': label,
        'marks': marks,
        'maxMarks': maxMarks,
        'includeInTotal': includeInTotal,
        'isAbsent': isAbsent,
      };

  factory InternalComponent.fromJson(Map<String, dynamic> json) =>
      InternalComponent(
        label: json['label'] as String? ?? '',
        marks: (json['marks'] as num?)?.toDouble() ?? 0.0,
        maxMarks: (json['maxMarks'] as num?)?.toDouble() ?? 0.0,
        includeInTotal: json['includeInTotal'] as bool? ?? true,
        isAbsent: json['isAbsent'] as bool? ?? false,
      );

  InternalComponent copyWith({
    String? label,
    double? marks,
    double? maxMarks,
    bool? includeInTotal,
    bool? isAbsent,
  }) =>
      InternalComponent(
        label: label ?? this.label,
        marks: marks ?? this.marks,
        maxMarks: maxMarks ?? this.maxMarks,
        includeInTotal: includeInTotal ?? this.includeInTotal,
        isAbsent: isAbsent ?? this.isAbsent,
      );
}

class Grade {
  late String id;
  late String userId;
  late String subject;
  late int credits;
  late String semester;
  late DateTime date;

  /// Internal assessment components — sum of [marks] must be ≤ 50.
  late List<InternalComponent> internalComponents;

  /// External exam marks entered out of 100; divide by 2 to get /50.
  late double externalMarksRaw;

  Grade({
    required this.id,
    required this.userId,
    required this.subject,
    required this.credits,
    required this.semester,
    required this.date,
    List<InternalComponent>? internalComponents,
    double externalMarksRaw = 0.0,
  })  : internalComponents = internalComponents ?? [],
        externalMarksRaw = externalMarksRaw;

  /// Total internal marks (sum of components where includeInTotal is true, capped at 50).
  double get internalTotal => internalComponents
      .fold(0.0, (s, c) => c.includeInTotal && !c.isAbsent ? s + c.marks : s)
      .clamp(0.0, 50.0);

  /// External marks converted to /50.
  double get externalTotal => (externalMarksRaw / 2.0).clamp(0.0, 50.0);

  /// Total marks out of 100 (internal /50 + external /50).
  double get totalMarks => internalTotal + externalTotal;

  /// Alias kept for backward compatibility with CGPA calculations.
  double get marks => totalMarks;

  double get gradePoint => _calculateGradePoint(totalMarks);

  static double _calculateGradePoint(double marks) {
    if (marks >= 90) return 10.0;
    if (marks >= 80) return 9.0;
    if (marks >= 70) return 8.0;
    if (marks >= 60) return 7.0;
    if (marks >= 50) return 6.0;
    if (marks >= 40) return 5.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'subject': subject,
      'marks': totalMarks, // stored for legacy reads
      'credits': credits,
      'semester': semester,
      'date': date.toIso8601String(),
      'internalComponents': internalComponents.map((c) => c.toJson()).toList(),
      'externalMarksRaw': externalMarksRaw,
    };
  }

  factory Grade.fromJson(Map<String, dynamic> json) {
    final internalJson = json['internalComponents'] as List?;
    final components = internalJson
            ?.map((e) => InternalComponent.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <InternalComponent>[];
    final externalRaw = (json['externalMarksRaw'] as num?)?.toDouble() ?? 0.0;

    return Grade(
      id: json['_id'] as String? ?? json['id'] as String,
      userId: json['userId'] as String? ?? '',
      subject: json['subject'] as String,
      credits: json['credits'] as int? ?? 4,
      semester: json['semester'] as String,
      date: DateTime.parse(json['date'] as String),
      internalComponents: components,
      externalMarksRaw: externalRaw,
    );
  }
}
