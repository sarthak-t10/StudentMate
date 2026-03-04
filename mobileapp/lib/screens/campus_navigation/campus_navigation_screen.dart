import 'package:flutter/material.dart';

class CampusNavigationScreen extends StatelessWidget {
  const CampusNavigationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Map'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 80, color: Colors.blue),
            const SizedBox(height: 16),
            const Text('Interactive Campus Map'),
            const SizedBox(height: 16),
            const Text('Coming soon...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
