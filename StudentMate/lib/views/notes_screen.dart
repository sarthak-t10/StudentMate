import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/animated_gradient_background.dart';
import '../services/file_service.dart';
import '../services/mongodb_service.dart';
import '../utils/notes_subject_catalog.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String? selectedType; // 'notes' or 'pyqs'
  String? selectedBranch;
  String? selectedSemester;
  String? selectedSubject;
  Future<List<Map<String, dynamic>>>? _uploadsFuture;

  List<String> getSubjects() {
    return getNotesSubjects(selectedBranch, selectedSemester);
  }

  Future<List<Map<String, dynamic>>> _loadUploads() async {
    if (selectedType == null ||
        selectedBranch == null ||
        selectedSemester == null ||
        selectedSubject == null) {
      return [];
    }

    final db = await MongoDBService.getDb();
    final cursor = await db.collection('notes_uploads').find({
      'branch': selectedBranch,
      'semester': selectedSemester,
      'subject': selectedSubject,
      'uploadType': selectedType,
    }).toList();

    return cursor.cast<Map<String, dynamic>>();
  }

  String _sectionLabelForItem(String item) {
    return selectedType == 'notes' ? item : item;
  }

  List<String> _itemsForCurrentUploadType() {
    return selectedType == 'notes'
        ? ['Unit 1', 'Unit 2', 'Unit 3', 'Unit 4', 'Unit 5']
        : ['CIE 1', 'CIE 2', 'CIE 3', 'SEE'];
  }

  List<Map<String, dynamic>> _uploadsForLabel(
    List<Map<String, dynamic>> uploads,
    String label,
  ) {
    return uploads.where((upload) {
      final rawValue =
          selectedType == 'notes' ? upload['unit'] : upload['examType'];
      return rawValue == label;
    }).toList();
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
            'StudentMate Notes',
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Step 1: Select Type (Notes or PYQs)
                if (selectedType == null)
                  _buildTypeSelectionStep(context)
                // Step 2: Select Branch & Semester
                else if (selectedBranch == null || selectedSemester == null)
                  _buildBranchSemesterStep(context)
                // Step 3: Select Subject
                else if (selectedSubject == null)
                  _buildSubjectSelectionStep(context)
                // Step 4: Show Units/Exams
                else
                  _buildContentStep(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelectionStep(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Text(
          'What would you like to view?',
          style: GoogleFonts.orbitron(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 60),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: _buildTypeCard(
                title: 'Notes',
                icon: Icons.note_outlined,
                onTap: () {
                  setState(() => selectedType = 'notes');
                },
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildTypeCard(
                title: "PYQ's",
                icon: Icons.assignment_outlined,
                onTap: () {
                  setState(() => selectedType = 'pyqs');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildTypeCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.blue.withOpacity(0.3),
              Colors.purple.withOpacity(0.2),
            ],
          ),
          border: Border.all(color: Colors.white24, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white70),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.orbitron(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchSemesterStep(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Text(
          'Select Branch & Semester',
          style: GoogleFonts.orbitron(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 40),
        _buildDropdown(
          label: 'Branch',
          value: selectedBranch,
          items: kNotesBranches,
          onChanged: (value) {
            setState(() => selectedBranch = value);
          },
        ),
        const SizedBox(height: 24),
        _buildDropdown(
          label: 'Semester',
          value: selectedSemester,
          items: kNotesSemesters,
          onChanged: (value) {
            setState(() => selectedSemester = value);
          },
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedType = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.withOpacity(0.3),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Back'),
            ),
            ElevatedButton(
              onPressed: selectedBranch != null && selectedSemester != null
                  ? () {
                      setState(() => selectedSubject = null);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Next'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubjectSelectionStep(BuildContext context) {
    final subjects = getSubjects();
    return Column(
      children: [
        const SizedBox(height: 40),
        Text(
          'Select Subject',
          style: GoogleFonts.orbitron(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '$selectedBranch - Sem $selectedSemester',
          style: GoogleFonts.orbitron(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 40),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            final subject = subjects[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedSubject = subject;
                    _uploadsFuture = _loadUploads();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withOpacity(0.2),
                        Colors.purple.withOpacity(0.1),
                      ],
                    ),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.book, color: Colors.white70),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          subject,
                          style: GoogleFonts.orbitron(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward, color: Colors.white70),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            setState(() {
              selectedBranch = null;
              selectedSemester = null;
              selectedSubject = null;
              _uploadsFuture = null;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.withOpacity(0.3),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Back'),
        ),
      ],
    );
  }

  Widget _buildContentStep(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Text(
          selectedSubject ?? '',
          style: GoogleFonts.orbitron(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          '${selectedType == 'notes' ? 'Notes' : "PYQ's"} - $selectedBranch Sem $selectedSemester',
          style: GoogleFonts.orbitron(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 40),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _uploadsFuture ?? _loadUploads(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Unable to load files right now.',
                  style: GoogleFonts.orbitron(color: Colors.white70),
                ),
              );
            }

            final uploads = snapshot.data ?? [];
            final items = _itemsForCurrentUploadType();

            return Column(
              children: items.map((item) {
                final itemUploads = _uploadsForLabel(uploads, item);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.withOpacity(0.2),
                          Colors.blue.withOpacity(0.1),
                        ],
                      ),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item,
                              style: GoogleFonts.orbitron(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: itemUploads.isEmpty
                                    ? Colors.orange.withOpacity(0.3)
                                    : Colors.green.withOpacity(0.3),
                                border: Border.all(
                                  color: itemUploads.isEmpty
                                      ? Colors.orange
                                      : Colors.green,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                itemUploads.isEmpty
                                    ? 'No files'
                                    : '${itemUploads.length} file(s)',
                                style: GoogleFonts.orbitron(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (itemUploads.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          ...itemUploads.map(
                            (upload) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: () async {
                                  final fileUrl = upload['fileUrl'] as String?;
                                  if (fileUrl == null || fileUrl.isEmpty) {
                                    return;
                                  }
                                  try {
                                    await FileService.openFile(fileUrl);
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Unable to open file: $e')),
                                    );
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.description_outlined,
                                          color: Colors.white70),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          upload['fileName']?.toString() ??
                                              'Untitled file',
                                          style: GoogleFonts.orbitron(
                                            fontSize: 13,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const Icon(Icons.open_in_new,
                                          color: Colors.white70, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 12),
                          Text(
                            'No files uploaded yet for this section.',
                            style: GoogleFonts.orbitron(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            setState(() {
              selectedType = null;
              selectedBranch = null;
              selectedSemester = null;
              selectedSubject = null;
              _uploadsFuture = null;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.withOpacity(0.3),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Reset'),
        ),
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
}
