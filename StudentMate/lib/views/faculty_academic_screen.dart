import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/attendance_model.dart';
import '../models/grade_model.dart';
import '../models/subject_model.dart';
import '../models/user_model.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/grade_repository.dart';
import '../repositories/subject_repository.dart';
import '../repositories/user_repository.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/responsive_layout_components.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_widgets.dart';

/// Faculty unified academics screen.
/// Step 1 - select branch+section.
/// Step 2 - select subject.
/// Step 3 - subject detail with "Marks" and "Attendance" tabs.
class FacultyAcademicScreen extends StatefulWidget {
  const FacultyAcademicScreen({Key? key}) : super(key: key);

  @override
  State<FacultyAcademicScreen> createState() => _FacultyAcademicScreenState();
}

enum _Step { section, subject, detail }

class _FacultyAcademicScreenState extends State<FacultyAcademicScreen>
    with SingleTickerProviderStateMixin {
  final UserRepository _userRepo = UserRepository();
  final SubjectRepository _subjectRepo = SubjectRepository();
  final GradeRepository _gradeRepo = GradeRepository();
  final AttendanceRepository _attendanceRepo = AttendanceRepository();

  bool _isLoading = true;
  _Step _step = _Step.section;

  List<User> _allStudents = [];
  List<String> _sectionKeys = [];
  String? _selectedSectionKey;
  String? _selectedBranch;
  String? _selectedSection;

  List<Subject> _subjects = [];
  Subject? _selectedSubject;

  List<User> _sectionStudents = [];

  Map<String, Grade?> _gradesMap = {};
  Map<String, Attendance?> _attendanceMap = {};

  bool _dataLoading = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final users = await _userRepo.getUsersByType(UserType.student);
      final keys = <String>{};
      for (final u in users) {
        if (u.branch.isNotEmpty && u.section.isNotEmpty) {
          keys.add('${u.branch}|${u.section}');
        }
      }
      if (!mounted) return;
      setState(() {
        _allStudents = users;
        _sectionKeys = keys.toList()..sort();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onSectionSelected(String key) async {
    final parts = key.split('|');
    final branch = parts[0];
    final section = parts[1];
    final students = _allStudents
        .where((u) => u.branch == branch && u.section == section)
        .toList();
    setState(() {
      _selectedSectionKey = key;
      _selectedBranch = branch;
      _selectedSection = section;
      _sectionStudents = students;
      _subjects = [];
      _selectedSubject = null;
      _step = _Step.subject;
    });
    try {
      final subs = await _subjectRepo.getSubjectsByBranch(branch);
      if (!mounted) return;
      setState(() => _subjects = subs);
    } catch (_) {}
  }

  Future<void> _onSubjectSelected(Subject subject) async {
    setState(() {
      _selectedSubject = subject;
      _dataLoading = true;
      _gradesMap = {};
      _attendanceMap = {};
      _step = _Step.detail;
    });

    try {
      final userIds = _sectionStudents.map((s) => s.id).toList();

      final results = await Future.wait([
        _gradeRepo.getGradesBySubjectAndUsers(
            subject.subjectName, subject.semester, userIds),
        _attendanceRepo.getAttendanceBySubjectAndSection(
            subject.subjectName, _selectedSection!),
      ]);

      final grades = results[0] as List<Grade>;
      final attendances = results[1] as List<Attendance>;

      final gMap = <String, Grade?>{};
      final aMap = <String, Attendance?>{};
      for (final s in _sectionStudents) {
        gMap[s.id] = null;
        aMap[s.id] = null;
      }
      for (final g in grades) {
        gMap[g.userId] = g;
      }
      for (final a in attendances) {
        aMap[a.userId] = a;
      }

      if (!mounted) return;
      setState(() {
        _gradesMap = gMap;
        _attendanceMap = aMap;
        _dataLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _dataLoading = false);
    }
  }

  int get _currentTotalClasses {
    if (_attendanceMap.isEmpty) return 0;
    return _attendanceMap.values
        .where((a) => a != null)
        .map((a) => a!.totalClasses)
        .fold<int>(0, (prev, e) => e > prev ? e : prev);
  }

  void _goBack() {
    setState(() {
      if (_step == _Step.detail) {
        _step = _Step.subject;
        _selectedSubject = null;
        _gradesMap = {};
        _attendanceMap = {};
        _tabController.index = 0;
      } else if (_step == _Step.subject) {
        _step = _Step.section;
        _selectedSectionKey = null;
        _selectedBranch = null;
        _selectedSection = null;
        _subjects = [];
        _sectionStudents = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_step != _Step.section) {
          _goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: _step == _Step.section
              ? const AppLogo()
              : BackButton(onPressed: _goBack),
          title: Text(_appBarTitle),
          centerTitle: true,
          bottom: _step == _Step.detail
              ? TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(icon: Icon(Icons.bar_chart), text: 'Marks'),
                    Tab(icon: Icon(Icons.fact_check), text: 'Attendance'),
                  ],
                )
              : null,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(),
      ),
    );
  }

  String get _appBarTitle {
    switch (_step) {
      case _Step.section:
        return 'Academics';
      case _Step.subject:
        final parts = _selectedSectionKey!.split('|');
        return '${parts[0]} - ${parts[1]}';
      case _Step.detail:
        return _selectedSubject!.subjectName;
    }
  }

  Widget _buildBody() {
    switch (_step) {
      case _Step.section:
        return _buildSectionStep();
      case _Step.subject:
        return _buildSubjectStep();
      case _Step.detail:
        return _dataLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildMarksTab(),
                  _buildAttendanceTab(),
                ],
              );
    }
  }

  Widget _buildSectionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: _card(
        title: 'Select Section',
        child: _sectionKeys.isEmpty
            ? const Text('No student sections found.',
                style: TextStyle(color: AppColors.textSecondaryColor))
            : Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _sectionKeys.map((key) {
                  final parts = key.split('|');
                  final isSelected = _selectedSectionKey == key;
                  return ChoiceChip(
                    label: Text('${parts[0]} - ${parts[1]}'),
                    selected: isSelected,
                    selectedColor: AppColors.purpleDark,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => _onSectionSelected(key),
                  );
                }).toList(),
              ),
      ),
    );
  }

  Widget _buildSubjectStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: _card(
        title: 'Select Subject',
        child: _subjects.isEmpty
            ? const Text('No subjects found for this branch.',
                style: TextStyle(color: AppColors.textSecondaryColor))
            : Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _subjects.map((sub) {
                  return ChoiceChip(
                    label: Text('${sub.subjectName} (Sem ${sub.semester})'),
                    selected: _selectedSubject?.id == sub.id,
                    selectedColor: AppColors.purpleDark,
                    labelStyle: TextStyle(
                      color: _selectedSubject?.id == sub.id
                          ? Colors.white
                          : AppColors.textPrimaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                    onSelected: (_) => _onSubjectSelected(sub),
                  );
                }).toList(),
              ),
      ),
    );
  }

  Widget _buildMarksTab() {
    if (_sectionStudents.isEmpty) {
      return const Center(child: Text('No students in this section.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: _sectionStudents.length,
      itemBuilder: (_, i) {
        final student = _sectionStudents[i];
        final grade = _gradesMap[student.id];
        return _buildStudentMarksCard(student, grade);
      },
    );
  }

  Widget _buildStudentMarksCard(User student, Grade? grade) {
    final hasGrade = grade != null &&
        (grade.internalComponents.isNotEmpty || grade.externalMarksRaw > 0);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [AppShadow.light],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.fullName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(student.email,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondaryColor)),
                  ],
                ),
              ),
              if (hasGrade)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    '${grade.totalMarks.toStringAsFixed(1)}/100',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Text('Not graded',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondaryColor)),
                ),
            ],
          ),
          if (hasGrade) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Internal: ${grade.internalTotal.toStringAsFixed(1)}/50  '
              'External: ${grade.externalTotal.toStringAsFixed(1)}/50',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondaryColor),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => _showUpdateMarksDialog(student, grade),
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Update Marks'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purpleDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                textStyle: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showUpdateMarksDialog(User student, Grade? existing) async {
    final List<Map<String, dynamic>> internalRows = [];

    if (existing != null && existing.internalComponents.isNotEmpty) {
      for (final c in existing.internalComponents) {
        internalRows.add({
          'label': TextEditingController(text: c.label),
          'marks': TextEditingController(text: c.marks.toStringAsFixed(1)),
          'maxMarks':
              TextEditingController(text: c.maxMarks.toStringAsFixed(0)),
          'includeInTotal': c.includeInTotal,
          'isAbsent': c.isAbsent,
        });
      }
    }

    final externalController = TextEditingController(
        text: existing != null
            ? existing.externalMarksRaw.toStringAsFixed(1)
            : '');

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setDlgState) {
          double internalTotal() => internalRows.fold(0.0, (sum, row) {
                return sum + (double.tryParse(row['marks']!.text) ?? 0.0);
              });

          double externalTotal() {
            final raw = double.tryParse(externalController.text) ?? 0.0;
            return raw / 2.0;
          }

          double grandTotal() => internalTotal() + externalTotal();

          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl)),
            title: Text('Marks - ${student.fullName}',
                style: const TextStyle(fontSize: 16)),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _dialogSection('Internal Marks (Total <= 50)'),
                    const SizedBox(height: AppSpacing.xs),
                    // Legend for checkboxes
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          const SizedBox(width: 32),
                          const SizedBox(width: AppSpacing.xs),
                          const SizedBox(width: 32),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Include',
                                  style: Theme.of(ctx2)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: AppColors.textSecondaryColor,
                                        fontSize: 11,
                                      ),
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  'Absent',
                                  style: Theme.of(ctx2)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: AppColors.textSecondaryColor,
                                        fontSize: 11,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (internalRows.isEmpty)
                      const Text(
                        'No components yet. Tap "+ Add Component" below.',
                        style: TextStyle(
                            color: AppColors.textSecondaryColor, fontSize: 12),
                      ),
                    ...internalRows.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final row = entry.value;
                      return _internalRow(
                          ctx2, setDlgState, row, idx, internalRows);
                    }),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton.icon(
                      onPressed: () {
                        setDlgState(() {
                          internalRows.add({
                            'label': TextEditingController(),
                            'marks': TextEditingController(),
                            'maxMarks': TextEditingController(),
                            'includeInTotal': true,
                            'isAbsent': false,
                          });
                        });
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Component'),
                    ),
                    const Divider(height: AppSpacing.xl),
                    _dialogSection('External Marks (out of 100 / 2 = /50)'),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: externalController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.black87),
                      onChanged: (_) => setDlgState(() {}),
                      decoration: InputDecoration(
                        labelText: 'External marks (0 - 100)',
                        border: const OutlineInputBorder(),
                        suffixText:
                            '/ 2 = ${externalTotal().toStringAsFixed(1)}/50',
                      ),
                    ),
                    const Divider(height: AppSpacing.xl),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.purpleDark.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.purpleDark)),
                          Text(
                            '${internalTotal().toStringAsFixed(1)}/50 + '
                            '${externalTotal().toStringAsFixed(1)}/50 = '
                            '${grandTotal().toStringAsFixed(1)}/100',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.purpleDark,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purpleDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md))),
                onPressed: () async {
                  double intTotal = internalRows.fold(0.0, (sum, row) {
                    return sum + (double.tryParse(row['marks']!.text) ?? 0.0);
                  });
                  if (intTotal > 50) {
                    ScaffoldMessenger.of(ctx2).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Internal marks total exceeds 50. Please adjust.'),
                        backgroundColor: AppColors.errorColor,
                      ),
                    );
                    return;
                  }
                  final extRaw =
                      double.tryParse(externalController.text) ?? 0.0;
                  if (extRaw < 0 || extRaw > 100) {
                    ScaffoldMessenger.of(ctx2).showSnackBar(
                      const SnackBar(
                        content:
                            Text('External marks must be between 0 and 100.'),
                        backgroundColor: AppColors.errorColor,
                      ),
                    );
                    return;
                  }

                  final components = internalRows.map((row) {
                    return InternalComponent(
                      label: row['label']!.text.trim().isEmpty
                          ? 'Component'
                          : row['label']!.text.trim(),
                      marks: double.tryParse(row['marks']!.text) ?? 0.0,
                      maxMarks: double.tryParse(row['maxMarks']!.text) ?? 0.0,
                      includeInTotal: row['includeInTotal'] as bool? ?? true,
                      isAbsent: row['isAbsent'] as bool? ?? false,
                    );
                  }).toList();

                  final grade = Grade(
                    id: existing?.id ?? const Uuid().v4(),
                    userId: student.id,
                    subject: _selectedSubject!.subjectName,
                    credits: _selectedSubject!.credits,
                    semester: _selectedSubject!.semester,
                    date: DateTime.now(),
                    internalComponents: components,
                    externalMarksRaw: extRaw,
                  );

                  Navigator.pop(ctx);
                  await _saveGrade(student, grade);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _dialogSection(String title) => Text(
        title,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.purpleDark,
            fontSize: 13),
      );

  Widget _internalRow(
    BuildContext ctx,
    StateSetter setDlgState,
    Map<String, dynamic> row,
    int idx,
    List<Map<String, dynamic>> allRows,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Checkbox(
              value: row['includeInTotal'] as bool? ?? true,
              onChanged: (value) {
                setDlgState(() {
                  row['includeInTotal'] = value ?? true;
                });
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          SizedBox(
            width: 32,
            child: Checkbox(
              value: row['isAbsent'] as bool? ?? false,
              onChanged: (value) {
                setDlgState(() {
                  row['isAbsent'] = value ?? false;
                });
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            flex: 3,
            child: TextField(
              controller: row['label'] as TextEditingController,
              style: const TextStyle(color: Colors.black87, fontSize: 13),
              decoration: const InputDecoration(
                labelText: 'Label',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            flex: 2,
            child: TextField(
              controller: row['marks'] as TextEditingController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.black87, fontSize: 13),
              onChanged: (_) => setDlgState(() {}),
              decoration: const InputDecoration(
                labelText: 'Marks',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            flex: 2,
            child: TextField(
              controller: row['maxMarks'] as TextEditingController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.black87, fontSize: 13),
              decoration: const InputDecoration(
                labelText: 'Max',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: AppColors.errorColor, size: 20),
            onPressed: () {
              setDlgState(() => allRows.removeAt(idx));
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveGrade(User student, Grade grade) async {
    setState(() => _dataLoading = true);
    try {
      await _gradeRepo.upsertGrade(grade);
      _gradesMap[student.id] = grade;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving grade: $e'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
    if (!mounted) return;
    setState(() => _dataLoading = false);
  }

  Widget _buildAttendanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildClassCounter(),
          const SizedBox(height: AppSpacing.lg),
          if (_sectionStudents.isEmpty)
            const Text('No students in this section.',
                style: TextStyle(color: AppColors.textSecondaryColor))
          else ...[
            Text(
              'Student Attendance',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.purpleDark,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ..._sectionStudents.map(_buildAttendanceRow),
          ],
        ],
      ),
    );
  }

  Widget _buildClassCounter() {
    final total = _currentTotalClasses;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Classes',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text('$total',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            children: [
              _counterButton(
                  icon: Icons.remove,
                  onTap: _showDecrementDialog,
                  tooltip: 'Remove last class'),
              const SizedBox(width: AppSpacing.md),
              _counterButton(
                  icon: Icons.add,
                  onTap: _showAddClassDialog,
                  tooltip: 'Add new class'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _counterButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  Future<void> _showAddClassDialog() async {
    final subjectName = _selectedSubject!.subjectName;
    final section = _selectedSection!;
    final branch = _selectedBranch!;
    final classNumber = _currentTotalClasses + 1;
    DateTime selectedDate = DateTime.now();
    final Map<String, bool> absentMap = {
      for (final s in _sectionStudents) s.id: false,
    };

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl)),
          title: Text('Class #$classNumber - Mark Absent'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 18, color: AppColors.purpleDark),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${selectedDate.year}-'
                      '${selectedDate.month.toString().padLeft(2, '0')}-'
                      '${selectedDate.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.purpleDark),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx2,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setDlgState(() => selectedDate = picked);
                        }
                      },
                      child: const Text('Change Date'),
                    ),
                  ],
                ),
                const Divider(),
                const Text('Mark students absent:',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.xs),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(ctx2).size.height * 0.4,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _sectionStudents.length,
                    itemBuilder: (_, i) {
                      final student = _sectionStudents[i];
                      return CheckboxListTile(
                        dense: true,
                        title: Text(student.fullName,
                            style: const TextStyle(fontSize: 14)),
                        subtitle: Text(student.email,
                            style: const TextStyle(fontSize: 12)),
                        value: absentMap[student.id] ?? false,
                        activeColor: AppColors.errorColor,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (val) => setDlgState(
                            () => absentMap[student.id] = val ?? false),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purpleDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md))),
              onPressed: () async {
                Navigator.pop(ctx);
                await _saveClass(
                    subjectName, section, branch, selectedDate, absentMap);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveClass(
    String subjectName,
    String section,
    String branch,
    DateTime date,
    Map<String, bool> absentMap,
  ) async {
    setState(() => _dataLoading = true);
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    try {
      for (final student in _sectionStudents) {
        final isAbsent = absentMap[student.id] ?? false;
        final existing = _attendanceMap[student.id];
        if (existing == null) {
          final rec = Attendance(
            id: const Uuid().v4(),
            userId: student.id,
            subject: subjectName,
            section: section,
            branch: branch,
            totalClasses: 1,
            presentClasses: isAbsent ? 0 : 1,
            absentDates: isAbsent ? [dateStr] : [],
            lastUpdated: DateTime.now(),
          );
          await _attendanceRepo.upsertAttendance(rec);
          _attendanceMap[student.id] = rec;
        } else {
          final updatedDates = List<String>.from(existing.absentDates);
          if (isAbsent && !updatedDates.contains(dateStr)) {
            updatedDates.add(dateStr);
          }
          final updated = Attendance(
            id: existing.id,
            userId: existing.userId,
            subject: existing.subject,
            section: existing.section,
            branch: existing.branch,
            totalClasses: existing.totalClasses + 1,
            presentClasses: existing.presentClasses + (isAbsent ? 0 : 1),
            absentDates: updatedDates,
            lastUpdated: DateTime.now(),
          );
          await _attendanceRepo.upsertAttendance(updated);
          _attendanceMap[student.id] = updated;
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving: $e'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
    if (!mounted) return;
    setState(() => _dataLoading = false);
  }

  Future<void> _showDecrementDialog() async {
    if (_currentTotalClasses == 0) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: const Text('Remove Last Class'),
        content: const Text(
            'This will decrement the total class count for all students in this section.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md))),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _dataLoading = true);
    try {
      for (final student in _sectionStudents) {
        final existing = _attendanceMap[student.id];
        if (existing == null || existing.totalClasses == 0) continue;
        final updated = Attendance(
          id: existing.id,
          userId: existing.userId,
          subject: existing.subject,
          section: existing.section,
          branch: existing.branch,
          totalClasses: existing.totalClasses - 1,
          presentClasses:
              (existing.presentClasses - 1).clamp(0, existing.totalClasses - 1),
          absentDates: existing.absentDates,
          lastUpdated: DateTime.now(),
        );
        await _attendanceRepo.upsertAttendance(updated);
        _attendanceMap[student.id] = updated;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
    if (!mounted) return;
    setState(() => _dataLoading = false);
  }

  Widget _buildAttendanceRow(User student) {
    final att = _attendanceMap[student.id];
    final total = att?.totalClasses ?? 0;
    final present = att?.presentClasses ?? 0;
    final pct = total == 0 ? 100.0 : present / total * 100;
    final isLow = total > 0 && pct < 75;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isLow
            ? AppColors.errorColor.withValues(alpha: 0.06)
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: isLow
            ? Border.all(color: AppColors.errorColor.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(student.email,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondaryColor)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$present/$total',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        isLow ? AppColors.errorColor : AppColors.successColor),
              ),
              Text(
                '${pct.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: isLow
                      ? AppColors.errorColor
                      : AppColors.textSecondaryColor,
                  fontWeight: isLow ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          if (isLow) ...[
            const SizedBox(width: AppSpacing.sm),
            const Icon(Icons.warning_amber_rounded,
                color: AppColors.errorColor, size: 18),
          ],
        ],
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [AppShadow.light],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.purpleDark,
                  )),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}
