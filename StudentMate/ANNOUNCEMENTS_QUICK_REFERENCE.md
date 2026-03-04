# StudentMate Announcements Module - Quick Integration Guide

## 🚀 Quick Start

### 1. Navigation Integration

Add these navigation entries to your navigation drawer or bottom navigation:

**For Students:**
```dart
StudentAnnouncementsScreen()
```

**For Faculty:**
```dart
FacultyCreateAnnouncementScreen()
```

**For Admin:**
```dart
AdminCreateAnnouncementScreen()
```

### 2. Code Snippet

#### Import
```dart
import 'models/announcement_model.dart';
import 'services/announcement_service.dart';
import 'views/student_announcements_screen.dart';
import 'views/faculty_create_announcement_screen.dart';
import 'views/admin_create_announcement_screen.dart';
```

#### Navigate to Student Announcements
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const StudentAnnouncementsScreen(),
  ),
);
```

#### Navigate to Faculty Create
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const FacultyCreateAnnouncementScreen(),
  ),
);
```

#### Navigate to Admin Create
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const AdminCreateAnnouncementScreen(),
  ),
);
```

---

## 📁 File Structure

All announcement-related files:

```
✓ lib/models/announcement_model.dart                    [2.8 KB]
✓ lib/repositories/announcement_repository.dart         [3.2 KB]
✓ lib/services/announcement_service.dart               [3.5 KB]
✓ lib/services/file_service.dart                       [7.2 KB]
✓ lib/views/student_announcements_screen.dart          [6.5 KB]
✓ lib/views/faculty_create_announcement_screen.dart    [8.1 KB]
✓ lib/views/admin_create_announcement_screen.dart      [8.3 KB]
✓ lib/widgets/announcement_widgets.dart                [9.4 KB]
✓ ANNOUNCEMENTS_DOCUMENTATION.md                       [Comprehensive]
✓ ANNOUNCEMENTS_QUICK_REFERENCE.md                     [This file]
```

---

## 🎯 Feature Summary

### Student Features
- ✅ View college announcements (all students)
- ✅ View faculty announcements (branch/section specific)
- ✅ Filter by subject
- ✅ View attachment files
- ✅ Pull-to-refresh
- ✅ Responsive design

### Faculty Features
- ✅ Create announcements
- ✅ Select branch, section, subject
- ✅ Add title and content
- ✅ Upload attachment (PDF, image, document)
- ✅ Auto-save to MongoDB
- ✅ View recently posted

### Admin Features
- ✅ Create college-wide announcements
- ✅ Mark as important
- ✅ Add attachments
- ✅ View recent posts (dashboard)
- ✅ Responsive layout (two-column on tablet)

---

## 🔧 Technical Details

### Dependencies (Already in pubspec.yaml)
```yaml
mongo_dart: ^0.10.8          # Database
file_picker: ^10.3.10        # File selection
url_launcher: ^6.3.0         # Open files
uuid: ^4.0.0                 # Generate IDs
```

### MongoDB Indexes
```javascript
// Automatically created on app startup
- announcementType + createdAt
- announcementType + branch + section + createdAt
- announcementType + branch + section + subject + createdAt
- authorId + createdAt
- isActive + createdAt
```

### File Upload Support
- **PDF:** pdf
- **Images:** jpg, jpeg, png, gif, webp
- **Documents:** doc, docx, txt, ppt, pptx, xls, xlsx
- **Max Size:** 50MB (configurable)

---

## 📱 Responsive Design

### Mobile
- Full-width screens
- Single column layout
- Tab-based navigation (students)
- Touch-optimized buttons

### Tablet
- Optimized padding and margins
- Two-column layout (admin)
- Portrait and landscape support

### Web
- Maximum content width
- Multi-column layout
- Full keyboard support

---

## 🐛 Common Tasks

### Add to Home Screen Navigation

**In your home_screen.dart or navigation drawer:**

```dart
ListTile(
  leading: const Icon(Icons.notifications),
  title: const Text('Announcements'),
  onTap: () {
    final authService = AuthService();
    final user = authService.getCurrentUserSync();
    
    if (user?.userType == UserType.student) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const StudentAnnouncementsScreen(),
        ),
      );
    } else if (user?.userType == UserType.faculty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FacultyCreateAnnouncementScreen(),
        ),
      );
    } else if (user?.userType == UserType.admin) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminCreateAnnouncementScreen(),
        ),
      );
    }
  },
)
```

### Custom Usage of AnnouncementService

```dart
final announcementService = AnnouncementService();

// Get college announcements
final collegeAnnouncements = 
  await announcementService.getCollegeAnnouncements();

// Get faculty announcements for a student
final facultyAnnouncements = 
  await announcementService.getFacultyAnnouncementsForStudent(
    student: currentUser,
    subject: 'Data Structures',
  );

// Search announcements
final results = await announcementService.searchAnnouncements(
  query: 'exam',
);

// Get available subjects for filtering
final subjects = await announcementService.getAvailableSubjects(
  branch: 'CSE',
  section: 'A',
);
```

### File Operations

```dart
// Pick and upload file
final file = await FileService.pickPdfFile();
if (file != null) {
  print('File: ${file.fileName}');
  print('URL: ${file.fileUrl}');
  print('Size: ${FileService.formatFileSize(file.fileSizeBytes)}');
}

// Open file
await FileService.openFile(fileUrl);

// Check if file exists
final exists = await FileService.fileExists(fileUrl);

// Delete file
await FileService.deleteFile(fileUrl);
```

---

## ⚙️ Configuration

### Change Maximum File Size

In announcement creation screens, update:
```dart
FileUploadWidget(
  maxSizeMB: 100,  // Changed from 50
  ...
)
```

### Modify Supported File Types

In `FileUploadWidget`:
```dart
FileUploadWidget(
  allowedFileTypes: 'pdf,image,document,video',  // Added video
  ...
)
```

### Update Pagination

In `AnnouncementService.getCollegeAnnouncements()`:
```dart
final announcements = await announcementService.getCollegeAnnouncements(
  limit: 50,  // Items per page (default: 20)
  skip: 0,    // Pagination offset
);
```

---

## 🔐 Security & Permissions

### User Type Validation

The system automatically:
- Prevents students from creating announcements
- Prevents faculty from creating college announcements
- Filters announcements based on user's branch/section
- Validates all input data

### MongoDB Soft Deletes

Announcements are soft-deleted (marked as inactive):
```dart
await announcementService.deleteAnnouncement(id);
// Sets isActive: false instead of permanent deletion
```

Only admins can hard-delete:
```dart
await repository.hardDeleteAnnouncement(id);  // Permanent
```

---

## 📊 Data Model Reference

```dart
// Create announcement model
Announcement(
  id: 'unique-id',
  title: 'Important Update',
  content: 'Announcement body...',
  authorId: 'faculty-id',
  authorName: 'Dr. John Doe',
  createdAt: DateTime.now(),
  announcementType: AnnouncementType.faculty,
  branch: 'CSE',
  section: 'A',
  subject: 'Data Structures',
  attachmentUrl: 'file://path/document.pdf',
  attachmentName: 'document.pdf',
  attachmentType: 'pdf',
  isImportant: true,
  isActive: true,
)
```

---

## 🧪 Testing Guide

### Test College Announcements
```
1. Login as Admin
2. Post college announcement
3. Login as Student (any branch/section)
4. Go to Announcements > College tab
5. Verify announcement visible
```

### Test Faculty Announcements
```
1. Login as Faculty
2. Create announcement for CSE-A, Data Structures subject
3. Login as Student in CSE-A
4. Go to Announcements > Faculty tab
5. Select "Data Structures" subject
6. Verify announcement visible
```

### Test File Upload
```
1. Create announcement with PDF attachment
2. View announcement detail
3. Click "View Attachment"
4. Verify PDF opens in default viewer
```

### Test Filtering
```
1. Multiple faculty announcements for different subjects
2. Switch between subject filters
3. Verify correct announcements display
```

---

## 🎨 Customization Examples

### Change Color Scheme

In `announcement_widgets.dart`, update color constants:
```dart
// From
Colors.blue.shade50
// To
Colors.purple.shade50
```

### Modify Card Layout

Edit `AnnouncementCard` widget to add custom fields, change arrangement, etc.

### Add Archive Functionality

Extend `AnnouncementService` with:
```dart
Future<void> archiveAnnouncement(String id) async {
  final announcement = await _repository.getAnnouncementById(id);
  if (announcement != null) {
    final archived = announcement.copyWith(isArchived: true);
    await _repository.updateAnnouncement(archived);
  }
}
```

---

## 🚨 Troubleshooting

| Issue | Solution |
|-------|----------|
| Announcements not loading | Check MongoDB connection, verify indexes |
| File upload fails | Check file size < 50MB, valid format |
| Students see all announcements | Verify branch/section filtering in repository |
| Subjects not loading | Ensure subjects exist in database |
| Important flag not showing | Check `isImportant: true` in model |
| Attachments not opening | Verify file path exists, supported extension |

---

## 📞 Support Resources

1. **Full Documentation:** See `ANNOUNCEMENTS_DOCUMENTATION.md`
2. **File Service Reference:** Check `lib/services/file_service.dart`
3. **Database Queries:** Review `lib/repositories/announcement_repository.dart`
4. **UI Components:** Explore `lib/widgets/announcement_widgets.dart`

---

## 🎓 Learning Path

**Recommended order to understand the system:**

1. Read this quick reference first
2. Review the models: `announcement_model.dart`
3. Study the repositories: `announcement_repository.dart`
4. Explore the services: `announcement_service.dart`, `file_service.dart`
5. Examine the screens: Student > Faculty > Admin
6. Review widgets: `announcement_widgets.dart`
7. Read full documentation for deep dive

---

## ✅ Implementation Checklist

- [ ] All files created/updated
- [ ] Dependencies installed (already in pubspec.yaml)
- [ ] MongoDB indexes created (automatic)
- [ ] Navigation integrated
- [ ] Tested student view
- [ ] Tested faculty creation
- [ ] Tested admin creation
- [ ] File upload/download working
- [ ] Responsive design verified
- [ ] Error handling tested
- [ ] Documentation reviewed

---

**Status:** ✅ Production Ready
**Last Updated:** March 19, 2026
**Version:** 1.0.0
