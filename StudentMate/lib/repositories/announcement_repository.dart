import 'package:mongo_dart/mongo_dart.dart' show where;
import '../models/announcement_model.dart';
import '../services/mongodb_service.dart';
import '../services/offline_cache_service.dart';

class AnnouncementRepository {
  static const String collectionName = 'announcements';

  /// Insert a new announcement
  Future<String> insertAnnouncement(Announcement announcement) async {
    final db = await MongoDBService.getDb();
    final result =
        await db.collection(collectionName).insert(announcement.toJson());
    return result.toString();
  }

  /// Get college announcements (visible to all students)
  Future<List<Announcement>> getCollegeAnnouncements() async {
    const cacheKey = 'announcements.college.active';
    try {
      final db = await MongoDBService.getDb();
      final records = await db
          .collection(collectionName)
          .find(where
              .eq('announcementType', 'college')
              .eq('isActive', true)
              .sortBy('createdAt', descending: true))
          .toList();

      await OfflineCacheService.saveList(
        cacheKey,
        records.map((e) => Map<String, dynamic>.from(e)).toList(),
      );

      return records
          .map((e) => Announcement.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      final cached = await OfflineCacheService.readList(cacheKey);
      return cached.map((e) => Announcement.fromJson(e)).toList();
    }
  }

  /// Get faculty announcements for a specific student
  /// Filters by student's branch, section, and optionally by subject
  Future<List<Announcement>> getFacultyAnnouncementsForStudent({
    required String branch,
    required String section,
    String? subject,
  }) async {
    final cacheKey =
        'announcements.faculty.student.$branch.$section.${subject ?? 'all'}';

    try {
      final db = await MongoDBService.getDb();

      final selectorBuilder = where
          .eq('announcementType', 'faculty')
          .eq('branch', branch)
          .eq('section', section)
          .eq('isActive', true);

      if (subject != null && subject.isNotEmpty) {
        selectorBuilder.eq('subject', subject);
      }

      selectorBuilder.sortBy('createdAt', descending: true);

      final records =
          await db.collection(collectionName).find(selectorBuilder).toList();

      await OfflineCacheService.saveList(
        cacheKey,
        records.map((e) => Map<String, dynamic>.from(e)).toList(),
      );

      return records
          .map((e) => Announcement.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      final cached = await OfflineCacheService.readList(cacheKey);
      return cached.map((e) => Announcement.fromJson(e)).toList();
    }
  }

  /// Get faculty announcements for a specific subject and branch/section
  Future<List<Announcement>> getAnnouncementsForSubject({
    required String branch,
    required String section,
    required String subject,
  }) async {
    final db = await MongoDBService.getDb();
    final records = await db
        .collection(collectionName)
        .find(where
            .eq('announcementType', 'faculty')
            .eq('branch', branch)
            .eq('section', section)
            .eq('subject', subject)
            .eq('isActive', true)
            .sortBy('createdAt', descending: true))
        .toList();

    return records
        .map((e) => Announcement.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get all announcements for a faculty member
  Future<List<Announcement>> getAnnouncementsByFaculty({
    required String facultyId,
  }) async {
    final db = await MongoDBService.getDb();
    final records = await db
        .collection(collectionName)
        .find(where
            .eq('authorId', facultyId)
            .eq('announcementType', 'faculty')
            .sortBy('createdAt', descending: true))
        .toList();

    return records
        .map((e) => Announcement.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get all announcements for an admin
  Future<List<Announcement>> getAnnouncementsByAdmin({
    required String adminId,
  }) async {
    final db = await MongoDBService.getDb();
    final records = await db
        .collection(collectionName)
        .find(where
            .eq('authorId', adminId)
            .eq('announcementType', 'college')
            .sortBy('createdAt', descending: true))
        .toList();

    return records
        .map((e) => Announcement.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get unique subjects for a branch and section (for filtering)
  Future<List<String>> getSubjectsForBranchSection({
    required String branch,
    required String section,
  }) async {
    final db = await MongoDBService.getDb();

    // Get all faculty announcements for this branch/section
    final selector = where
        .eq('announcementType', 'faculty')
        .eq('branch', branch)
        .eq('section', section)
        .eq('isActive', true);

    final records = await db.collection(collectionName).find(selector).toList();

    // Extract unique subjects
    final subjects = <String>{};
    for (var record in records) {
      final subject = record['subject'] as String?;
      if (subject != null && subject.isNotEmpty) {
        subjects.add(subject);
      }
    }

    return subjects.toList();
  }

  /// Update an announcement
  Future<void> updateAnnouncement(Announcement announcement) async {
    final db = await MongoDBService.getDb();
    await db.collection(collectionName).replaceOne(
      {'_id': announcement.id},
      announcement.toJson(),
    );
  }

  /// Delete (soft delete) an announcement
  Future<void> deleteAnnouncement(String id) async {
    final db = await MongoDBService.getDb();
    await db.collection(collectionName).updateOne(
      where.eq('_id', id),
      {
        '\$set': {'isActive': false}
      },
    );
  }

  /// Get announcement by ID
  Future<Announcement?> getAnnouncementById(String id) async {
    final db = await MongoDBService.getDb();
    final record =
        await db.collection(collectionName).findOne(where.eq('_id', id));
    return record != null
        ? Announcement.fromJson(record as Map<String, dynamic>)
        : null;
  }

  /// Count announcements
  Future<int> countAnnouncements({String? announcementType}) async {
    final db = await MongoDBService.getDb();

    final selector = announcementType != null
        ? where.eq('announcementType', announcementType).eq('isActive', true)
        : where.eq('isActive', true);

    return await db.collection(collectionName).count(selector);
  }
}
