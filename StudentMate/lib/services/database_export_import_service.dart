import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'mongodb_service.dart';

/// Service to export and import database collections as JSON for portability
class DatabaseExportImportService {
  static const String _exportDirName = 'studentmate_db_export';
  static const List<String> _collectionNames = [
    'users',
    'grades',
    'attendance',
    'subjects',
    'marks',
    'timetable',
    'club_events',
    'calendar_events',
    'announcements',
    'documents',
    'folders',
  ];

  /// Export all collections to JSON files in app documents directory
  /// Returns the export directory path
  static Future<String> exportDatabase() async {
    try {
      final db = await MongoDBService.getDb();
      final appDocsDir = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${appDocsDir.path}/$_exportDirName');

      // Create export directory
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      // Export each collection
      final exportedCollections = <String>[];
      for (final collectionName in _collectionNames) {
        try {
          final collection = db.collection(collectionName);
          final documents = await collection.find().toList();

          final jsonFile = File('${exportDir.path}/$collectionName.json');
          await jsonFile.writeAsString(
            jsonEncode(documents),
            flush: true,
          );

          exportedCollections.add(collectionName);
          debugPrint('Exported $collectionName: ${documents.length} documents');
        } catch (e) {
          debugPrint('Error exporting $collectionName: $e');
          // Continue with other collections even if one fails
        }
      }

      // Create metadata file
      final metadata = {
        'exportedAt': DateTime.now().toIso8601String(),
        'exportedCollections': exportedCollections,
        'totalCollections': exportedCollections.length,
      };
      final metadataFile = File('${exportDir.path}/metadata.json');
      await metadataFile.writeAsString(
        jsonEncode(metadata),
        flush: true,
      );

      debugPrint('Database export completed to: ${exportDir.path}');
      return exportDir.path;
    } catch (e) {
      debugPrint('Database export failed: $e');
      rethrow;
    }
  }

  /// Import collections from JSON files
  /// Pass directory path containing the exported JSON files
  static Future<Map<String, int>> importDatabase(String importDirPath) async {
    try {
      final db = await MongoDBService.getDb();
      final importDir = Directory(importDirPath);

      if (!await importDir.exists()) {
        throw Exception('Import directory does not exist: $importDirPath');
      }

      final importResults = <String, int>{}; // collection -> document count

      for (final collectionName in _collectionNames) {
        try {
          final jsonFile = File('${importDir.path}/$collectionName.json');

          if (!await jsonFile.exists()) {
            debugPrint('Skipping $collectionName - file not found');
            continue;
          }

          final jsonContent = await jsonFile.readAsString();
          final documents = jsonDecode(jsonContent) as List;

          if (documents.isEmpty) {
            importResults[collectionName] = 0;
            continue;
          }

          final collection = db.collection(collectionName);

          // Clear existing documents
          await collection.deleteMany({});

          // Insert all documents
          for (final doc in documents) {
            await collection.insertOne(doc as Map<String, dynamic>);
          }

          importResults[collectionName] = documents.length;
          debugPrint('Imported $collectionName: ${documents.length} documents');
        } catch (e) {
          debugPrint('Error importing $collectionName: $e');
          importResults[collectionName] = 0;
          // Continue with other collections even if one fails
        }
      }

      debugPrint('Database import completed');
      return importResults;
    } catch (e) {
      debugPrint('Database import failed: $e');
      rethrow;
    }
  }

  /// Get the export directory path (for accessing previously exported data)
  static Future<String> getExportDirectoryPath() async {
    final appDocsDir = await getApplicationDocumentsDirectory();
    return '${appDocsDir.path}/$_exportDirName';
  }

  /// Check if export directory exists and has export files
  static Future<bool> hasExistingExport() async {
    try {
      final exportDirPath = await getExportDirectoryPath();
      final exportDir = Directory(exportDirPath);
      final metadataFile = File('${exportDir.path}/metadata.json');
      return await metadataFile.exists();
    } catch (_) {
      return false;
    }
  }

  /// Get metadata of the last export
  static Future<Map<String, dynamic>?> getExportMetadata() async {
    try {
      final exportDirPath = await getExportDirectoryPath();
      final metadataFile = File('$exportDirPath/metadata.json');

      if (!await metadataFile.exists()) {
        return null;
      }

      final jsonContent = await metadataFile.readAsString();
      return jsonDecode(jsonContent) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error reading export metadata: $e');
      return null;
    }
  }

  /// List all JSON files in the export directory
  static Future<List<String>> listExportedCollections() async {
    try {
      final exportDirPath = await getExportDirectoryPath();
      final exportDir = Directory(exportDirPath);

      if (!await exportDir.exists()) {
        return [];
      }

      final files = await exportDir.list().toList();
      return files
          .where(
              (f) => f.path.endsWith('.json') && !f.path.contains('metadata'))
          .map((f) => f.path.split('/').last.replaceAll('.json', ''))
          .toList();
    } catch (e) {
      debugPrint('Error listing exported collections: $e');
      return [];
    }
  }
}
