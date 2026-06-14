import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../services/voice_service.dart';
import '../../widgets/inclusive_layout.dart';
import 'inclusive_components.dart';

class RetiroScreen extends StatefulWidget {
  const RetiroScreen({super.key});

  @override
  State<RetiroScreen> createState() => _RetiroScreenState();
}

class _RetiroScreenState extends State<RetiroScreen> {
  final List<String> _claveNumeros = ['4', '7', '2', '9', '1'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppState>(context, listen: false);
      final voiceService = Provider.of<VoiceService>(context, listen: false);
      final lang = state.currentLanguage;
      
      String textToSpeak = "Tu clave secreta para el cajero es: cuatro, siete, dos, nueve, uno.";
      if (lang == 'QU') {
        textToSpeak = "Cajeropaq secretu claviykiqa: tawa, qanchis, iskay, isqun, huk.";
      } else if (lang == 'AY') {
        textToSpeak = "Cajerotaki secretu clavimaxa: pusi, paqallqu, paya, llätunka, maya.";
      }
      voiceService.speak(textToSpeak);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final lang = state.currentLanguage;

    String topText = "Tu clave secreta para el cajero es:";
    String supportText = "Usa esta clave en el cajero automático más cercano";
    String saveBtnText = "GUARDAR FOTO EN CELULAR 📷";
    String exitBtnText = "SALIR CON SEGURIDAD 🔒";

    if (lang == 'QU') {
      topText = "Cajeropaq secretu claviykiqa:";
      supportText = "Kay clavitam cajeropi churanki";
      saveBtnText = "FOTOTA CELULARMAN WAQAYCHAY 📷";
      exitBtnText = "LLUQSIPUY HAWKALLA 🔒";
    } else if (lang == 'AY') {
      topText = "Cajerotaki secretu clavimaxa:";
      supportText = "Kay clavimpi cajeruna apnaqäta";
      saveBtnText = "FOTO CELULARARU IMT'AÑA 📷";
      exitBtnText = "MISTUÑA SUMANKI 🔒";
    }

    return InclusiveLayout(
      child: Scaffold(
        backgroundColor: kBnBg,
        body: SafeArea(
        child: Column(
          children: [
            // Header
            BnInclusiveHeader(
              tituloPaso: lang == 'ES' ? 'Retiro sin tarjeta' : lang == 'QU' ? 'Qharquy qullqi' : 'Qullqi apsuña',
              paso: 4,
              totalPasos: 5,
              onLanguageTap: () => Navigator.pushReplacementNamed(context, '/inclusive/language'),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  children: [
                    // Bubble / Top Info
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
                    const SizedBox(height: 24),

                    // Clave Boxes Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _claveNumeros.map((digit) {
                        return Container(
                          width: 60,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F4F5), // gris claro
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFC8102E), // Rojo corporativo
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            digit,
                            style: const TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Supporting Info
                    Text(
                      supportText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: kBnGrey,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Buttons Section (both height >= 100)
                    Column(
                      children: [
                        // Button 1: Save photo
                        SizedBox(
                          width: double.infinity,
                          height: 100,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF605F5E), // Gris oscuro
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 4,
                            ),
                            onPressed: () {
                              final voiceService = Provider.of<VoiceService>(context, listen: false);
                              String saveMsg = "Foto guardada en tu galería.";
                              if (lang == 'QU') saveMsg = "Foto celularniykipi waqaychasqaña.";
                              if (lang == 'AY') saveMsg = "Foto celulararu imt'atäxiwa.";
                              voiceService.speak(saveMsg);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFF605F5E),
                                  duration: const Duration(seconds: 3),
                                  content: Text(
                                    lang == 'ES' ? "📷 Foto guardada en Galería" : "📷 Foto waqaychasqa",
                                    style: const TextStyle(
                                      fontFamily: 'Arial',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  saveBtnText,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Button 2: Exit
                        SizedBox(
                          width: double.infinity,
                          height: 100,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC8102E), // Rojo corporativo
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 4,
                            ),
                            onPressed: () {
                              final voiceService = Provider.of<VoiceService>(context, listen: false);
                              String exitMsg = "Sesión cerrada de forma segura.";
                              if (lang == 'QU') exitMsg = "Hawka lluqsipusqanki.";
                              if (lang == 'AY') exitMsg = "Sum mistuñani jutasa.";
                              voiceService.speak(exitMsg);

                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (route) => false,
                              );
                            },
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  exitBtnText,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 20,
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
