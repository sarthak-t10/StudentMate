import '../models/timetable_model.dart';
import '../services/mongodb_service.dart';
import '../services/offline_cache_service.dart';

class TimeTableRepository {
  static const String collectionName = 'timetables';
  static const String imageCollectionName = 'timetable_images';

  Future<void> insertTimeTable(TimeTable timetable) async {
    final db = await MongoDBService.getDb();
    await db.collection(collectionName).insert(timetableToJson(timetable));
  }

  Future<List<TimeTable>> getTimeTableBySection(String section) async {
    final cacheKey = 'timetable.section.$section';
    try {
      final db = await MongoDBService.getDb();
      final records = await db
          .collection(collectionName)
          .find({'section': section}).toList();
      await OfflineCacheService.saveList(
        cacheKey,
        records.map((e) => Map<String, dynamic>.from(e)).toList(),
      );
      return records.map((e) => timetableFromJson(e)).toList();
    } catch (_) {
      final cached = await OfflineCacheService.readList(cacheKey);
      return cached.map((e) => timetableFromJson(e)).toList();
    }
  }

  Future<void> updateTimeTable(TimeTable timetable) async {
    final db = await MongoDBService.getDb();
    await db
        .collection(collectionName)
        .replaceOne({'_id': timetable.id}, timetableToJson(timetable));
  }

  Future<void> deleteTimeTable(String id) async {
    final db = await MongoDBService.getDb();
    await db.collection(collectionName).remove({'_id': id});
  }

  // ── Timetable image (one image per branch+section) ──────────────────────

  /// Upsert: replaces existing image for the same branch+section or inserts new.
  Future<void> upsertTimetableImage(TimetableImage img) async {
    final db = await MongoDBService.getDb();
    final col = db.collection(imageCollectionName);
    final existing =
        await col.findOne({'branch': img.branch, 'section': img.section});
    if (existing != null) {
      await col.replaceOne(
          {'branch': img.branch, 'section': img.section}, img.toJson());
    } else {
      await col.insert(img.toJson());
    }
  }

  Future<TimetableImage?> getTimetableImage(
      String branch, String section) async {
    final cacheKey = 'timetable.image.$branch.$section';
    try {
      final db = await MongoDBService.getDb();
      final doc = await db
          .collection(imageCollectionName)
          .findOne({'branch': branch, 'section': section});
      await OfflineCacheService.saveMap(
        cacheKey,
        doc == null ? null : Map<String, dynamic>.from(doc),
      );
      if (doc == null) return null;
      return TimetableImage.fromJson(doc);
    } catch (_) {
      final cached = await OfflineCacheService.readMap(cacheKey);
      if (cached == null) return null;
      return TimetableImage.fromJson(cached);
    }
  }
}

Map<String, dynamic> timetableToJson(TimeTable t) => {
      '_id': t.id,
      'subject': t.subject,
      'instructor': t.instructor,
      'room': t.room,
      'dayOfWeek': t.dayOfWeek,
      'startTime': t.startTime,
      'endTime': t.endTime,
    };

TimeTable timetableFromJson(Map<String, dynamic> json) => TimeTable(
      id: json['_id'] as String? ?? json['id'] as String,
      subject: json['subject'] as String,
      instructor: json['instructor'] as String,
      room: json['room'] as String,
      dayOfWeek: json['dayOfWeek'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
    );
