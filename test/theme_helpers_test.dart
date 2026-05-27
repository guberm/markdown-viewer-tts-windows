import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:markdown_viewer_tts_windows/src/domain/app_settings.dart';
import 'package:markdown_viewer_tts_windows/src/ui/theme_helpers.dart';

void main() {
  testWidgets('dark markdown paragraph text uses dark theme foreground color', (
    WidgetTester tester,
  ) async {
    const settings = AppSettings.defaults();
    late ThemeData theme;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(
          brightness: Brightness.dark,
          settings: settings,
        ),
        home: Builder(
          builder: (context) {
            theme = Theme.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final styleSheet = buildMarkdownStyleSheet(theme, settings);

    expect(styleSheet.p?.color, theme.colorScheme.onSurface);
  });

  testWidgets('light markdown paragraph text uses light theme foreground color', (
    WidgetTester tester,
  ) async {
    const settings = AppSettings.defaults();
    late ThemeData theme;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(
          brightness: Brightness.light,
          settings: settings,
        ),
        home: Builder(
          builder: (context) {
            theme = Theme.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final styleSheet = buildMarkdownStyleSheet(theme, settings);

    expect(styleSheet.p?.color, theme.colorScheme.onSurface);
  });
}
