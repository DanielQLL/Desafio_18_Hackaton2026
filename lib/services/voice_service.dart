import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';

class VoiceService extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isListening = false;
  String _lastWords = '';
  BuildContext? _navigatorContext;

  bool get isListening => _isListening;
  String get lastWords => _lastWords;

  VoiceService() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("es-PE");
    await _tts.setSpeechRate(0.5); // Natural y claro
    await _tts.setPitch(1.0);
  }

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  void startListening(BuildContext context) async {
    _navigatorContext = context;
    _lastWords = '';

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening' || status == 'done') {
          _stopAndProcess();
        }
      },
      onError: (errorNotification) {
        _handleError();
      },
    );

    if (available) {
      _isListening = true;
      notifyListeners();
      _speech.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords.toLowerCase();
          notifyListeners();
        },
        listenOptions: stt.SpeechListenOptions(localeId: "es_PE"),
      );
    } else {
      _handleError();
    }
  }

  void _stopAndProcess() async {
    if (!_isListening) return;
    _isListening = false;
    notifyListeners();
    await _speech.stop();
    _evaluateCommand(_lastWords);
  }

  void stopListeningManual() {
    _stopAndProcess();
  }

  void _evaluateCommand(String text) {
    if (text.isEmpty) return;
    if (_navigatorContext == null) return;

    final appState = Provider.of<AppState>(_navigatorContext!, listen: false);
    final lang = appState.currentLanguage;

    final txt = text.toLowerCase();

    bool isSaldo = txt.contains('saldo') || txt.contains('plata') || txt.contains('cuánto') || txt.contains('cuanto') ||
                   txt.contains('qhaway') || txt.contains('uñja');

    bool isRetiro = txt.contains('sacar') || txt.contains('retiro') || txt.contains('cajero') ||
                    txt.contains('qharquy') || txt.contains('surquy') || txt.contains('apsu') || txt.contains('ixsu');

    bool isPago = txt.contains('pagar') || txt.contains('pago') || txt.contains('luz') || txt.contains('agua') ||
                  txt.contains('pagay') || txt.contains('k\'anchay') || txt.contains('yaku') ||
                  txt.contains('pagaña') || txt.contains('qhana') || txt.contains('uma');

    bool isTransferencia = txt.contains('mandar') || txt.contains('enviar') || txt.contains('transferir') ||
                           txt.contains('astachiy') || txt.contains('apachiy') || txt.contains('khithaqa');

    if (isSaldo) {
      String msg = "Vamos a ver cuánta plata tienes";
      if (lang == 'QU') msg = "Haku qullqiykita qhawaykusun";
      if (lang == 'AY') msg = "Haku qullqima uñjañataki";
      speak(msg);
      Navigator.pushNamed(_navigatorContext!, '/inclusive/saldo');
    } else if (isRetiro) {
      String msg = "Vamos a generar una clave para sacar dinero";
      if (lang == 'QU') msg = "Haku qullqita qharqumusun";
      if (lang == 'AY') msg = "Haku qullqi apsuñataki";
      speak(msg);
      Navigator.pushNamed(_navigatorContext!, '/inclusive/retiro');
    } else if (isPago) {
      String msg = "Vamos a pagar tus servicios";
      if (lang == 'QU') msg = "Haku k'anchayta yakuta pagamusun";
      if (lang == 'AY') msg = "Haku qhana uma pagañataki";
      speak(msg);
      Navigator.pushNamed(_navigatorContext!, '/inclusive/pago');
    } else if (isTransferencia) {
      String msg = "Vamos a mandar plata";
      if (lang == 'QU') msg = "Haku qullqita astachimusun";
      if (lang == 'AY') msg = "Haku qullqi khithaqañataki";
      speak(msg);
      Navigator.pushNamed(_navigatorContext!, '/inclusive/transferencia');
    } else {
      String msg = "No te escuché bien. Volvamos a intentarlo despacio";
      if (lang == 'QU') msg = "Mana allintachu uyariki. Haku wamachakusun allillamanta.";
      if (lang == 'AY') msg = "Janiw sum ist'kiti. Wasitap kuttañani sumanki.";
      speak(msg);
      Navigator.pushNamed(_navigatorContext!, '/inclusive/error');
    }
    _lastWords = '';
  }

  void _handleError() {
    _isListening = false;
    notifyListeners();
    
    String msg = "No te escuché bien. Volvamos a intentarlo despacio";
    if (_navigatorContext != null) {
      final appState = Provider.of<AppState>(_navigatorContext!, listen: false);
      final lang = appState.currentLanguage;
      if (lang == 'QU') msg = "Mana allintachu uyariki. Haku wamachakusun allillamanta.";
      if (lang == 'AY') msg = "Janiw sum ist'kiti. Wasitap kuttañani sumanki.";
    }
    speak(msg);
    if (_navigatorContext != null) {
      Navigator.pushNamed(_navigatorContext!, '/inclusive/error');
    }
  }
}
