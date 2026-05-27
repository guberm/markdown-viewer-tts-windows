import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

class PickedDocument {
  const PickedDocument({
    required this.path,
    required this.title,
    required this.markdown,
  });

  final String path;
  final String title;
  final String markdown;
}

class DocumentService {
  Future<PickedDocument?> pickDocument() async {
    final result = await FilePicker.pickFiles(
      dialogTitle: 'Open Markdown document',
      type: FileType.custom,
      allowedExtensions: <String>['md', 'markdown', 'txt'],
      lockParentWindow: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final path = result.files.first.path;
    if (path == null || path.trim().isEmpty) {
      return null;
    }

    return openDocument(path);
  }

  Future<PickedDocument> openDocument(String path) async {
    final file = File(path);
    final markdown = await file.readAsString();
    return PickedDocument(
      path: path,
      title: p.basename(path),
      markdown: markdown,
    );
  }
}
