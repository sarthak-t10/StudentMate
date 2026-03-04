import '../models/academic_model.dart';
import '../services/mongodb_service.dart';
import '../services/offline_cache_service.dart';

class AcademicRepository {
  static const String subjectCollection = 'subjects';
  static const String marksCollection = 'student_marks';

  Future<void> insertSubject(Subject subject) async {
    final db = await MongoDBService.getDb();
    await db.collection(subjectCollection).insert(subject.toJson());
  }

  Future<List<Subject>> getAllSubjects() async {
    const cacheKey = 'academic.subjects.all';
    try {
      final db = await MongoDBService.getDb();
      final records = await db.collection(subjectCollection).find().toList();
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

  Future<void> insertStudentMarks(StudentMarks marks) async {
    final db = await MongoDBService.getDb();
    await db.collection(marksCollection).insert(marks.toJson());
  }

  Future<List<StudentMarks>> getMarksByStudent(String studentId) async {
    final cacheKey = 'academic.marks.$studentId';
    try {
      final db = await MongoDBService.getDb();
      final records = await db
          .collection(marksCollection)
          .find({'studentId': studentId}).toList();
      await OfflineCacheService.saveList(
        cacheKey,
        records.map((e) => Map<String, dynamic>.from(e)).toList(),
      );
      return records.map((e) => StudentMarks.fromJson(e)).toList();
    } catch (_) {
      final cached = await OfflineCacheService.readList(cacheKey);
      return cached.map((e) => StudentMarks.fromJson(e)).toList();
    }
  }
}
