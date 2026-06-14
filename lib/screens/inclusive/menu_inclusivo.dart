import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../services/voice_service.dart';
import '../../widgets/inclusive_layout.dart';
import 'inclusive_components.dart';

/// PANTALLA 3 — Menú principal (fiel al mockup Screen 3)
class MenuInclusivo extends StatefulWidget {
  const MenuInclusivo({super.key});
  @override
  State<MenuInclusivo> createState() => _MenuInclusivoState();
}

class _MenuInclusivoState extends State<MenuInclusivo> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = Provider.of<AppState>(context, listen: false);
      final lang = s.currentLanguage;
      String msg = 'Hola, Juana. ¿Qué quieres hacer hoy?';
      if (lang == 'QU') msg = 'Allillan, Juana. ¿Imatam ruranki munankis?';
      if (lang == 'AY') msg = 'Kamisaki, Juana. ¿Kunata luraña munsta?';
      s.speak(msg, force: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final voiceService = Provider.of<VoiceService>(context);
    final lang = state.currentLanguage;
    final isListening = voiceService.isListening;

    String bubbleText = 'Hola, Juana. ¿Qué quieres hacer hoy?';
    String op1 = 'VER MI PLATA';
    String op2 = 'SACAR DINERO';
    String op3 = 'PAGAR LUZ O AGUA';
    String op4 = 'MANDAR PLATA';
    String oHabla = 'O HABLA';
    String tocaHablar = 'Toca para hablar';

    if (lang == 'QU') {
      bubbleText = 'Allillan, Juana. ¿Imatam ruranki munankis?';
      op1 = 'QULLQIYTA QHAWAY';
      op2 = 'QULLQIYTA QHARQUY';
      op3 = 'K\'ANCHAY O YAKUTA PAGAY';
      op4 = 'QULLQIYTA ASTACHIY';
      oHabla = 'RIMAYPAS';
      tocaHablar = 'Llamiy rimaypaq';
    } else if (lang == 'AY') {
      bubbleText = 'Kamisaki, Juana. ¿Kunata luraña munsta?';
      op1 = 'QULLQIMA UÑJAÑA';
      op2 = 'QULLQI IXSUÑA';
      op3 = 'QHANA O UMA PAGAÑA';
      op4 = 'QULLQI KHITHAQAÑA';
      oHabla = 'ARSUÑAPAS';
      tocaHablar = 'Lakami arsuñataki';
    }

    return InclusiveLayout(
      child: Scaffold(
        backgroundColor: kBnBg,
        body: SafeArea(
        child: Column(
          children: [
            // Header: logo + red line + language drop + step segment indicator
            BnInclusiveHeader(
              tituloPaso: '¿Qué quieres hacer?',
              paso: 2,
              totalPasos: 5,
              onLanguageTap: () => Navigator.pushReplacementNamed(context, '/inclusive/language'),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                children: [
                  // Asistente de Voz
                  BnVoiceBubble(
                    texto: bubbleText,
                    onTap: () => state.speak(bubbleText, force: true),
                  ),
                  const SizedBox(height: 20),

                  // Opción 1: Ver mi plata
                  _MenuBtn(
                    icono: Icons.account_balance_wallet_outlined,
                    texto: op1,
                    onTap: () {
                      state.speak(op1, force: true);
                      Navigator.pushNamed(context, '/inclusive/saldo');
                    },
                  ),
                  const SizedBox(height: 12),

                  // Opción 2: Sacar dinero
                  _MenuBtn(
                    icono: Icons.atm_outlined,
                    texto: op2,
                    onTap: () {
                      state.speak(op2, force: true);
                      Navigator.pushNamed(context, '/inclusive/retiro');
                    },
                  ),
                  const SizedBox(height: 12),

                  // Opción 3: Pagar servicios
                  _MenuBtn(
                    icono: Icons.bolt_rounded,
                    texto: op3,
                    onTap: () {
                      state.speak(op3, force: true);
                      Navigator.pushNamed(context, '/inclusive/pago');
                    },
                  ),
                  const SizedBox(height: 12),

                  // Opción 4: Mandar plata
                  _MenuBtn(
                    icono: Icons.send_rounded,
                    texto: op4,
                    onTap: () {
                      state.speak(op4, force: true);
                      Navigator.pushNamed(context, '/inclusive/transferencia');
                    },
                  ),
                  const SizedBox(height: 20),

                  // Separador "O HABLA"
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Color(0xFFD4D4D8), thickness: 1.2)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          oHabla,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: kBnGrey,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Color(0xFFD4D4D8), thickness: 1.2)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Botón de micrófono gigante animado/toca para hablar
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (isListening) {
                              voiceService.stopListeningManual();
                            } else {
                              voiceService.startListening(context);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: isListening ? Colors.green : kBnRed,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (isListening ? Colors.green : kBnRed).withValues(alpha: 0.35),
                                  blurRadius: isListening ? 24 : 16,
                                  spreadRadius: isListening ? 4 : 2,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Icon(
                              isListening ? Icons.mic_none_rounded : Icons.mic_rounded,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isListening
                              ? (lang == 'ES' ? 'Escuchando...' : lang == 'QU' ? 'Uyarisqayki...' : 'Ist\'askayki...')
                              : tocaHablar,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: kBnGrey,
                          ),
                        ),
                        if (isListening) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                             decoration: BoxDecoration(
                               color: const Color(0xFFF0FDF4),
                               borderRadius: BorderRadius.circular(20),
                               border: Border.all(color: Colors.green, width: 1.5),
                             ),
                             child: Row(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 const SizedBox(
                                   width: 14,
                                   height: 14,
                                   child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
                                 ),
                                 const SizedBox(width: 10),
                                 Text(
                                   lang == 'ES' ? 'Hable ahora' :
                                   lang == 'QU' ? 'Rimay kunan' : 'Arsuma jichha',
                                   style: const TextStyle(
                                     fontSize: 13,
                                     fontWeight: FontWeight.w800,
                                     color: Colors.green,
                                   ),
                                 ),
                               ],
                             ),
                           ),
                         ],
                         if (voiceService.lastWords.isNotEmpty) ...[
                           const SizedBox(height: 10),
                           Text(
                             '"${voiceService.lastWords}"',
                             style: const TextStyle(
                               fontSize: 14,
                               fontStyle: FontStyle.italic,
                               fontWeight: FontWeight.w600,
                               color: kBnGrey,
                             ),
                           ),
                         ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Nav
            BnBottomNav(
              currentIndex: 0,
              onInicio: () => Navigator.pushReplacementNamed(context, '/login'),
              onAyuda: () {},
            ),
          ],
        ),
      ),
    ));
  }
}

class _MenuBtn extends StatelessWidget {
  final IconData icono;
  final String texto;
  final VoidCallback onTap;

  const _MenuBtn({required this.icono, required this.texto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
        decoration: BoxDecoration(
          color: kBnDark,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icono, color: Colors.white, size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                texto,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.3,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
