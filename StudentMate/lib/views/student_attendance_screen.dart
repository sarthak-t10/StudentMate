import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../repositories/attendance_repository.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_widgets.dart';

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({Key? key}) : super(key: key);

  @override
  State<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  final AuthService _authService = AuthService();
  final AttendanceRepository _attendanceRepo = AttendanceRepository();

  bool _isLoading = true;
  List<Attendance> _records = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = _authService.getCurrentUser();
    if (user == null) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      return;
    }
    try {
      final records = await _attendanceRepo.getAttendanceByUser(user.id);
      if (!mounted) return;
      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<Attendance> get _lowAttendanceRecords =>
      _records.where((r) => r.isLowAttendance).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppLogo(),
        title: const Text('My Attendance'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _load();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      if (_lowAttendanceRecords.isNotEmpty)
                        _buildWarningBanner(),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Subject-wise Attendance',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.purpleDark,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ..._records.map(_buildSubjectCard),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available,
                size: 72, color: AppColors.purpleDark.withValues(alpha: 0.3)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No attendance records yet.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Your faculty will update attendance after each class.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningBanner() {
    final subjects = _lowAttendanceRecords.map((r) => r.subject).join(', ');
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.errorColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.errorColor, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                    color: AppColors.textPrimaryColor, fontSize: 13),
                children: [
                  const TextSpan(
                    text: 'Low attendance warning! ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.errorColor),
                  ),
                  TextSpan(
                    text: 'Your attendance has fallen below 75% in: $subjects. '
                        'Please attend classes regularly to avoid detainment.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(Attendance record) {
    final pct = record.percentage;
    final isLow = record.isLowAttendance;
    final Color statusColor =
        isLow ? AppColors.errorColor : AppColors.successColor;
    final absentSorted = List<String>.from(record.absentDates)..sort();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [AppShadow.light],
        border: isLow
            ? Border.all(
                color: AppColors.errorColor.withValues(alpha: 0.35), width: 1.5)
            : null,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          childrenPadding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withValues(alpha: 0.12),
            ),
            child: Center(
              child: Icon(
                isLow ? Icons.warning_amber_rounded : Icons.check_circle,
                color: statusColor,
                size: 26,
              ),
            ),
          ),
          title: Text(
            record.subject,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Percentage row
                Row(
                  children: [
                    Text(
                      '${pct.toStringAsFixed(1)}%',
                      style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '(${record.presentClasses}/${record.totalClasses} classes)',
                      style: const TextStyle(
                          color: AppColors.textSecondaryColor, fontSize: 12),
                    ),
                    if (isLow) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.errorColor,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Text('LOW',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    minHeight: 6,
                    backgroundColor:
                        AppColors.textHintColor.withValues(alpha: 0.4),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
              ],
            ),
          ),
          children: [
            const Divider(),
            if (absentSorted.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.sm),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: AppColors.successColor, size: 16),
                    SizedBox(width: AppSpacing.xs),
                    Text('No absences recorded.',
                        style: TextStyle(color: AppColors.textSecondaryColor)),
                  ],
                ),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Row(
                  children: [
                    const Icon(Icons.event_busy,
                        color: AppColors.errorColor, size: 16),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Absent on ${absentSorted.length} date(s):',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.errorColor,
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: absentSorted.map((dateStr) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.errorColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                          color: AppColors.errorColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      dateStr,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.errorColor,
                          fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            // Requirement to not be detained
            if (record.totalClasses > 0) _buildRequirementTile(record),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementTile(Attendance record) {
    final needed = _classesNeededFor75(record);
    if (record.percentage >= 75) {
      // How many classes can be missed and stay above 75%
      final canMiss = _canMissClasses(record);
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
                    ? 'You can miss $canMiss more class${canMiss == 1 ? '' : 'es'} and still maintain 75%.'
                    : 'You must attend all upcoming classes to maintain 75%.',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondaryColor),
              ),
            ),
          ],
        ),
      );
    } else {
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
                'You need to attend $needed consecutive class${needed == 1 ? '' : 'es'} to reach 75%.',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondaryColor),
              ),
            ),
          ],
        ),
      );
    }
  }

  /// How many consecutive classes must be attended to reach 75%.
  int _classesNeededFor75(Attendance record) {
    int present = record.presentClasses;
    int total = record.totalClasses;
    int n = 0;
    while (total == 0 || (present / total * 100) < 75) {
      present++;
      total++;
      n++;
      if (n > 1000) break; // safety
    }
    return n;
  }

  /// How many classes can be missed while staying at or above 75%.
  int _canMissClasses(Attendance record) {
    int canMiss = 0;
    int present = record.presentClasses;
    int total = record.totalClasses;
    while (true) {
      total++;
      final newPct = present / total * 100;
      if (newPct < 75) break;
      canMiss++;
      if (canMiss > 1000) break;
    }
    return canMiss;
  }
}
