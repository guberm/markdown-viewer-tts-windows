import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'src/domain/app_settings.dart';
import 'src/domain/document_state.dart';
import 'src/domain/markdown_processing.dart';
import 'src/services/app_persistence.dart';
import 'src/services/document_service.dart';
import 'src/services/speech_service.dart';
import 'src/ui/theme_helpers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(MarkdownViewerApp(preferences: preferences));
}

class MarkdownViewerApp extends StatefulWidget {
  const MarkdownViewerApp({super.key, this.preferences});

  final SharedPreferences? preferences;

  @override
  State<MarkdownViewerApp> createState() => _MarkdownViewerAppState();
}

class _MarkdownViewerAppState extends State<MarkdownViewerApp> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DocumentService _documentService = DocumentService();
  final SpeechService _speechService = SpeechService();

  AppPersistence? _persistence;
  AppSettings _settings = const AppSettings.defaults();
  DocumentStateStore _documentState = DocumentStateStore();

  PickedDocument? _document;
  List<String> _tags = const <String>[];
  String? _selectedTag;
  bool _isSpeaking = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_persistScrollPosition);

    if (widget.preferences != null) {
      _applyPersistence(AppPersistence(widget.preferences!));
      unawaited(_restoreLastDocument());
    } else {
      unawaited(_initializeAsync());
    }
  }

  Future<void> _initializeAsync() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }

    _applyPersistence(AppPersistence(preferences));
    await _restoreLastDocument();
  }

  void _applyPersistence(AppPersistence persistence) {
    setState(() {
      _persistence = persistence;
      _settings = persistence.loadSettings();
      _documentState = persistence.loadDocumentState();
      _initialized = true;
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_persistScrollPosition)
      ..dispose();
    unawaited(_speechService.stop());
    super.dispose();
  }

  Future<void> _restoreLastDocument() async {
    final recent = _documentState.getMostRecentDocument();
    if (recent == null) {
      return;
    }
    await _openDocumentPath(recent.path, reopen: true);
  }

  Future<void> _openFromPicker() async {
    final document = await _documentService.pickDocument();
    if (document == null) {
      return;
    }
    await _setDocument(document, recordOpen: true);
  }

  Future<void> _openRecentDocument(RecentDocument recent) async {
    await _openDocumentPath(recent.path, reopen: true);
  }

  Future<void> _openDocumentPath(String path, {bool reopen = false}) async {
    try {
      final document = await _documentService.openDocument(path);
      await _setDocument(document, recordOpen: !reopen || _document?.path != path);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open document: $error')),
      );
    }
  }

  Future<void> _setDocument(
    PickedDocument document, {
    required bool recordOpen,
  }) async {
    if (recordOpen) {
      _documentState.recordOpen(document.path, document.title);
    }

    final tags = extractTags(document.markdown);
    final selectedTag = _selectedTag != null && tags.contains(_selectedTag)
        ? _selectedTag
        : null;

    setState(() {
      _document = document;
      _tags = tags;
      _selectedTag = selectedTag;
    });

    await _persistDocumentState();
    unawaited(_restoreScrollOffsetFor(document.path));
  }

  Future<void> _restoreScrollOffsetFor(String path) async {
    await Future<void>.delayed(const Duration(milliseconds: 60));
    if (!_scrollController.hasClients) {
      return;
    }

    final savedOffset = _documentState.getReadingPosition(path) ?? 0;
    final maxExtent = _scrollController.position.maxScrollExtent;
    final targetOffset = savedOffset.clamp(0, maxExtent).toDouble();
    _scrollController.jumpTo(targetOffset);
  }

  void _persistScrollPosition() {
    final path = _document?.path;
    if (path == null || !_scrollController.hasClients) {
      return;
    }

    _documentState.saveReadingPosition(path, _scrollController.offset);
    unawaited(_persistDocumentState());
  }

  Future<void> _persistDocumentState() async {
    final persistence = _persistence;
    if (persistence == null) {
      return;
    }
    await persistence.saveDocumentState(_documentState);
  }

  Future<void> _persistSettings() async {
    final persistence = _persistence;
    if (persistence == null) {
      return;
    }
    await persistence.saveSettings(_settings);
  }

  Future<void> _toggleSpeech() async {
    final document = _document;
    if (document == null) {
      return;
    }

    if (_isSpeaking) {
      await _speechService.stop();
      if (!mounted) {
        return;
      }
      setState(() {
        _isSpeaking = false;
      });
      return;
    }

    setState(() {
      _isSpeaking = true;
    });

    final markdown = _selectedTag == null
        ? document.markdown
        : filterMarkdownByTag(document.markdown, _selectedTag!);

    try {
      await _speechService.speakMarkdown(
        markdown: markdown,
        speechRate: _settings.speechRate,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
    }
  }

  Future<void> _openLink(String text, String? href, String title) async {
    final raw = href?.trim();
    if (raw == null || raw.isEmpty) {
      return;
    }

    final uri = Uri.tryParse(raw);
    if (uri == null) {
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String get _visibleMarkdown {
    final markdown = _document?.markdown;
    if (markdown == null) {
      return _sampleMarkdown;
    }
    if (_selectedTag == null) {
      return markdown;
    }
    return filterMarkdownByTag(markdown, _selectedTag!);
  }

  @override
  Widget build(BuildContext context) {
    final lightTheme = buildAppTheme(
      brightness: Brightness.light,
      settings: _settings,
    );
    final darkTheme = buildAppTheme(
      brightness: Brightness.dark,
      settings: _settings,
    );

    return MaterialApp(
      title: 'Markdown Viewer TTS',
      themeMode: _settings.themeMode.flutterThemeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: !_initialized
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : Builder(
              builder: (context) {
                final theme = Theme.of(context);
                return Scaffold(
                  key: _scaffoldKey,
                  endDrawer: _buildSettingsDrawer(context),
                  appBar: AppBar(
                    title: const Text('Markdown Viewer TTS'),
                    actions: <Widget>[
                      IconButton(
                        tooltip: 'Reopen last document',
                        onPressed: _documentState.getMostRecentDocument() == null
                            ? null
                            : () => _openRecentDocument(
                                  _documentState.getMostRecentDocument()!,
                                ),
                        icon: const Icon(Icons.history),
                      ),
                      IconButton(
                        tooltip: 'Settings',
                        onPressed: () =>
                            _scaffoldKey.currentState?.openEndDrawer(),
                        icon: const Icon(Icons.tune),
                      ),
                    ],
                  ),
                  body: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            FilledButton.icon(
                              onPressed: _openFromPicker,
                              icon: const Icon(Icons.folder_open),
                              label: const Text('Open file'),
                            ),
                            FilledButton.tonalIcon(
                              onPressed:
                                  _document == null ? null : _toggleSpeech,
                              icon: Icon(
                                _isSpeaking
                                    ? Icons.stop
                                    : Icons.record_voice_over,
                              ),
                              label: Text(
                                _isSpeaking ? 'Stop reading' : 'Read aloud',
                              ),
                            ),
                            ActionChip(
                              label: const Text('All tags'),
                              avatar: _selectedTag == null
                                  ? const Icon(Icons.check, size: 18)
                                  : null,
                              onPressed: () {
                                setState(() {
                                  _selectedTag = null;
                                });
                              },
                            ),
                            ..._tags.map(
                              (tag) => FilterChip(
                                label: Text('#$tag'),
                                selected: _selectedTag == tag,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedTag =
                                        _selectedTag == tag ? null : tag;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_document != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _document!.title,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Markdown(
                          data: _visibleMarkdown,
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          selectable: true,
                          onTapLink: _openLink,
                          styleSheet: buildMarkdownStyleSheet(
                            theme,
                            _settings,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Drawer _buildSettingsDrawer(BuildContext context) {
    final recentDocuments = _documentState.recentDocuments;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            DropdownButtonFormField<AppThemeMode>(
              initialValue: _settings.themeMode,
              decoration: const InputDecoration(labelText: 'Theme'),
              items: AppThemeMode.values
                  .map(
                    (mode) => DropdownMenuItem<AppThemeMode>(
                      value: mode,
                      child: Text(mode.label),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) async {
                if (value == null) {
                  return;
                }
                setState(() {
                  _settings = _settings.copyWith(themeMode: value);
                });
                await _persistSettings();
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ReaderFontFamily>(
              initialValue: _settings.fontFamily,
              decoration: const InputDecoration(labelText: 'Font family'),
              items: ReaderFontFamily.values
                  .map(
                    (family) => DropdownMenuItem<ReaderFontFamily>(
                      value: family,
                      child: Text(family.label),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) async {
                if (value == null) {
                  return;
                }
                setState(() {
                  _settings = _settings.copyWith(fontFamily: value);
                });
                await _persistSettings();
              },
            ),
            const SizedBox(height: 16),
            Text('Font size: ${_settings.fontSize.toStringAsFixed(0)}'),
            Slider(
              value: _settings.fontSize,
              min: 12,
              max: 30,
              divisions: 18,
              label: _settings.fontSize.toStringAsFixed(0),
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(fontSize: value);
                });
              },
              onChangeEnd: (_) {
                unawaited(_persistSettings());
              },
            ),
            const SizedBox(height: 16),
            Text('Speech rate: ${_settings.speechRate.toStringAsFixed(2)}'),
            Slider(
              value: _settings.speechRate,
              min: 0.1,
              max: 1.0,
              divisions: 18,
              label: _settings.speechRate.toStringAsFixed(2),
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(speechRate: value);
                });
              },
              onChangeEnd: (_) {
                unawaited(_persistSettings());
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Recent documents',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (recentDocuments.isEmpty)
              const Text('No recent documents yet.')
            else
              ...recentDocuments.map(
                (doc) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(doc.title),
                  subtitle: Text(
                    doc.path,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: doc.lastScrollOffset != null
                      ? Text('${doc.lastScrollOffset!.round()} px')
                      : null,
                  onTap: () {
                    Navigator.of(context).maybePop();
                    unawaited(_openRecentDocument(doc));
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

const String _sampleMarkdown = '''
---
tags: [demo, windows, markdown, tts]
---

# Markdown Viewer TTS

Open `.md`, `.markdown`, or `.txt` files, read them aloud, and filter by tags.

| Feature | Status |
|---|---|
| Markdown rendering | ready |
| Tag filters | ready |
| Text to speech | ready |
| Recent documents | ready |

Inline tags: #demo #windows #tts
''';
