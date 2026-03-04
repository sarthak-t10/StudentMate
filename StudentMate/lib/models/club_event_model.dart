import 'package:uuid/uuid.dart';

class ClubEventModel {
  final String id;
  final String clubName;
  final String eventName;
  final DateTime eventDate;
  final String eventTime; // Format: "HH:MM"
  final String description;
  final String? posterImageUrl; // Base64 or direct URL
  final String posterImagePath; // Local file path for upload
  final String eventLocation;
  final String registrationLink; // Google Forms or registration URL
  final int activityPoints; // Points assigned for attending this event
  final String createdBy;
  final DateTime createdAt;
  final List<String> registeredUsers; // User IDs who registered
  final List<String>
      attendedUsers; // User IDs who attended (for post-event processing)
  final bool pointsAwarded; // Track if points have been awarded for this event

  ClubEventModel({
    String? id,
    required this.clubName,
    required this.eventName,
    required this.eventDate,
    required this.eventTime,
    required this.description,
    this.posterImageUrl,
    required this.posterImagePath,
    required this.eventLocation,
    required this.registrationLink,
    this.activityPoints = 0,
    required this.createdBy,
    DateTime? createdAt,
    this.registeredUsers = const [],
    this.attendedUsers = const [],
    this.pointsAwarded = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// Convert model to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'clubName': clubName,
      'eventName': eventName,
      'eventDate': eventDate.toIso8601String(),
      'eventTime': eventTime,
      'description': description,
      'posterImageUrl': posterImageUrl,
      'posterImagePath': posterImagePath,
      'eventLocation': eventLocation,
      'registrationLink': registrationLink,
      'activityPoints': activityPoints,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'registeredUsers': registeredUsers,
      'attendedUsers': attendedUsers,
      'pointsAwarded': pointsAwarded,
    };
  }

  /// Create instance from JSON
  factory ClubEventModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawId = json['_id'] ?? json['id'];
    final String resolvedId = rawId?.toString() ?? const Uuid().v4();

    final String resolvedEventName =
        (json['eventName'] ?? json['title'] ?? 'Untitled Event').toString();
    final String resolvedClubName =
        (json['clubName'] ?? 'Club Event').toString();
    final String resolvedDescription = (json['description'] ?? '').toString();
    final String resolvedEventTime = (json['eventTime'] ?? 'TBD').toString();
    final String resolvedLocation =
        (json['eventLocation'] ?? json['location'] ?? 'TBD').toString();
    final String resolvedRegistrationLink =
        (json['registrationLink'] ?? '').toString();
    final String resolvedCreatedBy = (json['createdBy'] ?? 'system').toString();

    final dynamic rawEventDate = json['eventDate'];
    final DateTime resolvedEventDate = rawEventDate is DateTime
        ? rawEventDate
        : DateTime.tryParse((rawEventDate ?? '').toString()) ?? DateTime.now();

    final dynamic rawCreatedAt = json['createdAt'];
    final DateTime resolvedCreatedAt = rawCreatedAt is DateTime
        ? rawCreatedAt
        : DateTime.tryParse((rawCreatedAt ?? '').toString()) ?? DateTime.now();

    return ClubEventModel(
      id: resolvedId,
      clubName: resolvedClubName,
      eventName: resolvedEventName,
      eventDate: resolvedEventDate,
      eventTime: resolvedEventTime,
      description: resolvedDescription,
      posterImageUrl: json['posterImageUrl'] as String?,
      posterImagePath: json['posterImagePath'] as String? ?? '',
      eventLocation: resolvedLocation,
      registrationLink: resolvedRegistrationLink,
      activityPoints: json['activityPoints'] as int? ?? 0,
      createdBy: resolvedCreatedBy,
      createdAt: resolvedCreatedAt,
      registeredUsers:
          List<String>.from(json['registeredUsers'] as List? ?? []),
      attendedUsers: List<String>.from(json['attendedUsers'] as List? ?? []),
      pointsAwarded: json['pointsAwarded'] as bool? ?? false,
    );
  }

  /// Copy with method for immutable updates
  ClubEventModel copyWith({
    String? id,
    String? clubName,
    String? eventName,
    DateTime? eventDate,
    String? eventTime,
    String? description,
    String? posterImageUrl,
    String? posterImagePath,
    String? eventLocation,
    String? registrationLink,
    int? activityPoints,
    String? createdBy,
    DateTime? createdAt,
    List<String>? registeredUsers,
    List<String>? attendedUsers,
    bool? pointsAwarded,
  }) {
    return ClubEventModel(
      id: id ?? this.id,
      clubName: clubName ?? this.clubName,
      eventName: eventName ?? this.eventName,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      description: description ?? this.description,
      posterImageUrl: posterImageUrl ?? this.posterImageUrl,
      posterImagePath: posterImagePath ?? this.posterImagePath,
      eventLocation: eventLocation ?? this.eventLocation,
      registrationLink: registrationLink ?? this.registrationLink,
      activityPoints: activityPoints ?? this.activityPoints,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      registeredUsers: registeredUsers ?? this.registeredUsers,
      attendedUsers: attendedUsers ?? this.attendedUsers,
      pointsAwarded: pointsAwarded ?? this.pointsAwarded,
    );
  }

  /// Get formatted date string
  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${eventDate.day} ${months[eventDate.month - 1]} ${eventDate.year}';
  }

  /// Get combined date and time string
  String get dateTimeString => '$formattedDate at $eventTime';

  /// Check if event is registered by user
  bool isRegisteredBy(String userId) => registeredUsers.contains(userId);

  /// Check if event was attended by user
  bool isAttendedBy(String userId) => attendedUsers.contains(userId);

  /// Registration count
  int get registrationCount => registeredUsers.length;

  /// Attended count
  int get attendanceCount => attendedUsers.length;

  /// Check if event has passed
  bool get hasPassed => eventDate.isBefore(DateTime.now()) && !pointsAwarded;

  /// Attendance percentage
  double get attendancePercentage {
    if (registeredUsers.isEmpty) return 0.0;
    return (attendedUsers.length / registeredUsers.length) * 100;
  }
}
