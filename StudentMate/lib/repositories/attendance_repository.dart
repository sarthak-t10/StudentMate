import '../models/attendance_model.dart';
import '../services/mongodb_service.dart';
import '../services/offline_cache_service.dart';

class AttendanceRepository {
  static const String collectionName = 'attendance';

  Future<void> insertAttendance(Attendance attendance) async {
    final db = await MongoDBService.getDb();
    await db.collection(collectionName).insert(attendance.toJson());
  }

  Future<List<Attendance>> getAttendanceByUser(String userId) async {
    final cacheKey = 'attendance.byUser.$userId';
    try {
      final db = await MongoDBService.getDb();
      final records =
          await db.collection(collectionName).find({'userId': userId}).toList();
      await OfflineCacheService.saveList(
        cacheKey,
        records.map((e) => Map<String, dynamic>.from(e)).toList(),
      );
      return records.map((e) => Attendance.fromJson(e)).toList();
    } catch (_) {
      final cached = await OfflineCacheService.readList(cacheKey);
      return cached.map((e) => Attendance.fromJson(e)).toList();
    }
  }

  Future<Attendance?> getAttendanceByUserAndSubject(
      String userId, String subject) async {
    final cacheKey = 'attendance.byUserAndSubject.$userId.$subject';
    try {
      final db = await MongoDBService.getDb();
      final record = await db
          .collection(collectionName)
          .findOne({'userId': userId, 'subject': subject});
      await OfflineCacheService.saveMap(
        cacheKey,
        record == null ? null : Map<String, dynamic>.from(record),
      );
      return record != null ? Attendance.fromJson(record) : null;
    } catch (_) {
      final cached = await OfflineCacheService.readMap(cacheKey);
      return cached != null ? Attendance.fromJson(cached) : null;
    }
  }

  /// Returns all attendance records for a section+subject combination.
  Future<List<Attendance>> getAttendanceBySubjectAndSection(
      String subject, String section) async {
    final db = await MongoDBService.getDb();
    final records = await db
        .collection(collectionName)
        .find({'subject': subject, 'section': section}).toList();
    return records.map((e) => Attendance.fromJson(e)).toList();
  }

  /// Insert if no record exists for userId+subject, otherwise update.
  Future<void> upsertAttendance(Attendance attendance) async {
    final db = await MongoDBService.getDb();
    final existing = await db
        .collection(collectionName)
        .findOne({'userId': attendance.userId, 'subject': attendance.subject});
    if (existing == null) {
      await db.collection(collectionName).insert(attendance.toJson());
    } else {
      await db.collection(collectionName).replaceOne(
          {'userId': attendance.userId, 'subject': attendance.subject},
          attendance.toJson());
    }
  }

  Future<void> updateAttendance(Attendance attendance) async {
    final db = await MongoDBService.getDb();
    await db
        .collection(collectionName)
        .replaceOne({'_id': attendance.id}, attendance.toJson());
  }

  Future<void> deleteAttendance(String id) async {
    final db = await MongoDBService.getDb();
    await db.collection(collectionName).remove({'_id': id});
  }
}
