import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import '../models/club_event_model.dart';
import '../services/mongodb_service.dart';

/// Service to handle Club Events database operations with Hive persistence
class ClubEventService {
  static final ClubEventService _instance = ClubEventService._internal();

  factory ClubEventService() {
    return _instance;
  }

  ClubEventService._internal();

  static const String _boxName = 'clubEvents';
  late Box<String> _eventsBox;
  bool _initialized = false;

  static const String _collectionName = 'club_events';

  /// Initialize Hive box for club events
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      if (!Hive.isBoxOpen(_boxName)) {
        _eventsBox = await Hive.openBox<String>(_boxName);
      } else {
        _eventsBox = Hive.box<String>(_boxName);
      }
      _initialized = true;
      debugPrint('✓ Hive box initialized for club events');

      // One-time best-effort migration from legacy local Hive storage to MongoDB
      await _migrateLegacyHiveEventsToMongo();
    } catch (e) {
      debugPrint('✗ Error initializing Hive: $e');
    }
  }

  Future<void> _migrateLegacyHiveEventsToMongo() async {
    try {
      if (_eventsBox.isEmpty) return;

      final db = await MongoDBService.getDb();
      final collection = db.collection(_collectionName);

      for (final jsonString in _eventsBox.values) {
        try {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          final event = ClubEventModel.fromJson(json);
          await collection
              .replaceOne({'_id': event.id}, event.toJson(), upsert: true);
        } catch (_) {
          // Ignore malformed legacy records and continue migration
        }
      }
      debugPrint('✓ Legacy Hive club events migrated to MongoDB');
    } catch (e) {
      debugPrint('⚠ Hive→Mongo migration skipped: $e');
    }
  }

  /// Ensure box is initialized before operations
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  /// Add a new club event
  Future<bool> addClubEvent(ClubEventModel event) async {
    try {
      await _ensureInitialized();

      final db = await MongoDBService.getDb();
      await db
          .collection(_collectionName)
          .replaceOne({'_id': event.id}, event.toJson(), upsert: true);

      // Keep local mirror for offline fallback only
      final jsonString = jsonEncode(event.toJson());
      await _eventsBox.put(event.id, jsonString);
      debugPrint('✓ Event added: ${event.eventName}');
      return true;
    } catch (e) {
      debugPrint('✗ Error adding event: $e');
      return false;
    }
  }

  /// Fetch all club events
  Future<List<ClubEventModel>> getAllClubEvents() async {
    try {
      await _ensureInitialized();

      final db = await MongoDBService.getDb();
      final records = await db.collection(_collectionName).find().toList();

      final events = records
          .map((e) => ClubEventModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      // Refresh local mirror from Mongo to keep both sources aligned
      for (final event in events) {
        await _eventsBox.put(event.id, jsonEncode(event.toJson()));
      }

      // Sort by date (upcoming first)
      events.sort((a, b) => a.eventDate.compareTo(b.eventDate));
      return events;
    } catch (e) {
      debugPrint(
          '✗ Error fetching events from MongoDB, falling back to Hive: $e');

      // Fallback to local cache if Mongo is unreachable
      final fallbackEvents = <ClubEventModel>[];
      for (final jsonString in _eventsBox.values) {
        try {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          fallbackEvents.add(ClubEventModel.fromJson(json));
        } catch (_) {}
      }
      fallbackEvents.sort((a, b) => a.eventDate.compareTo(b.eventDate));
      return fallbackEvents;
    }
  }

  /// Fetch events by club name
  Future<List<ClubEventModel>> getEventsByClub(String clubName) async {
    try {
      final all = await getAllClubEvents();
      return all.where((event) => event.clubName == clubName).toList();
    } catch (e) {
      debugPrint('✗ Error fetching club events: $e');
      return [];
    }
  }

  /// Fetch upcoming events only
  Future<List<ClubEventModel>> getUpcomingEvents() async {
    try {
      final now = DateTime.now();
      final all = await getAllClubEvents();
      return all.where((event) => event.eventDate.isAfter(now)).toList();
    } catch (e) {
      debugPrint('✗ Error fetching upcoming events: $e');
      return [];
    }
  }

  /// Get event by ID
  Future<ClubEventModel?> getEventById(String eventId) async {
    try {
      await _ensureInitialized();

      final db = await MongoDBService.getDb();
      final record =
          await db.collection(_collectionName).findOne({'_id': eventId});
      if (record != null) {
        return ClubEventModel.fromJson(Map<String, dynamic>.from(record));
      }
      return null;
    } catch (e) {
      debugPrint('✗ Event lookup failed: $e');

      // Fallback to local cache
      final jsonString = _eventsBox.get(eventId);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return ClubEventModel.fromJson(json);
      }
      return null;
    }
  }

  /// Update event
  Future<bool> updateEvent(ClubEventModel event) async {
    try {
      await _ensureInitialized();

      final db = await MongoDBService.getDb();
      await db
          .collection(_collectionName)
          .replaceOne({'_id': event.id}, event.toJson(), upsert: true);

      final jsonString = jsonEncode(event.toJson());
      await _eventsBox.put(event.id, jsonString);
      debugPrint('✓ Event updated: ${event.eventName}');
      return true;
    } catch (e) {
      debugPrint('✗ Error updating event: $e');
      return false;
    }
  }

  /// Delete event
  Future<bool> deleteEvent(String eventId) async {
    try {
      await _ensureInitialized();

      final db = await MongoDBService.getDb();
      await db.collection(_collectionName).remove({'_id': eventId});

      await _eventsBox.delete(eventId);
      debugPrint('✓ Event deleted: $eventId');
      return true;
    } catch (e) {
      debugPrint('✗ Error deleting event: $e');
      return false;
    }
  }

  /// Register user for event
  Future<bool> registerUserForEvent(String eventId, String userId) async {
    try {
      final event = await getEventById(eventId);
      if (event != null && !event.isRegisteredBy(userId)) {
        final updatedEvent = event.copyWith(
          registeredUsers: [...event.registeredUsers, userId],
        );
        return updateEvent(updatedEvent);
      }
      return false;
    } catch (e) {
      debugPrint('✗ Error registering user: $e');
      return false;
    }
  }

  /// Unregister user from event
  Future<bool> unregisterUserFromEvent(String eventId, String userId) async {
    try {
      final event = await getEventById(eventId);
      if (event != null && event.isRegisteredBy(userId)) {
        final updatedUsers =
            event.registeredUsers.where((id) => id != userId).toList();
        final updatedEvent = event.copyWith(registeredUsers: updatedUsers);
        return updateEvent(updatedEvent);
      }
      return false;
    } catch (e) {
      debugPrint('✗ Error unregistering user: $e');
      return false;
    }
  }

  /// Get total events
  Future<int> getTotalEventsCount() async {
    final all = await getAllClubEvents();
    return all.length;
  }

  /// Get user's registered events
  Future<List<ClubEventModel>> getUserRegisteredEvents(String userId) async {
    try {
      final all = await getAllClubEvents();
      return all.where((event) => event.isRegisteredBy(userId)).toList();
    } catch (e) {
      debugPrint('✗ Error fetching user events: $e');
      return [];
    }
  }

  /// Seed demo events (for testing - only if storage is empty)
  Future<void> seedDemoEvents() async {
    try {
      await _ensureInitialized();

      // Only seed if no events exist
      if (_eventsBox.isNotEmpty) {
        debugPrint('ℹ Events already exist, skipping demo seed');
        return;
      }

      final demoEvents = [
        ClubEventModel(
          clubName: 'Music Club',
          eventName: 'Treble Cleft - Musical Fest',
          eventDate: DateTime.now().add(const Duration(days: 5)),
          eventTime: '11:00 AM',
          description:
              'Join us for an amazing musical performance by talented artists. In collaboration with IEEE PES.',
          posterImagePath: '',
          eventLocation: 'Audi 2, PJ Block',
          registrationLink:
              'https://docs.google.com/forms/d/1XxF8mPnK2c9vW7y0gJ4hN5lQrT6sFp2I3kU8mV9lW0xY1zB2cD3/viewform',
          activityPoints: 10,
          createdBy: 'admin',
        ),
        ClubEventModel(
          clubName: 'Tech Club',
          eventName: 'Browser Battle - Codeathon',
          eventDate: DateTime.now().add(const Duration(days: 8)),
          eventTime: '2:00 PM',
          description:
              'Compete in coding challenges with a prize pool of ₹25,000. Show your web development skills!',
          posterImagePath: '',
          eventLocation: 'Computer Lab',
          registrationLink:
              'https://docs.google.com/forms/d/1AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXx/viewform',
          activityPoints: 25,
          createdBy: 'admin',
        ),
        ClubEventModel(
          clubName: 'Photography Club',
          eventName: 'Campus PhotoWalk',
          eventDate: DateTime.now().add(const Duration(days: 10)),
          eventTime: '4:00 PM',
          description:
              'Explore campus beauty through your lens. Share your best shots and win prizes!',
          posterImagePath: '',
          eventLocation: 'Main Campus',
          registrationLink:
              'https://docs.google.com/forms/d/1YyZzAaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvW/viewform',
          activityPoints: 15,
          createdBy: 'admin',
        ),
      ];

      for (final event in demoEvents) {
        await addClubEvent(event);
      }

      debugPrint('✓ Demo events seeded with activity points');
    } catch (e) {
      debugPrint('✗ Error seeding demo events: $e');
    }
  }
}
