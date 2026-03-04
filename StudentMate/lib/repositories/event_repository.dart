import 'package:mongo_dart/mongo_dart.dart';
import '../models/event_model.dart';
import '../services/mongodb_service.dart';
import '../services/offline_cache_service.dart';

class EventRepository {
  static const String clubCollection = 'club_events';
  static const String calendarCollection = 'calendar_events';

  Future<void> insertClubEvent(ClubEvent event) async {
    final db = await MongoDBService.getDb();
    await db.collection(clubCollection).insert(event.toJson());
  }

  Future<List<ClubEvent>> getAllClubEvents() async {
    const cacheKey = 'events.club.all';
    try {
      final db = await MongoDBService.getDb();
      final records = await db
          .collection(clubCollection)
          .find(where.sortBy('eventDate', descending: false))
          .toList();
      await OfflineCacheService.saveList(
        cacheKey,
        records.map((e) => Map<String, dynamic>.from(e)).toList(),
      );
      return records.map((e) => ClubEvent.fromJson(e)).toList();
    } catch (_) {
      final cached = await OfflineCacheService.readList(cacheKey);
      return cached.map((e) => ClubEvent.fromJson(e)).toList();
    }
  }

  Future<void> updateClubEvent(ClubEvent event) async {
    final db = await MongoDBService.getDb();
    await db
        .collection(clubCollection)
        .replaceOne({'_id': event.id}, event.toJson(), upsert: true);
  }

  Future<void> deleteClubEvent(String id) async {
    final db = await MongoDBService.getDb();
    await db.collection(clubCollection).remove({'_id': id});
  }

  Future<void> insertCalendarEvent(CalendarEvent event) async {
    final db = await MongoDBService.getDb();
    await db.collection(calendarCollection).insert(event.toJson());
  }

  Future<List<CalendarEvent>> getAllCalendarEvents() async {
    const cacheKey = 'events.calendar.all';
    try {
      final db = await MongoDBService.getDb();
      final records = await db
          .collection(calendarCollection)
          .find(where.sortBy('eventDate', descending: false))
          .toList();
      await OfflineCacheService.saveList(
        cacheKey,
        records.map((e) => Map<String, dynamic>.from(e)).toList(),
      );
      return records.map((e) => CalendarEvent.fromJson(e)).toList();
    } catch (_) {
      final cached = await OfflineCacheService.readList(cacheKey);
      return cached.map((e) => CalendarEvent.fromJson(e)).toList();
    }
  }

  Future<void> updateCalendarEvent(CalendarEvent event) async {
    final db = await MongoDBService.getDb();
    await db
        .collection(calendarCollection)
        .replaceOne({'_id': event.id}, event.toJson(), upsert: true);
  }

  Future<void> deleteCalendarEvent(String id) async {
    final db = await MongoDBService.getDb();
    await db.collection(calendarCollection).remove({'_id': id});
  }
}
