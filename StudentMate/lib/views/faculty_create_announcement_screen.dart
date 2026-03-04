import 'package:flutter/material.dart';
import '../models/announcement_model.dart';
import '../models/subject_model.dart';
import '../models/user_model.dart';
import '../repositories/subject_repository.dart';
import '../services/announcement_service.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/announcement_widgets.dart';

class FacultyCreateAnnouncementScreen extends StatefulWidget {
  final User? initialUser;

  const FacultyCreateAnnouncementScreen({
    Key? key,
    this.initialUser,
  }) : super(key: key);

  @override
  State<FacultyCreateAnnouncementScreen> createState() =>
      _FacultyCreateAnnouncementScreenState();
}

class _FacultyCreateAnnouncementScreenState
    extends State<FacultyCreateAnnouncementScreen> {
  late AnnouncementService _announcementService;
  late AuthService _authService;
  late SubjectRepository _subjectRepository;

  User? _currentUser;

  // Form state
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  // Dropdowns
  List<String> _branches = [];
  List<String> _sections = [];
  List<Subject> _subjects = [];

  String? _selectedBranch;
  String? _selectedSection;
  String? _selectedSubject;
  String? _selectedSubjectId;

  // File upload
  String? _attachmentUrl;
  String? _attachmentName;
  String? _attachmentType;

  // Loading states
  bool _isLoadingBranches = false;
  bool _isLoadingSections = false;
  bool _isLoadingSubjects = false;
  bool _isSubmitting = false;

  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    _announcementService = AnnouncementService();
    _authService = AuthService();
    _subjectRepository = SubjectRepository();

    _titleController = TextEditingController();
    _contentController = TextEditingController();

    _initializeUser();
    _loadBranches();
  }

  Future<void> _initializeUser() async {
    try {
      final user = widget.initialUser ?? await _authService.getCurrentUser();
      if (user != null && user.userType == UserType.faculty) {
        setState(() => _currentUser = user);
        // Pre-select faculty's branch and section if available
        if (user.branch.isNotEmpty) {
          setState(() => _selectedBranch = user.branch);
          _loadSections(user.branch);
        }
        if (user.section.isNotEmpty) {
          setState(() => _selectedSection = user.section);
        }
      }
    } catch (e) {
      _showError('Error loading user: $e');
    }
  }

  Future<void> _loadBranches() async {
    setState(() => _isLoadingBranches = true);
    try {
      // Get all subjects to extract unique branches
      final subjects = await _subjectRepository.getAllSubjects();
      final branches = subjects.map((s) => s.branch).toSet().toList();
      setState(() => _branches = branches);
    } catch (e) {
      _showError('Error loading branches: $e');
    } finally {
      setState(() => _isLoadingBranches = false);
    }
  }

  Future<void> _loadSections(String branch) async {
    setState(() => _isLoadingSections = true);
    try {
      // In a real app, fetch sections from backend
      // For now, use common section names
      setState(() {
        _sections = ['A', 'B', 'C', 'D'];
        _selectedSection = null; // Reset section when branch changes
      });
    } catch (e) {
      _showError('Error loading sections: $e');
    } finally {
      setState(() => _isLoadingSections = false);
    }
  }

  Future<void> _loadSubjects(String branch, String section) async {
    setState(() => _isLoadingSubjects = true);
    try {
      // Filter subjects by branch
      final subjects = await _subjectRepository.getSubjectsByBranch(branch);
      setState(() {
        _subjects = subjects;
        _selectedSubject = null; // Reset subject when filters change
      });
    } catch (e) {
      _showError('Error loading subjects: $e');
    } finally {
      setState(() => _isLoadingSubjects = false);
    }
  }

  void _onBranchChanged(String? branch) {
    if (branch != null) {
      setState(() => _selectedBranch = branch);
      _loadSections(branch);
      _loadSubjects(branch, ''); // Load subjects for branch
    }
  }

  void _onSectionChanged(String? section) {
    if (section != null && _selectedBranch != null) {
      setState(() => _selectedSection = section);
      _loadSubjects(_selectedBranch!, section);
    }
  }

  void _onSubjectChanged(String? subject) {
    if (subject != null) {
      final selectedSubjectObj =
          _subjects.firstWhere((s) => s.subjectName == subject);
      setState(() {
        _selectedSubject = subject;
        _selectedSubjectId = selectedSubjectObj.id;
      });
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

    if (_selectedBranch == null ||
        _selectedSection == null ||
        _selectedSubject == null) {
      _showError('Please select branch, section, and subject');
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
      final announcement = await _announcementService.createFacultyAnnouncement(
        faculty: _currentUser!,
        title: _titleController.text,
        content: _contentController.text,
        branch: _selectedBranch!,
        section: _selectedSection!,
        subject: _selectedSubject!,
        subjectId: _selectedSubjectId,
        attachmentUrl: _attachmentUrl,
        attachmentName: _attachmentName,
        attachmentType: _attachmentType,
      );

      setState(() => _success = 'Announcement posted successfully!');

      // Clear form
      _formKey.currentState!.reset();
      _titleController.clear();
      _contentController.clear();
      setState(() {
        _attachmentUrl = null;
        _attachmentName = null;
        _attachmentType = null;
        _selectedSubject = null;
        _selectedSubjectId = null;
      });

      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Announcement posted successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate back
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context);
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
    final isMobile = responsive.isSmallPhone;

    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Announcement'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 24,
          vertical: 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

              // Branch Selection
              Text(
                'Branch',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              _isLoadingBranches
                  ? const SizedBox(
                      height: 48,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : DropdownButtonFormField<String>(
                      value: _selectedBranch,
                      items: _branches
                          .map((branch) => DropdownMenuItem(
                              value: branch, child: Text(branch)))
                          .toList(),
                      onChanged: _onBranchChanged,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'Select branch',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) =>
                          value == null ? 'Please select a branch' : null,
                    ),
              const SizedBox(height: 16),

              // Section Selection
              Text(
                'Section',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              if (_selectedBranch == null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    'Please select a branch first',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              else if (_isLoadingSections)
                const SizedBox(
                  height: 48,
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                DropdownButtonFormField<String>(
                  value: _selectedSection,
                  items: _sections
                      .map((section) => DropdownMenuItem(
                          value: section, child: Text(section)))
                      .toList(),
                  onChanged: _onSectionChanged,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'Select section',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) =>
                      value == null ? 'Please select a section' : null,
                ),
              const SizedBox(height: 16),

              // Subject Selection
              Text(
                'Subject',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              if (_selectedSection == null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    'Please select section first',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              else if (_isLoadingSubjects)
                const SizedBox(
                  height: 48,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_subjects.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Text(
                    'No subjects available for this branch',
                    style: TextStyle(color: Colors.orange.shade700),
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  value: _selectedSubject,
                  items: _subjects
                      .map((subject) => DropdownMenuItem(
                            value: subject.subjectName,
                            child: Text(subject.subjectName),
                          ))
                      .toList(),
                  onChanged: _onSubjectChanged,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'Select subject',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) =>
                      value == null ? 'Please select a subject' : null,
                ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Title',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                maxLines: 1,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Announcement title',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a title' : null,
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
                maxLines: 6,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Write your announcement here...',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter content' : null,
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
                  onPressed:
                      _isSubmitting ? null : () => Navigator.pop(context),
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
      ),
    );
  }
}
