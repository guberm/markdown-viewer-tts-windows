import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_viewer_tts_windows/src/domain/app_settings.dart';

void main() {
  test('defaults match expected reader settings', () {
    const settings = AppSettings.defaults();

    expect(settings.themeMode, AppThemeMode.system);
    expect(settings.fontFamily, ReaderFontFamily.sans);
    expect(settings.fontSize, 18);
    expect(settings.speechRate, 0.45);
  });

  test('round-trips settings through json', () {
    const settings = AppSettings(
      themeMode: AppThemeMode.dark,
      fontFamily: ReaderFontFamily.monospace,
      fontSize: 22,
      speechRate: 0.7,
    );

    final restored = AppSettings.fromJson(settings.toJson());

    expect(restored.themeMode, AppThemeMode.dark);
    expect(restored.fontFamily, ReaderFontFamily.monospace);
    expect(restored.fontSize, 22);
    expect(restored.speechRate, 0.7);
  });
}