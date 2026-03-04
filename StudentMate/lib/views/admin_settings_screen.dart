import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/database_export_import_service.dart';
import '../utils/responsive_helper.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _isExporting = false;
  bool _isImporting = false;
  String? _exportMessage;
  String? _importMessage;
  Map<String, dynamic>? _exportMetadata;

  @override
  void initState() {
    super.initState();
    _loadExportMetadata();
  }

  Future<void> _loadExportMetadata() async {
    final metadata = await DatabaseExportImportService.getExportMetadata();
    if (mounted) {
      setState(() => _exportMetadata = metadata);
    }
  }

  Future<void> _handleExportDatabase() async {
    if (_isExporting) return;

    setState(() {
      _isExporting = true;
      _exportMessage = null;
    });

    try {
      final exportPath = await DatabaseExportImportService.exportDatabase();
      if (mounted) {
        setState(() {
          _exportMessage =
              '✓ Database exported successfully!\n\nLocation: $exportPath\n\nYou can now:\n1. Zip this folder with your project\n2. Share with others to transfer data\n3. Use Import to restore data';
          _isExporting = false;
        });
        _loadExportMetadata();

        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database exported successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _exportMessage = '✗ Export failed: $e';
          _isExporting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Export failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleImportDatabase() async {
    if (_isImporting) return;

    try {
      // Check if user has an export folder or wants to select a folder
      bool useExisting = false;
      final hasExisting = await DatabaseExportImportService.hasExistingExport();

      if (hasExisting) {
        useExisting = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Import Data'),
                content: const Text(
                    'Use existing exported data or select a custom folder?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Use Existing Export'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Select Custom Folder'),
                  ),
                ],
              ),
            ) ??
            false;
      }

      String? importPath;

      if (useExisting) {
        importPath = await DatabaseExportImportService.getExportDirectoryPath();
      } else {
        importPath = await FilePicker.platform.getDirectoryPath();
        if (importPath == null) return;
      }

      setState(() {
        _isImporting = true;
        _importMessage = null;
      });

      final results =
          await DatabaseExportImportService.importDatabase(importPath);

      if (mounted) {
        final totalDocs =
            results.values.fold<int>(0, (sum, count) => sum + count);
        setState(() {
          _importMessage =
              '✓ Database imported successfully!\n\nImported ${results.length} collections with $totalDocs total documents\n\nCollections:\n${results.entries.map((e) => '${e.key}: ${e.value} docs').join('\n')}';
          _isImporting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database imported successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _importMessage = '✗ Import failed: $e';
          _isImporting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    return WillPopScope(
      onWillPop: () async {
        if (_isExporting || _isImporting) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Operation in progress. Please wait...'),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Database Settings'),
          elevation: 0,
          backgroundColor: Colors.deepPurple.shade700,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(responsive.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: responsive.verticalPadding * 2),

              // Export Section
              _buildCard(
                title: '📦 Export Database',
                description:
                    'Export all collections to JSON files for backup or sharing',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isExporting ? null : _handleExportDatabase,
                      icon: _isExporting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.cloud_download),
                      label: Text(
                        _isExporting ? 'Exporting...' : 'Export Now',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    if (_exportMessage != null) ...[
                      SizedBox(height: responsive.verticalPadding),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _exportMessage!.contains('✓')
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          border: Border.all(
                            color: _exportMessage!.contains('✓')
                                ? Colors.green
                                : Colors.red,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _exportMessage!,
                          style: TextStyle(
                            fontSize: 13,
                            color: _exportMessage!.contains('✓')
                                ? Colors.green.shade900
                                : Colors.red.shade900,
                          ),
                        ),
                      ),
                    ],
                    if (_exportMetadata != null) ...[
                      SizedBox(height: responsive.verticalPadding),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Last Export Info:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Exported at: ${_exportMetadata!['exportedAt']}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Collections: ${_exportMetadata!['totalCollections']}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: responsive.verticalPadding * 2),

              // Import Section
              _buildCard(
                title: '📂 Import Database',
                description:
                    'Import collections from exported JSON files to restore data',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isImporting ? null : _handleImportDatabase,
                      icon: _isImporting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.cloud_upload),
                      label: Text(
                        _isImporting ? 'Importing...' : 'Import Now',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: responsive.verticalPadding),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '⚠️ Warning: Import will replace existing data in the database. Ensure you have a backup before proceeding.',
                        style: TextStyle(fontSize: 12, color: Colors.orange),
                      ),
                    ),
                    if (_importMessage != null) ...[
                      SizedBox(height: responsive.verticalPadding),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _importMessage!.contains('✓')
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          border: Border.all(
                            color: _importMessage!.contains('✓')
                                ? Colors.green
                                : Colors.red,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _importMessage!,
                          style: TextStyle(
                            fontSize: 13,
                            color: _importMessage!.contains('✓')
                                ? Colors.green.shade900
                                : Colors.red.shade900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: responsive.verticalPadding * 2),

              // Instructions Section
              _buildCard(
                title: '📋 How to Share with Others',
                child: SingleChildScrollView(
                  child: Text(
                    '1. Click "Export Now" to create a backup of all database collections\n\n'
                    '2. A folder named "studentmate_db_export" will be created in your app\'s documents directory\n\n'
                    '3. Zip this folder along with the StudentMate project files\n\n'
                    '4. Send the zip file to the other person\n\n'
                    '5. They should:\n'
                    '   • Extract the zip file\n'
                    '   • Open the StudentMate app on their device\n'
                    '   • Go to Admin Settings → Import Database\n'
                    '   • Select the exported folder from the zip\n'
                    '   • All data will be restored to their device\n\n'
                    '💡 Tip: Export works offline - you can share data without needing MongoDB connection on either device',
                    style: const TextStyle(fontSize: 13, height: 1.6),
                  ),
                ),
              ),

              SizedBox(height: responsive.verticalPadding * 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    String? description,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
