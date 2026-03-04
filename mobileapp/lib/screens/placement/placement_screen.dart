import 'package:flutter/material.dart';

class PlacementScreen extends StatelessWidget {
  const PlacementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Placements & Career'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('Job Postings', Icons.work),
          const SizedBox(height: 16),
          _buildSection('Internships', Icons.school),
          const SizedBox(height: 16),
          _buildSection('Placement Drives', Icons.event),
          const SizedBox(height: 16),
          _buildSection('My Resume', Icons.description),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
