import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_viewer_tts_windows/main.dart';

void main() {
  Future<File> createTempFile(String name) async {
    final dir = await Directory.systemTemp.createTemp('md_viewer_path_test_');
    final file = File('${dir.path}${Platform.pathSeparator}$name');
    await file.writeAsString('# test');
    return file;
  }

  test('resolveStartupDocumentPath returns supported existing markdown file', () async {
    final file = await createTempFile('demo.md');

    final result = resolveStartupDocumentPath(<String>['--verbose', file.path]);

    expect(result, file.path);
  });

  test('resolveStartupDocumentPath ignores unsupported or missing files', () async {
    final txt = await createTempFile('notes.txt');
    final missing = '${txt.parent.path}${Platform.pathSeparator}missing.md';
    final unsupported = await createTempFile('image.png');

    final result = resolveStartupDocumentPath(<String>[
      '--flag',
      missing,
      unsupported.path,
      txt.path,
    ]);

    expect(result, txt.path);
  });

  test('resolveStartupDocumentPath returns null when nothing valid is passed', () {
    final result = resolveStartupDocumentPath(<String>[
      '',
      '--flag',
      '/definitely/not/found.md',
      'C:/fake/path/image.pdf',
    ]);

    expect(result, isNull);
  });
}
