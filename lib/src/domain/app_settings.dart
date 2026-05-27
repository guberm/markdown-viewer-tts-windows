import 'dart:convert';

import 'package:flutter/material.dart';

enum AppThemeMode { system, light, dark }

enum ReaderFontFamily { sans, serif, monospace }

extension AppThemeModeX on AppThemeMode {
  String get storageValue => name;

  String get label {
    switch (this) {
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }

  ThemeMode get flutterThemeMode {
    switch (this) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  static AppThemeMode fromStorageValue(String? raw) {
    return AppThemeMode.values.firstWhere(
      (value) => value.name == raw,
      orElse: () => AppThemeMode.system,
    );
  }
}

extension ReaderFontFamilyX on ReaderFontFamily {
  String get storageValue => name;

  String get label {
    switch (this) {
      case ReaderFontFamily.sans:
        return 'Sans';
      case ReaderFontFamily.serif:
        return 'Serif';
      case ReaderFontFamily.monospace:
        return 'Monospace';
    }
  }

  String get windowsFontFamily {
    switch (this) {
      case ReaderFontFamily.sans:
        return 'Segoe UI';
      case ReaderFontFamily.serif:
        return 'Georgia';
      case ReaderFontFamily.monospace:
        return 'Consolas';
    }
  }

  static ReaderFontFamily fromStorageValue(String? raw) {
    return ReaderFontFamily.values.firstWhere(
      (value) => value.name == raw,
      orElse: () => ReaderFontFamily.sans,
    );
  }
}

class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.fontFamily,
    required this.fontSize,
    required this.speechRate,
  });

  const AppSettings.defaults()
      : themeMode = AppThemeMode.system,
        fontFamily = ReaderFontFamily.sans,
        fontSize = 18,
        speechRate = 0.45;

  final AppThemeMode themeMode;
  final ReaderFontFamily fontFamily;
  final double fontSize;
  final double speechRate;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    ReaderFontFamily? fontFamily,
    double? fontSize,
    double? speechRate,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      speechRate: speechRate ?? this.speechRate,
    );
  }

  String toJson() {
    return jsonEncode(<String, dynamic>{
      'themeMode': themeMode.storageValue,
      'fontFamily': fontFamily.storageValue,
      'fontSize': fontSize,
      'speechRate': speechRate,
    });
  }

  factory AppSettings.fromJson(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const AppSettings.defaults();
    }

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return AppSettings(
        themeMode: AppThemeModeX.fromStorageValue(map['themeMode'] as String?),
        fontFamily: ReaderFontFamilyX.fromStorageValue(
          map['fontFamily'] as String?,
        ),
        fontSize: (map['fontSize'] as num?)?.toDouble() ?? 18,
        speechRate: (map['speechRate'] as num?)?.toDouble() ?? 0.45,
      );
    } catch (_) {
      return const AppSettings.defaults();
    }
  }
}
