import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/attendance_model.dart';
import '../models/subject_model.dart';
import '../models/user_model.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/subject_repository.dart';
import '../repositories/user_repository.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_widgets.dart';

class FacultyAttendanceScreen extends StatefulWidget {
  const FacultyAttendanceScreen({Key? key}) : super(key: key);

  @override
  State<FacultyAttendanceScreen> createState() =>
      _FacultyAttendanceScreenState();
}

class _FacultyAttendanceScreenState extends State<FacultyAttendanceScreen> {
  final UserRepository _userRepo = UserRepository();
  final SubjectRepository _subjectRepo = SubjectRepository();
  final AttendanceRepository _attendanceRepo = AttendanceRepository();

  bool _isLoading = true;

  // Step 1 — section selection
  List<User> _allStudents = [];
  List<String> _sectionKeys = []; // "Branch|Section" display keys
  String? _selectedSectionKey;
  String? _selectedBranch;
  String? _selectedSection;

  // Step 2 — subject selection
  List<Subject> _subjects = [];
  Subject? _selectedSubject;

  // Step 3 — attendance data
  List<User> _sectionStudents = [];

  /// userId → Attendance record (may be null if no record yet)
  Map<String, Attendance?> _attendanceMap = {};
  bool _attendanceLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
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
    setState(() {
      _selectedSectionKey = key;
      _selectedBranch = branch;
      _selectedSection = section;
      _selectedSubject = null;
      _subjects = [];
      _sectionStudents = _allStudents
          .where((u) => u.branch == branch && u.section == section)
          .toList();
      _attendanceMap = {};
    });
    try {
      final subjects = await _subjectRepo.getSubjectsByBranch(branch);
      if (!mounted) return;
      setState(() => _subjects = subjects);
    } catch (_) {}
  }

  Future<void> _onSubjectSelected(Subject subject) async {
    setState(() {
      _selectedSubject = subject;
      _attendanceLoading = true;
      _attendanceMap = {};
    });
    try {
      final records = await _attendanceRepo.getAttendanceBySubjectAndSection(
          subject.subjectName, _selectedSection!);
      final map = <String, Attendance?>{};
      for (final s in _sectionStudents) {
        map[s.id] = null;
      }
      for (final r in records) {
        map[r.userId] = r;
      }
      if (!mounted) return;
      setState(() {
        _attendanceMap = map;
        _attendanceLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _attendanceLoading = false);
    }
  }

  int get _currentTotalClasses {
    if (_attendanceMap.isEmpty) return 0;
    return _attendanceMap.values
        .where((a) => a != null)
        .map((a) => a!.totalClasses)
        .fold<int>(0, (prev, e) => e > prev ? e : prev);
  }

  Future<void> _showAddClassDialog() async {
    final subjectName = _selectedSubject!.subjectName;
    final section = _selectedSection!;
    final branch = _selectedBranch!;
    final classNumber = _currentTotalClasses + 1;

    DateTime selectedDate = DateTime.now();
    // userId → isAbsent
    final Map<String, bool> absentMap = {
      for (final s in _sectionStudents) s.id: false,
    };

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.xl)),
              title: Text('Class #$classNumber — Mark Absent'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date picker row
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 18, color: AppColors.purpleDark),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Date: ${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
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
                              setDialogState(() => selectedDate = picked);
                            }
                          },
                          child: const Text('Change'),
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
                            onChanged: (val) {
                              setDialogState(
                                  () => absentMap[student.id] = val ?? false);
                            },
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
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purpleDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _saveClass(
                        subjectName, section, branch, selectedDate, absentMap);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveClass(
    String subjectName,
    String section,
    String branch,
    DateTime date,
    Map<String, bool> absentMap,
  ) async {
    setState(() => _attendanceLoading = true);
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    try {
      for (final student in _sectionStudents) {
        final isAbsent = absentMap[student.id] ?? false;
        final existing = _attendanceMap[student.id];
        if (existing == null) {
          // Create new record
          final newRecord = Attendance(
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
          await _attendanceRepo.upsertAttendance(newRecord);
          _attendanceMap[student.id] = newRecord;
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
    setState(() => _attendanceLoading = false);
  }

  Future<void> _showDecrementDialog() async {
    final total = _currentTotalClasses;
    if (total == 0) return;

    // Find all students that have an absent date for the last class — we can't
    // know the exact date: instead just decrement totals and remove as needed.
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: const Text('Remove Last Class'),
        content: const Text(
            'This will decrement the total class count for all students in this section. If any student was absent in the last class, their absent date will not be automatically removed.'),
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
    if (confirm != true) return;
    setState(() => _attendanceLoading = true);
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
    setState(() => _attendanceLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppLogo(),
        title: const Text('Attendance Tracker'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionSelector(),
                  if (_selectedSectionKey != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _buildSubjectSelector(),
                  ],
                  if (_selectedSubject != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _buildAttendancePanel(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSectionCard(String label, Widget child) {
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
          Text(label,
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

  Widget _buildSectionSelector() {
    return _buildSectionCard(
      'Step 1 — Select Section',
      _sectionKeys.isEmpty
          ? const Text('No student sections found.',
              style: TextStyle(color: AppColors.textSecondaryColor))
          : Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _sectionKeys.map((key) {
                final parts = key.split('|');
                final isSelected = _selectedSectionKey == key;
                return ChoiceChip(
                  label: Text('${parts[0]} – ${parts[1]}'),
                  selected: isSelected,
                  selectedColor: AppColors.purpleDark,
                  labelStyle: TextStyle(
                    color:
                        isSelected ? Colors.white : AppColors.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => _onSectionSelected(key),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildSubjectSelector() {
    return _buildSectionCard(
      'Step 2 — Select Subject',
      _subjects.isEmpty
          ? const Text('No subjects found for this branch.',
              style: TextStyle(color: AppColors.textSecondaryColor))
          : Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _subjects.map((sub) {
                final isSelected = _selectedSubject?.id == sub.id;
                return ChoiceChip(
                  label: Text('${sub.subjectName} (Sem ${sub.semester})'),
                  selected: isSelected,
                  selectedColor: AppColors.purpleDark,
                  labelStyle: TextStyle(
                    color:
                        isSelected ? Colors.white : AppColors.textPrimaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  onSelected: (_) => _onSubjectSelected(sub),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildAttendancePanel() {
    return _buildSectionCard(
      'Attendance — ${_selectedSubject!.subjectName}',
      _attendanceLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: CircularProgressIndicator(),
              ),
            )
          : Column(
              children: [
                // Class counter
                _buildClassCounter(),
                const SizedBox(height: AppSpacing.lg),
                // Student list
                if (_sectionStudents.isEmpty)
                  const Text('No students in this section.',
                      style: TextStyle(color: AppColors.textSecondaryColor))
                else
                  ..._sectionStudents.map(_buildStudentAttendanceRow),
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
              Text(
                '$total',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            children: [
              _counterButton(
                icon: Icons.remove,
                onTap: _showDecrementDialog,
                tooltip: 'Remove last class',
              ),
              const SizedBox(width: AppSpacing.md),
              _counterButton(
                icon: Icons.add,
                onTap: _showAddClassDialog,
                tooltip: 'Add new class',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _counterButton(
      {required IconData icon,
      required VoidCallback onTap,
      required String tooltip}) {
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

  Widget _buildStudentAttendanceRow(User student) {
    final att = _attendanceMap[student.id];
    final total = att?.totalClasses ?? 0;
    final present = att?.presentClasses ?? 0;
    final pct = total == 0 ? 100.0 : (present / total * 100);
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
                  color: isLow ? AppColors.errorColor : AppColors.successColor,
                ),
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
}
