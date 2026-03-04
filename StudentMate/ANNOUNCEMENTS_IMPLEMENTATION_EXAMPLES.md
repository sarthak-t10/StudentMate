# StudentMate Announcements - Implementation Examples

## Example 1: Integrating Announcements into HomeScreen

**Location:** `lib/views/home_screen.dart` (add to navigation)

```dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../views/student_announcements_screen.dart';
import '../views/faculty_create_announcement_screen.dart';
import '../views/admin_create_announcement_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AuthService _authService;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUser();
    setState(() => _currentUser = user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('StudentMate')),
      drawer: _buildDrawer(),
      body: _buildHomeContent(),
    );
  }

  Widget _buildDrawer() {
    if (_currentUser == null) {
      return Drawer(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          UserAccountsDrawerHeader(
            accountName: Text(_currentUser!.fullName),
            accountEmail: Text(_currentUser!.email),
          ),
          
          // Common items
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Announcements'),
            onTap: _navigateToAnnouncements,
          ),
          
          const Divider(),
          
          // Role-specific items
          if (_currentUser!.userType == UserType.student)
            ..._buildStudentMenuItems()
          else if (_currentUser!.userType == UserType.faculty)
            ..._buildFacultyMenuItems()
          else if (_currentUser!.userType == UserType.admin)
            ..._buildAdminMenuItems(),
          
          const Divider(),
          
          // Logout
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStudentMenuItems() {
    return [
      ListTile(
        leading: const Icon(Icons.school),
        title: const Text('Academics'),
        onTap: () {
          Navigator.pop(context);
          // Navigate to academics
        },
      ),
      ListTile(
        leading: const Icon(Icons.calendar_today),
        title: const Text('Timetable'),
        onTap: () {
          Navigator.pop(context);
          // Navigate to timetable
        },
      ),
    ];
  }

  List<Widget> _buildFacultyMenuItems() {
    return [
      ListTile(
        leading: const Icon(Icons.add_circle),
        title: const Text('Create Announcement'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FacultyCreateAnnouncementScreen(),
            ),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.assignment),
        title: const Text('Manage Grades'),
        onTap: () {
          Navigator.pop(context);
          // Navigate to grade management
        },
      ),
    ];
  }

  List<Widget> _buildAdminMenuItems() {
    return [
      ListTile(
        leading: const Icon(Icons.newspaper),
        title: const Text('Post College Announcement'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminCreateAnnouncementScreen(),
            ),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.manage_accounts),
        title: const Text('Manage Users'),
        onTap: () {
          Navigator.pop(context);
          // Navigate to user management
        },
      ),
    ];
  }

  void _navigateToAnnouncements() {
    Navigator.pop(context);
    
    if (_currentUser == null) return;
    
    // Route based on user type
    if (_currentUser!.userType == UserType.student) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const StudentAnnouncementsScreen(),
        ),
      );
    } else if (_currentUser!.userType == UserType.faculty) {
      // Faculty sees own posted announcements or can create new
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FacultyCreateAnnouncementScreen(),
        ),
      );
    } else if (_currentUser!.userType == UserType.admin) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminCreateAnnouncementScreen(),
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    Navigator.pop(context);
    // Implement logout logic
    Navigator.of(context).pushReplacementNamed('/signin');
  }

  Widget _buildHomeContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome, ${_currentUser?.fullName ?? 'User'}!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          if (_currentUser != null)
            ElevatedButton(
              onPressed: _navigateToAnnouncements,
              child: const Text('View Announcements'),
            ),
        ],
      ),
    );
  }
}
```

---

## Example 2: Standalone Announcements Widget

Use this widget anywhere to display announcements inline:

```dart
import 'package:flutter/material.dart';
import '../models/announcement_model.dart';
import '../services/announcement_service.dart';
import '../widgets/announcement_widgets.dart';

class AnnouncementsWidget extends StatefulWidget {
  final String? title;
  final int maxItems;
  final VoidCallback? onViewAll;
  final bool showOnlyImportant;

  const AnnouncementsWidget({
    Key? key,
    this.title = 'Recent Announcements',
    this.maxItems = 5,
    this.onViewAll,
    this.showOnlyImportant = false,
  }) : super(key: key);

  @override
  State<AnnouncementsWidget> createState() => _AnnouncementsWidgetState();
}

class _AnnouncementsWidgetState extends State<AnnouncementsWidget> {
  late AnnouncementService _announcementService;
  List<Announcement> _announcements = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _announcementService = AnnouncementService();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() => _isLoading = true);
    
    try {
      var announcements = 
        await _announcementService.getCollegeAnnouncements(
          limit: widget.maxItems * 2,
        );
      
      if (widget.showOnlyImportant) {
        announcements = announcements
          .where((a) => a.isImportant)
          .toList();
      }
      
      setState(() {
        _announcements = announcements.take(widget.maxItems).toList();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and view all button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title!,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.onViewAll != null)
                  TextButton(
                    onPressed: widget.onViewAll,
                    child: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Content
            if (_isLoading)
              const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    'Error loading announcements',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              )
            else if (_announcements.isEmpty)
              SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    widget.showOnlyImportant 
                      ? 'No important announcements' 
                      : 'No announcements yet',
                  ),
                ),
              )
            else
              Column(
                children: _announcements.map((announcement) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AnnouncementCard(
                      announcement: announcement,
                      onTap: () => _showDetail(announcement),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  void _showDetail(Announcement announcement) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  announcement.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(announcement.content),
                if (announcement.attachmentUrl != null) ...[
                  const SizedBox(height: 16),
                  AttachmentPreview(
                    attachmentUrl: announcement.attachmentUrl,
                    attachmentName: announcement.attachmentName,
                    attachmentType: announcement.attachmentType,
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Usage in any screen:
// AnnouncementsWidget(
//   title: 'Important Updates',
//   maxItems: 3,
//   showOnlyImportant: true,
//   onViewAll: () => Navigator.push(...),
// )
```

---

## Example 3: Creating an Announcement Programmatically

```dart
import 'package:uuid/uuid.dart';
import '../models/announcement_model.dart';
import '../models/user_model.dart';
import '../services/announcement_service.dart';

class AnnouncementExample {
  final AnnouncementService _service = AnnouncementService();

  // Create a college announcement
  Future<void> createCollegeAnnouncement(User admin) async {
    try {
      final announcement = await _service.createCollegeAnnouncement(
        admin: admin,
        title: 'Mid-Semester Examinations Schedule',
        content: '''
Dear Students,

The mid-semester examinations are scheduled as follows:
- Physics: March 25-30
- Chemistry: April 1-5
- Mathematics: April 8-12

All exams will be conducted in the main examination hall from 9:00 AM to 12:00 PM.

Best wishes!
        ''',
        isImportant: true,
        // Optional: attachmentUrl, attachmentName, attachmentType
      );
      
      print('Created: ${announcement.id}');
    } catch (e) {
      print('Error: $e');
    }
  }

  // Create a faculty announcement
  Future<void> createFacultyAnnouncement(User faculty) async {
    try {
      final announcement = await _service.createFacultyAnnouncement(
        faculty: faculty,
        title: 'Data Structures Assignment 3 Due',
        content: '''
Assignment 3 on "Graphs and Trees" is due by April 15, 2024.

Requirements:
- Implement BFS and DFS algorithms
- Handle both directed and undirected graphs
- Write comprehensive test cases
- Submit as PDF with code and results

Submission format: YourName_Assignment3.pdf
        ''',
        branch: 'CSE',
        section: 'A',
        subject: 'Data Structures',
      );
      
      print('Faculty announcement created: ${announcement.id}');
    } catch (e) {
      print('Error: $e');
    }
  }

  // Retrieve and display announcements
  Future<void> retrieveAnnouncements(User student) async {
    try {
      // Get college announcements
      final collegeAnnouncements = 
        await _service.getCollegeAnnouncements(limit: 10);
      print('College announcements: ${collegeAnnouncements.length}');

      // Get faculty announcements for student
      final facultyAnnouncements = 
        await _service.getFacultyAnnouncementsForStudent(
          student: student,
          limit: 10,
        );
      print('Faculty announcements: ${facultyAnnouncements.length}');

      // Get announcements for specific subject
      final subjectAnnouncements = 
        await _service.getAnnouncementsForSubject(
          student: student,
          subject: 'Data Structures',
          limit: 5,
        );
      print('Data Structures announcements: ${subjectAnnouncements.length}');
    } catch (e) {
      print('Error: $e');
    }
  }
}
```

---

## Example 4: Custom Announcement Filtering

```dart
import '../models/announcement_model.dart';
import '../services/announcement_service.dart';
import '../models/user_model.dart';

Future<List<Announcement>> getCustomFilteredAnnouncements(
  User student,
  List<String> prioritySubjects,
) async {
  final service = AnnouncementService();
  
  // Get all announcements for student
  final announcements = 
    await service.getAllAnnouncementsForStudent(student: student);

  // Custom filtering
  return announcements.where((announcement) {
    // Priority: important announcements first
    if (announcement.isImportant) return true;
    
    // Then faculty announcements for priority subjects
    if (announcement.announcementType == AnnouncementType.faculty &&
        announcement.subject != null &&
        prioritySubjects.contains(announcement.subject)) {
      return true;
    }
    
    // Finally, college announcements
    if (announcement.announcementType == AnnouncementType.college) {
      return true;
    }
    
    return false;
  }).toList();
}
```

---

## Example 5: Search and Analytics

```dart
import '../services/announcement_service.dart';

class AnnouncementAnalytics {
  final AnnouncementService _service = AnnouncementService();

  // Search announcements
  Future<void> searchExample() async {
    try {
      final results = await _service.searchAnnouncements(
        query: 'exam',
        announcementType: 'college',
      );
      print('Found ${results.length} announcements containing "exam"');
    } catch (e) {
      print('Search error: $e');
    }
  }

  // Get statistics
  Future<void> getStatistics() async {
    try {
      final totalCount = await _service.countAnnouncements();
      final collegeCount = await _service.countAnnouncements(
        announcementType: 'college',
      );
      final facultyCount = totalCount - collegeCount;
      
      print('''
Announcement Statistics:
- Total: $totalCount
- College: $collegeCount
- Faculty: $facultyCount
      ''');
    } catch (e) {
      print('Statistics error: $e');
    }
  }

  // Get trending announcements (by recency and importance)
  Future<List<Announcement>> getTrendingAnnouncements() async {
    try {
      final important = await _service.getImportantAnnouncements(limit: 5);
      return important;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }
}
```

---

## Example 6: File Upload and Handler

```dart
import '../services/file_service.dart';
import 'package:flutter/material.dart';

class FileUploadExample {
  // Upload and get file attachment
  static Future<void> handleFileUpload(
    BuildContext context,
    Function(String url, String? name, String? type) onFileSelected,
  ) async {
    try {
      // Show file picker
      final file = await FileService.pickDocumentFile(maxSizeMB: 50);
      
      if (file != null) {
        // Show success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File selected: ${file.fileName}'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Return file details
        onFileSelected(
          file.fileUrl,
          file.fileName,
          file.fileType.toString(),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Open attachment
  static Future<void> openAttachment(
    BuildContext context,
    String fileUrl,
  ) async {
    try {
      await FileService.openFile(fileUrl);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

---

## Example 7: Error Handling Best Practices

```dart
import 'package:flutter/material.dart';
import '../services/announcement_service.dart';

class AnnouncementErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is String) {
      if (error.contains('MongoDB')) {
        return 'Database connection error. Please check your internet.';
      } else if (error.contains('only admins')) {
        return 'You do not have permission to perform this action.';
      } else if (error.contains('empty')) {
        return 'Please fill all required fields.';
      }
    }
    return 'An error occurred. Please try again.';
  }

  static void showErrorDialog(
    BuildContext context,
    dynamic error,
    VoidCallback onRetry,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(getErrorMessage(error)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
```

---

## Example 8: Basic Unit Test Template

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:student_mate/models/announcement_model.dart';
import 'package:student_mate/models/user_model.dart';
import 'package:student_mate/services/announcement_service.dart';

void main() {
  group('AnnouncementService Tests', () {
    late AnnouncementService announcementService;

    setUp(() {
      announcementService = AnnouncementService();
    });

    test('Create college announcement', () async {
      final admin = User(
        id: 'admin-1',
        fullName: 'Admin User',
        email: 'admin@college.edu',
        password: 'password123',
        branch: 'Admin',
        section: 'Admin',
        userType: UserType.admin,
        createdAt: DateTime.now(),
        totalActivityPoints: 0,
        attendanceRecords: [],
        activityPointHistory: [],
      );

      final announcement = await announcementService.createCollegeAnnouncement(
        admin: admin,
        title: 'Test Announcement',
        content: 'This is a test announcement',
        attachmentUrl: null,
      );

      expect(announcement.title, equals('Test Announcement'));
      expect(announcement.announcementType, equals(AnnouncementType.college));
      expect(announcement.isActive, isTrue);
    });

    test('Create faculty announcement', () async {
      final faculty = User(
        id: 'faculty-1',
        fullName: 'Dr. John Doe',
        email: 'john@college.edu',
        password: 'password123',
        branch: 'CSE',
        section: 'A',
        userType: UserType.faculty,
        createdAt: DateTime.now(),
        totalActivityPoints: 0,
        attendanceRecords: [],
        activityPointHistory: [],
      );

      final announcement = await announcementService.createFacultyAnnouncement(
        faculty: faculty,
        title: 'Assignment Due',
        content: 'Assignment 1 is due on Friday',
        branch: 'CSE',
        section: 'A',
        subject: 'Data Structures',
      );

      expect(announcement.subject, equals('Data Structures'));
      expect(announcement.announcementType, equals(AnnouncementType.faculty));
    });
  });
}
```

---

**All examples follow best practices and error handling!**

For more details, refer to:
- `ANNOUNCEMENTS_DOCUMENTATION.md` - Full documentation
- `ANNOUNCEMENTS_QUICK_REFERENCE.md` - Quick integration guide
- Source files for implementation details
