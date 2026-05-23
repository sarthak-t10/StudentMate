import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../models/grade_model.dart';
import '../models/subject_model.dart';
import '../utils/app_theme.dart';
import '../widgets/animated_gradient_background.dart';

/// Student's per-subject detail screen with "Marks" and "Attendance" tabs.
class StudentSubjectDetailScreen extends StatelessWidget {
  final Subject subject;
  final Grade? grade;
  final Attendance? attendance;

  const StudentSubjectDetailScreen({
    Key? key,
    required this.subject,
    required this.grade,
    required this.attendance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          leading: const BackButton(),
          title: Text(
            subject.subjectName,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.black26,
          elevation: 0,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.amber[700],
            tabs: [
              Tab(icon: Icon(Icons.bar_chart), text: 'Marks'),
              Tab(icon: Icon(Icons.fact_check), text: 'Attendance'),
            ],
          ),
        ),
        body: AnimatedGradientBackground(
          child: SafeArea(
            child: TabBarView(
              children: [
                _MarksTab(grade: grade, subject: subject),
                _AttendanceTab(attendance: attendance, subject: subject),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _MarksTab extends StatelessWidget {
  final Grade? grade;
  final Subject subject;

  const _MarksTab({required this.grade, required this.subject});

  @override
  Widget build(BuildContext context) {
    if (grade == null ||
        (grade!.internalComponents.isEmpty && grade!.externalMarksRaw == 0)) {
      return _buildUngraded(context);
    }
    return _buildGradeDetail(context, grade!);
  }

  Widget _buildUngraded(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_empty,
              size: 72, color: AppColors.purpleDark.withValues(alpha: 0.3)),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Not graded yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your faculty will update marks after assessments.',
            style: TextStyle(
              color: Colors.amber[700],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGradeDetail(BuildContext context, Grade g) {
    final gradeLetter = _getGradeLetter(g.totalMarks.toInt());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Marks',
                        style: TextStyle(color: Colors.black, fontSize: 12)),
                    Text(
                      '${g.totalMarks.toStringAsFixed(1)} / 100',
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    ),
                    Text('Credits: ${subject.credits}',
                        style: const TextStyle(color: Colors.black, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      gradeLetter,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Grade Point
          _infoRow(context, 'Grade Point',
              '${g.gradePoint.toStringAsFixed(1)} / 10'),
          const SizedBox(height: AppSpacing.lg),
          // Internal marks section
          _sectionTitle(context, 'Internal Marks (out of 50)'),
          const SizedBox(height: AppSpacing.sm),
          if (g.internalComponents.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text('No internal components added.',
                  style: TextStyle(color: AppColors.textSecondaryColor)),
            )
          else ...[
            ...g.internalComponents.map((c) => _componentRow(context, c)),
            const Divider(),
            _totalRow(context, 'Internal Total', g.internalTotal, 50),
          ],
          const SizedBox(height: AppSpacing.lg),
          // External marks section
          _sectionTitle(context, 'External Marks (out of 100 ÷ 2 = /50)'),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('External Exam',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500)),
                Text(
                  '${g.externalMarksRaw.toStringAsFixed(1)}/100'
                  '  →  ${g.externalTotal.toStringAsFixed(1)}/50',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.purpleDark,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Grand total
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber.shade300,
                  Colors.amber.shade600,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: Colors.amber.shade700, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Grand Total',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        )),
                Text(
                  '${g.internalTotal.toStringAsFixed(1)}/50 + '
                  '${g.externalTotal.toStringAsFixed(1)}/50 = '
                  '${g.totalMarks.toStringAsFixed(1)}/100',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) => Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
    fontWeight: FontWeight.bold, color: Colors.black),
      );

  Widget _infoRow(BuildContext context, String label, String value) =>
      Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.95),
              Colors.blue.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                  ?.copyWith(color: Colors.black)),
            Text(value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
      );

  Widget _componentRow(BuildContext context, InternalComponent c) => Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.98),
              Colors.purple.withValues(alpha: 0.06),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.28)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                c.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Text(
              '${c.marks.toStringAsFixed(1)} / ${c.maxMarks.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      );

  Widget _totalRow(
          BuildContext context, String label, double val, double max) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.amber.shade200,
              Colors.amber.shade500,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: Colors.amber.shade700, width: 1.5),
        ),
        child: Text(
          '$label: ${val.toStringAsFixed(1)} / ${max.toStringAsFixed(0)}',
          textAlign: TextAlign.right,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                  color: Colors.black,
              ),
        ),
      );

  String _getGradeLetter(int marks) {
    if (marks >= 90) return 'O';
    if (marks >= 80) return 'A+';
    if (marks >= 70) return 'A';
    if (marks >= 60) return 'B+';
    if (marks >= 50) return 'B';
    if (marks >= 40) return 'C';
    return 'F';
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _AttendanceTab extends StatelessWidget {
  final Attendance? attendance;
  final Subject subject;

  const _AttendanceTab({required this.attendance, required this.subject});

  @override
  Widget build(BuildContext context) {
    final att = attendance;
    if (att == null || att.totalClasses == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available,
                size: 72, color: AppColors.purpleDark.withValues(alpha: 0.3)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No attendance recorded yet.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your faculty will update attendance after each class.',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final pct = att.percentage;
    final isLow = att.isLowAttendance;
    final absentSorted = List<String>.from(att.absentDates)..sort();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warning banner
          if (isLow) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                    color: AppColors.errorColor.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.black),
                  SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Text(
                      'Attendance below 75%! Attend classes regularly to avoid detainment.',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Stats card
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: isLow
                  ? LinearGradient(
                      colors: [
                        AppColors.errorColor.withValues(alpha: 0.8),
                        AppColors.errorColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Attendance',
                            style:
                                TextStyle(color: Colors.black, fontSize: 12)),
                        Text(
                          '${pct.toStringAsFixed(1)}%',
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 40,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${att.presentClasses} / ${att.totalClasses} classes',
                          style: const TextStyle(color: Colors.black, fontSize: 13),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Icon(
                      isLow ? Icons.warning_amber_rounded : Icons.check_circle,
                      color: Colors.black,
                      size: 48,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Requirement notice
          _buildRequirementTile(context, att),
          const SizedBox(height: AppSpacing.lg),
          // Absent dates
          Text('Absent Dates',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
          const SizedBox(height: AppSpacing.sm),
          if (absentSorted.isEmpty)
            const Row(
              children: [
                Icon(Icons.check_circle_outline,
                    color: AppColors.successColor, size: 16),
                SizedBox(width: AppSpacing.xs),
                Text('No absences recorded in this subject.',
                  style: TextStyle(color: Colors.black)),
              ],
            )
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: absentSorted
                  .map(
                    (d) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.errorColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                            color: AppColors.errorColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(d,
                          style: const TextStyle(
                              fontSize: 12,
                            color: Colors.black,
                              fontWeight: FontWeight.w500)),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildRequirementTile(BuildContext context, Attendance att) {
    if (att.percentage >= 75) {
      final canMiss = _canMissClasses(att);
      return Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.successColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline,
                size: 16, color: AppColors.successColor),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                canMiss > 0
                    ? 'You can miss $canMiss more class${canMiss == 1 ? '' : 'es'} while staying above 75%.'
                    : 'Attend all upcoming classes to maintain 75%.',
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
            ),
          ],
        ),
      );
    } else {
      final needed = _classesNeededFor75(att);
      return Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.errorColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline,
                size: 16, color: AppColors.errorColor),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                'Attend $needed consecutive class${needed == 1 ? '' : 'es'} to reach 75%.',
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
            ),
          ],
        ),
      );
    }
  }

  int _classesNeededFor75(Attendance att) {
    int present = att.presentClasses;
    int total = att.totalClasses;
    int n = 0;
    while (total == 0 || (present / total * 100) < 75) {
      present++;
      total++;
      n++;
      if (n > 1000) break;
    }
    return n;
  }

  int _canMissClasses(Attendance att) {
    int canMiss = 0;
    int present = att.presentClasses;
    int total = att.totalClasses;
    while (true) {
      total++;
      if (present / total * 100 < 75) break;
      canMiss++;
      if (canMiss > 1000) break;
    }
    return canMiss;
  }
}
