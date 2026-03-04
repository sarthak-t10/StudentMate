import 'package:flutter/material.dart';

class AcademicScreen extends StatelessWidget {
  const AcademicScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academics'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('Timetable', Icons.schedule),
          const SizedBox(height: 16),
          _buildSection('Attendance', Icons.check_circle),
          const SizedBox(height: 16),
          _buildSection('Internal Marks', Icons.grade),
          const SizedBox(height: 16),
          _buildSection('Exam Schedule', Icons.calendar_today),
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
