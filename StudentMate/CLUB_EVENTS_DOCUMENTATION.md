# Club Events Module Documentation

## Overview

The Club Events module provides a complete system for managing club events in the StudentMate application. It includes:

- **Data Model** (`ClubEventModel`) - Comprehensive event representation with image support
- **Database Service** (`ClubEventService`) - CRUD operations for event management
- **Admin Screen** (`AdminCreateClubEventScreen`) - Event creation form with image upload
- **Student Screen** (`StudentClubEventsScreen`) - Responsive event browsing with filtering
- **Interactive UI** - Hover overlays (web) and tap modals (mobile) for event details

## File Structure

```
lib/
├── models/
│   └── club_event_model.dart          # Enhanced club event data model
├── services/
│   └── club_event_service.dart        # Database operations service
└── views/
    ├── admin_create_club_event_screen.dart    # Admin event creation screen
    └── student_club_events_screen.dart        # Student event browsing screen
```

## Usage

### 1. Import Service

```dart
import '../services/club_event_service.dart';

final eventService = ClubEventService();
```

### 2. Access Screens

#### Admin Panel - Create Events

```dart
// Navigate to event creation screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const AdminCreateClubEventScreen(),
  ),
);
```

#### Student View - Browse Events

```dart
// Navigate to student events screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const StudentClubEventsScreen(),
  ),
);
```

### 3. Service Operations

```dart
final eventService = ClubEventService();

// Add new event
final success = await eventService.addClubEvent(event);

// Get all events
final events = await eventService.getAllClubEvents();

// Get upcoming events
final upcoming = await eventService.getUpcomingEvents();

// Get events by club
final clubEvents = await eventService.getEventsByClub('Music Club');

// Register user for event
await eventService.registerUserForEvent(eventId, userId);

// Unregister user
await eventService.unregisterUserFromEvent(eventId, userId);

// Get user's registered events
final myEvents = await eventService.getUserRegisteredEvents(userId);
```

## Features

### Admin Event Creation

**Form Fields:**
- Club Name (required)
- Event Name (required)
- Event Date (required, future dates only)
- Event Time (required)
- Event Location (required)
- Event Description (required, min 10 characters)
- Poster Image (picked from device)

**Validation:**
- All fields are mandatory
- Date must be in the future
- Description minimum length enforcement
- Image format validation

**Upload Process:**
- Image selected via FilePicker
- Image path stored in event model
- Support for future Base64 encoding to MongoDB

### Student Event Browsing

**Responsive Grid:**
- Small phones: 1 card per row
- Medium screens (600-900dp): 2 cards per row
- Tablets (900-1200dp): 2 cards per row
- Large screens (≥1200dp): 3 cards per row

**Event Card Display:**
- Club name badge (top)
- Event poster image
- Event title and date/time
- Event location
- Registration count
- Register button (disabled for past events)

**Filter Options:**
- All Events (default)
- Upcoming Events
- Registered Events

**Interactive Elements:**
- **Web/Desktop**: Hover overlay with description
- **Mobile**: Tap image → Modal bottom sheet with full details
- Register button opens bottom sheet with complete event information

### Hover Overlay (Web/Desktop)

When hovering over event cards on web/desktop:
- Semi-transparent dark overlay appears
- Event description displayed in white text
- Click to open full event details modal

### Mobile Modal Bottom Sheet

When tapping event on mobile:
- Draggable bottom sheet slides up
- Shows full event details:
  - Event name and club info
  - Date, time, and location
  - Complete description
  - Registration count
  - Register button

## Data Model

### ClubEventModel

```dart
class ClubEventModel {
  final String id;                      // UUID
  final String clubName;                // Club organizing event
  final String eventName;               // Event title
  final DateTime eventDate;             // Date of event
  final String eventTime;               // Time (HH:MM format)
  final String description;             // Event description
  final String posterImagePath;         // Local file path
  final String posterImageUrl;          // URL for Base64/cloud
  final String eventLocation;           // Venue/location
  final String createdBy;               // User ID who created
  final DateTime createdAt;             // Creation timestamp
  final List<String> registeredUsers;   // User IDs registered
  
  // Helper methods
  String get formattedDate;             // Format: "1/3/2026"
  String get dateTimeString;            // Full date-time string
  bool isRegisteredBy(String userId);   // Check registration
  int get registrationCount;            // Total registrations
}
```

## Integration with MongoDB

The service currently uses in-memory storage. To integrate with MongoDB:

1. Update `ClubEventService` to use MongoDB operations:

```dart
// Replace in-memory storage
final MongoDBService _mongoService = MongoDBService();

// In addClubEvent:
await _mongoService.insertEvent('clubEvents', event.toJson());

// In getAllClubEvents:
final data = await _mongoService.query('clubEvents', {});
return data.map((json) => ClubEventModel.fromJson(json)).toList();
```

2. Ensure `ClubEventModel.toJson()` and `fromJson()` methods properly serialize/deserialize.

## State Management

The views use:
- **StatefulWidget** for local state management
- **FutureBuilder** for async data loading
- **ScaffoldMessenger** for user feedback (snackbars)

For production, consider integrating with Provider or Riverpod for centralized state management.

## Responsive Design

The module uses the existing `ResponsiveHelper` utility:

```dart
final responsive = ResponsiveHelper(context);

// Available properties
responsive.screenWidth              // Screen width in dp
responsive.cardGridColumns          // Grid columns (1-3)
responsive.horizontalPadding        // Padding (12-24dp)
responsive.spacingSmall/Medium/Large  // Spacing values
responsive.radiusMedium             // Border radius
responsive.buttonHeight             // Button height (44-52dp)
```

## Customization

### Change Card Styling

In `StudentClubEventsScreen`, modify `_EventCard` card properties:

```dart
Card(
  elevation: 8,  // Shadow depth
  color: Colors.white,  // Card background
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
)
```

### Change Register Button Color

Modify `_EventCard` button color:

```dart
backgroundColor: Colors.red[600],  // Change color
disabledBackgroundColor: Colors.grey[400],
```

### Change Grid Spacing

In `StudentClubEventsScreen`, modify grid properties:

```dart
gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: responsive.cardGridColumns,
  childAspectRatio: 1.2,  // Width:Height ratio
  crossAxisSpacing: 16,   // Horizontal spacing
  mainAxisSpacing: 16,    // Vertical spacing
),
```

## Error Handling

- Image selection failures show snackbar with error message
- Event creation failures display failure notification
- Registration errors handled with appropriate feedback
- Network errors will be managed once MongoDB integration is complete

## Testing

### Seed Demo Events

```dart
await eventService.seedDemoEvents();
```

This loads sample events for testing (3 demo events with various dates).

### Manual Testing Checklist

- [ ] Admin can create event with all fields
- [ ] Image picker works on mobile and web
- [ ] Event appears in student view immediately
- [ ] Filter "All" shows all events
- [ ] Filter "Upcoming" hides past events
- [ ] Filter "Registered" shows only registered events
- [ ] Desktop hover overlay displays correctly
- [ ] Mobile tap opens modal bottom sheet
- [ ] Register button works and updates count
- [ ] Past events show "Event Ended" on button
- [ ] Grid is responsive across device sizes

## Future Enhancements

1. **Image Upload to Cloud**
   - Convert image to Base64 for MongoDB storage
   - Or upload to Firebase Storage with URL reference

2. **Event Analytics**
   - Track registration trends
   - Attendance vs registration ratio

3. **Event Notifications**
   - Send notifications for upcoming events
   - Reminder before event start time

4. **Event Search**
   - Search by event name, club, location
   - Full-text search support

5. **Export Event Details**
   - Download event poster
   - Export as ICS calendar file

6. **Advanced Filtering**
   - Filter by date range
   - Filter by location
   - Filter by specific clubs

7. **Event Capacity Management**
   - Maximum registration limit
   - Waitlist support
   - Random selection for overbooked events

## Dependencies

- `flutter/material.dart` - UI framework
- `file_picker` - Image selection
- `uuid` - For event ID generation
- `responsive_helper` - Responsive design calculations

## Support

For issues or questions about the Club Events module, refer to the StudentMate documentation or contact the development team.
