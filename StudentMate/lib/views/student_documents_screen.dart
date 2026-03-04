import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' show where;
import 'package:open_filex/open_filex.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:uuid/uuid.dart';

import '../services/auth_service.dart';
import '../services/mongodb_service.dart';
import '../services/offline_cache_service.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_widgets.dart';

// ── Folders screen ───────────────────────────────────────────────────────────

class StudentDocumentsScreen extends StatefulWidget {
  const StudentDocumentsScreen({Key? key}) : super(key: key);

  @override
  State<StudentDocumentsScreen> createState() => _StudentDocumentsScreenState();
}

class _StudentDocumentsScreenState extends State<StudentDocumentsScreen> {
  final AuthService _auth = AuthService();
  List<Map<String, dynamic>> _folders = [];
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = _auth.getCurrentUser()?.id;
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    if (_userId == null) return;
    setState(() => _isLoading = true);
    final cacheKey = 'documents.folders.${_userId!}';
    try {
      final db = await MongoDBService.getDb();
      final docs = await db
          .collection('doc_folders')
          .find(where.eq('userId', _userId).sortBy('createdAt'))
          .toList();
      await OfflineCacheService.saveList(
        cacheKey,
        docs.map((e) => Map<String, dynamic>.from(e)).toList(),
      );
      if (!mounted) return;
      setState(() {
        _folders = docs.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (_) {
      final cached = await OfflineCacheService.readList(cacheKey);
      if (!mounted) return;
      setState(() {
        _folders = cached;
        _isLoading = false;
      });
    }
  }

  void _showCreateFolderDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title:
            const Text('New Folder', style: TextStyle(color: Colors.black87)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.black87),
          decoration: const InputDecoration(
            labelText: 'Folder name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              try {
                final db = await MongoDBService.getDb();
                await db.collection('doc_folders').insert({
                  '_id': const Uuid().v4(),
                  'userId': _userId,
                  'name': name,
                  'createdAt': DateTime.now().toIso8601String(),
                });
                if (!mounted) return;
                Navigator.pop(ctx);
                await _loadFolders();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFolder(String folderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Folder',
            style: TextStyle(color: Colors.black87)),
        content: const Text(
            'This will permanently delete the folder and all documents inside it.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.errorColor))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final db = await MongoDBService.getDb();
      await db
          .collection('student_documents')
          .remove(where.eq('folderId', folderId));
      await db.collection('doc_folders').remove(where.eq('_id', folderId));
      await _loadFolders();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppLogo(),
        title: const Text('My Documents'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateFolderDialog,
        backgroundColor: AppColors.purpleDark,
        foregroundColor: Colors.white,
        tooltip: 'New Folder',
        child: const Icon(Icons.create_new_folder),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _folders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.folder_open,
                          size: 72, color: AppColors.purpleDark),
                      const SizedBox(height: AppSpacing.md),
                      Text('No folders yet',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.sm),
                      Text('Tap + to create a folder',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: _folders.length,
                  itemBuilder: (context, index) {
                    final folder = _folders[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: GradientCard(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FolderDocumentsScreen(
                              folderId: folder['_id'] as String,
                              folderName: folder['name'] as String,
                              userId: _userId!,
                            ),
                          ),
                        ).then((_) => _loadFolders()),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                              child: const Icon(Icons.folder,
                                  color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                folder['name'] as String,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: AppColors.errorColor),
                              onPressed: () =>
                                  _deleteFolder(folder['_id'] as String),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                size: 14, color: AppColors.textSecondaryColor),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// ── Documents inside a folder ────────────────────────────────────────────────

class FolderDocumentsScreen extends StatefulWidget {
  final String folderId;
  final String folderName;
  final String userId;

  const FolderDocumentsScreen({
    Key? key,
    required this.folderId,
    required this.folderName,
    required this.userId,
  }) : super(key: key);

  @override
  State<FolderDocumentsScreen> createState() => _FolderDocumentsScreenState();
}

class _FolderDocumentsScreenState extends State<FolderDocumentsScreen> {
  List<Map<String, dynamic>> _documents = [];
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);
    final cacheKey = 'documents.items.${widget.userId}.${widget.folderId}';
    try {
      final db = await MongoDBService.getDb();
      final docs = await db
          .collection('student_documents')
          .find(where
              .eq('folderId', widget.folderId)
              .sortBy('createdAt', descending: true))
          .toList();
      await OfflineCacheService.saveList(
        cacheKey,
        docs.map((e) => Map<String, dynamic>.from(e)).toList(),
      );
      if (!mounted) return;
      setState(() {
        _documents = docs.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (_) {
      final cached = await OfflineCacheService.readList(cacheKey);
      if (!mounted) return;
      setState(() {
        _documents = cached;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
      withReadStream: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;

    List<int>? fileBytes = file.bytes;
    if (fileBytes == null && file.readStream != null) {
      final collected = <int>[];
      await for (final chunk in file.readStream!) {
        collected.addAll(chunk);
      }
      if (collected.isNotEmpty) {
        fileBytes = collected;
      }
    }

    if (fileBytes == null && file.path != null && file.path!.isNotEmpty) {
      try {
        fileBytes = await File(file.path!).readAsBytes();
      } catch (_) {
        // Some providers do not expose directly readable paths.
      }
    }

    if (fileBytes == null || fileBytes.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not read selected file')),
        );
      }
      return;
    }

    // 5 MB safety limit
    if (fileBytes.length > 5 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('File too large. Maximum allowed size is 5 MB.')),
        );
      }
      return;
    }

    setState(() => _isUploading = true);
    try {
      final base64Str = base64Encode(fileBytes);
      final db = await MongoDBService.getDb();
      await db.collection('student_documents').insert({
        '_id': const Uuid().v4(),
        'userId': widget.userId,
        'folderId': widget.folderId,
        'fileName': file.name,
        'fileExtension': file.extension ?? '',
        'fileBase64': base64Str,
        'fileSize': fileBytes.length,
        'createdAt': DateTime.now().toIso8601String(),
      });
      await _loadDocuments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${file.name}" saved!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
    if (mounted) setState(() => _isUploading = false);
  }

  Future<void> _deleteDocument(String docId) async {
    try {
      final db = await MongoDBService.getDb();
      await db.collection('student_documents').remove(where.eq('_id', docId));
      await _loadDocuments();
    } catch (_) {}
  }

  bool _isImage(String? ext) =>
      ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext?.toLowerCase());

  bool _isPdf(String? ext) => (ext ?? '').toLowerCase() == 'pdf';

  bool _isTextLike(String? ext) {
    const textExt = {
      'txt',
      'json',
      'csv',
      'md',
      'log',
      'yaml',
      'yml',
      'xml',
      'html',
      'htm'
    };
    return textExt.contains((ext ?? '').toLowerCase());
  }

  IconData _fileIcon(String? ext) {
    switch (ext?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Uint8List? _extractDocumentBytes(Map<String, dynamic> doc) {
    try {
      final raw = doc['fileBase64'];

      if (raw is Uint8List) {
        return raw;
      }

      if (raw is List<int>) {
        return Uint8List.fromList(raw);
      }

      if (raw is String && raw.isNotEmpty) {
        final normalized =
            raw.contains(';base64,') ? raw.split(';base64,').last : raw;
        return base64Decode(normalized);
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  void _viewImage(BuildContext context, Map<String, dynamic> doc) {
    final bytes = _extractDocumentBytes(doc);
    if (bytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image preview is unavailable')),
        );
      }
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            leading: const AppLogo(),
            title: Text(doc['fileName'] as String? ?? ''),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          backgroundColor: Colors.black,
          body: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4,
            child: Center(child: Image.memory(bytes)),
          ),
        ),
      ),
    );
  }

  Future<void> _openDocument(Map<String, dynamic> doc) async {
    try {
      final bytes = _extractDocumentBytes(doc);
      if (bytes == null || bytes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File data is unavailable')),
          );
        }
        return;
      }

      final name = (doc['fileName'] as String? ?? 'document').trim();
      final ext = (doc['fileExtension'] as String? ?? '').trim();
      final safeName = name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final fileName = safeName.contains('.')
          ? safeName
          : (ext.isNotEmpty ? '$safeName.$ext' : safeName);

      final tempPath =
          '${Directory.systemTemp.path}${Platform.pathSeparator}$fileName';
      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(bytes, flush: true);

      final result = await OpenFilex.open(tempFile.path);

      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message.isNotEmpty
                ? result.message
                : 'Could not open this file on device'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening file: $e')),
        );
      }
    }
  }

  void _showFilePreview(Map<String, dynamic> doc) {
    final ext = doc['fileExtension'] as String?;
    final isImg = _isImage(ext);
    final isPdf = _isPdf(ext);
    final isText = _isTextLike(ext);
    final bytes = _extractDocumentBytes(doc);
    final fileName = doc['fileName'] as String? ?? 'Unknown';
    final fileSize = doc['fileSize'] as int? ?? 0;

    if (bytes == null || bytes.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _UnsupportedPreviewScreen(
            fileName: fileName,
            extension: ext,
            fileSize: fileSize,
            message: 'This file has no readable content stored.',
            onTryOpenExternal: () => _openDocument(doc),
          ),
        ),
      );
      return;
    }

    if (isImg) {
      _viewImage(context, doc);
      return;
    }

    if (isPdf) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _PdfPreviewScreen(
            fileName: doc['fileName'] as String? ?? 'PDF Preview',
            bytes: bytes,
          ),
        ),
      );
      return;
    }

    if (isText) {
      final textContent = utf8.decode(bytes, allowMalformed: true);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _TextPreviewScreen(
            fileName: doc['fileName'] as String? ?? 'Text Preview',
            content: textContent,
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _UnsupportedPreviewScreen(
          fileName: fileName,
          extension: ext,
          fileSize: fileSize,
          message:
              'In-app preview is not available for this file type yet. Try opening it with another app.',
          onTryOpenExternal: () => _openDocument(doc),
        ),
      ),
    );
  }

  Future<void> _renameDocument(Map<String, dynamic> doc) async {
    final currentName = doc['fileName'] as String? ?? '';
    final ctrl = TextEditingController(text: currentName);

    final nextName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename Document'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'File name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, ctrl.text.trim()),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (nextName == null || nextName.isEmpty || nextName == currentName) return;

    try {
      final db = await MongoDBService.getDb();
      await db.collection('student_documents').updateOne(
        where.eq('_id', doc['_id']),
        {
          r'$set': {'fileName': nextName}
        },
      );

      await _loadDocuments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document renamed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rename failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppLogo(),
        title: Text(widget.folderName),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isUploading ? null : _pickAndUpload,
        backgroundColor: AppColors.purpleDark,
        foregroundColor: Colors.white,
        tooltip: 'Add Document',
        child: _isUploading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _documents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.upload_file,
                          size: 72, color: AppColors.purpleDark),
                      const SizedBox(height: AppSpacing.md),
                      Text('No documents yet',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.sm),
                      Text('Tap + to add a document',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: _documents.length,
                  itemBuilder: (context, index) {
                    final doc = _documents[index];
                    final ext = doc['fileExtension'] as String?;
                    final fileName = doc['fileName'] as String? ?? 'Unknown';
                    final fileSize = doc['fileSize'] as int? ?? 0;
                    final isImg = _isImage(ext);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: GradientCard(
                        onTap: () => _showFilePreview(doc),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: isImg
                                  ? Image.memory(
                                      _extractDocumentBytes(doc) ??
                                          Uint8List(0),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.broken_image_outlined,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    )
                                  : Icon(_fileIcon(ext),
                                      color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fileName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _formatSize(fileSize),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isImg ? Icons.zoom_in : Icons.remove_red_eye,
                                color: AppColors.purpleDark,
                              ),
                              tooltip: 'Preview',
                              onPressed: () => _showFilePreview(doc),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  color: AppColors.purpleDark),
                              tooltip: 'Rename',
                              onPressed: () => _renameDocument(doc),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: AppColors.errorColor),
                              onPressed: () =>
                                  _deleteDocument(doc['_id'] as String),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _PdfPreviewScreen extends StatelessWidget {
  final String fileName;
  final Uint8List bytes;

  const _PdfPreviewScreen({
    required this.fileName,
    required this.bytes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppLogo(),
        title: Text(fileName),
        centerTitle: true,
      ),
      body: SfPdfViewer.memory(bytes),
    );
  }
}

class _TextPreviewScreen extends StatelessWidget {
  final String fileName;
  final String content;

  const _TextPreviewScreen({
    required this.fileName,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppLogo(),
        title: Text(fileName),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SelectableText(
          content.isEmpty ? 'No preview content available.' : content,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class _UnsupportedPreviewScreen extends StatelessWidget {
  final String fileName;
  final String? extension;
  final int fileSize;
  final String message;
  final VoidCallback onTryOpenExternal;

  const _UnsupportedPreviewScreen({
    required this.fileName,
    required this.extension,
    required this.fileSize,
    required this.message,
    required this.onTryOpenExternal,
  });

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final extText = (extension == null || extension!.isEmpty)
        ? 'Unknown'
        : extension!.toUpperCase();

    return Scaffold(
      appBar: AppBar(
        leading: const AppLogo(),
        title: Text(fileName),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fileName,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Type: $extText'),
            Text('Size: ${_formatSize(fileSize)}'),
            const SizedBox(height: AppSpacing.lg),
            Text(message),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onTryOpenExternal,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Try Open In External App'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
