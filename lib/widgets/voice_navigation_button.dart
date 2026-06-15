import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import '../models/app_state.dart';
import '../services/voice_navigation_service.dart';
import '../screens/dashboard_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VOICE NAVIGATION BUTTON
// Floating microphone that listens → intent engine → navigate
// ─────────────────────────────────────────────────────────────────────────────

class VoiceNavigationButton extends StatefulWidget {
  const VoiceNavigationButton({super.key});

  @override
  State<VoiceNavigationButton> createState() => _VoiceNavigationButtonState();
}

class _VoiceNavigationButtonState extends State<VoiceNavigationButton>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speech = SpeechToText();

  bool _isListening = false;
  bool _isInitialized = false;
  bool _isInitializing = false;
  bool _isProcessing = false;
  String _lastWords = '';
  String _statusText = '';
  String? _errorText;

  // Best available locale for Spanish
  String _localeId = 'es-US'; // fallback

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.stop();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    if (_isInitializing) return;
    setState(() {
      _isInitializing = true;
      _errorText = null;
    });

    try {
      final available = await _speech.initialize(
        onError: _onSpeechError,
        onStatus: _onSpeechStatus,
        debugLogging: true,
      );

      if (available) {
        // Find best Spanish locale available on this device
        final locales = await _speech.locales();
        dev.log('Available speech locales: ${locales.map((l) => l.localeId).join(', ')}');

        // Priority order for Spanish locales
        const preferred = ['es_PE', 'es-PE', 'es_US', 'es-US', 'es_ES', 'es-ES', 'es_MX', 'es-MX'];
        for (final pref in preferred) {
          if (locales.any((l) => l.localeId == pref)) {
            _localeId = pref;
            break;
          }
        }
        // If none found, use any 'es' locale
        if (!preferred.contains(_localeId)) {
          final any = locales.where((l) => l.localeId.startsWith('es')).toList();
          if (any.isNotEmpty) _localeId = any.first.localeId;
        }
        dev.log('Using speech locale: $_localeId');
      }

      setState(() {
        _isInitialized = available;
        _isInitializing = false;
        if (!available) {
          _errorText = 'Reconocimiento de voz no disponible en este dispositivo';
        }
      });
    } catch (e) {
      dev.log('Speech init error: $e');
      setState(() {
        _isInitialized = false;
        _isInitializing = false;
        _errorText = 'Error al iniciar micrófono: $e';
      });
    }
  }

  void _onSpeechError(SpeechRecognitionError error) {
    dev.log('Speech error: ${error.errorMsg} permanent=${error.permanent}');
    if (mounted) {
      setState(() {
        _isListening = false;
        _pulseController.stop();
        _errorText = 'Error: ${error.errorMsg}';
      });
      // If we got some words before the error, still process them
      if (_lastWords.isNotEmpty) {
        _processResult(_lastWords);
      }
    }
  }

  void _onSpeechStatus(String status) {
    dev.log('Speech status: $status');
    if (mounted) {
      setState(() => _statusText = 'Estado: $status'); // Show status in UI
      if (status == SpeechToText.listeningStatus) {
        setState(() => _isListening = true);
      } else if (status == SpeechToText.doneStatus || status == SpeechToText.notListeningStatus) {
        setState(() => _isListening = false);
        _pulseController.stop();
        if (_lastWords.isNotEmpty && !_isProcessing) {
          _processResult(_lastWords);
        }
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _startListening() async {
    final state = Provider.of<AppState>(context, listen: false);

    // Re-try initialization if not done yet
    if (!_isInitialized) {
      if (!_isInitializing) await _initSpeech();
      if (!_isInitialized) {
        _showSnack('Micrófono no disponible. Verifique los permisos en Ajustes.');
        dev.log('Speech not initialized, cannot listen');
        return;
      }
    }

    if (_speech.isListening || _isListening) {
      return;
    }

    setState(() {
      _lastWords = '';
      _statusText = 'Escuchando...';
      _isListening = true;
      _errorText = null;
    });
    
    // Stop TTS before listening so they don't overlap
    await state.stopSpeak();
    
    if (!_isListening) return; // User released button before TTS stopped

    _pulseController.repeat(reverse: true);

    await _speech.listen(
      onResult: (result) {
        if (mounted) {
          setState(() {
            _lastWords = result.recognizedWords;
            _statusText = 'Oigo: ${result.recognizedWords}';
          });
        }
      },
      // localeId: 'es-US', // Removed to let the browser use its native default, avoiding "network" errors
      partialResults: true,
      cancelOnError: true,
    );
  }

  void _stopListening() {
    if (!_isListening) return;
    _speech.stop();
    _pulseController.stop();
    setState(() {
      _isListening = false;
      _statusText = 'Analizando voz...';
    });
    if (_lastWords.isNotEmpty) _processResult(_lastWords);
  }

  Future<void> _processResult(String words) async {
    if (_isProcessing || words.isEmpty) return;
    if (mounted) {
      setState(() {
        _isProcessing = true;
        _statusText = 'Procesando: "$words"';
        _lastWords = ''; // Clear to prevent double processing
      });
    }

    dev.log('Processing voice command: "$words"');
    final state = Provider.of<AppState>(context, listen: false);
    final result = await VoiceNavigationService.resolve(words, state.currentLanguage);
    dev.log('Voice resolved to: ${result.destination} (AI=${result.usedAI})');

    if (!mounted) return;

    final msg = result.confirmationMessage.isNotEmpty
        ? result.confirmationMessage
        : (state.currentLanguage == 'ES'
            ? 'No entendí el comando. Intente de nuevo.'
            : 'Mana entendinichu.');

    // Always speak feedback, even if TTS is off (force=true)
    state.speak(msg, force: true);

    if (mounted) setState(() => _isProcessing = false);

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    _navigate(result.destination, state);
  }

  DateTime? _lastNavigatedTime;

  void _navigate(VoiceDestination dest, AppState state) {
    if (_lastNavigatedTime != null && DateTime.now().difference(_lastNavigatedTime!).inMilliseconds < 1500) {
      dev.log('Navigation debounced (too fast)');
      return;
    }
    _lastNavigatedTime = DateTime.now();

    final ctx = context;
    switch (dest) {
      case VoiceDestination.home:
        state.setTab(0);
        if (state.simpleModeEnabled) state.toggleSimpleMode();
        break;
      case VoiceDestination.transferCell:
        _push(ctx, const TransferCellularScreen());
        break;
      case VoiceDestination.transferAccounts:
        _push(ctx, const TransferAccountsScreen());
        break;
      case VoiceDestination.pagosRecargas:
        _push(ctx, const PagosRecargasScreen());
        break;
      case VoiceDestination.giros:
        _push(ctx, const GirosScreen());
        break;
      case VoiceDestination.retiroSinTarjeta:
        _push(ctx, const RetiroSinTarjetaScreen());
        break;
      case VoiceDestination.loans:
        _push(ctx, const LoanScreen());
        break;
      case VoiceDestination.socialPlans:
        _push(ctx, const SocialPlansScreen());
        break;
      case VoiceDestination.security:
        state.setTab(2);
        if (state.simpleModeEnabled) state.toggleSimpleMode();
        break;
      case VoiceDestination.editProfile:
        _push(ctx, const EditProfileScreen());
        break;
      case VoiceDestination.contactanos:
        _push(ctx, const ContactanosScreen());
        break;
      case VoiceDestination.ubicanos:
        _push(ctx, const UbicanosScreen());
        break;
      case VoiceDestination.changeClave:
        _push(ctx, const ChangeClaveScreen());
        break;
      case VoiceDestination.logout:
        state.logout();
        Navigator.pushReplacementNamed(ctx, '/login');
        break;
      case VoiceDestination.unknown:
        break;
    }
  }

  void _push(BuildContext ctx, Widget screen) {
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => screen));
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFC8102E),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show spinner while initializing
    if (_isInitializing) {
      return Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF2A2B30),
          border: Border.all(color: const Color(0xFF3A3B40), width: 1.5),
        ),
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFF2522E),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Status / error bubble
        if (_isListening || _isProcessing || _errorText != null)
          Container(
            margin: const EdgeInsets.only(bottom: 8, right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            constraints: const BoxConstraints(maxWidth: 220),
            decoration: BoxDecoration(
              color: _errorText != null
                  ? const Color(0xFF3A1010)
                  : const Color(0xFF1E1F23),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _errorText != null
                    ? Colors.redAccent
                    : const Color(0xFFF2522E),
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 3))
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_errorText != null)
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 16)
                else if (_isProcessing)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFF2522E),
                    ),
                  )
                else
                  const Icon(Icons.hearing, color: Color(0xFFF2522E), size: 16),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _errorText ??
                        (_isProcessing
                            ? _statusText
                            : (_lastWords.isNotEmpty ? '"$_lastWords"' : _statusText)),
                    style: TextStyle(
                      color: _errorText != null ? Colors.redAccent : Colors.white,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (_isListening) {
              _stopListening();
            } else {
              _startListening();
            }
          },
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (_, child) {
              return Transform.scale(
                scale: _isListening ? _pulseAnimation.value : 1.0,
                child: child,
              );
            },
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isListening
                      ? [const Color(0xFFFF1744), const Color(0xFFF2522E)]
                      : !_isInitialized
                          ? [const Color(0xFF444444), const Color(0xFF333333)]
                          : [const Color(0xFF2A2B30), const Color(0xFF1A1A1B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isListening
                        ? const Color(0xFFF2522E).withValues(alpha: 0.5)
                        : Colors.black45,
                    blurRadius: _isListening ? 18 : 6,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: _isListening
                      ? const Color(0xFFFF1744)
                      : !_isInitialized
                          ? const Color(0xFF555555)
                          : const Color(0xFF3A3B40),
                  width: 1.5,
                ),
              ),
              child: Icon(
                _isListening
                    ? Icons.stop_rounded
                    : !_isInitialized
                        ? Icons.mic_off
                        : Icons.mic,
                color: _isListening
                    ? Colors.white
                    : !_isInitialized
                        ? Colors.grey
                        : const Color(0xFFF2522E),
                size: 26,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
