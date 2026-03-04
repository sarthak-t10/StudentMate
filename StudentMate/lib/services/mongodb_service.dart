import 'package:mongo_dart/mongo_dart.dart';

class MongoDBService {
  static Db? _db;

  // ──────────────────────────────────────────────────────────────────────────
  // ANDROID / PHYSICAL DEVICE: change this to your PC's LAN IP.
  // Run `ipconfig` (Windows) or `ifconfig` (Mac/Linux) to find it.
  // The phone and the PC must be on the same WiFi network.
  // Example: 'mongodb://192.168.29.118:27017/studentmate'
  //
  // ANDROID EMULATOR: use 'mongodb://10.0.2.2:27017/studentmate'
  //
  // WINDOWS / WEB dev:  'mongodb://localhost:27017/studentmate'
  // ──────────────────────────────────────────────────────────────────────────
  static const String _mongoHost = 'localhost';
  static const String _defaultConnectionString =
      'mongodb://$_mongoHost:27017/studentmate';
  static const String _connectionString = String.fromEnvironment(
    'MONGODB_URI',
    defaultValue: _defaultConnectionString,
  );

  static Future<Db> getDb() async {
    if (_db == null || !_db!.isConnected) {
      _db = await Db.create(_connectionString);
      await _db!.open();
      await _ensureIndexes(_db!);
    }
    return _db!;
  }

  static Future<void> _ensureIndexes(Db db) async {
    await db.collection('users').createIndex(keys: {'email': 1}, unique: true);
    await db
        .collection('grades')
        .createIndex(keys: {'userId': 1, 'semester': 1});
    await db
        .collection('attendance')
        .createIndex(keys: {'userId': 1, 'subject': 1});
    await db.collection('club_events').createIndex(keys: {'eventDate': 1});
    await db.collection('calendar_events').createIndex(keys: {'eventDate': 1});
    await db.collection('notices').createIndex(keys: {'createdAt': -1});

    // Announcements indexes for efficient querying
    await db
        .collection('announcements')
        .createIndex(keys: {'announcementType': 1, 'createdAt': -1});
    await db.collection('announcements').createIndex(keys: {
      'announcementType': 1,
      'branch': 1,
      'section': 1,
      'createdAt': -1
    });
    await db.collection('announcements').createIndex(keys: {
      'announcementType': 1,
      'branch': 1,
      'section': 1,
      'subject': 1,
      'createdAt': -1
    });
    await db
        .collection('announcements')
        .createIndex(keys: {'authorId': 1, 'createdAt': -1});
    await db
        .collection('announcements')
        .createIndex(keys: {'isActive': 1, 'createdAt': -1});
  }

  // Collection accessors
  static Future<DbCollection> getUsersCollection() async {
    final db = await getDb();
    return db.collection('users');
  }

  static Future<DbCollection> getAttendanceCollection() async {
    final db = await getDb();
    return db.collection('attendance');
  }

  static Future<DbCollection> getGradesCollection() async {
    final db = await getDb();
    return db.collection('grades');
  }

  static Future<DbCollection> getTimetableCollection() async {
    final db = await getDb();
    return db.collection('timetable');
  }

  static Future<DbCollection> getAnnouncementsCollection() async {
    final db = await getDb();
    return db.collection('announcements');
  }

  static Future<DbCollection> getClubEventsCollection() async {
    final db = await getDb();
    return db.collection('club_events');
  }

  static Future<DbCollection> getCalendarEventsCollection() async {
    final db = await getDb();
    return db.collection('calendar_events');
  }

  static Future<DbCollection> getSubjectsCollection() async {
    final db = await getDb();
    return db.collection('subjects');
  }

  static Future<DbCollection> getStudentMarksCollection() async {
    final db = await getDb();
    return db.collection('student_marks');
  }

  static Future<DbCollection> getNoticesCollection() async {
    final db = await getDb();
    return db.collection('notices');
  }

  static Future<void> close() async {
    if (_db != null && _db!.isConnected) {
      await _db!.close();
    }
  }
}
