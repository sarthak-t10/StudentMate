# StudentMate Announcements System - Visual Documentation

## 🏗️ System Architecture Diagram

```
┌────────────────────────────────────────────────────────────────────┐
│                        USER INTERFACE LAYER                         │
├────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  STUDENT                    FACULTY                   ADMIN        │
│  ┌──────────────┐           ┌──────────────┐         ┌──────────┐ │
│  │  View Tabs   │           │   Create     │         │  Create  │ │
│  │  ┌────────┐  │           │   Form       │         │  Form    │ │
│  │  │College │  │           │              │         │          │ │
│  │  │Faculty │  │  ────────▶│   Branch ▼   │  ───┈──▶│ Title    │ │
│  │  └────────┘  │           │   Section ▼  │         │ Content  │ │
│  │              │           │   Subject ▼  │         │ Attach   │ │
│  │  [Filter]    │           │   Title      │         │ Important│ │
│  │  [Subject]   │  ◀────────│   Content    │  ◀─────│ Submit   │ │
│  └──────────────┘           │   Attach     │         └──────────┘ │
│         │                   │   Submit     │                        │
│         └──────────────────▶└──────────────┘                        │
│              Detail View              │
│                │                      │
│                ▼                      ▼
│         ┌────────────────┐   ┌────────────────┐
│         │ Modal Dialog   │   │ Success/Error  │
│         │ - Full text    │   │ Messages       │
│         │ - Attachment   │   └────────────────┘
│         │ - Author info  │
│         │ - Date/Subject │
│         └────────────────┘
│
└────────────────────────────────────────────────────────────────────┘
         │                              │                          │
         │ UserAnnouncementsScreen      │ FacultyCreateScreen     │ AdminCreateScreen
         │                              │                          │
         └──────────────────┬───────────┴──────────────────────────┘
                            │
┌───────────────────────────▼──────────────────────────────────────┐
│                   SERVICE LAYER (Business Logic)                 │
├───────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────────────────────────┐                  │
│  │    AnnouncementService                   │                  │
│  │  • createCollegeAnnouncement()           │                  │
│  │  • createFacultyAnnouncement()           │                  │
│  │  • getCollegeAnnouncements()             │                  │
│  │  • getFacultyAnnouncementsForStudent()   │                  │
│  │  • getAnnouncementsForSubject()          │                  │
│  │  • getAnnouncementsByFaculty()           │                  │
│  │  • getAnnouncementsByAdmin()             │                  │
│  │  • searchAnnouncements()                 │                  │
│  │  • updateAnnouncement()                  │                  │
│  │  • deleteAnnouncement()                  │                  │
│  │  • countAnnouncements()                  │                  │
│  └──────────────────────────────────────────┘                  │
│                        │                                        │
│  ┌──────────────────────────────────────────┐                  │
│  │    FileService                           │                  │
│  │  • pickFile()                        │                  │
│  │  • openFile()                        │                  │
│  │  • validateFileType()                     │                  │
│  │  • formatFileSize()                      │                  │
│  │  • handleFileUpload()                    │                  │
│  └──────────────────────────────────────────┘                  │
│                        │                                        │
└────────────────────────▼────────────────────────────────────────┘
                        │
┌───────────────────────▼──────────────────────────────────────────┐
│            REPOSITORY LAYER (Data Access Layer)                 │
├───────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────────────────────────┐                  │
│  │   AnnouncementRepository                 │                  │
│  │  • insertAnnouncement()                  │                  │
│  │  • updateAnnouncement()                  │                  │
│  │  • deleteAnnouncement()                  │                  │
│  │  • getAllAnnouncements()                 │                  │
│  │  • getCollegeAnnouncements()             │                  │
│  │  • getFacultyAnnouncements..*()          │                  │
│  │  • getAnnouncementsByFaculty()           │                  │
│  │  • getAnnouncementsByAdmin()             │                  │
│  │  • getSubjectsForBranchSection()         │                  │
│  │  • searchAnnouncements()                 │                  │
│  │  • countAnnouncements()                  │                  │
│  └──────────────────────────────────────────┘                  │
│                        │                                        │
│  ┌──────────────────────────────────────────┐                  │
│  │   SubjectRepository (existing)           │                  │
│  │  • getSubjectsByBranch()                 │                  │
│  │  • getAllSubjects()                      │                  │
│  └──────────────────────────────────────────┘                  │
│                        │                                        │
└────────────────────────▼────────────────────────────────────────┘
                        │
┌───────────────────────▼──────────────────────────────────────────┐
│           DATABASE LAYER (MongoDB via mongo_dart)               │
├───────────────────────────────────────────────────────────────────┤
│                                                                  │
│  announcements collection                                       │
│  ├── Index: { announcementType, createdAt }                    │
│  ├── Index: { announcementType, branch, section, createdAt }   │
│  ├── Index: { announcementType, branch, section, subject, ..}  │
│  ├── Index: { authorId, createdAt }                            │
│  └── Index: { isActive, createdAt }                            │
│                                                                  │
│  Soft Delete: isActive = false                                  │
│                                                                  │
└────────────────────────────────────────────────────────────────────┘
```

## 📊 Data Flow Diagrams

### Flow 1: Student Views Announcements

```
Student
    │
    ▼
StudentAnnouncementsScreen (initState)
    │
    ├─▶ _loadAvailableSubjects()
    │        │
    │        └─▶ AnnouncementService
    │             │
    │             └─▶ AnnouncementRepository
    │                  │
    │                  └─▶ MongoDB (distinct query)
    │                      Returns: [Subject1, Subject2, ...]
    │
    └─▶ _loadAnnouncements()
         │
         ├─▶ _loadCollegeAnnouncements()
         │    │
         │    └─▶ AnnouncementService.getCollegeAnnouncements()
         │         │
         │         └─▶ AnnouncementRepository
         │              │
         │              └─▶ MongoDB
         │                  find({ announcementType: 'college', isActive: true })
         │                  Returns: [Announcement, ...]
         │
         └─▶ Display in ListView with AnnouncementCard widgets
              │
              ├─▶ Show title, content, author, date
              ├─▶ Show important badge (if isImportant)
              ├─▶ Show attachment icon (if attachmentUrl)
              └─▶ Tap to show detail modal
```

### Flow 2: Student Filters Faculty Announcements

```
Student selects subject chip
    │
    ▼
setState(_selectedSubject = subject)
    │
    ▼
_loadFacultyAnnouncements()
    │
    ▼
AnnouncementService.getFacultyAnnouncementsForStudent(
  branch: student.branch,
  section: student.section,
  subject: selectedSubject
)
    │
    ▼
AnnouncementRepository.getFacultyAnnouncementsForStudent()
    │
    ▼
MongoDB query:
  find({
    announcementType: 'faculty',
    branch: student.branch,
    section: student.section,
    subject: selectedSubject,
    isActive: true
  })
  .sort({ createdAt: -1 })
    │
    ▼
Returns: [Announcement, ...]
    │
    ▼
Display filtered announcements in ListView
```

### Flow 3: Faculty Creates Announcement

```
Faculty fills form
    │
    ├─▶ Select: Branch, Section, Subject
    ├─▶ Enter: Title, Content
    ├─▶ Upload: File (optional)
    │
    ▼
Click Submit
    │
    ▼
Validate form
    │
    ├─▶ Check required fields
    ├─▶ Check file size/type
    │
    ▼
AnnouncementService.createFacultyAnnouncement()
    │
    ├─▶ Validate user type = FACULTY
    ├─▶ Validate input data
    │
    ▼
Create Announcement model
    │
    ▼
AnnouncementRepository.insertAnnouncement()
    │
    ▼
MongoDB insert
    │
    ▼
Show success message
    │
    ▼
Clear form & update recent posts
    │
    ▼
Announcement visible to students in 
branch/section for that subject
```

### Flow 4: Admin Creates College Announcement

```
Admin fills form
    │
    ├─▶ Enter: Title, Content
    ├─▶ Toggle: Important
    ├─▶ Upload: File (optional)
    │
    ▼
Click Submit
    │
    ▼
Validate form
    │
    ▼
AnnouncementService.createCollegeAnnouncement()
    │
    ├─▶ Validate user type = ADMIN
    │
    ▼
Create Announcement model
    │
    ├─▶ announcementType: COLLEGE
    ├─▶ branch: null
    ├─▶ section: null
    ├─▶ subject: null
    │
    ▼
AnnouncementRepository.insertAnnouncement()
    │
    ▼
MongoDB insert
    │
    ▼
Show success & recent posts update
    │
    ▼
Announcement visible to ALL STUDENTS in
College tab on StudentAnnouncementsScreen
```

## 📱 UI Component Hierarchy

```
StudentAnnouncementsScreen (StatefulWidget)
├── AppBar
│   └── TabBar (2 tabs)
│       ├── Tab 1: College
│       └── Tab 2: Faculty
│
└── TabBarView
    ├── Tab 0: College Announcements
    │   ├── FloatingRefreshIndicator
    │   └── ListView
    │       └── AnnouncementCard (repeated)
    │           ├── Title + Important Badge
    │           ├── Content Preview (3 lines)
    │           ├── Metadata Row
    │           │   ├── Author icon + name
    │           │   ├── Date icon + formatted date
    │           │   └── Subject + Attachment icons
    │           └── Tap handler → Detail Modal
    │
    └── Tab 1: Faculty Announcements
        ├── Subject Filter Section
        │   ├── Text: "Filter by Subject"
        │   └── SingleChildScrollView (horizontal)
        │       ├── FilterChip "All"
        │       └── FilterChip (per subject)
        │
        └── AnnouncementsList
            ├── FloatingRefreshIndicator
            └── ListView
                └── AnnouncementCard (repeated)

Detail Modal (showDialog)
└── AlertDialog
    ├── Title (close button)
    ├── Important Badge (if needed)
    ├── Announcement Title
    ├── Metadata Chips
    │   ├── Author chip
    │   ├── Date chip
    │   └── Subject chip (if faculty)
    ├── Full Content
    ├── AttachmentPreview (if exists)
    └── Close Button
```

## 🔄 State Management Flow

```
StudentAnnouncementsScreen (StatefulWidget)
    │
    ├── _currentUser: User?
    │   ├── Load from AuthService
    │   └── Validate UserType == STUDENT
    │
    ├── College Tab State
    │   ├── _collegeAnnouncements: List<Announcement>
    │   ├── _loadingCollege: bool
    │   └── _collegeError: String?
    │
    ├── Faculty Tab State
    │   ├── _facultyAnnouncements: List<Announcement>
    │   ├── _availableSubjects: List<String>
    │   ├── _selectedSubject: String?
    │   ├── _loadingFaculty: bool
    │   ├── _loadingSubjects: bool
    │   └── _facultyError: String?
    │
    └── Event Handlers
        ├── _initializeUser() → Load user on init
        ├── _loadAvailableSubjects() → Load subjects
        ├── _loadCollegeAnnouncements() → Fetch college
        ├── _loadFacultyAnnouncements() → Fetch faculty
        └── _showAnnouncementDetail() → Show modal
```

## 📦 File Organization

```
StudentMate/
├── lib/
│   ├── models/
│   │   └── announcement_model.dart ✓ [UPDATED]
│   │
│   ├── repositories/
│   │   └── announcement_repository.dart ✓ [UPDATED]
│   │
│   ├── services/
│   │   ├── announcement_service.dart ✓ [NEW]
│   │   ├── file_service.dart ✓ [NEW]
│   │   └── mongodb_service.dart ✓ [UPDATED]
│   │
│   ├── views/
│   │   ├── student_announcements_screen.dart ✓ [NEW]
│   │   ├── faculty_create_announcement_screen.dart ✓ [NEW]
│   │   └── admin_create_announcement_screen.dart ✓ [NEW]
│   │
│   ├── widgets/
│   │   └── announcement_widgets.dart ✓ [NEW]
│   │
│   └── main.dart (existing)
│
└── Documentation/
    ├── ANNOUNCEMENTS_DOCUMENTATION.md ✓ [NEW]
    ├── ANNOUNCEMENTS_QUICK_REFERENCE.md ✓ [NEW]
    ├── ANNOUNCEMENTS_IMPLEMENTATION_EXAMPLES.md ✓ [NEW]
    ├── ANNOUNCEMENTS_DELIVERY_SUMMARY.md ✓ [NEW]
    └── ANNOUNCEMENTS_IMPLEMENTATION_CHECKLIST.md ✓ [NEW]
```

## 🔐 Role-Based Access Matrix

```
┌─────────────────────────────────────────────────────────────────┐
│ Operation              │ Student │ Faculty │ Admin              │
├─────────────────────────────────────────────────────────────────┤
│ View College Ann.      │   ✓     │   ✓    │   ✓               │
│ View Faculty Ann.      │   ✓*    │   ✓    │   ✓               │
│ Create College Ann.    │   ✗     │   ✗    │   ✓               │
│ Create Faculty Ann.    │   ✗     │   ✓    │   ✗               │
│ Edit Own Ann.          │   ✗     │   ✓    │   ✓               │
│ Delete Own Ann.        │   ✗     │   ✓    │   ✓               │
│ Delete Any Ann.        │   ✗     │   ✗    │   ✓               │
│ Upload Attachment      │   ✗     │   ✓    │   ✓               │
│ View User Emails       │   ✗     │   ✓    │   ✓               │
└─────────────────────────────────────────────────────────────────┘

* Filtered by student's branch/section
✓ Allowed
✗ Not Allowed
```

## 🎨 UI Color Scheme

```
Components              │ Color
───────────────────────┼──────────────────
Important Badge        │ Red (#FF0000)
Active Chips          │ Primary color
Disabled Chips        │ Gray shade 300
MetadataText          │ Gray shade 600
Background            │ White
Hover/Ripple          │ Gray shade 100
Error Messages        │ Red shade
Success Messages      │ Green shade
Attachment Icons      │ Orange shade
Subject Tags          │ Blue shade
```

## 📈 Performance Metrics

```
Operation             │ Time Complexity │ Space Complexity
──────────────────────┼──────────────────┼──────────────────
Load college ann.     │ O(log n)         │ O(n)
Load faculty ann.     │ O(log n)         │ O(n)
Filter by subject     │ O(log n)         │ O(m)
Search ann.          │ O(n)             │ O(m)
Create ann.          │ O(log n)         │ O(1)
Upload file          │ O(f)             │ O(f)
```

Where:
- n = total announcements
- m = filtered announcements
- f = file size

---

**Visual Documentation Complete** ✅
