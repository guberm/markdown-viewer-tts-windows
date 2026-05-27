import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:markdown_viewer_tts_windows/main.dart';
import 'package:markdown_viewer_tts_windows/src/domain/app_settings.dart';

void main() {
  testWidgets('uses dark markdown text color when dark mode is enabled', (
    WidgetTester tester,
  ) async {
    const darkSettings = AppSettings(
      themeMode: AppThemeMode.dark,
      fontFamily: ReaderFontFamily.sans,
      fontSize: 18,
      speechRate: 0.45,
    );

    SharedPreferences.setMockInitialValues(<String, Object>{
      'app_settings_json': darkSettings.toJson(),
    });

    await tester.pumpWidget(const MarkdownViewerApp());
    await tester.pumpAndSettle();

    final markdown = tester.widget<Markdown>(find.byType(Markdown));
    final expectedTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      fontFamily: darkSettings.fontFamily.windowsFontFamily,
    );

    expect(markdown.styleSheet?.p?.color, expectedTheme.colorScheme.onSurface);
  });
}
