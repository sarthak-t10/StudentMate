import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/event_model.dart';
import '../repositories/event_repository.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/responsive_layout_components.dart';

class AdminCalendarScreen extends StatefulWidget {
  const AdminCalendarScreen({Key? key}) : super(key: key);

  @override
  State<AdminCalendarScreen> createState() => _AdminCalendarScreenState();
}

class _AdminCalendarScreenState extends State<AdminCalendarScreen> {
  final EventRepository _eventRepository = EventRepository();
  final DateFormat _displayDateFormat = DateFormat('dd MMM yyyy');
  final DateFormat _inputDateFormat = DateFormat('dd MMM yyyy');
  List<CalendarEvent> _calendarEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCalendarEvents();
  }

  Future<void> _loadCalendarEvents() async {
    try {
      final events = await _eventRepository.getAllCalendarEvents();
      if (events.isEmpty) {
        await _seedDefaultEvents();
      }
      final refreshed = await _eventRepository.getAllCalendarEvents();
      if (!mounted) return;
      setState(() {
        _calendarEvents = refreshed;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _seedDefaultEvents() async {
    final now = DateTime.now();
    final defaults = [
      CalendarEvent(
        id: const Uuid().v4(),
        title: 'Mid Semester Exam',
        description: 'Mid semester examination begins',
        eventDate: now.add(const Duration(days: 10)),
        createdBy: 'admin',
        createdAt: now,
      ),
      CalendarEvent(
        id: const Uuid().v4(),
        title: 'Sports Day',
        description: 'Annual sports day celebration',
        eventDate: now.add(const Duration(days: 25)),
        createdBy: 'admin',
        createdAt: now,
      ),
    ];

    for (final event in defaults) {
      await _eventRepository.insertCalendarEvent(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppLogo(),
        title: const Text('Manage Calendar Events'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventForm(),
        backgroundColor: AppColors.purpleDark,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
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
                      'Calendar Events',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.purpleDark,
                              ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_calendarEvents.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Text(
                            'No calendar events yet. Tap + to add one!',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppColors.textSecondaryColor,
                                    ),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: _calendarEvents
                            .map(
                              (event) => Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppSpacing.lg),
                                child: _buildEventCard(event),
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

  Widget _buildEventCard(CalendarEvent event) {
    return GradientCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
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
                    const SizedBox(height: AppSpacing.sm),
                    Chip(
                      label: const Text('Event'),
                      backgroundColor: AppColors.pinkLight.withOpacity(0.2),
                      labelStyle: const TextStyle(
                        color: AppColors.pinkLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    _showEventForm(event: event);
                    return;
                  }
                  if (value == 'delete') {
                    await _eventRepository.deleteCalendarEvent(event.id);
                    await _loadCalendarEvents();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 14,
                color: AppColors.textSecondaryColor,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _displayDateFormat.format(event.eventDate),
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

  void _showEventForm({CalendarEvent? event}) {
    final titleController = TextEditingController(text: event?.title ?? '');
    final dateController = TextEditingController(
      text: event == null ? '' : _displayDateFormat.format(event.eventDate),
    );
    final descriptionController =
        TextEditingController(text: event?.description ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title:
            Text(event == null ? 'Add Calendar Event' : 'Edit Calendar Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.black87),
                decoration: const InputDecoration(
                  labelText: 'Event Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: dateController,
                style: const TextStyle(color: Colors.black87),
                decoration: const InputDecoration(
                  labelText: 'Date (e.g., 15 Mar 2026)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                style: const TextStyle(color: Colors.black87),
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isEmpty || dateController.text.isEmpty) {
                return;
              }

              final parsedDate = DateTime.tryParse(dateController.text) ??
                  _tryParseDisplayDate(dateController.text) ??
                  DateTime.now();

              final payload = CalendarEvent(
                id: event?.id ?? const Uuid().v4(),
                title: titleController.text,
                description: descriptionController.text,
                eventDate: parsedDate,
                createdBy: 'admin',
                createdAt: event?.createdAt ?? DateTime.now(),
              );

              if (event == null) {
                await _eventRepository.insertCalendarEvent(payload);
              } else {
                await _eventRepository.updateCalendarEvent(payload);
              }

              if (!mounted) return;
              await _loadCalendarEvents();
              if (!mounted) return;
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(event == null ? 'Event added!' : 'Event updated!'),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  DateTime? _tryParseDisplayDate(String input) {
    try {
      return _inputDateFormat.parseStrict(input);
    } catch (_) {
      return null;
    }
  }
}
