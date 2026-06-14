import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../widgets/inclusive_layout.dart';
import 'inclusive_components.dart';

/// PANTALLA 7 — Error / No te preocupes (fiel al mockup)
class InclusiveErrorScreen extends StatefulWidget {
  const InclusiveErrorScreen({super.key});
  @override
  State<InclusiveErrorScreen> createState() => _InclusiveErrorScreenState();
}

class _InclusiveErrorScreenState extends State<InclusiveErrorScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = Provider.of<AppState>(context, listen: false);
      s.speak('No pasó nada con tu plata. Volvamos a intentarlo.', force: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final lang = state.currentLanguage;

    String bubbleText = 'No pasó nada con tu plata. Volvamos a intentarlo.';
    String title = 'No te preocupes';
    String subText = 'Puedes intentarlo 2 veces más.\nNo hay apuro.';
    String labelIntento = 'Intento 1 de 3';
    String btnVolverHablar = 'VOLVER A HABLAR';
    String btnOtraForma = 'USAR OTRA FORMA DE ENTRAR';
    String btnLlamar = 'Llamar a un agente BN';

    if (lang == 'QU') {
      bubbleText = 'Mana imapas qullqiykiwan kanchu. Haku wamachakusun.';
      title = 'Ama llakikuychu';
      subText = 'Iskay kutikunatawan rurayta atiwaq.\nHaku, ama utqaychu.';
      labelIntento = 'Ñawpaq kaq kutin 1 (kimsamanta)';
      btnVolverHablar = 'KUTIY RIMAYTA';
      btnOtraForma = 'HUK HINA YAYKUYTA';
      btnLlamar = 'Banco de la Naciónman waqyay';
    } else if (lang == 'AY') {
      bubbleText = 'Janiw kunasa qullqimampi utjkiti. Wasitap kuttañani.';
      title = 'Jan pisi chuymachasiñati';
      subText = 'Paya kutinakampi lurañatakiw utji.\nJaniw jank\'äñakiti.';
      labelIntento = 'Nayrïr kuti 1 (kimsata)';
      btnVolverHablar = 'WASITAP ARSUÑA';
      btnOtraForma = 'MAYJA MANTATAÑA';
      btnLlamar = 'Banco de la Naciónaru achikt\'aña';
    }

    return InclusiveLayout(
      child: Scaffold(
        backgroundColor: kBnBg,
        body: SafeArea(
          child: Column(
          children: [
            // Header
            BnInclusiveHeader(
              tituloPaso: 'Acceso fallido',
              paso: 1,
              totalPasos: 5,
              onBack: () => Navigator.pop(context),
              onLanguageTap: () {},
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
                  const SizedBox(height: 28),

                  // Círculo con carita feliz/neutral
                  Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: kBnDark, width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.sentiment_satisfied_alt_rounded,
                          size: 56,
                          color: kBnDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Títulos
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: kBnDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: kBnGrey,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Puntos de intentos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: kBnDark,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: kBnDark, width: 1.5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: kBnDark, width: 1.5),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        labelIntento,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kBnGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Botón 1: Volver a hablar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBnRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                      onPressed: () {
                        // Vuelve a intentar el escaneo
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.mic_rounded, size: 24),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          btnVolverHablar,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Botón 2: Usar otra forma de entrar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBnDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      icon: const Icon(Icons.arrow_forward_rounded, size: 24),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          btnOtraForma,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Botón 3: Llamar a un agente (dashed/outlined style)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      side: const BorderSide(color: kBnGrey, width: 1.5, style: BorderStyle.solid),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      state.speak('Llamando a un agente del Banco de la Nación.', force: true);
                    },
                    icon: const Icon(Icons.phone_outlined, color: kBnGrey, size: 22),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        btnLlamar,
                        style: const TextStyle(
                          fontSize: 15,
                          color: kBnGrey,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
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
