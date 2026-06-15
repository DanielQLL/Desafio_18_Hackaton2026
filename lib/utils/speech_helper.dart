import 'package:flutter_tts/flutter_tts.dart';

class SpeechHelper {
  static final FlutterTts _tts = FlutterTts();

  static Future<void> speak(String text, {String lang = 'es-PE'}) async {
    try {
      await _tts.setLanguage(lang);
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.speak(text);
    } catch (_) {
      // Fallback: ignore if the platform cannot speak.
    }
  }

  static Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
