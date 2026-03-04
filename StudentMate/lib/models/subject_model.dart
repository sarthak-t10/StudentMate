class Subject {
  final String id;
  final String branch;
  final String semester; // "1" – "8"
  final String subjectName;
  final int credits;

  Subject({
    required this.id,
    required this.branch,
    required this.semester,
    required this.subjectName,
    required this.credits,
  });

  Map<String, dynamic> toJson() => {
        '_id': id,
        'branch': branch,
        'semester': semester,
        'subjectName': subjectName,
        'credits': credits,
      };

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        id: json['_id'] as String? ?? json['id'] as String,
        branch: json['branch'] as String,
        semester: json['semester'] as String,
        subjectName: json['subjectName'] as String,
        credits: json['credits'] as int,
      );
}
