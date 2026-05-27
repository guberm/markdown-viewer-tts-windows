import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_settings.dart';
import '../domain/document_state.dart';

class AppPersistence {
  AppPersistence(this.preferences);

  final SharedPreferences preferences;

  static const String _settingsKey = 'app_settings_json';
  static const String _documentStateKey = 'document_state_json';

  AppSettings loadSettings() {
    return AppSettings.fromJson(preferences.getString(_settingsKey));
  }

  Future<void> saveSettings(AppSettings settings) async {
    await preferences.setString(_settingsKey, settings.toJson());
  }

  DocumentStateStore loadDocumentState() {
    return DocumentStateStore.fromJson(preferences.getString(_documentStateKey));
  }

  Future<void> saveDocumentState(DocumentStateStore state) async {
    await preferences.setString(_documentStateKey, state.toJson());
  }
}
