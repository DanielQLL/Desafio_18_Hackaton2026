import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../widgets/inclusive_layout.dart';
import 'inclusive_components.dart';

/// PANTALLA 2 — Acceso con huella digital (fiel al mockup Screen 2)
class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});
  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen> {
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = Provider.of<AppState>(context, listen: false);
      s.speak('Pon tu dedo en el círculo para entrar de forma segura.', force: true);
    });
  }

  Future<void> _scan() async {
    if (_scanning) return;
    setState(() => _scanning = true);
    final s = Provider.of<AppState>(context, listen: false);

    s.speak('Revisando tu huella...', force: true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    setState(() => _scanning = false);
    // Simula éxito y pasa a la pantalla 3 (Menú)
    s.speak('¡Bienvenido! Entrando a tu cuenta...', force: true);
    Navigator.pushReplacementNamed(context, '/inclusive/menu');
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final lang = state.currentLanguage;

    String bubbleText = 'Pon tu dedo en el círculo para entrar de forma segura.';
    String labelFingerprint = 'PON TU DEDO AQUÍ';
    String boxText = 'Tu huella no sale de tu celular';
    String linkText = '¿No funciona? → Ver otras opciones';

    if (lang == 'QU') {
      bubbleText = 'Yaykuyta, makiykita kay circularpi churay allillamanta.';
      labelFingerprint = 'MAKIYTA KAYPI CHURAY';
      boxText = 'Makiyki mana celularmanta lluqsinchu';
      linkText = '¿Mana allinchu? → Huk yanapana';
    } else if (lang == 'AY') {
      bubbleText = 'Mantataña, lakata aka circulararu apthapiña sumaña.';
      labelFingerprint = 'LAKATA KAYARU APTHAPIÑA';
      boxText = 'Lakamaxa janiw celularata mistkiti';
      linkText = '¿Janïr allïkiti? → Mayja yanapaña';
    }

    return InclusiveLayout(
      child: Scaffold(
        backgroundColor: kBnBg,
        body: SafeArea(
        child: Column(
          children: [
            // Header: logo + red line + language drop + step segment indicator
            BnInclusiveHeader(
              tituloPaso: 'Acceso seguro',
              paso: 1,
              totalPasos: 5,
              onBack: () => Navigator.pushReplacementNamed(context, '/inclusive/language'),
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
                  const SizedBox(height: 36),

                  // Círculo gigante con huella y texto (diseño exacto)
                  Center(
                    child: GestureDetector(
                      onTap: _scan,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: kBnDark, width: 3.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 12),
                            Icon(
                              Icons.fingerprint_rounded,
                              size: 80,
                              color: _scanning ? kBnRed : kBnDark,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              labelFingerprint,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: kBnDark,
                                letterSpacing: 0.3,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Caja gris claro de seguridad
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F1F4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shield_outlined, color: kBnGrey, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            boxText,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: kBnGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Link simular error de acceso
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/inclusive/error');
                      },
                      child: Text(
                        linkText,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: kBnGrey,
                          decoration: TextDecoration.underline,
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
