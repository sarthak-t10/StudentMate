import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../models/grade_model.dart';
import '../models/subject_model.dart';
import '../services/auth_service.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/grade_repository.dart';
import '../repositories/subject_repository.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/responsive_layout_components.dart';
import 'student_subject_detail_screen.dart';
import 'timetable_screen.dart';

class AcademicsScreen extends StatefulWidget {
  const AcademicsScreen({Key? key}) : super(key: key);

  @override
  State<AcademicsScreen> createState() => _AcademicsScreenState();
}

class _AcademicsScreenState extends State<AcademicsScreen> {
  final AuthService _authService = AuthService();
  final GradeRepository _gradeRepo = GradeRepository();
  final SubjectRepository _subjectRepo = SubjectRepository();
  final AttendanceRepository _attendanceRepo = AttendanceRepository();

  int _selectedSemester = 1;
  List<Subject> _catalogSubjects = [];
  List<Grade> _grades = [];
  List<Attendance> _attendanceRecords = [];
  bool _isLoading = true;
  String? _userBranch;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final user = _authService.getCurrentUser();
    if (user == null) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      return;
    }
    _userBranch = user.branch;

    final results = await Future.wait([
      _gradeRepo.getGradesByUser(user.id),
      _attendanceRepo.getAttendanceByUser(user.id),
    ]);

    if (!mounted) return;
    setState(() {
      _grades = results[0] as List<Grade>;
      _attendanceRecords = results[1] as List<Attendance>;
    });

    await _loadSubjectsForSemester(_selectedSemester);
  }

  Future<void> _loadSubjectsForSemester(int semester) async {
    if (_userBranch == null) return;
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final subjects = await _subjectRepo.getSubjectsByBranchAndSemester(
          _userBranch!, semester.toString());
      if (!mounted) return;
      setState(() {
        _catalogSubjects = subjects;
        _selectedSemester = semester;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Grade? _gradeFor(String subjectName) {
    try {
      return _grades.firstWhere(
        (g) =>
            g.subject == subjectName &&
            g.semester == _selectedSemester.toString(),
      );
    } catch (_) {
      return null;
    }
  }

  Attendance? _attendanceFor(String subjectName) {
    try {
      return _attendanceRecords.firstWhere((a) => a.subject == subjectName);
    } catch (_) {
      return null;
    }
  }

  double _calculateCGPA() {
    double totalGradePoints = 0;
    int totalCredits = 0;
    for (final g in _grades) {
      totalGradePoints += g.gradePoint * g.credits;
      totalCredits += g.credits;
    }
    return totalCredits > 0 ? totalGradePoints / totalCredits : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppLogo(),
        title: const Text('Academics'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ResponsiveBuilder(
                builder: (context, responsive) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(responsive.horizontalPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Semester',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: responsive.titleFontSize,
                                ),
                          ),
                          SizedBox(height: responsive.spacingMedium),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(8, (index) {
                                final semester = index + 1;
                                final isSelected =
                                    _selectedSemester == semester;
                                return Padding(
                                  padding: EdgeInsets.only(
                                      right: responsive.spacingMedium),
                                  child: GestureDetector(
                                    onTap: () =>
                                        _loadSubjectsForSemester(semester),
                                    child: Container(
                                      width:
                                          responsive.isMediumScreen ? 65 : 60,
                                      height:
                                          responsive.isMediumScreen ? 65 : 60,
                                      decoration: BoxDecoration(
                                        gradient: isSelected
                                            ? AppColors.primaryGradient
                                            : const LinearGradient(
                                                colors: [
                                                  Colors.white,
                                                  Colors.white
                                                ],
                                              ),
                                        borderRadius: BorderRadius.circular(
                                            responsive.radiusMedium),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.transparent
                                              : AppColors.purpleDark
                                                  .withValues(alpha: 0.2),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'S$semester',
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : AppColors.purpleDark,
                                            fontWeight: FontWeight.w600,
                                            fontSize: responsive.isMediumScreen
                                                ? 15
                                                : 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          SizedBox(height: responsive.spacingLarge),
                          // Low attendance warning across all subjects
                          if (_attendanceRecords
                              .any((a) => a.isLowAttendance)) ...[
                            _buildLowAttendanceBanner(responsive),
                            SizedBox(height: responsive.spacingMedium),
                          ],
                          Text(
                            'Subjects — Semester $_selectedSemester',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: responsive.titleFontSize,
                                ),
                          ),
                          SizedBox(height: responsive.spacingMedium),
                          if (_catalogSubjects.isEmpty)
                            Center(
                              child: Text(
                                'No subjects available for Semester $_selectedSemester.\nAsk your admin to add subjects.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            )
                          else
                            ..._catalogSubjects.map((subject) {
                              final grade = _gradeFor(subject.subjectName);
                              final att = _attendanceFor(subject.subjectName);
                              return Padding(
                                padding: EdgeInsets.only(
                                    bottom: responsive.spacingMedium),
                                child: _buildSubjectCard(
                                    context, subject, grade, att, responsive),
                              );
                            }),
                          SizedBox(height: responsive.spacingLarge),
                          Text(
                            'CGPA Calculator',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: responsive.titleFontSize,
                                ),
                          ),
                          SizedBox(height: responsive.spacingMedium),
                          GradientCard(
                            child: Column(
                              children: [
                                Container(
                                  width: responsive.isMediumScreen ? 140 : 120,
                                  height: responsive.isMediumScreen ? 140 : 120,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(
                                        responsive.avatarSize),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'CGPA',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontSize:
                                                    responsive.bodyFontSize,
                                              ),
                                        ),
                                        SizedBox(
                                            height: responsive.spacingSmall),
                                        Text(
                                          _calculateCGPA().toStringAsFixed(2),
                                          style: TextStyle(
                                            fontSize: responsive.isMediumScreen
                                                ? 40
                                                : 36,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          '/ 10',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Colors.white70,
                                                fontSize:
                                                    responsive.smallFontSize,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: responsive.spacingLarge),
                                Text(
                                  'Calculated on a 10-point scale based on all graded subjects.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontSize: responsive.smallFontSize,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: responsive.spacingLarge),
                          Text(
                            'Timetable',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: responsive.titleFontSize,
                                ),
                          ),
                          SizedBox(height: responsive.spacingMedium),
                          GradientCard(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const TimetableScreen()),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding:
                                      EdgeInsets.all(responsive.spacingMedium),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(
                                        responsive.radiusMedium),
                                  ),
                                  child: Icon(Icons.table_chart,
                                      color: Colors.white,
                                      size:
                                          responsive.isMediumScreen ? 30 : 28),
                                ),
                                SizedBox(width: responsive.spacingMedium),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'View My Timetable',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize: responsive.bodyFontSize,
                                            ),
                                      ),
                                      Text(
                                        'See your class schedule for this section',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              fontSize:
                                                  responsive.smallFontSize,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios,
                                    size: 16, color: AppColors.purpleDark),
                              ],
                            ),
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

  Widget _buildLowAttendanceBanner(ResponsiveHelper responsive) {
    final lowSubjects = _attendanceRecords
        .where((a) => a.isLowAttendance)
        .map((a) => a.subject)
        .join(', ');
    return Container(
      padding: EdgeInsets.all(responsive.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(responsive.radiusLarge),
        border: Border.all(color: AppColors.errorColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.errorColor, size: 20),
          SizedBox(width: responsive.spacingSmall),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                    color: AppColors.textPrimaryColor,
                    fontSize: responsive.smallFontSize),
                children: [
                  const TextSpan(
                    text: 'Low attendance! ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.errorColor),
                  ),
                  TextSpan(text: lowSubjects),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, Subject subject, Grade? grade,
      Attendance? att, ResponsiveHelper responsive) {
    final hasGrade = grade != null &&
        (grade.internalComponents.isNotEmpty || grade.externalMarksRaw > 0);
    final attPct = att != null && att.totalClasses > 0 ? att.percentage : null;
    final attLow = att?.isLowAttendance ?? false;

    return GradientCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StudentSubjectDetailScreen(
            subject: subject,
            grade: grade,
            attendance: att,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  subject.subjectName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: responsive.bodyFontSize,
                      ),
                ),
              ),
              if (attLow)
                Padding(
                  padding: EdgeInsets.only(right: responsive.spacingSmall),
                  child: const Icon(Icons.warning_amber_rounded,
                      size: 18, color: AppColors.errorColor),
                ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.spacingMedium,
                  vertical: responsive.spacingSmall,
                ),
                decoration: BoxDecoration(
                  gradient: hasGrade ? AppColors.primaryGradient : null,
                  color: hasGrade ? null : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(responsive.radiusMedium),
                ),
                child: Text(
                  hasGrade
                      ? '${grade.totalMarks.toStringAsFixed(0)}/100'
                      : 'N/A',
                  style: TextStyle(
                    color:
                        hasGrade ? Colors.white : AppColors.textSecondaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: responsive.smallFontSize,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacingSmall),
          Wrap(
            spacing: responsive.spacingSmall,
            runSpacing: responsive.spacingSmall / 2,
            alignment: WrapAlignment.spaceBetween,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 140),
                child: Text(
                  'Credits: ${subject.credits}  ·  Sem ${subject.semester}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: responsive.smallFontSize,
                      ),
                ),
              ),
              if (attPct != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle,
                        size: 8,
                        color: attLow
                            ? AppColors.errorColor
                            : AppColors.successColor),
                    SizedBox(width: responsive.spacingSmall / 2),
                    Text(
                      'Att: ${attPct.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: responsive.smallFontSize,
                        fontWeight: FontWeight.w600,
                        color: attLow
                            ? AppColors.errorColor
                            : AppColors.successColor,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  'Att: —',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: responsive.smallFontSize,
                      ),
                ),
            ],
          ),
          SizedBox(height: responsive.spacingSmall / 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Tap to view marks & attendance',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.purpleDark.withValues(alpha: 0.7),
                      fontSize: responsive.smallFontSize - 1,
                    ),
              ),
              SizedBox(width: responsive.spacingSmall / 2),
              const Icon(Icons.arrow_forward_ios,
                  size: 11, color: AppColors.purpleDark),
            ],
          ),
        ],
      ),
    );
  }
}
