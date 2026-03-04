import 'dart:convert';
import 'package:flutter/material.dart';
import '../repositories/timetable_repository.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_widgets.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({Key? key}) : super(key: key);

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  final TimeTableRepository _repo = TimeTableRepository();
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  String? _branch;
  String? _section;
  String? _imageBase64;

  @override
  void initState() {
    super.initState();
    _loadTimetable();
  }

  Future<void> _loadTimetable() async {
    final user = _authService.getCurrentUser();
    if (user == null) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      return;
    }

    _branch = user.branch;
    _section = user.section;

    try {
      final img = await _repo.getTimetableImage(user.branch, user.section);
      if (!mounted) return;
      setState(() {
        _imageBase64 = img?.imageBase64;
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
        title: const Text('Timetable'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadTimetable();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GradientCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: const Icon(Icons.table_chart,
                              color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Branch: ${_branch ?? '-'}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Section: ${_section ?? '-'}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (_imageBase64 == null)
                    Center(
                      child: Column(
                        children: [
                          const Icon(Icons.calendar_view_week_outlined,
                              size: 64, color: AppColors.purpleDark),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'No timetable uploaded yet for your section.',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Please ask your admin to upload the timetable\nfor $_branch – Section $_section.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondaryColor),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    InteractiveViewer(
                      panEnabled: true,
                      minScale: 0.5,
                      maxScale: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Image.memory(
                          base64Decode(_imageBase64!),
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
