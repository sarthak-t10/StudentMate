import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/club_event_model.dart';
import '../services/club_event_service.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';

class ClubScreen extends StatefulWidget {
  const ClubScreen({Key? key}) : super(key: key);

  @override
  State<ClubScreen> createState() => _ClubScreenState();
}

class _ClubScreenState extends State<ClubScreen> {
  final _eventService = ClubEventService();
  final _authService = AuthService();
  String? _currentUserId;
  List<ClubEventModel> _events = [];
  List<ClubEventModel> _filteredEvents = [];
  bool _isLoading = true;
  String _selectedFilter = 'All'; // All, Upcoming, Registered

  @override
  void initState() {
    super.initState();
    _currentUserId = _authService.getCurrentUser()?.id;
    _loadEvents();
  }

  /// Load events from service
  Future<void> _loadEvents() async {
    try {
      setState(() => _isLoading = true);

      final events = await _eventService.getAllClubEvents();
      setState(() {
        _events = events;
        _applyFilter();
      });
    } catch (e) {
      debugPrint('Error loading events: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Apply filter based on selection
  void _applyFilter() {
    switch (_selectedFilter) {
      case 'Upcoming':
        _filteredEvents =
            _events.where((e) => e.eventDate.isAfter(DateTime.now())).toList();
        break;
      case 'Registered':
        if (_currentUserId == null) {
          _filteredEvents = [];
          break;
        }
        _filteredEvents =
            _events.where((e) => e.isRegisteredBy(_currentUserId!)).toList();
        break;
      default: // All
        _filteredEvents = _events;
    }
  }

  /// Handle filter change
  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilter();
    });
  }

  /// Handle register button press - Open registration link
  Future<void> _registerForEvent(ClubEventModel event) async {
    if (_currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to register for events'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // First, try to open the registration link
    try {
      final Uri registrationUri = Uri.parse(event.registrationLink);

      if (!await launchUrl(
        registrationUri,
        mode: LaunchMode.externalApplication,
      )) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Could not open registration link: ${event.registrationLink}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // If link opened successfully, track the registration locally
      final success =
          await _eventService.registerUserForEvent(event.id, _currentUserId!);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ Registered for ${event.eventName}'),
              backgroundColor: Colors.green,
            ),
          );
          // Reload events to show updated registration status
          await _loadEvents();
        } else {
          // Registration link opened but user was already registered
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ℹ Registration link opened (already registered)'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening registration: $e'),
            backgroundColor: Colors.red,
          ),
        );
        debugPrint('Error launching URL: $e');
      }
    }
  }

  Future<void> _cancelRegistration(ClubEventModel event) async {
    if (_currentUserId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Registration?'),
        content:
            Text('Do you want to cancel registration for ${event.eventName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success =
        await _eventService.unregisterUserFromEvent(event.id, _currentUserId!);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration cancelled for ${event.eventName}'),
          backgroundColor: Colors.orange,
        ),
      );
      await _loadEvents();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not cancel registration'),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Check if event is in past
  bool _isEventPast(DateTime eventDate) {
    return eventDate.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Club Events'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.all(responsive.horizontalPadding),
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        isSelected: _selectedFilter == 'All',
                        onTap: () => _onFilterChanged('All'),
                      ),
                      SizedBox(width: responsive.spacingSmall),
                      _FilterChip(
                        label: 'Upcoming',
                        isSelected: _selectedFilter == 'Upcoming',
                        onTap: () => _onFilterChanged('Upcoming'),
                      ),
                      SizedBox(width: responsive.spacingSmall),
                      _FilterChip(
                        label: 'Registered',
                        isSelected: _selectedFilter == 'Registered',
                        onTap: () => _onFilterChanged('Registered'),
                      ),
                    ],
                  ),
                ),
                // Events List
                Expanded(
                  child: _filteredEvents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_note,
                                  size: 64, color: Colors.grey[400]),
                              SizedBox(height: responsive.spacingMedium),
                              Text(
                                _selectedFilter == 'Registered'
                                    ? 'No registered events yet'
                                    : 'No events available',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : PageView.builder(
                          scrollDirection: Axis.vertical,
                          physics: const PageScrollPhysics(),
                          itemCount: _filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = _filteredEvents[index];
                            return Padding(
                              padding:
                                  EdgeInsets.all(responsive.horizontalPadding),
                              child: _EventCard(
                                event: event,
                                isEventPast: _isEventPast(event.eventDate),
                                isRegistered: _currentUserId != null &&
                                    event.isRegisteredBy(_currentUserId!),
                                onRegister: () => _registerForEvent(event),
                                onCancelRegistration: () =>
                                    _cancelRegistration(event),
                                responsive: responsive,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

/// Reusable Filter Chip Widget
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

/// Event Card Widget with Hover/Tap Interaction
class _EventCard extends StatefulWidget {
  final ClubEventModel event;
  final bool isEventPast;
  final bool isRegistered;
  final VoidCallback onRegister;
  final VoidCallback onCancelRegistration;
  final ResponsiveHelper responsive;

  const _EventCard({
    required this.event,
    required this.isEventPast,
    required this.isRegistered,
    required this.onRegister,
    required this.onCancelRegistration,
    required this.responsive,
  });

  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<_EventCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final isDesktop = widget.responsive.screenWidth > 600;

    return GestureDetector(
      onTap: isDesktop
          ? null
          : () {
              // Show modal bottom sheet on mobile
              _showEventDetails(context);
            },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(widget.responsive.radiusMedium + 2),
        ),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(widget.responsive.radiusMedium + 2),
          child: MouseRegion(
            onEnter: (_) {
              if (isDesktop) setState(() => _isHovering = true);
            },
            onExit: (_) {
              if (isDesktop) setState(() => _isHovering = false);
            },
            child: Stack(
              children: [
                // Image Section
                Container(
                  color: Colors.grey[200],
                  child: Column(
                    children: [
                      // Image or Placeholder
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: _buildPosterImage(),
                        ),
                      ),
                      // Content Section
                      Padding(
                        padding: EdgeInsets.all(
                            widget.responsive.horizontalPadding * 0.8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Club Name (Badge)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    widget.responsive.horizontalPadding * 0.6,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.event.clubName,
                                style: AppTextStyles.grayGradient(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: widget.responsive.spacingSmall),
                            // Event Name
                            Text(
                              widget.event.eventName,
                              style: AppTextStyles.grayGradient(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: widget.responsive.spacingSmall),
                            // Date and Time
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 14, color: Colors.grey[600]),
                                SizedBox(
                                    width:
                                        widget.responsive.spacingSmall * 0.5),
                                Expanded(
                                  child: Text(
                                    '${widget.event.formattedDate} • ${widget.event.eventTime}',
                                    style: AppTextStyles.grayGradient(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: widget.responsive.spacingSmall),
                            // Location
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    size: 14, color: Colors.grey[600]),
                                SizedBox(
                                    width:
                                        widget.responsive.spacingSmall * 0.5),
                                Expanded(
                                  child: Text(
                                    widget.event.eventLocation,
                                    style: AppTextStyles.grayGradient(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: widget.responsive.spacingSmall),
                            // Registration Count & Activity Points
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${widget.event.registrationCount} registered',
                                  style: AppTextStyles.grayGradient(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        widget.responsive.horizontalPadding *
                                            0.5,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.star,
                                          size: 12, color: Colors.amber[700]),
                                      SizedBox(
                                          width:
                                              widget.responsive.spacingSmall *
                                                  0.3),
                                      Text(
                                        '${widget.event.activityPoints} pts',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: Colors.amber[700],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: widget.responsive.spacingSmall),
                            // Register Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: widget.isEventPast
                                    ? null
                                    : widget.isRegistered
                                        ? widget.onCancelRegistration
                                        : widget.onRegister,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    vertical: widget.responsive.spacingSmall,
                                  ),
                                  backgroundColor: widget.isEventPast
                                      ? Colors.grey[400]
                                      : widget.isRegistered
                                          ? Colors.orange[700]
                                          : Colors.red[600],
                                  disabledBackgroundColor: Colors.grey[400],
                                ),
                                icon: Icon(
                                  widget.isEventPast
                                      ? Icons.block
                                      : widget.isRegistered
                                          ? Icons.cancel_outlined
                                          : Icons.open_in_new,
                                  size: 14,
                                ),
                                label: Text(
                                  widget.isEventPast
                                      ? 'Event Ended'
                                      : widget.isRegistered
                                          ? 'Cancel Registration'
                                          : 'Register',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Hover Overlay (Web/Desktop only)
                if (_isHovering)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => _showEventDetails(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                        ),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(
                                widget.responsive.horizontalPadding),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.info,
                                    size: 48, color: Colors.white70),
                                SizedBox(
                                    height: widget.responsive.spacingMedium),
                                Text(
                                  'Event Details',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.grayGradient(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(
                                    height: widget.responsive.spacingSmall),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Text(
                                      widget.event.description,
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.grayGradient(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show event details modal
  void _showEventDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(widget.responsive.radiusMedium + 4),
        ),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: EdgeInsets.all(widget.responsive.horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: widget.responsive.spacingMedium),
                // Event Name
                Text(
                  widget.event.eventName,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: widget.responsive.spacingSmall),
                // Club Info
                Text(
                  'by ${widget.event.clubName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                SizedBox(height: widget.responsive.spacingMedium),
                // Date & Time
                _InfoRow(
                  icon: Icons.calendar_today,
                  label: 'Date & Time',
                  value:
                      '${widget.event.formattedDate} at ${widget.event.eventTime}',
                  responsive: widget.responsive,
                ),
                SizedBox(height: widget.responsive.spacingSmall),
                // Location
                _InfoRow(
                  icon: Icons.location_on,
                  label: 'Location',
                  value: widget.event.eventLocation,
                  responsive: widget.responsive,
                ),
                SizedBox(height: widget.responsive.spacingSmall),
                // Registrations
                _InfoRow(
                  icon: Icons.people,
                  label: 'Registrations',
                  value: '${widget.event.registrationCount} students',
                  responsive: widget.responsive,
                ),
                SizedBox(height: widget.responsive.spacingSmall),
                // Activity Points
                _InfoRow(
                  icon: Icons.star,
                  label: 'Activity Points',
                  value: '${widget.event.activityPoints} points',
                  responsive: widget.responsive,
                  iconColor: Colors.amber,
                ),
                SizedBox(height: widget.responsive.spacingMedium),
                // Description
                Text(
                  'About Event',
                  style: AppTextStyles.grayGradient(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: widget.responsive.spacingSmall),
                Text(
                  widget.event.description,
                  style: AppTextStyles.grayGradient(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: widget.responsive.spacingLarge),
                // Register Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: widget.isEventPast
                        ? null
                        : widget.isRegistered
                            ? widget.onCancelRegistration
                            : widget.onRegister,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: widget.responsive.buttonHeight,
                      ),
                      backgroundColor: widget.isEventPast
                          ? Colors.grey[400]
                          : widget.isRegistered
                              ? Colors.orange[700]
                              : Colors.red[600],
                      disabledBackgroundColor: Colors.grey[400],
                    ),
                    icon: Icon(
                      widget.isEventPast
                          ? Icons.block
                          : widget.isRegistered
                              ? Icons.cancel_outlined
                              : Icons.open_in_new,
                    ),
                    label: Text(
                      widget.isEventPast
                          ? 'Event Ended'
                          : widget.isRegistered
                              ? 'Cancel Registration'
                              : 'Register Now',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPosterImage() {
    final encoded = widget.event.posterImageUrl;
    if (encoded != null && encoded.isNotEmpty) {
      final normalized = encoded.trim();

      if (normalized.startsWith('http://') ||
          normalized.startsWith('https://')) {
        return Image.network(
          normalized,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) =>
              _ImagePlaceholder(responsive: widget.responsive),
        );
      }

      if (normalized.startsWith('file://')) {
        final localPath = normalized.replaceFirst('file://', '');
        return Image.file(
          File(localPath),
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) =>
              _ImagePlaceholder(responsive: widget.responsive),
        );
      }

      try {
        final payload = normalized.contains(';base64,')
            ? normalized.split(';base64,').last
            : normalized;
        final bytes = base64Decode(payload);
        return Image.memory(
          bytes,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) =>
              _ImagePlaceholder(responsive: widget.responsive),
        );
      } catch (_) {
        // Fall through to file-path fallback.
      }
    }

    if (widget.event.posterImagePath.isNotEmpty) {
      return Image.file(
        File(widget.event.posterImagePath),
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) =>
            _ImagePlaceholder(responsive: widget.responsive),
      );
    }

    return _ImagePlaceholder(responsive: widget.responsive);
  }
}

/// Image Placeholder Widget
class _ImagePlaceholder extends StatelessWidget {
  final ResponsiveHelper responsive;

  const _ImagePlaceholder({required this.responsive});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 72;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                size: compact ? 24 : 48,
                color: Colors.grey[600],
              ),
              if (!compact) ...[
                SizedBox(height: responsive.spacingSmall),
                Text(
                  'No image available',
                  style: Theme.of(context).textTheme.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Info Row Widget (for modal)
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ResponsiveHelper responsive;
  final Color? iconColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.responsive,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor ?? Colors.blue),
        SizedBox(width: responsive.spacingSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.grayGradient(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.grayGradient(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
