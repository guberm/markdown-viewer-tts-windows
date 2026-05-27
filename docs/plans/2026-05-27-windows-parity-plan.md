# Markdown Viewer TTS Windows Implementation Plan

> For Hermes: implement with strict TDD - failing tests first, then minimal code, then verification.

**Goal:** Build a Flutter Windows desktop app in a separate repo that matches the useful functionality of the Android/Kotlin markdown-viewer-tts project.

**Architecture:** Keep testable behavior in plain Dart domain/services classes and keep Flutter widgets thin. Persist settings/recent documents with shared_preferences, render markdown with flutter_markdown, open files with file_picker, speak text with flutter_tts, and restore scroll position via a document state store.

**Tech Stack:** Flutter desktop (Windows), flutter_markdown, file_picker, shared_preferences, flutter_tts, url_launcher.

---

### Task 1: Define and test domain behavior
- Add failing tests for document history ordering/limit/resume state.
- Add failing tests for markdown tag extraction/filtering/markdown-to-speech cleanup.
- Add a failing widget smoke test for the core Windows UI shell.

### Task 2: Implement plain Dart domain layer
- Implement document state model/store.
- Implement markdown processing helpers.
- Implement app settings/theme model.

### Task 3: Implement persistence and services
- Implement shared_preferences-backed state/settings persistence.
- Implement file open and TTS service wrappers.

### Task 4: Implement Flutter UI
- Build a Windows-focused reader screen with app bar, tag chips, markdown view, drawer/settings, recent docs, resume, and controls.
- Wire open file, reopen last, resume position, theme, font, and speech controls.

### Task 5: Verify and publish
- Run flutter test, flutter analyze, and a Windows build.
- Initialize git, create GitHub repo markdown-viewer-tts-windows, push main, and verify remote.
- Update README with features, build instructions, and Windows behavior notes.
