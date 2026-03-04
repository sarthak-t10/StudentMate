import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/subject_model.dart';
import '../models/timetable_model.dart';
import '../models/user_model.dart';
import '../repositories/subject_repository.dart';
import '../repositories/timetable_repository.dart';
import '../repositories/user_repository.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/responsive_layout_components.dart';

class AdminAcademicsScreen extends StatefulWidget {
  const AdminAcademicsScreen({Key? key}) : super(key: key);

  @override
  State<AdminAcademicsScreen> createState() => _AdminAcademicsScreenState();
}

class _AdminAcademicsScreenState extends State<AdminAcademicsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppLogo(),
        title: const Text('Academics Management'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.book), text: 'Subjects'),
            Tab(icon: Icon(Icons.table_chart), text: 'Timetable'),
            Tab(icon: Icon(Icons.person_pin), text: 'Photos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _SubjectsTab(),
          _TimetableTab(),
          _UserPhotosTab(),
        ],
      ),
    );
  }
}

// ── Tab 1: Subject Management ────────────────────────────────────────────────

class _SubjectsTab extends StatefulWidget {
  const _SubjectsTab();

  @override
  State<_SubjectsTab> createState() => _SubjectsTabState();
}

class _SubjectsTabState extends State<_SubjectsTab> {
  final SubjectRepository _repo = SubjectRepository();
  final TextEditingController _subjectNameCtrl = TextEditingController();
  final TextEditingController _creditsCtrl = TextEditingController();

  // Branches and semesters
  final List<String> _branches = [
    'CSE',
    'ISE',
    'ECE',
    'EEE',
    'ME',
    'CV',
    'BT',
    'CH'
  ];
  String _selectedBranch = 'CSE';
  String _selectedSemester = '1';
  List<Subject> _subjects = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  @override
  void dispose() {
    _subjectNameCtrl.dispose();
    _creditsCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSubjects() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final subjects = await _repo.getSubjectsByBranchAndSemester(
          _selectedBranch, _selectedSemester);
      if (!mounted) return;
      setState(() {
        _subjects = subjects;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addSubject() async {
    final name = _subjectNameCtrl.text.trim();
    final credits = int.tryParse(_creditsCtrl.text.trim());
    if (name.isEmpty || credits == null || credits <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid subject name and credits')),
      );
      return;
    }

    final subject = Subject(
      id: const Uuid().v4(),
      branch: _selectedBranch,
      semester: _selectedSemester,
      subjectName: name,
      credits: credits,
    );

    await _repo.insertSubject(subject);
    _subjectNameCtrl.clear();
    _creditsCtrl.clear();
    await _loadSubjects();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subject added successfully')),
      );
    }
  }

  Future<void> _deleteSubject(String id) async {
    await _repo.deleteSubject(id);
    await _loadSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branch selector
          Text('Branch', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _branches.map((b) {
                final isSelected = b == _selectedBranch;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedBranch = b);
                      _loadSubjects();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.primaryGradient : null,
                        color: isSelected ? null : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                            color: AppColors.purpleDark.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        b,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Semester selector
          Text('Semester', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: List.generate(8, (i) {
              final sem = (i + 1).toString();
              final isSelected = sem == _selectedSemester;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedSemester = sem);
                  _loadSubjects();
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.primaryGradient : null,
                    color: isSelected ? null : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                        color: AppColors.purpleDark.withValues(alpha: 0.3)),
                  ),
                  child: Center(
                    child: Text(
                      'S$sem',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Add subject form
          GradientCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Subject — $_selectedBranch Sem $_selectedSemester',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.purpleDark,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                CustomTextField(
                  label: 'Subject Name',
                  hintText: 'e.g. Data Structures',
                  controller: _subjectNameCtrl,
                ),
                const SizedBox(height: AppSpacing.md),
                CustomTextField(
                  label: 'Credits',
                  hintText: 'e.g. 4',
                  controller: _creditsCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    label: 'Add Subject',
                    onPressed: _addSubject,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Subjects list
          Text(
            'Subjects (${_subjects.length})',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_subjects.isEmpty)
            Center(
              child: Text(
                'No subjects yet for $_selectedBranch Sem $_selectedSemester',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            ..._subjects.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: GradientCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.subjectName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600)),
                              Text('Credits: ${s.credits}',
                                  style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.errorColor),
                          onPressed: () => _deleteSubject(s.id),
                        ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}

// ── Tab 2: Timetable Image ──────────────────────────────────────────────────

class _TimetableTab extends StatefulWidget {
  const _TimetableTab();

  @override
  State<_TimetableTab> createState() => _TimetableTabState();
}

class _TimetableTabState extends State<_TimetableTab> {
  final TimeTableRepository _repo = TimeTableRepository();

  final List<String> _branches = [
    'CSE',
    'ISE',
    'ECE',
    'EEE',
    'ME',
    'CV',
    'BT',
    'CH'
  ];
  final List<String> _sections = ['A', 'B', 'C', 'D'];
  String _selectedBranch = 'CSE';
  String _selectedSection = 'A';
  TimetableImage? _currentImage;
  bool _isLoading = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final img =
          await _repo.getTimetableImage(_selectedBranch, _selectedSection);
      if (!mounted) return;
      setState(() {
        _currentImage = img;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadTimetable() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;

    setState(() => _isUploading = true);
    try {
      final base64Str = base64Encode(file.bytes!);
      final img = TimetableImage(
        id: const Uuid().v4(),
        branch: _selectedBranch,
        section: _selectedSection,
        imageBase64: base64Str,
        updatedAt: DateTime.now(),
      );
      await _repo.upsertTimetableImage(img);
      await _loadImage();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Timetable "${file.name}" uploaded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branch selector
          Text('Branch', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _branches.map((b) {
                final isSelected = b == _selectedBranch;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedBranch = b);
                      _loadImage();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.primaryGradient : null,
                        color: isSelected ? null : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                            color: AppColors.purpleDark.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        b,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Section selector
          Text('Section', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: _sections.map((sec) {
              final isSelected = sec == _selectedSection;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedSection = sec);
                    _loadImage();
                  },
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppColors.primaryGradient : null,
                      color: isSelected ? null : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                          color: AppColors.purpleDark.withValues(alpha: 0.3)),
                    ),
                    child: Center(
                      child: Text(
                        sec,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Upload form
          GradientCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set Timetable — $_selectedBranch Section $_selectedSection',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.purpleDark,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Pick an image or PDF of the timetable to upload',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: _isUploading
                      ? const Center(child: CircularProgressIndicator())
                      : GradientButton(
                          label: 'Pick & Upload Timetable',
                          onPressed: _pickAndUploadTimetable,
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Current timetable preview
          Text(
            'Current Timetable Preview',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_currentImage == null)
            Center(
              child: Text(
                'No timetable uploaded for $_selectedBranch Section $_selectedSection',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            )
          else
            GradientCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last updated: ${_currentImage!.updatedAt.toLocal().toString().split('.').first}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Image.memory(
                      base64Decode(_currentImage!.imageBase64),
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Tab 3: User Photos ───────────────────────────────────────────────────────

class _UserPhotosTab extends StatefulWidget {
  const _UserPhotosTab();

  @override
  State<_UserPhotosTab> createState() => _UserPhotosTabState();
}

class _UserPhotosTabState extends State<_UserPhotosTab> {
  final UserRepository _userRepo = UserRepository();

  String _filter = 'student'; // 'student' or 'faculty'
  List<User> _users = [];
  bool _isLoading = true;
  String? _uploadingUserId;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final type = _filter == 'student' ? UserType.student : UserType.faculty;
      final users = await _userRepo.getUsersByType(type);
      if (!mounted) return;
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadPhoto(User user) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;

    if (file.bytes!.length > 2 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image must be under 2 MB')),
        );
      }
      return;
    }

    setState(() => _uploadingUserId = user.id);
    try {
      final base64Photo = base64Encode(file.bytes!);
      await _userRepo.updateUserPhoto(user.id, base64Photo);
      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Photo updated for ${user.fullName}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploadingUserId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter toggle
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _filter = 'student');
                    _loadUsers();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: _filter == 'student'
                          ? AppColors.primaryGradient
                          : null,
                      color: _filter == 'student'
                          ? null
                          : AppColors.surfaceVariant,
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(AppRadius.md)),
                    ),
                    child: Center(
                      child: Text(
                        'Students',
                        style: TextStyle(
                          color: _filter == 'student'
                              ? Colors.white
                              : AppColors.textPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _filter = 'faculty');
                    _loadUsers();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: _filter == 'faculty'
                          ? AppColors.primaryGradient
                          : null,
                      color: _filter == 'faculty'
                          ? null
                          : AppColors.surfaceVariant,
                      borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(AppRadius.md)),
                    ),
                    child: Center(
                      child: Text(
                        'Faculty',
                        style: TextStyle(
                          color: _filter == 'faculty'
                              ? Colors.white
                              : AppColors.textPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // User list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _users.isEmpty
                  ? Center(
                      child: Text(
                        'No ${_filter}s found.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        final isUploading = _uploadingUserId == user.id;
                        final hasPhoto = user.userPhotoUrl != null &&
                            user.userPhotoUrl!.isNotEmpty;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: GradientCard(
                            child: Row(
                              children: [
                                // Avatar
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppColors.primaryGradient,
                                    border: Border.all(
                                        color: AppColors.purpleDark,
                                        width: 2.5),
                                  ),
                                  child: ClipOval(
                                    child: hasPhoto
                                        ? Image.memory(
                                            base64Decode(user.userPhotoUrl!),
                                            fit: BoxFit.cover,
                                            width: 60,
                                            height: 60,
                                          )
                                        : Icon(
                                            _filter == 'student'
                                                ? Icons.person
                                                : Icons.school,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                // Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.fullName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        '${user.branch} · ${user.section}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                // Upload button
                                isUploading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : IconButton(
                                        icon: Icon(
                                          hasPhoto
                                              ? Icons.edit_outlined
                                              : Icons.add_a_photo_outlined,
                                          color: AppColors.purpleDark,
                                        ),
                                        tooltip: hasPhoto
                                            ? 'Change photo'
                                            : 'Add photo',
                                        onPressed: () =>
                                            _pickAndUploadPhoto(user),
                                      ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
