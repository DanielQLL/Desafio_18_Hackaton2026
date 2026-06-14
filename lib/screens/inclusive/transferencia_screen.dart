import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../widgets/inclusive_layout.dart';
import 'inclusive_components.dart';

class TransferenciaScreen extends StatefulWidget {
  const TransferenciaScreen({super.key});

  @override
  State<TransferenciaScreen> createState() => _TransferenciaScreenState();
}

class _TransferenciaScreenState extends State<TransferenciaScreen> {
  bool confirmada = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppState>(context, listen: false);
      final lang = state.currentLanguage;
      String speakMsg = "¿Quieres mandar 50 soles a María?";
      if (lang == 'QU') speakMsg = "María-man 50 soles qullqita apachiyta munankichu?";
      if (lang == 'AY') speakMsg = "María-taki 50 soles qullqinak khitaña munktati?";
      state.speak(speakMsg, force: true);
    });
  }

  void _confirmar(BuildContext context) {
    setState(() {
      confirmada = true;
    });
    final state = Provider.of<AppState>(context, listen: false);
    final lang = state.currentLanguage;
    String speakMsg = "¡Listo! La plata ya fue enviada.";
    if (lang == 'QU') speakMsg = "Allinñam! Qullqiyki apachisqaña.";
    if (lang == 'AY') speakMsg = "Ch'usañawa! Qullqimaxa khitatäxiwa.";
    state.speak(speakMsg, force: true);
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final lang = state.currentLanguage;

    String headerTitle = "Mandar plata";
    if (lang == 'QU') headerTitle = "Qullqi apachiy";
    if (lang == 'AY') headerTitle = "Qullqi khitaña";

    return InclusiveLayout(
      child: Scaffold(
        backgroundColor: kBnBg,
        body: SafeArea(
          child: Column(
          children: [
            BnInclusiveHeader(
              tituloPaso: headerTitle,
              paso: 4,
              totalPasos: 5,
              onLanguageTap: () => Navigator.pushReplacementNamed(context, '/inclusive/language'),
            ),
            Expanded(
              child: confirmada ? _buildPantallaExito(lang) : _buildPantallaConfirmacion(lang),
            ),
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

  Widget _buildPantallaConfirmacion(String lang) {
    String pregunta = "¿Quieres mandar S/ 50.00 a María?";
    String btnSi = "SÍ, MANDAR";
    String btnNo = "NO, VOLVER";

    if (lang == 'QU') {
      pregunta = "¿María-man S/ 50.00 qullqita apachiyta munankichu?";
      btnSi = "ARÍ, APACHIY";
      btnNo = "MANAN, KUTIY";
    } else if (lang == 'AY') {
      pregunta = "¿María-taki S/ 50.00 qullqinak khitaña munktati?";
      btnSi = "JISA, KHITAÑA";
      btnNo = "JANIW, KUTIÑA";
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        children: [
          // Bubble / Top Info
          Text(
            pregunta,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Arial',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: kBnDark,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 40),

          // Icon representation of transaction
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: const Icon(
              Icons.send_rounded,
              color: Color(0xFFC8102E),
              size: 72,
            ),
          ),
          const SizedBox(height: 50),

          // Botones enormes de acción (Fat-finger safe, height >= 100)
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 100,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA4C100), // Verde UOB
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.black, width: 2.5),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () => _confirmar(context),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        btnSi,
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                  onPressed: () => Navigator.pop(context),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        btnNo,
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 24,
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
    );
  }

  Widget _buildPantallaExito(String lang) {
    String exitoText = "¡Listo! La plata ya fue enviada.";
    String btnVolver = "VOLVER AL MENÚ";

    if (lang == 'QU') {
      exitoText = "¡Allinñam! Qullqiyki apachisqaña.";
      btnVolver = "KUTIY MENUMAN";
    } else if (lang == 'AY') {
      exitoText = "¡Ch'usañawa! Qullqimaxa khitatäxiwa.";
      btnVolver = "MENU KUTIÑA";
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFFA4C100), // Verde UOB
            size: 110,
          ),
          const SizedBox(height: 24),
          Text(
            exitoText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Arial',
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 90, // Fat finger safe
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kBnDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, '/inclusive/menu', (route) => false),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    btnVolver,
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
