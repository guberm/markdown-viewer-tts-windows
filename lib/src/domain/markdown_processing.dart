String _trimWrappedQuotes(String input) {
  var value = input.trim();
  while (value.length >= 2) {
    final startsDouble = value.startsWith('"') && value.endsWith('"');
    final startsSingle = value.startsWith("'") && value.endsWith("'");
    if (!startsDouble && !startsSingle) {
      break;
    }
    value = value.substring(1, value.length - 1).trim();
  }
  return value;
}

List<String> extractTags(String markdown) {
  final tags = <String>[];
  final seen = <String>{};

  final frontMatterMatch = RegExp(
    r'^---\s*\n([\s\S]*?)\n---',
    multiLine: true,
  ).firstMatch(markdown);

  if (frontMatterMatch != null) {
    final body = frontMatterMatch.group(1) ?? '';

    final inlineTags = RegExp(r'^tags:\s*\[(.*?)]\s*$', multiLine: true)
        .firstMatch(body)
        ?.group(1);
    if (inlineTags != null) {
      for (final tag in inlineTags.split(',')) {
        final cleaned = _trimWrappedQuotes(tag);
        if (cleaned.isNotEmpty && seen.add(cleaned)) {
          tags.add(cleaned);
        }
      }
    }

    final multilineMatch = RegExp(
      r'^tags:\s*\n((?:\s*-\s*.+\n?)*)',
      multiLine: true,
    ).firstMatch(body);
    if (multilineMatch != null) {
      final lines = (multilineMatch.group(1) ?? '').split('\n');
      for (final line in lines) {
        final cleaned = _trimWrappedQuotes(
          line.replaceFirst(RegExp(r'^\s*-\s*'), '').trim(),
        );
        if (cleaned.isNotEmpty && seen.add(cleaned)) {
          tags.add(cleaned);
        }
      }
    }
  }

  final hashtagPattern = RegExp(r'(?<!\w)#([A-Za-zА-Яа-яЁё0-9_\-/]+)');
  for (final match in hashtagPattern.allMatches(markdown)) {
    final tag = match.group(1);
    if (tag != null && tag.isNotEmpty && seen.add(tag)) {
      tags.add(tag);
    }
  }

  return tags;
}

String filterMarkdownByTag(String markdown, String tag) {
  if (tag.trim().isEmpty) {
    return markdown;
  }

  final normalized = tag.trim().toLowerCase();
  final filtered = markdown
      .split('\n')
      .where(
        (line) =>
            line.toLowerCase().contains('#$normalized') ||
            line.toLowerCase().contains(normalized),
      )
      .join('\n')
      .trim();

  return filtered.isEmpty ? markdown : filtered;
}

String stripMarkdownForSpeech(String markdown) {
  return markdown
      .replaceAll(RegExp(r'```[\s\S]*?```'), ' ')
      .replaceAllMapped(RegExp(r'`([^`]+)`'), (match) => match.group(1) ?? '')
      .replaceAll(RegExp(r'!\[[^\]]*\]\([^)]*\)'), ' ')
      .replaceAllMapped(
        RegExp(r'\[([^\]]+)\]\([^)]*\)'),
        (match) => match.group(1) ?? '',
      )
      .replaceAll(RegExp(r'[#>*_~\-]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String guessSpeechLanguageCode(String text) {
  var cyrillicCount = 0;
  var latinCount = 0;

  for (final rune in text.runes) {
    final char = String.fromCharCode(rune);
    if (RegExp(r'[А-Яа-яЁё]').hasMatch(char)) {
      cyrillicCount++;
    } else if (RegExp(r'[A-Za-z]').hasMatch(char)) {
      latinCount++;
    }
  }

  if (cyrillicCount > 0) {
    return 'ru-RU';
  }
  if (latinCount > 0) {
    return 'en-US';
  }
  return 'en-US';
}

List<String> chunkTextForSpeech(String text, {int maxChunkLength = 3000}) {
  final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.isEmpty) {
    return const [];
  }
  if (normalized.length <= maxChunkLength) {
    return <String>[normalized];
  }

  final chunks = <String>[];
  var remaining = normalized;

  while (remaining.isNotEmpty) {
    if (remaining.length <= maxChunkLength) {
      chunks.add(remaining.trim());
      break;
    }

    final candidate = remaining.substring(0, maxChunkLength);
    final splitPoints = <int>[
      candidate.lastIndexOf('. '),
      candidate.lastIndexOf('! '),
      candidate.lastIndexOf('? '),
      candidate.lastIndexOf('; '),
      candidate.lastIndexOf(': '),
      candidate.lastIndexOf(', '),
      candidate.lastIndexOf(' '),
    ];

    final splitAt = splitPoints.firstWhere(
      (value) => value >= maxChunkLength ~/ 2,
      orElse: () => maxChunkLength,
    );

    final endIndex = splitAt == maxChunkLength ? maxChunkLength : splitAt + 1;
    final chunk = remaining.substring(0, endIndex).trim();
    if (chunk.isNotEmpty) {
      chunks.add(chunk);
    }
    remaining = remaining.substring(endIndex).trimLeft();
  }

  return chunks;
}
