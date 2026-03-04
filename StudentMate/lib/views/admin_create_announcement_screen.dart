import 'package:flutter/material.dart';
import '../models/announcement_model.dart';
import '../models/user_model.dart';
import '../services/announcement_service.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/announcement_widgets.dart';

class AdminCreateAnnouncementScreen extends StatefulWidget {
  final User? initialUser;

  const AdminCreateAnnouncementScreen({
    Key? key,
    this.initialUser,
  }) : super(key: key);

  @override
  State<AdminCreateAnnouncementScreen> createState() =>
      _AdminCreateAnnouncementScreenState();
}

class _AdminCreateAnnouncementScreenState
    extends State<AdminCreateAnnouncementScreen> {
  late AnnouncementService _announcementService;
  late AuthService _authService;

  User? _currentUser;

  // Form state
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  // Toggles
  bool _isImportant = false;

  // File upload
  String? _attachmentUrl;
  String? _attachmentName;
  String? _attachmentType;

  // Loading states
  bool _isSubmitting = false;

  String? _error;
  String? _success;

  // Recently posted announcements (for display)
  List<Announcement> _recentAnnouncements = [];

  @override
  void initState() {
    super.initState();
    _announcementService = AnnouncementService();
    _authService = AuthService();

    _titleController = TextEditingController();
    _contentController = TextEditingController();

    _initializeUser();
  }

  Future<void> _initializeUser() async {
    try {
      final user = widget.initialUser ?? await _authService.getCurrentUser();
      if (user != null && user.userType == UserType.admin) {
        setState(() => _currentUser = user);
        _loadRecentAnnouncements();
      }
    } catch (e) {
      _showError('Error loading user: $e');
    }
  }

  Future<void> _loadRecentAnnouncements() async {
    if (_currentUser == null) return;

    try {
      final announcements = await _announcementService.getAnnouncementsByAdmin(
          admin: _currentUser!);
      setState(() => _recentAnnouncements = announcements.take(5).toList());
    } catch (e) {
      debugPrint('Error loading recent announcements: $e');
    }
  }

  void _onFileSelected(String? url, String? name, String? type) {
    setState(() {
      _attachmentUrl = url;
      _attachmentName = name;
      _attachmentType = type;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_currentUser == null) {
      _showError('User not loaded. Please try again.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
      _success = null;
    });

    try {
      await _announcementService.createCollegeAnnouncement(
        admin: _currentUser!,
        title: _titleController.text,
        content: _contentController.text,
        attachmentUrl: _attachmentUrl,
        attachmentName: _attachmentName,
        attachmentType: _attachmentType,
        isImportant: _isImportant,
      );

      setState(() => _success = 'College announcement posted successfully!');

      // Clear form
      _formKey.currentState!.reset();
      _titleController.clear();
      _contentController.clear();
      setState(() {
        _isImportant = false;
        _attachmentUrl = null;
        _attachmentName = null;
        _attachmentType = null;
      });

      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Announcement posted successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Reload recent announcements
      _loadRecentAnnouncements();

      // Optional: Navigate back or stay for more posts
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          // Could navigate back or stay - let's stay for batch posting
        }
      });
    } catch (e) {
      _showError('Error posting announcement: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    setState(() => _error = message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final isTablet = responsive.isTablet;
    final isMobile = responsive.isSmallPhone;

    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Two-column layout for tablets/desktop
    if (isTablet) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Create College Announcement'),
          elevation: 0,
        ),
        body: Row(
          children: [
            Expanded(
              flex: 1,
              child: _buildFormContent(isMobile),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.grey.shade50,
                child: _buildRecentAnnouncements(isMobile),
              ),
            ),
          ],
        ),
      );
    }

    // Single column layout for mobile
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create College Announcement'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildFormContent(isMobile),
            Container(
              color: Colors.grey.shade50,
              child: _buildRecentAnnouncements(isMobile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent(bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This announcement will be visible to all students across all branches and sections.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Error message
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade600),
                      ),
                    ),
                  ],
                ),
              ),

            // Success message
            if (_success != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _success!,
                        style: TextStyle(color: Colors.green.shade600),
                      ),
                    ),
                  ],
                ),
              ),

            // Title
            Text(
              'Title',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              maxLines: 1,
              maxLength: 200,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Announcement title (max 200 characters)',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                counterText: '',
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a title';
                }
                if (value!.length < 3) {
                  return 'Title must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Content
            Text(
              'Content',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _contentController,
              maxLines: 8,
              maxLength: 5000,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText:
                    'Write your announcement here... (max 5000 characters)',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                counterText: '',
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter content';
                }
                if (value!.length < 10) {
                  return 'Content must be at least 10 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Important toggle
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CheckboxListTile(
                title: const Text('Mark as Important'),
                subtitle:
                    const Text('This will be highlighted for all students'),
                value: _isImportant,
                onChanged: (value) {
                  setState(() => _isImportant = value ?? false);
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(height: 20),

            // File Upload
            Text(
              'Attachment (Optional)',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            FileUploadWidget(
              initialFileName: _attachmentName,
              onFileSelected: _onFileSelected,
              allowedFileTypes: 'pdf,image,document',
              maxSizeMB: 50,
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.black),
                        ),
                      )
                    : const Text('Post Announcement'),
              ),
            ),
            const SizedBox(height: 16),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAnnouncements(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Announcements',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your last ${_recentAnnouncements.length} announcements',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        if (_recentAnnouncements.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: 32,
            ),
            child: Center(
              child: Text(
                'No announcements yet',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentAnnouncements.length,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: 0,
            ),
            itemBuilder: (context, index) {
              final announcement = _recentAnnouncements[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  elevation: 0,
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                announcement.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            if (announcement.isImportant)
                              Icon(
                                Icons.priority_high,
                                size: 16,
                                color: Colors.red,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          announcement.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatDate(announcement.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
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
