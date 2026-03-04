import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

enum FileType { pdf, image, document, video, audio, other }

class FileAttachment {
  final String fileName;
  final String fileUrl;
  final FileType fileType;
  final int fileSizeBytes;
  final DateTime uploadedAt;

  FileAttachment({
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.fileSizeBytes,
    DateTime? uploadedAt,
  }) : uploadedAt = uploadedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileType': fileType.toString().split('.').last,
      'fileSizeBytes': fileSizeBytes,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  factory FileAttachment.fromJson(Map<String, dynamic> json) {
    return FileAttachment(
      fileName: json['fileName'] as String,
      fileUrl: json['fileUrl'] as String,
      fileType: parseFileType(json['fileType'] as String?),
      fileSizeBytes: json['fileSizeBytes'] as int,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
    );
  }

  static FileType parseFileType(String? type) {
    switch (type?.toLowerCase()) {
      case 'pdf':
        return FileType.pdf;
      case 'image':
        return FileType.image;
      case 'document':
        return FileType.document;
      case 'video':
        return FileType.video;
      case 'audio':
        return FileType.audio;
      default:
        return FileType.other;
    }
  }
}

class FileService {
  static const uuid = Uuid();

  // Allowed file extensions for each type
  static const Map<FileType, List<String>> allowedExtensions = {
    FileType.pdf: ['pdf'],
    FileType.image: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
    FileType.document: ['doc', 'docx', 'txt', 'rtf', 'odt'],
    FileType.video: ['mp4', 'avi', 'mov', 'mkv', 'flv', 'webm'],
    FileType.audio: ['mp3', 'aac', 'wav', 'flac', 'm4a', 'ogg'],
  };

  /// Pick a file and return FileAttachment object
  static Future<FileAttachment?> pickFile({
    List<String>? allowedExtensions,
    int maxSizeMB = 50,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowedExtensions: allowedExtensions,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;
      final fileSizeBytes = file.size;

      // Validate file size
      if (fileSizeBytes > (maxSizeMB * 1024 * 1024)) {
        throw Exception('File size exceeds $maxSizeMB MB limit');
      }

      final fileType = _detectFileType(file.extension);
      final fileUrl = await _uploadFile(file);

      return FileAttachment(
        fileName: file.name,
        fileUrl: fileUrl,
        fileType: fileType,
        fileSizeBytes: fileSizeBytes,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Pick image file
  static Future<FileAttachment?> pickImageFile({int maxSizeMB = 10}) async {
    return pickFile(
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
      maxSizeMB: maxSizeMB,
    );
  }

  /// Pick PDF file
  static Future<FileAttachment?> pickPdfFile({int maxSizeMB = 50}) async {
    return pickFile(
      allowedExtensions: ['pdf'],
      maxSizeMB: maxSizeMB,
    );
  }

  /// Pick document file
  static Future<FileAttachment?> pickDocumentFile({int maxSizeMB = 50}) async {
    return pickFile(
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'txt',
        'ppt',
        'pptx',
        'xls',
        'xlsx'
      ],
      maxSizeMB: maxSizeMB,
    );
  }

  /// Detect file type from extension
  static FileType _detectFileType(String? extension) {
    if (extension == null) return FileType.other;

    final ext = extension.toLowerCase();
    if (FileService.allowedExtensions[FileType.pdf]!.contains(ext)) {
      return FileType.pdf;
    } else if (FileService.allowedExtensions[FileType.image]!.contains(ext)) {
      return FileType.image;
    } else if (FileService.allowedExtensions[FileType.document]!
        .contains(ext)) {
      return FileType.document;
    } else if (FileService.allowedExtensions[FileType.video]!.contains(ext)) {
      return FileType.video;
    } else if (FileService.allowedExtensions[FileType.audio]!.contains(ext)) {
      return FileType.audio;
    }
    return FileType.other;
  }

  /// Upload file and return URL
  /// In production, this would upload to cloud storage (Firebase Storage, AWS S3, etc.)
  static Future<String> _uploadFile(PlatformFile file) async {
    try {
      // For now, we'll use a local file path URL
      // In production, implement cloud storage upload here
      if (file.path != null && file.path!.isNotEmpty) {
        return 'file://${file.path}';
      }

      // Fallback for web
      if (file.name.isNotEmpty) {
        return 'storage://${uuid.v4()}/${file.name}';
      }

      throw Exception('Unable to process file');
    } catch (e) {
      rethrow;
    }
  }

  /// Open/view file
  static Future<void> openFile(String fileUrl) async {
    try {
      if (fileUrl.startsWith('file://')) {
        // Local file
        final filePath = fileUrl.replaceFirst('file://', '');
        final file = File(filePath);

        if (!await file.exists()) {
          throw Exception('File not found');
        }

        // Try to open with default handler
        if (!await launchUrl(
          Uri.file(filePath),
          mode: LaunchMode.externalApplication,
        )) {
          throw Exception('Could not open file');
        }
      } else if (fileUrl.startsWith('http://') ||
          fileUrl.startsWith('https://')) {
        // Remote URL
        if (!await launchUrl(Uri.parse(fileUrl))) {
          throw Exception('Could not open URL');
        }
      } else {
        throw Exception('Invalid file URL');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get formatted file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// Get file icon/type name
  static String getFileTypeName(FileType type) {
    switch (type) {
      case FileType.pdf:
        return 'PDF Document';
      case FileType.image:
        return 'Image';
      case FileType.document:
        return 'Document';
      case FileType.video:
        return 'Video';
      case FileType.audio:
        return 'Audio';
      case FileType.other:
        return 'File';
    }
  }

  /// Validate file for specific type
  static bool validateFileType(String fileName, FileType requiredType) {
    final extension = fileName.split('.').last.toLowerCase();
    return allowedExtensions[requiredType]?.contains(extension) ?? false;
  }

  /// Get downloadable URL (can be implemented based on backend)
  static Future<String?> getDownloadUrl(String fileUrl) async {
    try {
      // For local files, return the file URL directly
      if (fileUrl.startsWith('file://')) {
        return fileUrl;
      }

      // For cloud storage, implement proper download URL generation
      if (fileUrl.startsWith('storage://')) {
        // Implement cloud storage download URL logic
        return fileUrl;
      }

      return fileUrl;
    } catch (e) {
      return null;
    }
  }

  /// Check if file exists
  static Future<bool> fileExists(String fileUrl) async {
    try {
      if (fileUrl.startsWith('file://')) {
        final filePath = fileUrl.replaceFirst('file://', '');
        return await File(filePath).exists();
      }
      return true; // Assume remote files exist
    } catch (e) {
      return false;
    }
  }

  /// Delete file
  static Future<void> deleteFile(String fileUrl) async {
    try {
      if (fileUrl.startsWith('file://')) {
        final filePath = fileUrl.replaceFirst('file://', '');
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      // For cloud storage, implement deletion here
    } catch (e) {
      rethrow;
    }
  }
}
