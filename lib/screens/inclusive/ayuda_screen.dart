import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../widgets/inclusive_layout.dart';
import 'inclusive_components.dart';

class AyudaScreen extends StatefulWidget {
  const AyudaScreen({super.key});

  @override
  State<AyudaScreen> createState() => _AyudaScreenState();
}

class _AyudaScreenState extends State<AyudaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppState>(context, listen: false);
      final lang = state.currentLanguage;
      String speakMsg = "Bienvenido al manual de ayuda. Toca cualquier instrucción para escucharla.";
      if (lang == 'QU') speakMsg = "Yanapakuy qillqaman chayamushanki. Ñit'iy rimayta uyaripaq.";
      if (lang == 'AY') speakMsg = "Yanapaña pankaru purt'anita. Kawkïr yatichäwi yatxatañataki ch'amanchaña.";
      state.speak(speakMsg, force: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final lang = state.currentLanguage;

    String headerTitle = "Manual de Ayuda";
    if (lang == 'QU') headerTitle = "Yanapakuy qillqa";
    if (lang == 'AY') headerTitle = "Yanapaña panka";

    String backBtnText = "VOLVER";
    if (lang == 'QU') backBtnText = "KUTIY";
    if (lang == 'AY') backBtnText = "KUTIÑA";

    // Data for the help steps
    final List<Map<String, String>> steps = [
      {
        'title_es': '1. Elige tu idioma',
        'title_qu': '1. Rimayta akllay',
        'title_ay': '1. Aru aklliña',
        'desc_es': 'Selecciona Español, Quechua o Aymara para escuchar a la aplicación en tu lengua materna.',
        'desc_qu': 'Castellano, Runasimi o Aymara simita akllay rimakuq chaskispa.',
        'desc_ay': 'Castellano, Quechua jan ukax Aymara aru akllitaw aruchaskaña arumata.',
        'voice_es': 'Paso uno. Selecciona Español, Quechua o Aymara para escuchar a la aplicación en tu lengua materna.',
        'voice_qu': 'Huk kaq paso. Castellano, Runasimi o Aymara simita akllay rimakuq chaskispa.',
        'voice_ay': 'Mayrïr paso. Castellano, Quechua jan ukax Aymara aru akllitaw aruchaskaña arumata.',
      },
      {
        'title_es': '2. Entra con tu huella',
        'title_qu': '2. Saywaykiwan yaykuy',
        'title_ay': '2. Mantxaña lakampi',
        'desc_es': 'Coloca tu dedo en el círculo blanco para iniciar sesión de forma rápida y 100% segura.',
        'desc_qu': 'Saywayki circularman churay. Utqayllaman hawkalla yaykunapaq.',
        'desc_ay': 'Lakama circulararu churam sum mantatäña ch\'amampi.',
        'voice_es': 'Paso dos. Coloca tu dedo en el círculo blanco para iniciar sesión de forma rápida y cien por ciento segura.',
        'voice_qu': 'Iskay kaq paso. Saywayki circularman churay. Utqayllaman hawkalla yaykunapaq.',
        'voice_ay': 'Payïr paso. Lakama circulararu churam sum mantatäña ch\'amampi.',
      },
      {
        'title_es': '3. Escucha el asistente',
        'title_qu': '3. Uyariy yanapapakuqta',
        'title_ay': '3. Ist\'añani yanapiriru',
        'desc_es': 'El asistente de voz te leerá todos los textos de la pantalla de forma automática.',
        'desc_qu': 'Asistente de voz automatico rimaykunata ñawinchasunki.',
        'desc_ay': 'Asistente de voz automatico aruchaspawa arunakaxa.',
        'voice_es': 'Paso tres. El asistente de voz te leerá todos los textos de la pantalla de forma automática.',
        'voice_qu': 'Kimsa kaq paso. Asistente de voz automatico rimaykunata ñawinchasunki.',
        'voice_ay': 'Kimsïr paso. Asistente de voz automatico aruchaspawa arunakaxa.',
      },
      {
        'title_es': '4. Habla con el micrófono',
        'title_qu': '4. Rimay micrófonowan',
        'title_ay': '4. Arsuña micrófonampi',
        'desc_es': 'Mantén presionado el botón del micrófono flotante en cualquier momento para dar órdenes de voz.',
        'desc_qu': 'Micrófono ñit\'iy rimayta munaspa imay pachapas ordenkuna qunapaq.',
        'desc_ay': 'Micrófono ch\'amanchaña, kawkïr pachan yanapaña achikt\'asiñataki.',
        'voice_es': 'Paso cuatro. Mantén presionado el botón del micrófono flotante en cualquier momento para dar órdenes de voz.',
        'voice_qu': 'Tawa kaq paso. Micrófono ñit\'iy rimayta munaspa imay pachapas ordenkuna qunapaq.',
        'voice_ay': 'Pusïr paso. Micrófono ch\'amanchaña, kawkïr pachan yanapaña achikt\'asiñataki.',
      },
    ];

    return InclusiveLayout(
      child: Scaffold(
        backgroundColor: kBnBg,
        body: SafeArea(
        child: Column(
          children: [
            BnInclusiveHeader(
              tituloPaso: headerTitle,
              paso: 5,
              totalPasos: 5,
              onLanguageTap: () => Navigator.pushReplacementNamed(context, '/inclusive/language'),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  final step = steps[index];
                  String title = step['title_es']!;
                  String desc = step['desc_es']!;
                  String voice = step['voice_es']!;

                  if (lang == 'QU') {
                    title = step['title_qu']!;
                    desc = step['desc_qu']!;
                    voice = step['voice_qu']!;
                  } else if (lang == 'AY') {
                    title = step['title_ay']!;
                    desc = step['desc_ay']!;
                    voice = step['voice_ay']!;
                  }

                  return GestureDetector(
                    onTap: () => state.speak(voice, force: true),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE4E4E7), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFEE2E2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.volume_up_rounded, color: kBnRed, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: kBnDark,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  desc,
                                  style: const TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: kBnGrey,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 70, // Fat finger safe
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBnDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      backBtnText,
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            BnBottomNav(
              currentIndex: 1, // Ayuda is selected
              onInicio: () => Navigator.pushReplacementNamed(context, '/login'),
              onAyuda: () {},
            ),
          ],
        ),
      ),
    ));
  }
}
