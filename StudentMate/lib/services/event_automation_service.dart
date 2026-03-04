import 'package:flutter/foundation.dart';
import '../models/club_event_model.dart';
import '../models/user_model.dart';
import 'club_event_service.dart';

/// Service to handle post-event automation including:
/// - Activity points award
/// - Attendance marking
/// - Point deduplication
class EventAutomationService {
  static final EventAutomationService _instance =
      EventAutomationService._internal();

  factory EventAutomationService() {
    return _instance;
  }

  EventAutomationService._internal();

  final ClubEventService _eventService = ClubEventService();

  // In-memory user storage (replace with actual API calls in production)
  final Map<String, User> _users = {};

  /// Process event after it has ended
  /// Awards activity points and marks attendance for registered students
  /// Returns number of students processed
  Future<int> processCompletedEvent(
    ClubEventModel event,
    List<String> attendedUserIds,
  ) async {
    try {
      // Prevent duplicate point awards
      if (event.pointsAwarded) {
        debugPrint(
            '⚠️ Event "${event.eventName}" already processed for points');
        return 0;
      }

      int processedCount = 0;

      // Award activity points to attended students
      for (final userId in attendedUserIds) {
        final success = await _awardActivityPoints(
          userId: userId,
          eventId: event.id,
          eventName: event.eventName,
          points: event.activityPoints,
        );
        if (success) {
          processedCount++;
        }
      }

      // Mark attendance for all registered students on event date
      for (final userId in event.registeredUsers) {
        final isAttended = attendedUserIds.contains(userId);
        await _markAttendance(
          userId: userId,
          date: event.eventDate,
          isPresent: isAttended,
          remarks: isAttended
              ? 'Attended: ${event.eventName}'
              : 'Registered but absent: ${event.eventName}',
          source: 'auto_event',
        );
      }

      // Update event to mark points as awarded
      final updatedEvent = event.copyWith(pointsAwarded: true);
      await _eventService.updateEvent(updatedEvent);

      debugPrint(
          '✓ Event "${event.eventName}" processed: $processedCount points awarded');
      return processedCount;
    } catch (e) {
      debugPrint('✗ Error processing event: $e');
      return 0;
    }
  }

  /// Award activity points to a user
  /// Prevents duplication by checking event history
  Future<bool> _awardActivityPoints({
    required String userId,
    required String eventId,
    required String eventName,
    required int points,
  }) async {
    try {
      final user = _getOrCreateUser(userId);

      // Check if points from this event already awarded
      final alreadyAwarded = user.activityPointHistory.any(
        (record) => record.sourceEventId == eventId,
      );

      if (alreadyAwarded) {
        debugPrint(
            '⚠️ Points already awarded for event "$eventName" to user $userId');
        return false;
      }

      // Award points
      final newTotalPoints = user.totalActivityPoints + points;
      final pointRecord = ActivityPointRecord(
        sourceEventId: eventId,
        eventName: eventName,
        points: points,
        awardedDate: DateTime.now(),
      );

      final updatedUser = user.copyWith(
        totalActivityPoints: newTotalPoints,
        activityPointHistory: [...user.activityPointHistory, pointRecord],
      );

      _users[userId] = updatedUser;

      debugPrint(
          '✓ Awarded $points points to $userId for "$eventName" (Total: $newTotalPoints)');
      return true;
    } catch (e) {
      debugPrint('✗ Error awarding points: $e');
      return false;
    }
  }

  /// Mark attendance for a student on a specific date
  Future<bool> _markAttendance({
    required String userId,
    required DateTime date,
    required bool isPresent,
    required String remarks,
    required String source,
  }) async {
    try {
      final user = _getOrCreateUser(userId);

      // Check if attendance already marked for this date
      final existingIndex = user.attendanceRecords.indexWhere(
        (r) =>
            r.date.year == date.year &&
            r.date.month == date.month &&
            r.date.day == date.day,
      );

      List<AttendanceRecord> updatedRecords = List.from(user.attendanceRecords);

      if (existingIndex != -1) {
        // Update existing record if it's from auto-event source
        final existing = updatedRecords[existingIndex];
        if (existing.source != 'auto_event') {
          debugPrint(
              '⚠️ Attendance already marked for $userId on ${date.toIso8601String()}');
          return false; // Don't override manually marked attendance
        }
        updatedRecords[existingIndex] = AttendanceRecord(
          date: date,
          isPresent: isPresent,
          remarks: remarks,
          source: source,
        );
      } else {
        // Add new record
        updatedRecords.add(
          AttendanceRecord(
            date: date,
            isPresent: isPresent,
            remarks: remarks,
            source: source,
          ),
        );
      }

      final updatedUser = user.copyWith(attendanceRecords: updatedRecords);
      _users[userId] = updatedUser;

      debugPrint(
          '✓ Marked ${isPresent ? 'present' : 'absent'} for $userId on ${date.toIso8601String()}');
      return true;
    } catch (e) {
      debugPrint('✗ Error marking attendance: $e');
      return false;
    }
  }

  /// Get or create user in memory storage
  User _getOrCreateUser(String userId) {
    return _users.putIfAbsent(
      userId,
      () => User(
        id: userId,
        fullName: 'User $userId',
        email: '$userId@college.edu',
        password: '',
        branch: '',
        section: '',
        userType: UserType.student,
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Get user by ID
  User? getUserById(String userId) {
    return _users[userId];
  }

  /// Get all users
  List<User> getAllUsers() {
    return _users.values.toList();
  }

  /// Update user (for syncing back to database)
  Future<bool> updateUser(User user) async {
    try {
      _users[user.id] = user;
      debugPrint('✓ User ${user.fullName} updated');
      return true;
    } catch (e) {
      debugPrint('✗ Error updating user: $e');
      return false;
    }
  }

  /// Check if an event is eligible for processing
  /// (has passed and not yet processed)
  bool isEventEligibleForProcessing(ClubEventModel event) {
    final now = DateTime.now();
    return event.eventDate.isBefore(now) && !event.pointsAwarded;
  }

  /// Get all completed events that haven't been processed
  Future<List<ClubEventModel>> getProcessingEligibleEvents() async {
    try {
      final allEvents = await _eventService.getAllClubEvents();
      return allEvents
          .where((event) => isEventEligibleForProcessing(event))
          .toList();
    } catch (e) {
      debugPrint('✗ Error getting eligible events: $e');
      return [];
    }
  }

  /// Auto-process all eligible events
  /// Should be called periodically (e.g., on app startup or scheduled)
  Future<int> autoProcessAllEligibleEvents() async {
    try {
      final eligibleEvents = await getProcessingEligibleEvents();
      int totalProcessed = 0;

      for (final event in eligibleEvents) {
        // For now, mark all registered users as attended
        // In production, this would check actual attendance records
        final processed = await processCompletedEvent(
          event,
          event.registeredUsers, // All registered = attended (for demo)
        );
        totalProcessed += processed;
      }

      debugPrint(
          '✓ Auto-processed ${eligibleEvents.length} events ($totalProcessed students)');
      return totalProcessed;
    } catch (e) {
      debugPrint('✗ Error in auto-processing: $e');
      return 0;
    }
  }
}
