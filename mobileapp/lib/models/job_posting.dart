class JobPosting {
  final String id;
  final String title;
  final String companyName;
  final String description;
  final String jobType; // Full-time, Part-time, Internship
  final String location;
  final double? salary;
  final DateTime postedDate;

  JobPosting({
    required this.id,
    required this.title,
    required this.companyName,
    required this.description,
    required this.jobType,
    required this.location,
    this.salary,
    required this.postedDate,
  });

  factory JobPosting.fromJson(Map<String, dynamic> json) {
    return JobPosting(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      companyName: json['companyName'] ?? '',
      description: json['description'] ?? '',
      jobType: json['jobType'] ?? 'Full-time',
      location: json['location'] ?? '',
      salary: (json['salary'] as num?)?.toDouble(),
      postedDate: DateTime.parse(json['postedDate'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'companyName': companyName,
      'description': description,
      'jobType': jobType,
      'location': location,
      'salary': salary,
      'postedDate': postedDate.toIso8601String(),
    };
  }
}
