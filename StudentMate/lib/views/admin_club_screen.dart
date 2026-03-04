import 'package:flutter/material.dart';
import '../models/club_event_model.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../services/club_event_service.dart';
import '../views/admin_create_club_event_screen.dart';
import '../utils/responsive_helper.dart';

class AdminClubScreen extends StatefulWidget {
  const AdminClubScreen({Key? key}) : super(key: key);

  @override
  State<AdminClubScreen> createState() => _AdminClubScreenState();
}

class _AdminClubScreenState extends State<AdminClubScreen> {
  final _eventService = ClubEventService();
  final _userRepository = UserRepository();
  List<ClubEventModel> _events = [];
  Map<String, User> _usersById = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      setState(() => _isLoading = true);

      final events = await _eventService.getAllClubEvents();
      final users = await _userRepository.getAllUsers();

      if (mounted) {
        setState(() {
          _events = events;
          _usersById = {for (final user in users) user.id: user};
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading events: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showRegisteredStudents(ClubEventModel event) {
    final registeredUsers = event.registeredUsers;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Registered Students (${registeredUsers.length})'),
        content: SizedBox(
          width: double.maxFinite,
          child: registeredUsers.isEmpty
              ? const Text('No students have registered for this event yet.')
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: registeredUsers.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final userId = registeredUsers[index];
                    final user = _usersById[userId];
                    final name = user?.fullName ?? 'Unknown Student';
                    final email = user?.email ?? userId;

                    return ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(name),
                      subtitle: Text(email),
                      dense: true,
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Club Events'),
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.all(responsive.horizontalPadding),
            child: Tooltip(
              message: 'Add New Event',
              child: InkWell(
                onTap: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminCreateClubEventScreen(),
                    ),
                  );
                  if (result == true) {
                    await _loadEvents();
                  }
                },
                child: const Icon(Icons.add_circle_outline, size: 28),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminCreateClubEventScreen(),
            ),
          );
          if (result == true) {
            await _loadEvents();
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_note, size: 64, color: Colors.grey[400]),
                      SizedBox(height: responsive.spacingMedium),
                      Text(
                        'No events created yet',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                      SizedBox(height: responsive.spacingSmall),
                      Text(
                        'Tap the + button to create a new event',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(responsive.horizontalPadding),
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final event = _events[index];
                    return _EventListCard(
                      event: event,
                      responsive: responsive,
                      onViewRegistrations: () => _showRegisteredStudents(event),
                      onDelete: () async {
                        final scaffoldMessenger =
                            ScaffoldMessenger.maybeOf(this.context);
                        final confirm = await showDialog<bool>(
                          context: this.context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Event?'),
                            content: Text(
                                'Are you sure you want to delete "${event.eventName}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await _eventService.deleteEvent(event.id);
                          await _loadEvents();
                          if (mounted && scaffoldMessenger != null) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content:
                                    Text('Event "${event.eventName}" deleted'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
    );
  }
}

/// Event List Card for Admin View
class _EventListCard extends StatelessWidget {
  final ClubEventModel event;
  final ResponsiveHelper responsive;
  final VoidCallback onViewRegistrations;
  final VoidCallback onDelete;

  const _EventListCard({
    required this.event,
    required this.responsive,
    required this.onViewRegistrations,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: responsive.spacingMedium),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(responsive.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Club Name Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.horizontalPadding * 0.6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          event.clubName,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: Colors.blue[800]),
                        ),
                      ),
                      SizedBox(height: responsive.spacingSmall),
                      // Event Name
                      Text(
                        event.eventName,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      SizedBox(height: responsive.spacingSmall),
                      // Date & Time
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 16, color: Colors.grey[600]),
                          SizedBox(width: responsive.spacingSmall * 0.5),
                          Text(
                            '${event.formattedDate} at ${event.eventTime}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      SizedBox(height: responsive.spacingSmall),
                      // Location
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 16, color: Colors.grey[600]),
                          SizedBox(width: responsive.spacingSmall * 0.5),
                          Expanded(
                            child: Text(
                              event.eventLocation,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: responsive.spacingSmall),
                      // Registrations
                      Text(
                        '${event.registrationCount} students registered',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.green,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                      if (event.registrationCount > 0)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: onViewRegistrations,
                            icon:
                                const Icon(Icons.people_alt_outlined, size: 16),
                            label: const Text('View Registered Students'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Delete Button
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: 'Delete Event',
                ),
              ],
            ),
            SizedBox(height: responsive.spacingSmall),
            // Description Preview
            Padding(
              padding: EdgeInsets.only(top: responsive.spacingSmall),
              child: Text(
                event.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
