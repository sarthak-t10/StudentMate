import 'package:uuid/uuid.dart';
import '../models/announcement_model.dart';
import '../models/user_model.dart';
import '../repositories/announcement_repository.dart';

class AnnouncementService {
  final AnnouncementRepository _repository = AnnouncementRepository();
  static const uuid = Uuid();

  /// Create college announcement (Admin only)
  Future<Announcement> createCollegeAnnouncement({
    required User admin,
    required String title,
    required String content,
    required String? attachmentUrl,
    String? attachmentName,
    String? attachmentType,
    bool isImportant = false,
  }) async {
    if (admin.userType != UserType.admin) {
      throw Exception('Only admins can create college announcements');
    }

    final announcement = Announcement(
      id: uuid.v4(),
      title: title.trim(),
      content: content.trim(),
      authorId: admin.id,
      authorName: admin.fullName,
      createdAt: DateTime.now(),
      announcementType: AnnouncementType.college,
      attachmentUrl: attachmentUrl,
      attachmentName: attachmentName,
      attachmentType: attachmentType,
      isImportant: isImportant,
      isActive: true,
    );

    await _repository.insertAnnouncement(announcement);
    return announcement;
  }

  /// Create faculty announcement
  Future<Announcement> createFacultyAnnouncement({
    required User faculty,
    required String title,
    required String content,
    required String branch,
    required String section,
    required String subject,
    String? subjectId,
    String? attachmentUrl,
    String? attachmentName,
    String? attachmentType,
  }) async {
    if (faculty.userType != UserType.faculty) {
      throw Exception('Only faculty can create faculty announcements');
    }

    // Validate required fields
    if (title.trim().isEmpty || content.trim().isEmpty) {
      throw Exception('Title and content cannot be empty');
    }

    if (branch.isEmpty || section.isEmpty || subject.isEmpty) {
      throw Exception('Branch, section, and subject are required');
    }

    final announcement = Announcement(
      id: uuid.v4(),
      title: title.trim(),
      content: content.trim(),
      authorId: faculty.id,
      authorName: faculty.fullName,
      createdAt: DateTime.now(),
      announcementType: AnnouncementType.faculty,
      branch: branch,
      section: section,
      subject: subject,
      subjectId: subjectId,
      attachmentUrl: attachmentUrl,
      attachmentName: attachmentName,
      attachmentType: attachmentType,
      isActive: true,
    );

    await _repository.insertAnnouncement(announcement);
    return announcement;
  }

  /// Get college announcements (for students)
  Future<List<Announcement>> getCollegeAnnouncements() async {
    return _repository.getCollegeAnnouncements();
  }

  /// Get faculty announcements relevant to a student
  Future<List<Announcement>> getFacultyAnnouncementsForStudent({
    required User student,
    String? subject,
  }) async {
    if (student.userType != UserType.student) {
      throw Exception('This method is for students only');
    }

    return _repository.getFacultyAnnouncementsForStudent(
      branch: student.branch,
      section: student.section,
      subject: subject,
    );
  }

  /// Get announcements for a specific subject
  Future<List<Announcement>> getAnnouncementsForSubject({
    required User student,
    required String subject,
  }) async {
    if (student.userType != UserType.student) {
      throw Exception('This method is for students only');
    }

    return _repository.getAnnouncementsForSubject(
      branch: student.branch,
      section: student.section,
      subject: subject,
    );
  }

  /// Get all announcements for a student (both college and faculty)
  Future<List<Announcement>> getAllAnnouncementsForStudent({
    required User student,
  }) async {
    if (student.userType != UserType.student) {
      throw Exception('This method is for students only');
    }

    final collegeAnnouncements = await getCollegeAnnouncements();
    final facultyAnnouncements = await getFacultyAnnouncementsForStudent(
      student: student,
    );

    // Combine and sort by date
    final all = [...collegeAnnouncements, ...facultyAnnouncements];
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all;
  }

  /// Get announcements created by a faculty member
  Future<List<Announcement>> getAnnouncementsByFaculty({
    required User faculty,
  }) async {
    if (faculty.userType != UserType.faculty) {
      throw Exception('This method is for faculty only');
    }

    return _repository.getAnnouncementsByFaculty(facultyId: faculty.id);
  }

  /// Get announcements created by an admin
  Future<List<Announcement>> getAnnouncementsByAdmin({
    required User admin,
  }) async {
    if (admin.userType != UserType.admin) {
      throw Exception('This method is for admin only');
    }

    return _repository.getAnnouncementsByAdmin(adminId: admin.id);
  }

  /// Get subjects available for a branch/section (for filtering)
  Future<List<String>> getAvailableSubjects({
    required String branch,
    required String section,
  }) async {
    return _repository.getSubjectsForBranchSection(
      branch: branch,
      section: section,
    );
  }

  /// Update announcement
  Future<void> updateAnnouncement(Announcement announcement) async {
    final updated = announcement.copyWith(
      updatedAt: DateTime.now(),
    );
    await _repository.updateAnnouncement(updated);
  }

  /// Delete announcement (soft delete)
  Future<void> deleteAnnouncement(String id) async {
    await _repository.deleteAnnouncement(id);
  }

  /// Get announcement by ID
  Future<Announcement?> getAnnouncementById(String id) async {
    return _repository.getAnnouncementById(id);
  }

  /// Count total announcements
  Future<int> countAnnouncements({String? announcementType}) async {
    return _repository.countAnnouncements(announcementType: announcementType);
  }
}
