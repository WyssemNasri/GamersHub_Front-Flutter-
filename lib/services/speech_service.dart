import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  Future<void> init() async {
    if (!_isInitialized) {
      _isInitialized = await _speech.initialize(
        onStatus: (status) => debugPrint('Speech status: $status'),
        onError: (error) => debugPrint('Speech error: $error'),
      );
    }
  }

  bool get isListening => _speech.isListening;

  Future<void> startListening(Function(String text) onResult, {String localeId = 'fr-FR'}) async {
    await init();
    if (_isInitialized) {
      _speech.listen(
        onResult: (val) => onResult(val.recognizedWords),
        localeId: localeId,
      );
    }
  }

  void stopListening() {
    if (_speech.isListening) {
      _speech.stop();
    }
  }
}
