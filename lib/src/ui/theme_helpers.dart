import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../domain/app_settings.dart';

ThemeData buildAppTheme({
  required Brightness brightness,
  required AppSettings settings,
}) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: brightness,
    ),
    useMaterial3: true,
    fontFamily: settings.fontFamily.windowsFontFamily,
  );
}

MarkdownStyleSheet buildMarkdownStyleSheet(
  ThemeData theme,
  AppSettings settings,
) {
  final foreground = theme.colorScheme.onSurface;

  TextStyle? sized(TextStyle? style, {String? fontFamily, double? height}) {
    return style?.copyWith(
      color: foreground,
      fontSize: settings.fontSize,
      fontFamily: fontFamily,
      height: height,
    );
  }

  return MarkdownStyleSheet.fromTheme(theme).copyWith(
    p: sized(theme.textTheme.bodyLarge, height: 1.5),
    code: theme.textTheme.bodyMedium?.copyWith(
      color: foreground,
      fontSize: settings.fontSize - 1,
      fontFamily: ReaderFontFamily.monospace.windowsFontFamily,
    ),
    h1: sized(theme.textTheme.headlineMedium),
    h2: sized(theme.textTheme.headlineSmall),
    h3: sized(theme.textTheme.titleLarge),
    h4: sized(theme.textTheme.titleMedium),
    h5: sized(theme.textTheme.titleSmall),
    h6: sized(theme.textTheme.bodyLarge),
    tableHead: sized(theme.textTheme.titleSmall),
    tableBody: sized(theme.textTheme.bodyMedium),
    blockquote: sized(theme.textTheme.bodyLarge, height: 1.5),
    em: sized(theme.textTheme.bodyLarge, height: 1.5),
    strong: sized(theme.textTheme.bodyLarge, height: 1.5),
    listBullet: theme.textTheme.bodyLarge?.copyWith(color: foreground),
    a: theme.textTheme.bodyLarge?.copyWith(
      color: theme.colorScheme.primary,
      fontSize: settings.fontSize,
      height: 1.5,
    ),
  );
}
