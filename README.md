# Markdown Viewer TTS for Windows

Flutter Windows desktop app with Markdown rendering, tag filtering, recent files, reading-position restore, and built-in text-to-speech.

GitHub repo name: `markdown-viewer-tts-windows`

## Features

- Open `.md`, `.markdown`, and `.txt` files
- Render Markdown, including tables and links
- Extract tags from:
  - YAML frontmatter
  - inline hashtags like `#demo`
- Filter visible content by tag
- Read the current document aloud with Windows TTS via `flutter_tts`
- Adjust speech rate
- Switch theme mode:
  - System
  - Light
  - Dark
- Switch font family:
  - Sans
  - Serif
  - Monospace
- Adjust font size
- Persist settings with `SharedPreferences`
- Keep recent documents
- Reopen the last document on startup
- Restore reading position per document

## Tech stack

- Flutter desktop
- Windows target
- `flutter_markdown`
- `flutter_tts`
- `file_picker`
- `shared_preferences`
- `url_launcher`

## Current status

Implemented and verified locally on Linux host:

- `flutter analyze` - passed
- `flutter test` - passed

Note: `flutter build windows` must be run on a Windows host with Flutter installed.

## Run locally

```bash
flutter pub get
flutter run -d windows
```

## Tests

```bash
flutter test
```

## Project structure

- `lib/main.dart` - app shell and UI
- `lib/src/domain/app_settings.dart` - persisted reader settings
- `lib/src/domain/document_state.dart` - recent docs and reading position state
- `lib/src/domain/markdown_processing.dart` - tag extraction, filtering, speech text prep
- `lib/src/services/document_service.dart` - file open/read helpers
- `lib/src/services/speech_service.dart` - TTS integration
- `lib/src/services/app_persistence.dart` - shared preferences persistence
- `test/` - widget and domain tests

## Planned next improvements

- Better section-aware tag filtering instead of line-based filtering
- File association / open-with integration on Windows
- Better TTS voice selection UI
- Native packaging/release artifacts from Windows CI or Windows host
