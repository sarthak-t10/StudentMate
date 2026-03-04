class Event {
  final String id;
  final String title;
  final String description;
  final DateTime eventDate;
  final String venue;
  final String? imageUrl;
  final bool hasReminder;
  final DateTime createdAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.venue,
    this.imageUrl,
    this.hasReminder = false,
    required this.createdAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      eventDate: DateTime.parse(json['eventDate'] ?? DateTime.now().toIso8601String()),
      venue: json['venue'] ?? '',
      imageUrl: json['imageUrl'],
      hasReminder: json['hasReminder'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'eventDate': eventDate.toIso8601String(),
      'venue': venue,
      'imageUrl': imageUrl,
      'hasReminder': hasReminder,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
