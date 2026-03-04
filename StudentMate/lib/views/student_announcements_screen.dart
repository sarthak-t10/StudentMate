import 'package:flutter/material.dart';
import '../models/announcement_model.dart';
import '../models/user_model.dart';
import '../services/announcement_service.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/announcement_widgets.dart';

class StudentAnnouncementsScreen extends StatefulWidget {
  final User? initialUser;

  const StudentAnnouncementsScreen({
    Key? key,
    this.initialUser,
  }) : super(key: key);

  @override
  State<StudentAnnouncementsScreen> createState() =>
      _StudentAnnouncementsScreenState();
}

class _StudentAnnouncementsScreenState extends State<StudentAnnouncementsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnnouncementService _announcementService;
  late AuthService _authService;

  User? _currentUser;
  int _selectedTabIndex = 0;

  // For college announcements
  List<Announcement> _collegeAnnouncements = [];
  bool _loadingCollege = false;
  String? _collegeError;

  // For faculty announcements
  List<Announcement> _facultyAnnouncements = [];
  bool _loadingFaculty = false;
  String? _facultyError;
  List<String> _availableSubjects = [];
  String? _selectedSubject;
  bool _loadingSubjects = false;

  @override
  void initState() {
    super.initState();
    _announcementService = AnnouncementService();
    _authService = AuthService();
    _tabController = TabController(length: 2, vsync: this);

    _initializeUser();
    _loadAnnouncements();
  }

  Future<void> _initializeUser() async {
    try {
      final user = widget.initialUser ?? await _authService.getCurrentUser();
      if (user != null && user.userType == UserType.student) {
        setState(() => _currentUser = user);
        await _loadAvailableSubjects();
      }
    } catch (e) {
      debugPrint('Error initializing user: $e');
    }
  }

  Future<void> _loadAvailableSubjects() async {
    if (_currentUser == null) return;

    setState(() => _loadingSubjects = true);

    try {
      final subjects = await _announcementService.getAvailableSubjects(
        branch: _currentUser!.branch,
        section: _currentUser!.section,
      );
      setState(() {
        _availableSubjects = subjects;
        if (subjects.isNotEmpty && _selectedSubject == null) {
          _selectedSubject = subjects.first;
        }
      });
    } catch (e) {
      debugPrint('Error loading subjects: $e');
    } finally {
      setState(() => _loadingSubjects = false);
    }
  }

  Future<void> _loadAnnouncements() async {
    if (_selectedTabIndex == 0) {
      _loadCollegeAnnouncements();
    } else {
      _loadFacultyAnnouncements();
    }
  }

  Future<void> _loadCollegeAnnouncements() async {
    setState(() {
      _loadingCollege = true;
      _collegeError = null;
    });

    try {
      final announcements =
          await _announcementService.getCollegeAnnouncements();
      setState(() => _collegeAnnouncements = announcements);
    } catch (e) {
      setState(() => _collegeError = e.toString());
    } finally {
      setState(() => _loadingCollege = false);
    }
  }

  Future<void> _loadFacultyAnnouncements() async {
    if (_currentUser == null) return;

    setState(() {
      _loadingFaculty = true;
      _facultyError = null;
    });

    try {
      final announcements =
          await _announcementService.getFacultyAnnouncementsForStudent(
        student: _currentUser!,
        subject: _selectedSubject,
      );
      setState(() => _facultyAnnouncements = announcements);
    } catch (e) {
      setState(() => _facultyError = e.toString());
    } finally {
      setState(() => _loadingFaculty = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final isMobile = responsive.isSmallPhone;

    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.darkModeWidgetColor,
          unselectedLabelColor: Colors.black,
          indicatorColor: AppColors.darkModeWidgetColor,
          dividerColor: Colors.black,
          onTap: (index) {
            setState(() => _selectedTabIndex = index);
            Future.delayed(
                const Duration(milliseconds: 100), _loadAnnouncements);
          },
          tabs: const [
            Tab(text: 'College', icon: Icon(Icons.school)),
            Tab(text: 'Faculty', icon: Icon(Icons.group)),
          ],
        ),
      ),
      body: _buildBody(isMobile),
    );
  }

  Widget _buildBody(bool isMobile) {
    return TabBarView(
      controller: _tabController,
      children: [
        // College Announcements Tab
        _buildCollegeAnnouncementsTab(isMobile),
        // Faculty Announcements Tab
        _buildFacultyAnnouncementsTab(isMobile),
      ],
    );
  }

  // ============================================================================
  // COLLEGE ANNOUNCEMENTS TAB
  // ============================================================================

  Widget _buildCollegeAnnouncementsTab(bool isMobile) {
    if (_loadingCollege) {
      return ListView(
        padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 12),
        children: List.generate(5, (_) => const AnnouncementCardSkeleton()),
      );
    }

    if (_collegeError != null) {
      return AnnouncementEmptyState(
        title: 'Error Loading Announcements',
        message: _collegeError!,
        icon: Icons.error_outline,
        onRetry: _loadCollegeAnnouncements,
      );
    }

    if (_collegeAnnouncements.isEmpty) {
      return AnnouncementEmptyState(
        title: 'No College Announcements',
        message: 'Check back later for updates from the administration.',
        icon: Icons.notifications_none,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCollegeAnnouncements,
      child: ListView.builder(
        itemCount: _collegeAnnouncements.length,
        padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 12),
        itemBuilder: (context, index) {
          final announcement = _collegeAnnouncements[index];
          return Column(
            children: [
              AnnouncementCard(
                announcement: announcement,
                onTap: () => _showAnnouncementDetail(context, announcement),
              ),
              if (index == _collegeAnnouncements.length - 1)
                const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  // ============================================================================
  // FACULTY ANNOUNCEMENTS TAB
  // ============================================================================

  Widget _buildFacultyAnnouncementsTab(bool isMobile) {
    return Column(
      children: [
        // Subject Filter
        _buildSubjectFilter(isMobile),

        // Content
        Expanded(
          child: _buildFacultyAnnouncementsContent(isMobile),
        ),
      ],
    );
  }

  Widget _buildSubjectFilter(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Subject',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          if (_loadingSubjects)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_availableSubjects.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No subjects available',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // "All Subjects" option
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: _selectedSubject == null,
                      onSelected: (selected) {
                        setState(() => _selectedSubject = null);
                        _loadFacultyAnnouncements();
                      },
                    ),
                  ),
                  // Individual subject chips
                  ..._availableSubjects.map((subject) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(subject),
                        selected: _selectedSubject == subject,
                        onSelected: (selected) {
                          setState(() =>
                              _selectedSubject = selected ? subject : null);
                          _loadFacultyAnnouncements();
                        },
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFacultyAnnouncementsContent(bool isMobile) {
    if (_loadingFaculty) {
      return ListView(
        padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 12),
        children: List.generate(5, (_) => const AnnouncementCardSkeleton()),
      );
    }

    if (_facultyError != null) {
      return AnnouncementEmptyState(
        title: 'Error Loading Announcements',
        message: _facultyError!,
        icon: Icons.error_outline,
        onRetry: _loadFacultyAnnouncements,
      );
    }

    if (_facultyAnnouncements.isEmpty) {
      return AnnouncementEmptyState(
        title: 'No Faculty Announcements',
        message: _selectedSubject == null
            ? 'No announcements for your branch and section.'
            : 'No announcements for $_selectedSubject yet.',
        icon: Icons.notifications_none,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFacultyAnnouncements,
      child: ListView.builder(
        itemCount: _facultyAnnouncements.length,
        padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 12),
        itemBuilder: (context, index) {
          final announcement = _facultyAnnouncements[index];
          return Column(
            children: [
              AnnouncementCard(
                announcement: announcement,
                onTap: () => _showAnnouncementDetail(context, announcement),
              ),
              if (index == _facultyAnnouncements.length - 1)
                const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  // ============================================================================
  // ANNOUNCEMENT DETAIL DIALOG
  // ============================================================================

  void _showAnnouncementDetail(
      BuildContext context, Announcement announcement) {
    final responsive = ResponsiveHelper(context);
    final isMobile = responsive.isSmallPhone;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 80,
          vertical: 24,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // Important badge
                if (announcement.isImportant)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.priority_high,
                              size: 16, color: Colors.red.shade700),
                          const SizedBox(width: 4),
                          Text(
                            'Important',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Title
                Text(
                  announcement.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),

                // Metadata
                Wrap(
                  spacing: 16,
                  children: [
                    if (announcement.authorName != null)
                      Chip(
                        avatar: const Icon(Icons.person, size: 16),
                        label: Text(announcement.authorName!),
                      ),
                    Chip(
                      avatar: const Icon(Icons.calendar_today, size: 16),
                      label: Text(_formatDate(announcement.createdAt)),
                    ),
                    if (announcement.subject != null)
                      Chip(
                        avatar: const Icon(Icons.subject, size: 16),
                        label: Text(announcement.subject!),
                        backgroundColor: Colors.blue.shade50,
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Content
                Text(
                  announcement.content,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                      ),
                ),

                // Attachment
                if (announcement.attachmentUrl != null) ...[
                  const SizedBox(height: 24),
                  AttachmentPreview(
                    attachmentUrl: announcement.attachmentUrl,
                    attachmentName: announcement.attachmentName,
                    attachmentType: announcement.attachmentType,
                  ),
                ],

                // Close button
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }
}
