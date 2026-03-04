enum AnnouncementType { college, faculty }

class Announcement {
  final String id;
  final String title;
  final String content;
  final String? authorId;
  final String? authorName;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Announcement Type: College (Admin) or Faculty
  final AnnouncementType announcementType;

  // For faculty announcements
  final String? branch;
  final String? section;
  final String? subject;
  final String? subjectId;

  // Attachments
  final String? attachmentUrl;
  final String? attachmentName;
  final String? attachmentType; // 'pdf', 'image', 'document', etc.

  // Legacy/optional fields
  final String?
      category; // academic, event, general (for backward compatibility)
  final bool isImportant;
  final bool isActive;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    this.authorId,
    this.authorName,
    required this.createdAt,
    this.updatedAt,
    required this.announcementType,
    this.branch,
    this.section,
    this.subject,
    this.subjectId,
    this.attachmentUrl,
    this.attachmentName,
    this.attachmentType,
    this.category,
    this.isImportant = false,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'announcementType': announcementType.toString().split('.').last,
      'branch': branch,
      'section': section,
      'subject': subject,
      'subjectId': subjectId,
      'attachmentUrl': attachmentUrl,
      'attachmentName': attachmentName,
      'attachmentType': attachmentType,
      'category': category,
      'isImportant': isImportant,
      'isActive': isActive,
    };
  }

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['_id'] as String? ?? json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      authorId: json['authorId'] as String?,
      authorName: json['authorName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      announcementType:
          _parseAnnouncementType(json['announcementType'] as String?),
      branch: json['branch'] as String?,
      section: json['section'] as String?,
      subject: json['subject'] as String?,
      subjectId: json['subjectId'] as String?,
      attachmentUrl: json['attachmentUrl'] as String?,
      attachmentName: json['attachmentName'] as String?,
      attachmentType: json['attachmentType'] as String?,
      category: json['category'] as String?,
      isImportant: json['isImportant'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  static AnnouncementType _parseAnnouncementType(String? type) {
    switch (type?.toLowerCase()) {
      case 'college':
        return AnnouncementType.college;
      case 'faculty':
        return AnnouncementType.faculty;
      default:
        return AnnouncementType.college;
    }
  }

  Announcement copyWith({
    String? id,
    String? title,
    String? content,
    String? authorId,
    String? authorName,
    DateTime? createdAt,
    DateTime? updatedAt,
    AnnouncementType? announcementType,
    String? branch,
    String? section,
    String? subject,
    String? subjectId,
    String? attachmentUrl,
    String? attachmentName,
    String? attachmentType,
    String? category,
    bool? isImportant,
    bool? isActive,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      announcementType: announcementType ?? this.announcementType,
      branch: branch ?? this.branch,
      section: section ?? this.section,
      subject: subject ?? this.subject,
      subjectId: subjectId ?? this.subjectId,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentName: attachmentName ?? this.attachmentName,
      attachmentType: attachmentType ?? this.attachmentType,
      category: category ?? this.category,
      isImportant: isImportant ?? this.isImportant,
      isActive: isActive ?? this.isActive,
    );
  }
}
