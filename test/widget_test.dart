// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:markdown_viewer_tts_windows/main.dart';

void main() {
  testWidgets('renders markdown viewer shell', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const MarkdownViewerApp());
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Markdown Viewer TTS'), findsOneWidget);
    expect(find.text('Open file'), findsOneWidget);
    expect(find.text('Read aloud'), findsOneWidget);
    expect(find.text('All tags'), findsOneWidget);
  });
}
