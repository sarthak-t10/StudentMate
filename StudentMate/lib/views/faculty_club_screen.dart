import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../repositories/event_repository.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/responsive_layout_components.dart';

class FacultyClubScreen extends StatefulWidget {
  const FacultyClubScreen({Key? key}) : super(key: key);

  @override
  State<FacultyClubScreen> createState() => _FacultyClubScreenState();
}

class _FacultyClubScreenState extends State<FacultyClubScreen> {
  final EventRepository _eventRepository = EventRepository();
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  List<ClubEvent> _clubEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final events = await _eventRepository.getAllClubEvents();
      if (!mounted) return;
      setState(() {
        _clubEvents = events;
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
        title: const Text('Club Events'),
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
                      'Upcoming Club Events',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.purpleDark,
                              ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_clubEvents.isEmpty)
                      Text(
                        'No events available',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    Column(
                      children: _clubEvents
                          .map(
                            (event) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.lg),
                              child: _buildEventCard(context, event),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    ClubEvent event,
  ) {
    return GradientCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.purpleDark,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: AppColors.textSecondaryColor,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _dateFormat.format(event.eventDate),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 16,
                color: AppColors.textSecondaryColor,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                event.location ?? '-',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: AppColors.purpleDark.withOpacity(0.1)),
          const SizedBox(height: AppSpacing.md),
          Text(
            event.description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
