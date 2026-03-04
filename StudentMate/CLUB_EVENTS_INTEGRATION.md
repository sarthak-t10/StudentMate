# Club Events Module - Integration Guide

## Adding Club Events Screens to Your App Navigation

### Step 1: Import the Screens

In your navigation or home screen file, add:

```dart
import 'package:studentmate/views/admin_create_club_event_screen.dart';
import 'package:studentmate/views/student_club_events_screen.dart';
```

### Step 2: Add Navigation Buttons

#### For Students (in Student Dashboard/Home)

```dart
// In column or grid
Container(
  margin: EdgeInsets.all(8),
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const StudentClubEventsScreen(),
        ),
      );
    },
    child: Column(
      children: const [
        Icon(Icons.event, size: 32),
        SizedBox(height: 8),
        Text('Club Events'),
      ],
    ),
  ),
)
```

#### For Admins (in Admin Panel)

```dart
// In admin menu or dashboard
ListTile(
  leading: Icon(Icons.add_event),
  title: const Text('Create Event'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminCreateClubEventScreen(),
      ),
    ).then((result) {
      if (result == true) {
        // Event created, refresh list if needed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event created successfully')),
        );
      }
    });
  },
)
```

### Step 3: Integration with Named Routes (Optional)

If using named routes, add to your route configuration:

```dart
// In main.dart or router.dart
final Map<String, WidgetBuilder> routes = {
  '/student-club-events': (context) => const StudentClubEventsScreen(),
  '/admin-create-event': (context) => const AdminCreateClubEventScreen(),
};

// Usage
Navigator.pushNamed(context, '/student-club-events');
Navigator.pushNamed(context, '/admin-create-event');
```

### Step 4: Add to Navigation Bar (if using BottomNavigationBar)

```dart
class MainNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Academics'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      onTap: (index) {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StudentClubEventsScreen(),
            ),
          );
        }
      },
    );
  }
}
```

### Step 5: User Role-Based Access

In your app, ensure proper routing based on user type:

```dart
// In authentication or user check
if (currentUser.userType == 'admin' || currentUser.userType == 'faculty') {
  // Show admin button to create events
  _buildAdminEventButton(context);
}

if (currentUser.userType == 'student') {
  // Show student events browsing
  _buildStudentEventsButton(context);
}
```

## Example Integration in home_screen.dart

```dart
// Add to your home screen's build method

Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const StudentClubEventsScreen(),
          ),
        );
      },
      child: _buildCard(
        icon: Icons.event,
        title: 'Club Events',
        color: Colors.orange,
      ),
    ),
    if (isAdmin) 
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminCreateClubEventScreen(),
            ),
          );
        },
        child: _buildCard(
          icon: Icons.add_event,
          title: 'Create Event',
          color: Colors.blue,
        ),
      ),
  ],
)
```

## Complete Example App

Here's a minimal example showing the complete integration:

```dart
import 'package:flutter/material.dart';
import 'package:studentmate/views/student_club_events_screen.dart';
import 'package:studentmate/views/admin_create_club_event_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudentMate Events',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudentMate Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudentClubEventsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.event),
              label: const Text('Browse Club Events'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminCreateClubEventScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_event),
              label: const Text('Create New Event (Admin)'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## State Management Integration

For better state management, consider using Provider or Riverpod:

### Using Provider

```dart
// Create a provider for event service
final eventServiceProvider = Provider((ref) {
  return ClubEventService();
});

// Create a provider for events list
final eventsProvider = FutureProvider((ref) async {
  final service = ref.watch(eventServiceProvider);
  return service.getAllClubEvents();
});

// In your widget
class StudentClubEventsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    
    return eventsAsync.when(
      data: (events) => _buildEventsList(events),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
```

## Testing Integration

Add this test to verify the screens open correctly:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:studentmate/views/student_club_events_screen.dart';
import 'package:studentmate/views/admin_create_club_event_screen.dart';

void main() {
  group('Club Events Integration', () {
    testWidgets('Student can open events screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () => Navigator.push(
                tester.element(find.byType(ElevatedButton)),
                MaterialPageRoute(
                  builder: (_) => const StudentClubEventsScreen(),
                ),
              ),
              child: const Text('Open Events'),
            ),
          ),
        ),
      );

      expect(find.text('Club Events'), findsWidgets);
    });

    testWidgets('Admin can open create event screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () => Navigator.push(
                tester.element(find.byType(ElevatedButton)),
                MaterialPageRoute(
                  builder: (_) => const AdminCreateClubEventScreen(),
                ),
              ),
              child: const Text('Create Event'),
            ),
          ),
        ),
      );

      expect(find.text('Create Club Event'), findsWidgets);
    });
  });
}
```

## Next Steps

1. **Add to your home_screen.dart** - Include navigation buttons
2. **Test on different devices** - Verify responsive layout
3. **Connect to MongoDB** - Replace in-memory storage
4. **Add user role checks** - Restrict admin access appropriately
5. **Set up push notifications** - Alert users of new events
6. **Implement user authentication** - Get current logged-in user ID

## Troubleshooting

### Images Not Displaying
- Check file path is correct in event model
- Ensure image file exists at the path
- Use proper error handling in Image.file()

### Events Not Loading
- Verify ClubEventService is properly initialized
- Check for null pointer exceptions
- Add debug prints in service methods

### Navigation Issues
- Ensure screens are properly imported
- Check BuildContext is passed correctly
- Verify MaterialApp is root widget

### Responsive Layout Issues
- Verify ResponsiveHelper is properly initialized
- Check device breakpoint values
- Test on actual devices, not just emulator

## Support Files

- Main documentation: [CLUB_EVENTS_DOCUMENTATION.md](CLUB_EVENTS_DOCUMENTATION.md)
- Service: [lib/services/club_event_service.dart](lib/services/club_event_service.dart)
- Model: [lib/models/club_event_model.dart](lib/models/club_event_model.dart)
- Admin Screen: [lib/views/admin_create_club_event_screen.dart](lib/views/admin_create_club_event_screen.dart)
- Student Screen: [lib/views/student_club_events_screen.dart](lib/views/student_club_events_screen.dart)
