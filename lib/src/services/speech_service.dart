import 'package:flutter_tts/flutter_tts.dart';

import '../domain/markdown_processing.dart';

class SpeechService {
  SpeechService({FlutterTts? flutterTts}) : _flutterTts = flutterTts ?? FlutterTts();

  final FlutterTts _flutterTts;

  Future<void> speakMarkdown({
    required String markdown,
    required double speechRate,
  }) async {
    final text = stripMarkdownForSpeech(markdown);
    if (text.isEmpty) {
      return;
    }

    final language = guessSpeechLanguageCode(text);
    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.setLanguage(language);
    await _flutterTts.setSpeechRate(speechRate.clamp(0.1, 1.0));

    for (final chunk in chunkTextForSpeech(text)) {
      await _flutterTts.speak(chunk);
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
