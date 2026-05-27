import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_viewer_tts_windows/src/domain/markdown_processing.dart';

void main() {
  test('extracts tags from frontmatter and hashtags', () {
    const markdown = '''
---
tags: [demo, windows]
---

# Title

Hello #tts #reader
''';

    expect(extractTags(markdown), ['demo', 'windows', 'tts', 'reader']);
  });

  test('extracts multiline frontmatter tags', () {
    const markdown = '''
---
tags:
  - alpha
  - beta
---
''';

    expect(extractTags(markdown), ['alpha', 'beta']);
  });

  test('filters markdown by tag and falls back to original when no matches exist', () {
    const markdown = 'first #alpha\nsecond #beta\nthird';

    expect(filterMarkdownByTag(markdown, 'beta'), 'second #beta');
    expect(filterMarkdownByTag(markdown, 'missing'), markdown);
  });

  test('strips markdown syntax for speech output', () {
    const markdown = '''
# Header
Paragraph with [link](https://example.com) and `code`.

```dart
print("hello");
```

![img](test.png)
''';

    expect(
      stripMarkdownForSpeech(markdown),
      'Header Paragraph with link and code.',
    );
  });

  test('guesses speech language from script', () {
    expect(guessSpeechLanguageCode('Привет мир'), 'ru-RU');
    expect(guessSpeechLanguageCode('Hello world'), 'en-US');
    expect(guessSpeechLanguageCode('Hello мир'), 'ru-RU');
  });

  test('chunks long text for speech', () {
    final input = List.filled(200, 'alpha beta gamma').join(' ');

    final chunks = chunkTextForSpeech(input, maxChunkLength: 120);

    expect(chunks.length, greaterThan(1));
    expect(chunks.every((chunk) => chunk.length <= 120), isTrue);
    expect(chunks.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim(), input);
  });
}
