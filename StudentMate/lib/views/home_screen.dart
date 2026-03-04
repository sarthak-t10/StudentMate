import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' show where;
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/mongodb_service.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/custom_widgets.dart';
import 'academics_screen.dart';
import 'club_screen.dart';
import 'calendar_screen.dart';
import 'student_documents_screen.dart';
import 'profile_screen.dart';
import 'admin_academics_screen.dart';
import 'admin_club_screen.dart';
import 'admin_calendar_screen.dart';
import 'admin_create_announcement_screen.dart';
import 'admin_settings_screen.dart';
import 'faculty_academic_screen.dart';
import 'faculty_calendar_screen.dart';
import 'faculty_create_announcement_screen.dart';
import 'student_announcements_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    // Show cached user immediately
    _currentUser = _authService.getCurrentUser();
    if (mounted) setState(() {});
    // Then fetch fresh from MongoDB so admin-uploaded photos appear
    _authService.refreshFromDb().then((_) {
      final fresh = _authService.getCurrentUser();
      if (fresh != null && mounted) {
        setState(() => _currentUser = fresh);
      }
    });
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/signin', (route) => false);
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.purpleDark),
          ),
        ),
      );
    }

    // Route to appropriate home screen based on user type
    if (_currentUser!.userType == UserType.admin) {
      return _buildAdminHome();
    } else if (_currentUser!.userType == UserType.faculty) {
      return _buildFacultyHome();
    } else {
      return _buildStudentHome();
    }
  }

  void _showProfileDialog(BuildContext context) {
    if (_currentUser == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  Widget _buildProfileHeader() {
    if (_currentUser == null) return const SizedBox.shrink();
    return Builder(
      builder: (context) {
        final responsive = ResponsiveHelper(context);
        return Column(
          children: [
            ProfileAvatar(
              base64Photo: _currentUser!.userPhotoUrl,
              name: _currentUser!.fullName,
              size: responsive.avatarSize,
              onTap: () => _showProfileDialog(context),
            ),
            SizedBox(height: responsive.spacingLarge),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.horizontalPadding,
                vertical: responsive.spacingMedium,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    _currentUser!.fullName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: responsive.subtitleFontSize,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: responsive.spacingSmall),
                  Text(
                    _currentUser!.branch.isNotEmpty
                        ? '${_currentUser!.branch} · ${_currentUser!.section}'
                        : _currentUser!.email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black87,
                          fontSize: responsive.smallFontSize,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: responsive.spacingSmall),
                  Text(
                    'Tap photo for details',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.purpleDark,
                          fontSize: responsive.smallFontSize * 0.9,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(height: responsive.spacingLarge),
          ],
        );
      },
    );
  }

  Widget _buildStudentHome() {
    return Scaffold(
      appBar: AppBar(
        leading: const AppLogo(),
        title: const Text('StudentMate'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            final responsive = ResponsiveHelper(context);
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(responsive.horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildProfileHeader(),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Student Modules',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: responsive.titleFontSize,
                                ),
                      ),
                    ),
                    SizedBox(height: responsive.spacingLarge),
                    GridView.count(
                      crossAxisCount: responsive.cardGridColumns,
                      childAspectRatio: 0.6,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: responsive.spacingMedium,
                      mainAxisSpacing: responsive.spacingMedium,
                      children: [
                        ModuleCard(
                          title: 'Academics',
                          icon: Icons.school,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AcademicsScreen()),
                          ),
                        ),
                        ModuleCard(
                          title: 'Club',
                          icon: Icons.groups,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ClubScreen()),
                          ),
                        ),
                        ModuleCard(
                          title: 'Calendar',
                          icon: Icons.calendar_today,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CalendarScreen()),
                          ),
                        ),
                        ModuleCard(
                          title: 'My Documents',
                          icon: Icons.folder_copy,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const StudentDocumentsScreen()),
                          ),
                        ),
                        ModuleCard(
                          title: 'Announcements',
                          icon: Icons.notifications_active,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const StudentAnnouncementsScreen()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAdminHome() {
    return Scaffold(
      appBar: AppBar(
        leading: const AppLogo(),
        title: const Text('Admin Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            final responsive = ResponsiveHelper(context);
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(responsive.horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Controls',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.purpleDark,
                              fontSize: responsive.titleFontSize),
                    ),
                    SizedBox(height: responsive.spacingLarge),
                    GridView.count(
                      crossAxisCount: responsive.cardGridColumns,
                      childAspectRatio: responsive.cardAspectRatio,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: responsive.spacingMedium,
                      mainAxisSpacing: responsive.spacingMedium,
                      children: [
                        ModuleCard(
                          title: 'Student Academics',
                          icon: Icons.school,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const AdminAcademicsScreen()),
                          ),
                        ),
                        ModuleCard(
                          title: 'Manage Clubs',
                          icon: Icons.event,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AdminClubScreen()),
                          ),
                        ),
                        ModuleCard(
                          title: 'Manage Calendar',
                          icon: Icons.calendar_month,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const AdminCalendarScreen()),
                          ),
                        ),
                        ModuleCard(
                          title: 'Create Announcement',
                          icon: Icons.announcement,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const AdminCreateAnnouncementScreen()),
                          ),
                        ),
                        ModuleCard(
                          title: 'Database Settings',
                          icon: Icons.storage,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const AdminSettingsScreen()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFacultyHome() {
    return Scaffold(
      appBar: AppBar(
        leading: const AppLogo(),
        title: const Text('Faculty Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            final responsive = ResponsiveHelper(context);
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(responsive.horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildProfileHeader(),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Faculty Controls',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.purpleDark,
                                fontSize: responsive.titleFontSize),
                      ),
                    ),
                    SizedBox(height: responsive.spacingLarge),
                    GridView.count(
                      crossAxisCount: responsive.cardGridColumns,
                      childAspectRatio: responsive.cardAspectRatio,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: responsive.spacingMedium,
                      mainAxisSpacing: responsive.spacingMedium,
                      children: [
                        ModuleCard(
                          title: 'Academics',
                          icon: Icons.school,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const FacultyAcademicScreen()),
                          ),
                        ),
                        ModuleCard(
                          title: 'View Calendar',
                          icon: Icons.calendar_today,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const FacultyCalendarScreen()),
                          ),
                        ),
                        ModuleCard(
                          title: 'Documents',
                          icon: Icons.folder_copy,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const StudentDocumentsScreen()),
                          ),
                        ),
                        ModuleCard(
                          title: 'Create Announcement',
                          icon: Icons.notifications,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const FacultyCreateAnnouncementScreen()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AdminAnnouncementScreen extends StatefulWidget {
  const AdminAnnouncementScreen({Key? key}) : super(key: key);

  @override
  State<AdminAnnouncementScreen> createState() =>
      _AdminAnnouncementScreenState();
}

class _AdminAnnouncementScreenState extends State<AdminAnnouncementScreen> {
  List<Map<String, dynamic>> _announcements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final db = await MongoDBService.getDb();
      final docs = await db
          .collection('notices')
          .find(where.sortBy('createdAt', descending: true))
          .toList();
      if (!mounted) return;
      setState(() {
        _announcements = docs.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _showCreateDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'New Announcement',
          style: TextStyle(color: Colors.black87),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.black87),
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: contentController,
                maxLines: 4,
                style: const TextStyle(color: Colors.black87),
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isEmpty) return;
              try {
                final db = await MongoDBService.getDb();
                await db.collection('notices').insert({
                  '_id': const Uuid().v4(),
                  'title': titleController.text,
                  'content': contentController.text,
                  'category': 'College',
                  'createdBy': 'Admin',
                  'createdAt': DateTime.now().toIso8601String(),
                });
                if (!mounted) return;
                Navigator.pop(dialogContext);
                await _loadAnnouncements();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Announcement posted to all students!')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppLogo(),
        title: const Text('Manage Announcements'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        backgroundColor: AppColors.purpleDark,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'College Announcements',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.purpleDark,
                              ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_announcements.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Text(
                            'No announcements yet. Tap + to add one!',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppColors.textSecondaryColor,
                                    ),
                          ),
                        ),
                      )
                    else
                      ..._announcements.map((notice) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.lg),
                            child: GradientCard(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notice['title'] as String? ?? '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.purpleDark,
                                              ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: AppColors.errorColor,
                                        ),
                                        onPressed: () async {
                                          try {
                                            final db =
                                                await MongoDBService.getDb();
                                            await db
                                                .collection('notices')
                                                .remove(where.eq(
                                                    '_id', notice['_id']));
                                            await _loadAnnouncements();
                                          } catch (_) {}
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    notice['content'] as String? ?? '',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    _formatDate(
                                        notice['createdAt'] as String? ?? ''),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.textSecondaryColor,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                  ],
                ),
              ),
            ),
    );
  }

  String _formatDate(String isoDate) {
    if (isoDate.length >= 10) return isoDate.substring(0, 10);
    return isoDate;
  }
}

class FacultyAnnouncementScreen extends StatefulWidget {
  const FacultyAnnouncementScreen({Key? key}) : super(key: key);

  @override
  State<FacultyAnnouncementScreen> createState() =>
      _FacultyAnnouncementScreenState();
}

class _FacultyAnnouncementScreenState extends State<FacultyAnnouncementScreen> {
  List<Map<String, dynamic>> _notices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  Future<void> _loadNotices() async {
    setState(() => _isLoading = true);
    try {
      final db = await MongoDBService.getDb();
      final docs = await db
          .collection('notices')
          .find(where.sortBy('createdAt', descending: true))
          .toList();
      if (!mounted) return;
      setState(() {
        _notices = docs.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppLogo(),
        title: const Text('Announcements'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latest Announcements',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.purpleDark),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_notices.isEmpty)
                      Center(
                        child: Text('No announcements yet.',
                            style: Theme.of(context).textTheme.bodyMedium),
                      )
                    else
                      ..._notices.map((notice) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.md),
                            child: GradientCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.md,
                                            vertical: AppSpacing.sm),
                                        decoration: BoxDecoration(
                                          gradient: AppColors.primaryGradient,
                                          borderRadius: BorderRadius.circular(
                                              AppRadius.md),
                                        ),
                                        child: Text(
                                          notice['category'] as String? ??
                                              'College',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12),
                                        ),
                                      ),
                                      Text(
                                        (notice['createdAt'] as String? ?? '')
                                                    .length >=
                                                10
                                            ? (notice['createdAt'] as String)
                                                .substring(0, 10)
                                            : '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    notice['title'] as String? ?? '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    notice['content'] as String? ?? '',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          )),
                  ],
                ),
              ),
            ),
    );
  }
}
