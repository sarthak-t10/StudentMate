import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/animated_gradient_background.dart';
import '../services/mongodb_service.dart';
import '../services/file_service.dart';
import '../utils/notes_subject_catalog.dart';

class AdminUploadScreen extends StatefulWidget {
  const AdminUploadScreen({Key? key}) : super(key: key);

  @override
  State<AdminUploadScreen> createState() => _AdminUploadScreenState();
}

class _AdminUploadScreenState extends State<AdminUploadScreen> {
  String? selectedBranch;
  String? selectedSemester;
  String? selectedSubject;
  String? selectedUploadType; // 'notes' or 'pyqs'
  String? selectedUnit; // For notes: 1-5
  String? selectedExamType; // For PYQs: CIE 1-3, SEE
  String? selectedFileName;
  String? selectedFileUrl;
  String? selectedFileType;

  List<String> getSubjects() {
    return getNotesSubjects(selectedBranch, selectedSemester);
  }

  Future<void> _pickFile() async {
    try {
      final file = await FileService.pickDocumentFile(maxSizeMB: 100);
      if (!mounted || file == null) return;

      setState(() {
        selectedFileName = file.fileName;
        selectedFileUrl = file.fileUrl;
        selectedFileType = file.fileType.toString().split('.').last;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File selection failed: $e')),
      );
    }
  }

  Future<void> _saveUpload() async {
    try {
      final db = await MongoDBService.getDb();
      await db.collection('notes_uploads').insertOne({
        'branch': selectedBranch,
        'semester': selectedSemester,
        'subject': selectedSubject,
        'uploadType': selectedUploadType,
        'unit': selectedUnit,
        'examType': selectedExamType,
        'fileName': selectedFileName,
        'fileUrl': selectedFileUrl,
        'fileType': selectedFileType,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File uploaded successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleUpload() {
    // Validate all required fields
    if (selectedBranch == null ||
        selectedSemester == null ||
        selectedSubject == null ||
        selectedUploadType == null ||
        selectedFileUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all required fields and select a file')),
      );
      return;
    }

    if (selectedUploadType == 'notes' && selectedUnit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a unit')),
      );
      return;
    }

    if (selectedUploadType == 'pyqs' && selectedExamType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an exam type')),
      );
      return;
    }

    // Show upload summary
    _showUploadSummary();
  }

  void _showUploadSummary() {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.grey[900],
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Upload Summary',
                style: GoogleFonts.orbitron(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              _buildSummaryRow('Branch', selectedBranch!),
              const SizedBox(height: 12),
              _buildSummaryRow('Semester', selectedSemester!),
              const SizedBox(height: 12),
              _buildSummaryRow('Subject', selectedSubject!),
              const SizedBox(height: 12),
              _buildSummaryRow('File', selectedFileName ?? 'Not selected'),
              const SizedBox(height: 12),
              _buildSummaryRow(
                'Upload Type',
                selectedUploadType == 'notes' ? 'Notes' : "PYQ's",
              ),
              if (selectedUploadType == 'notes') ...[
                const SizedBox(height: 12),
                _buildSummaryRow('Unit', selectedUnit!),
              ],
              if (selectedUploadType == 'pyqs') ...[
                const SizedBox(height: 12),
                _buildSummaryRow('Exam Type', selectedExamType!),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.3),
                    ),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                      await _saveUpload();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                    ),
                    child: const Text('Upload'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.orbitron(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black26,
          elevation: 0,
          title: Text(
            'Admin Upload Panel',
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload Educational Content',
                  style: GoogleFonts.orbitron(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload notes and PYQs for students',
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),
                // Branch Selection
                _buildFormField(
                  label: 'Branch *',
                  child: _buildDropdown(
                    label: 'Select Branch',
                    value: selectedBranch,
                    items: kNotesBranches,
                    onChanged: (value) {
                      setState(() => selectedBranch = value);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Semester Selection
                _buildFormField(
                  label: 'Semester *',
                  child: _buildDropdown(
                    label: 'Select Semester',
                    value: selectedSemester,
                    items: kNotesSemesters,
                    onChanged: (value) {
                      setState(() => selectedSemester = value);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Subject Selection
                _buildFormField(
                  label: 'Subject *',
                  child: _buildDropdown(
                    label: 'Select Subject',
                    value: selectedSubject,
                    items: getSubjects(),
                    onChanged: (value) {
                      setState(() => selectedSubject = value);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Upload Type Selection
                _buildFormField(
                  label: 'Upload Type *',
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTypeButton(
                          label: 'Notes',
                          isSelected: selectedUploadType == 'notes',
                          onTap: () {
                            setState(() {
                              selectedUploadType = 'notes';
                              selectedUnit = null;
                              selectedExamType = null;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTypeButton(
                          label: "PYQ's",
                          isSelected: selectedUploadType == 'pyqs',
                          onTap: () {
                            setState(() {
                              selectedUploadType = 'pyqs';
                              selectedUnit = null;
                              selectedExamType = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Unit Selection (for Notes)
                if (selectedUploadType == 'notes') ...[
                  _buildFormField(
                    label: 'Unit *',
                    child: _buildDropdown(
                      label: 'Select Unit',
                      value: selectedUnit,
                      items: ['Unit 1', 'Unit 2', 'Unit 3', 'Unit 4', 'Unit 5'],
                      onChanged: (value) {
                        setState(() => selectedUnit = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                // Exam Type Selection (for PYQs)
                if (selectedUploadType == 'pyqs') ...[
                  _buildFormField(
                    label: 'Exam Type *',
                    child: _buildDropdown(
                      label: 'Select Exam Type',
                      value: selectedExamType,
                      items: ['CIE 1', 'CIE 2', 'CIE 3', 'SEE'],
                      onChanged: (value) {
                        setState(() => selectedExamType = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                // File Upload Area
                _buildFormField(
                  label: 'Select File *',
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white24,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      color: Colors.white.withOpacity(0.05),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_upload_outlined,
                            size: 48, color: Colors.white70),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _pickFile,
                          child: Text(
                            selectedFileName ?? 'Click to select file',
                            style: GoogleFonts.orbitron(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          selectedFileType == null
                              ? 'PDF, DOC, DOCX supported'
                              : 'Selected: ${selectedFileType!.toUpperCase()}',
                          style: GoogleFonts.orbitron(
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Upload Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleUpload,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Upload',
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
        color: Colors.white.withOpacity(0.05),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: value,
        hint: Text(
          label,
          style: GoogleFonts.orbitron(color: Colors.white70),
        ),
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child:
                      Text(item, style: const TextStyle(color: Colors.black)),
                ))
            .toList(),
        onChanged: onChanged,
        dropdownColor: Colors.grey[800],
        style: const TextStyle(color: Colors.white),
        underline: Container(),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
      ),
    );
  }

  Widget _buildTypeButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD700) : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? const Color(0xFFFFD700).withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? const Color(0xFFFFD700) : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}
