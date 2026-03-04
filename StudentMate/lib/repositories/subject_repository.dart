import '../models/subject_model.dart';
import '../services/mongodb_service.dart';
import '../services/offline_cache_service.dart';

class SubjectRepository {
  static const String collectionName = 'subjects';

  Future<void> insertSubject(Subject subject) async {
    final db = await MongoDBService.getDb();
    await db.collection(collectionName).insert(subject.toJson());
  }

  Future<List<Subject>> getSubjectsByBranchAndSemester(
      String branch, String semester) async {
    final cacheKey = 'subjects.branchSemester.$branch.$semester';
    try {
      final db = await MongoDBService.getDb();
      final records = await db
          .collection(collectionName)
          .find({'branch': branch, 'semester': semester}).toList();
      await OfflineCacheService.saveList(
        cacheKey,
        records.map((e) => Map<String, dynamic>.from(e)).toList(),
      );
      return records.map((e) => Subject.fromJson(e)).toList();
    } catch (_) {
      final cached = await OfflineCacheService.readList(cacheKey);
      return cached.map((e) => Subject.fromJson(e)).toList();
    }
  }

  Future<List<Subject>> getSubjectsByBranch(String branch) async {
    final cacheKey = 'subjects.branch.$branch';
    try {
      final db = await MongoDBService.getDb();
      final records =
          await db.collection(collectionName).find({'branch': branch}).toList();
      await OfflineCacheService.saveList(
        cacheKey,
        records.map((e) => Map<String, dynamic>.from(e)).toList(),
      );
      return records.map((e) => Subject.fromJson(e)).toList();
    } catch (_) {
      final cached = await OfflineCacheService.readList(cacheKey);
      return cached.map((e) => Subject.fromJson(e)).toList();
    }
  }

  Future<List<Subject>> getAllSubjects() async {
    const cacheKey = 'subjects.all';
    try {
      final db = await MongoDBService.getDb();
      final records = await db.collection(collectionName).find().toList();
      await OfflineCacheService.saveList(
        cacheKey,
        records.map((e) => Map<String, dynamic>.from(e)).toList(),
      );
      return records.map((e) => Subject.fromJson(e)).toList();
    } catch (_) {
      final cached = await OfflineCacheService.readList(cacheKey);
      return cached.map((e) => Subject.fromJson(e)).toList();
    }
  }

  Future<void> deleteSubject(String id) async {
    final db = await MongoDBService.getDb();
    await db.collection(collectionName).remove({'_id': id});
  }
}
