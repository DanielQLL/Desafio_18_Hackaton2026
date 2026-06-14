import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../services/voice_service.dart';
import '../../widgets/inclusive_layout.dart';
import 'inclusive_components.dart';

class SaldoScreen extends StatefulWidget {
  const SaldoScreen({super.key});

  @override
  State<SaldoScreen> createState() => _SaldoScreenState();
}

class _SaldoScreenState extends State<SaldoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppState>(context, listen: false);
      final voiceService = Provider.of<VoiceService>(context, listen: false);
      final lang = state.currentLanguage;
      final saldo = state.savingsSoles.toStringAsFixed(2);
      
      String textToSpeak = "Tu plata disponible es: $saldo soles.";
      if (lang == 'QU') {
        textToSpeak = "Qullqiykiqa $saldo solesmi.";
      } else if (lang == 'AY') {
        textToSpeak = "Qullqimaxa $saldo soleskiwa.";
      }
      voiceService.speak(textToSpeak);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final lang = state.currentLanguage;
    final saldo = state.savingsSoles.toStringAsFixed(2);

    String topText = "Tu plata disponible es:";
    String buttonNeed = "LO NECESITO";
    String buttonWithdraw = "SACAR MI PLATA";
    String bannerText = "¡Felicidades! Tienes un Préstamo Multired pre-aprobado de hasta S/ 10,000 para emergencias";

    if (lang == 'QU') {
      topText = "Qullqiyki kapusuqniykiqa:";
      buttonNeed = "MUNANIM";
      buttonWithdraw = "QULLQIYTA QHARQUY";
      bannerText = "¡Kusiwan! Chaskiyta atiwaq Préstamo Multired S/ 10,000 nisqata llakiypaq";
    } else if (lang == 'AY') {
      topText = "Qullqimaxa uñjataraxa:";
      buttonNeed = "MUNTHAWA";
      buttonWithdraw = "QULLQI APSUÑA";
      bannerText = "¡Jach'a khuyapayaña! Préstamo Multired katuqañataqi S/ 10,000 ch'axwawitaki";
    }

    return InclusiveLayout(
      child: Scaffold(
        backgroundColor: kBnBg,
        body: SafeArea(
        child: Column(
          children: [
            // Header
            BnInclusiveHeader(
              tituloPaso: lang == 'ES' ? 'Ver mi plata' : lang == 'QU' ? 'Qullqi qhaway' : 'Qullqi uñjaña',
              paso: 3,
              totalPasos: 5,
              onLanguageTap: () => Navigator.pushReplacementNamed(context, '/inclusive/language'),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  children: [
                    // Top Info
                    Text(
                      topText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: kBnGrey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "S/ $saldo",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Disruptive Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9CC00), // Amarillo Multired
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Text(
                        bannerText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Giant Buttons Section
                    Row(
                      children: [
                        // Left button: LO NECESITO
                        Expanded(
                          child: SizedBox(
                            height: 110,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFA4C100), // Verde UOB
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  side: const BorderSide(color: Colors.black, width: 3),
                                ),
                                elevation: 6,
                              ),
                              onPressed: () {
                                final voiceService = Provider.of<VoiceService>(context, listen: false);
                                String speakMsg = "Préstamo solicitado. Nos comunicaremos contigo.";
                                if (lang == 'QU') speakMsg = "Préstamo mañasqa. Willasqaykiku pisi tiempollapi.";
                                if (lang == 'AY') speakMsg = "Préstamo mayt'atawa. Juch'usa pachan yatiyapxäma.";
                                voiceService.speak(speakMsg);

                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    title: Text(
                                      lang == 'ES' ? "Préstamo Solicitado" : "Préstamo mañasqa",
                                      style: const TextStyle(fontFamily: 'Arial', fontWeight: FontWeight.bold),
                                    ),
                                    content: Text(
                                      lang == 'ES'
                                          ? "Tu solicitud de Préstamo Multired ha sido recibida con éxito."
                                          : "Préstamo Multired mañakuyniyki chaskisqañam.",
                                      style: const TextStyle(fontFamily: 'Arial', fontSize: 18),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text(
                                          "OK",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  buttonNeed,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Right button: SACAR MI PLATA
                        Expanded(
                          child: SizedBox(
                            height: 110,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC8102E), // Rojo Corporativo
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 6,
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, '/inclusive/retiro');
                              },
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  buttonWithdraw,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
