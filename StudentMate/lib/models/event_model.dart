class ClubEvent {
  final String id;
  final String title;
  final String description;
  final DateTime eventDate;
  final String? location;
  final String createdBy;
  final DateTime createdAt;

  ClubEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    this.location,
    required this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'eventDate': eventDate.toIso8601String(),
      'location': location,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ClubEvent.fromJson(Map<String, dynamic> json) {
    return ClubEvent(
      id: json['_id'] as String? ?? json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      eventDate: DateTime.parse(json['eventDate'] as String),
      location: json['location'] as String?,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime eventDate;
  final String createdBy;
  final DateTime createdAt;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'eventDate': eventDate.toIso8601String(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['_id'] as String? ?? json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      eventDate: DateTime.parse(json['eventDate'] as String),
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class Notice {
  final String id;
  final String title;
  final String content;
  final String category; // 'class' or 'college'
  final String createdBy;
  final DateTime createdAt;
  final String? targetBranch;
  final String? targetSection;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.createdBy,
    required this.createdAt,
    this.targetBranch,
    this.targetSection,
  });

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'content': content,
      'category': category,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'targetBranch': targetBranch,
      'targetSection': targetSection,
    };
  }

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['_id'] as String? ?? json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      targetBranch: json['targetBranch'] as String?,
      targetSection: json['targetSection'] as String?,
    );
  }
}
