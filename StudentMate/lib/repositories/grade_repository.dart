import '../models/grade_model.dart';
import '../services/mongodb_service.dart';
import '../services/offline_cache_service.dart';

class GradeRepository {
  static const String collectionName = 'grades';

  Future<void> insertGrade(Grade grade) async {
    final db = await MongoDBService.getDb();
    await db.collection(collectionName).insert(grade.toJson());
  }

  Future<List<Grade>> getGradesByUser(String userId) async {
    final cacheKey = 'grades.byUser.$userId';
    try {
      final db = await MongoDBService.getDb();
      final records =
          await db.collection(collectionName).find({'userId': userId}).toList();
      await OfflineCacheService.saveList(
        cacheKey,
        records.map((e) => Map<String, dynamic>.from(e)).toList(),
      );
      return records.map((e) => Grade.fromJson(e)).toList();
    } catch (_) {
      final cached = await OfflineCacheService.readList(cacheKey);
      return cached.map((e) => Grade.fromJson(e)).toList();
    }
  }

  Future<Grade?> getGradeByUserSubjectSemester(
      String userId, String subject, String semester) async {
    final cacheKey = 'grades.byUserSubjectSemester.$userId.$subject.$semester';
    try {
      final db = await MongoDBService.getDb();
      final doc = await db.collection(collectionName).findOne(
          {'userId': userId, 'subject': subject, 'semester': semester});
      await OfflineCacheService.saveMap(
        cacheKey,
        doc == null ? null : Map<String, dynamic>.from(doc),
      );
      if (doc == null) return null;
      return Grade.fromJson(doc);
    } catch (_) {
      final cached = await OfflineCacheService.readMap(cacheKey);
      if (cached == null) return null;
      return Grade.fromJson(cached);
    }
  }

  Future<List<Grade>> getGradesByBranchAndSemester(
      String branch, String semester, List<String> userIds) async {
    final db = await MongoDBService.getDb();
    final records = await db.collection(collectionName).find({
      'userId': {'\$in': userIds},
      'semester': semester
    }).toList();
    return records.map((e) => Grade.fromJson(e)).toList();
  }

  /// Returns all grades for the given subject+semester across the provided users.
  Future<List<Grade>> getGradesBySubjectAndUsers(
      String subject, String semester, List<String> userIds) async {
    final db = await MongoDBService.getDb();
    final records = await db.collection(collectionName).find({
      'userId': {'\$in': userIds},
      'subject': subject,
      'semester': semester,
    }).toList();
    return records.map((e) => Grade.fromJson(e)).toList();
  }

  /// Insert a new grade if no record exists for the userId+subject+semester
  /// triplet; otherwise replace the existing record.
  Future<void> upsertGrade(Grade grade) async {
    final db = await MongoDBService.getDb();
    final existing = await db.collection(collectionName).findOne({
      'userId': grade.userId,
      'subject': grade.subject,
      'semester': grade.semester,
    });
    if (existing == null) {
      await db.collection(collectionName).insert(grade.toJson());
    } else {
      final id = existing['_id'];
      await db
          .collection(collectionName)
          .replaceOne({'_id': id}, grade.toJson());
    }
  }

  Future<void> updateGrade(Grade grade) async {
    final db = await MongoDBService.getDb();
    await db
        .collection(collectionName)
        .replaceOne({'_id': grade.id}, grade.toJson());
  }

  Future<void> deleteGrade(String id) async {
    final db = await MongoDBService.getDb();
    await db.collection(collectionName).remove({'_id': id});
  }
}
