# StudentMate Announcements Module - Complete Documentation

## Overview

The Announcements module is a comprehensive, role-based system designed to manage college and faculty announcements with seamless integration into the StudentMate application. It supports three user roles (Admin, Faculty, Student) with role-specific functionality, filtering capabilities, and file attachment support.

---

## Architecture Overview

### Layered Architecture

```
UI Layer (Views)
├── StudentAnnouncementsScreen
├── FacultyCreateAnnouncementScreen
└── AdminCreateAnnouncementScreen
        ↓
Service Layer (Business Logic)
├── AnnouncementService
├── FileService
├── AuthService
└── ClubEventService (existing)
        ↓
Repository Layer (Data Access)
├── AnnouncementRepository
├── SubjectRepository
└── UserRepository (existing)
        ↓
Database Layer
└── MongoDB (via mongo_dart)
```

---

## Data Models

### Announcement Model

Located in: `lib/models/announcement_model.dart`

**Fields:**
- `id` (String) - Unique identifier (UUID)
- `title` (String) - Announcement title
- `content` (String) - Full announcement content
- `authorId` (String?) - Creator's user ID
- `authorName` (String?) - Creator's name
- `createdAt` (DateTime) - Creation timestamp
- `updatedAt` (DateTime?) - Last update timestamp
- `announcementType` (AnnouncementType) - Enum: `college` or `faculty`
- `branch` (String?) - Target branch (faculty announcements only)
- `section` (String?) - Target section (faculty announcements only)
- `subject` (String?) - Subject name (faculty announcements only)
- `subjectId` (String?) - Subject ID reference
- `attachmentUrl` (String?) - File URL
- `attachmentName` (String?) - Original file name
- `attachmentType` (String?) - File type (pdf, image, document, etc.)
- `category` (String?) - Legacy category field (for backward compatibility)
- `isImportant` (bool) - Priority flag (default: false)
- `isActive` (bool) - Soft delete flag (default: true)

**Enum:**
```dart
enum AnnouncementType { college, faculty }
```

---

## Services

### 1. AnnouncementService

**Location:** `lib/services/announcement_service.dart`

**Purpose:** Business logic layer for announcement operations

**Key Methods:**

#### Creating Announcements
```dart
// Admin creates college announcement
Future<Announcement> createCollegeAnnouncement({
  required User admin,
  required String title,
  required String content,
  String? attachmentUrl,
  String? attachmentName,
  String? attachmentType,
  bool isImportant = false,
})

// Faculty creates faculty announcement
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
})
```

#### Retrieving Announcements
```dart
// Get college announcements (for students)
Future<List<Announcement>> getCollegeAnnouncements({
  int limit = 20,
  int skip = 0,
})

// Get faculty announcements for a student
Future<List<Announcement>> getFacultyAnnouncementsForStudent({
  required User student,
  String? subject,
  int limit = 20,
  int skip = 0,
})

// Get announcements for specific subject
Future<List<Announcement>> getAnnouncementsForSubject({
  required User student,
  required String subject,
  int limit = 20,
  int skip = 0,
})

// Get all announcements by faculty member
Future<List<Announcement>> getAnnouncementsByFaculty({
  required User faculty,
  int limit = 20,
  int skip = 0,
})

// Get all announcements by admin
Future<List<Announcement>> getAnnouncementsByAdmin({
  required User admin,
  int limit = 20,
  int skip = 0,
})

// Get available subjects for filtering
Future<List<String>> getAvailableSubjects({
  required String branch,
  required String section,
})
```

#### Management Operations
```dart
Future<void> updateAnnouncement(Announcement announcement)
Future<void> deleteAnnouncement(String id)
Future<Announcement?> getAnnouncementById(String id)
Future<List<Announcement>> searchAnnouncements({...})
Future<int> countAnnouncements({String? announcementType})
```

### 2. FileService

**Location:** `lib/services/file_service.dart`

**Purpose:** Handle file uploads, downloads, and viewing

**Key Methods:**

```dart
// Pick files
Future<FileAttachment?> pickFile({
  List<String>? allowedExtensions,
  int maxSizeMB = 50,
})
Future<FileAttachment?> pickImageFile({int maxSizeMB = 10})
Future<FileAttachment?> pickPdfFile({int maxSizeMB = 50})
Future<FileAttachment?> pickDocumentFile({int maxSizeMB = 50})

// File operations
Future<void> openFile(String fileUrl)
Future<bool> fileExists(String fileUrl)
Future<void> deleteFile(String fileUrl)
Future<String?> getDownloadUrl(String fileUrl)

// Utilities
String formatFileSize(int bytes)
String getFileTypeName(FileType type)
bool validateFileType(String fileName, FileType requiredType)
```

**Supported File Types:**
- PDF: `pdf`
- Images: `jpg, jpeg, png, gif, webp`
- Documents: `doc, docx, txt, rtf, odt`
- Videos: `mp4, avi, mov, mkv, flv, webm`
- Audio: `mp3, aac, wav, flac, m4a, ogg`

---

## Repository Layer

### AnnouncementRepository

**Location:** `lib/repositories/announcement_repository.dart`

**Purpose:** Data access layer for MongoDB operations

**Key Methods:**

```dart
// CRUD operations
Future<String> insertAnnouncement(Announcement announcement)
Future<void> updateAnnouncement(Announcement announcement)
Future<void> deleteAnnouncement(String id) // Soft delete
Future<void> hardDeleteAnnouncement(String id) // Permanent delete
Future<Announcement?> getAnnouncementById(String id)

// Retrieval with filtering
Future<List<Announcement>> getAllAnnouncements({int? limit, int? skip})
Future<List<Announcement>> getCollegeAnnouncements({int? limit, int? skip})
Future<List<Announcement>> getFacultyAnnouncementsForStudent({
  required String branch,
  required String section,
  String? subject,
  int? limit,
  int? skip,
})
Future<List<Announcement>> getAnnouncementsForSubject({
  required String branch,
  required String section,
  required String subject,
  int? limit,
  int? skip,
})

// Search and aggregation
Future<List<Announcement>> searchAnnouncements({...})
Future<int> countAnnouncements({String? announcementType})
Future<List<String>> getSubjectsForBranchSection({...})
```

---

## UI Components

### Widgets (Reusable Components)

**Location:** `lib/widgets/announcement_widgets.dart`

#### 1. AnnouncementCard
Displays announcement summary with:
- Title and important badge
- Description (3 lines max)
- Author, date, and subject metadata
- Attachment indicator
- Delete button (optional)

```dart
AnnouncementCard(
  announcement: announcement,
  onTap: () => showDetail(announcement),
  onDelete: () => deleteAnnouncement(),
  showDeleteButton: isAuthor,
)
```

#### 2. AttachmentPreview
Displays file attachment with:
- File type icon
- File name and type
- Download/view button
- Error handling

```dart
AttachmentPreview(
  attachmentUrl: announcement.attachmentUrl,
  attachmentName: announcement.attachmentName,
  attachmentType: announcement.attachmentType,
)
```

#### 3. AnnouncementEmptyState
Shows placeholder when no announcements exist

```dart
AnnouncementEmptyState(
  title: 'No Announcements',
  message: 'Check back later...',
  icon: Icons.notifications_none,
  onRetry: () => reload(),
)
```

#### 4. AnnouncementCardSkeleton
Loading skeleton for announcements

```dart
AnnouncementCardSkeleton()
```

#### 5. FileUploadWidget
File picker and upload UI with:
- Drag-and-drop support (conceptual)
- File type validation
- Size validation
- Progress indication

```dart
FileUploadWidget(
  initialFileName: _attachmentName,
  onFileSelected: (url, name, type) { },
  allowedFileTypes: 'pdf,image,document',
  maxSizeMB: 50,
)
```

---

## Screens/Views

### 1. StudentAnnouncementsScreen

**Location:** `lib/views/student_announcements_screen.dart`

**Features:**
- Two tabs: College and Faculty announcements
- Subject-based filtering for faculty announcements
- Pull-to-refresh functionality
- Announcement detail view in modal dialog
- Loading states and error handling
- Responsive design (mobile, tablet, web)

**Tab 1: College Announcements**
- Displays all college-wide announcements
- Shows college admin as author
- Sorted by date (newest first)

**Tab 2: Faculty Announcements**
- Subject filter chips for easy switching
- Auto-filtered by student's branch and section
- Detail view shows subject info

**Usage:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const StudentAnnouncementsScreen(),
  ),
);
```

### 2. FacultyCreateAnnouncementScreen

**Location:** `lib/views/faculty_create_announcement_screen.dart`

**Features:**
- Branch, Section, and Subject selection (cascading dropdowns)
- Title and content text fields with validation
- Optional file attachment
- Form validation
- Error and success messages
- Loading states

**Form Fields:**
1. Branch (required) - Dropdown
2. Section (required) - Dropdown (loads after branch)
3. Subject (required) - Dropdown (loads after section)
4. Title (required) - Text field
5. Content (required) - Text area
6. Attachment (optional) - File upload

**Usage:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const FacultyCreateAnnouncementScreen(),
  ),
);
```

### 3. AdminCreateAnnouncementScreen

**Location:** `lib/views/admin_create_announcement_screen.dart`

**Features:**
- Simplified form for college-wide announcements
- Title and content fields
- Important flag toggle
- Optional file attachment
- Recently posted announcements sidebar (tablet)
- Responsive two-column layout

**Form Fields:**
1. Title (required) - Text field
2. Content (required) - Text area
3. Mark as Important (optional) - Checkbox
4. Attachment (optional) - File upload

**Recent Announcements Section:**
- Shows last 5 announcements posted by admin
- Visible on tablet/desktop as sidebar
- On mobile, appears below form

**Usage:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const AdminCreateAnnouncementScreen(),
  ),
);
```

---

## MongoDB Schema

### Collections and Indexes

**Collection:** `announcements`

**Indexes Created:**
```javascript
// Type and date sorting
db.announcements.createIndex({ announcementType: 1, createdAt: -1 })

// Faculty announcements filtering
db.announcements.createIndex({ 
  announcementType: 1, 
  branch: 1, 
  section: 1, 
  createdAt: -1 
})

// Subject-based filtering
db.announcements.createIndex({ 
  announcementType: 1, 
  branch: 1, 
  section: 1, 
  subject: 1, 
  createdAt: -1 
})

// Author-based queries
db.announcements.createIndex({ authorId: 1, createdAt: -1 })

// Active status filtering
db.announcements.createIndex({ isActive: 1, createdAt: -1 })
```

**Sample Document:**
```json
{
  "_id": "uuid-string",
  "title": "Mid-semester Examination Schedule",
  "content": "The mid-semester examinations will be held from...",
  "authorId": "faculty-user-id",
  "authorName": "Dr. John Doe",
  "createdAt": "2024-03-19T10:30:00Z",
  "updatedAt": null,
  "announcementType": "faculty",
  "branch": "CSE",
  "section": "A",
  "subject": "Data Structures",
  "subjectId": "subject-id",
  "attachmentUrl": "file://path/or/https://url",
  "attachmentName": "exam-schedule.pdf",
  "attachmentType": "pdf",
  "category": null,
  "isImportant": true,
  "isActive": true
}
```

---

## Integration Guide

### Step 1: Add to Navigation

Update your main navigation (e.g., `home_screen.dart`) to include announcement screens:

```dart
// For students
ListTile(
  title: const Text('Announcements'),
  leading: const Icon(Icons.notifications),
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const StudentAnnouncementsScreen()),
  ),
)

// For faculty
ListTile(
  title: const Text('Create Announcement'),
  leading: const Icon(Icons.add_circle),
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const FacultyCreateAnnouncementScreen()),
  ),
)

// For admin
ListTile(
  title: const Text('Post College Announcement'),
  leading: const Icon(Icons.newspaper),
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const AdminCreateAnnouncementScreen()),
  ),
)
```

### Step 2: Update pubspec.yaml

The following dependencies are already in your `pubspec.yaml`:
```yaml
dependencies:
  file_picker: ^10.3.10        # File selection
  url_launcher: ^6.3.0          # Opening attachments
  uuid: ^4.0.0                  # ID generation
  mongo_dart: ^0.10.8           # Database
```

### Step 3: Initialize Services

The services are initialized automatically in `main.dart`:

```dart
// Add to existing initialization
try {
  await MongoDBService.getDb();
  debugPrint('✓ MongoDB connected for Announcements');
} catch (e) {
  debugPrint('✗ MongoDB connection failed: $e');
}
```

---

## Data Flow Examples

### 1. Student View College Announcements

```
StudentAnnouncementsScreen
    ↓ (Tab 0: College)
_loadCollegeAnnouncements()
    ↓
AnnouncementService.getCollegeAnnouncements()
    ↓
AnnouncementRepository.getCollegeAnnouncements()
    ↓
MongoDB Query: 
  find({ announcementType: 'college', isActive: true })
  .sort({ createdAt: -1 })
    ↓
[Announcement]
    ↓
Display in ListView with AnnouncementCard widgets
```

### 2. Student Filter Faculty Announcements by Subject

```
StudentAnnouncementsScreen
    ↓ (Tab 1: Faculty)
_loadAvailableSubjects()
    ↓
AnnouncementService.getAvailableSubjects()
    ↓
AnnouncementRepository.getSubjectsForBranchSection()
    ↓
MongoDB distinct query: 
  collection('announcements').distinct('subject',
    where announcementType='faculty' 
    AND branch=student.branch 
    AND section=student.section)
    ↓
Show FilterChips for each subject
    ↓ (User selects subject)
_loadFacultyAnnouncements(subject)
    ↓
AnnouncementService.getFacultyAnnouncementsForStudent()
    ↓
AnnouncementRepository.getFacultyAnnouncementsForStudent(
  branch, section, subject
)
    ↓
Display filtered announcements
```

### 3. Faculty Create Announcement

```
FacultyCreateAnnouncementScreen
    ↓ (Submit form)
_submitForm()
    ↓
AnnouncementService.createFacultyAnnouncement()
    ↓ (Create model)
Announcement(
  announcementType: faculty,
  branch, section, subject,
  authorId: faculty.id,
  attachment: file_url
)
    ↓
AnnouncementRepository.insertAnnouncement()
    ↓
MongoDB insert
    ↓
Show success message
    ↓
Navigate back
```

---

## Error Handling

### Common Error Scenarios

| Scenario | Handling |
|----------|----------|
| No announcements | Show `AnnouncementEmptyState` with relevant message |
| Network error | Show error message with retry button |
| File too large | Show error in `FileUploadWidget` |
| Invalid form data | Show validation messages under fields |
| MongoDB connection failed | Show error on initialization |
| File not found | Show error in `AttachmentPreview` |
| Unauthorized access | Prevent based on `UserType` checks |

---

## Best Practices

### 1. Performance Optimization

- Use pagination (limit/skip) for large datasets
- Create appropriate MongoDB indexes (already done)
- Implement lazy loading for announcements
- Cache available subjects list
- Use `const` widgets where possible

### 2. User Experience

- Show loading states while fetching data
- Implement pull-to-refresh for announcements
- Use snackbars for success/error messages
- Provide meaningful empty states
- Support responsive design

### 3. Data Validation

- Validate all user input on both client and server
- Check file size before upload
- Validate user role before operations
- Ensure branch/section exists before creating announcements
- Soft-delete announcements (set `isActive: false`)

### 4. Security

- Always check `UserType` before allowing operations
- Only show relevant announcements to students
- Prevent faculty from posting college announcements
- Validate file types before upload
- Sanitize text inputs (handled by `trim()`)

---

## Future Enhancements

1. **Rich Text Editor** - Support formatted announcements
2. **Real-time Notifications** - Push notifications for new announcements
3. **Announcement Analytics** - Track read counts, engagement
4. **Draft Announcements** - Save drafts before publishing
5. **Scheduled Publishing** - Schedule announcements for future dates
6. **Search Indexing** - Full-text search support
7. **Comments/Replies** - Allow comments on announcements
8. **Email Notifications** - Send copies via email
9. **Batch Operations** - Upload multiple announcements
10. **Cloud Storage Integration** - S3/Firebase Storage for attachments

---

## Testing Checklist

- [ ] Student can view college announcements
- [ ] Student can view faculty announcements
- [ ] Subject filtering works correctly
- [ ] Faculty can create announcements
- [ ] Faculty announcements appear in student view
- [ ] Admin can create college announcements
- [ ] College announcements visible to all students
- [ ] File upload and download works
- [ ] Important flag highlights announcements
- [ ] Error messages display correctly
- [ ] Responsive design on mobile/tablet/web
- [ ] Loading states appear correctly
- [ ] Pagination works (if implemented)
- [ ] Empty states show appropriately
- [ ] Delete functionality works
- [ ] Date formatting is correct
- [ ] Author names display correctly

---

## Troubleshooting

**Problem:** Announcements not appearing
- **Solution:** Check MongoDB connection, verify indexes created, check user type

**Problem:** File upload fails
- **Solution:** Check file size, verify supported format, check disk space

**Problem:** Subject filter not working
- **Solution:** Verify subjects exist in database, check branch/section values

**Problem:** Cascading dropdowns not loading
- **Solution:** Check subject repository, verify branch exists, check database connection

**Problem:** Attachment not opening
- **Solution:** Verify file path/URL, check file exists, ensure supported format

---

## File Structure Summary

```
lib/
├── models/
│   └── announcement_model.dart          [UPDATED]
├── repositories/
│   └── announcement_repository.dart     [UPDATED]
├── services/
│   ├── announcement_service.dart        [NEW]
│   ├── file_service.dart                [NEW]
│   └── mongodb_service.dart             [UPDATED]
├── views/
│   ├── student_announcements_screen.dart        [NEW]
│   ├── faculty_create_announcement_screen.dart  [NEW]
│   └── admin_create_announcement_screen.dart    [NEW]
├── widgets/
│   └── announcement_widgets.dart        [NEW]
└── main.dart                            [EXISTING]
```

---

## Support & Questions

For issues or questions about the Announcements module:
1. Check the error messages and troubleshooting section
2. Verify MongoDB connection and indexes
3. Check user type and permissions
4. Validate input data format
5. Review logs for detailed error information

---

**Last Updated:** March 19, 2026
**Version:** 1.0.0
**Status:** Production Ready
