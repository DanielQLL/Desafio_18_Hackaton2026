import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../widgets/inclusive_layout.dart';
import 'inclusive_components.dart';

/// PANTALLA 1 — Selección de Idioma (exacta al mockup)
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});
  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppState>(context, listen: false);
      state.ttsEnabled = true;
      state.speak('¿En qué idioma quieres que te hable?', force: true);
    });
  }

  void _select(String lang) {
    final state = Provider.of<AppState>(context, listen: false);
    state.setLanguage(lang);
    Navigator.pushReplacementNamed(context, '/inclusive/biometric');
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final selected = state.currentLanguage;

    return InclusiveLayout(
      child: Scaffold(
        backgroundColor: kBnBg,
        body: SafeArea(
        child: Column(
          children: [
            // Header completo: logo + red line + language drop + step segment indicator
            BnInclusiveHeader(
              tituloPaso: 'Selección de idioma',
              paso: 1,
              totalPasos: 5,
              onLanguageTap: () => _showPicker(context),
            ),

            // Cuerpo de la pantalla
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                children: [
                  // Asistente de Voz
                  BnVoiceBubble(
                    texto: '¿En qué idioma quieres que te hable?',
                    onTap: () => state.speak(
                      '¿En qué idioma quieres que te hable?',
                      force: true,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón ESPAÑOL
                  _LangBtn(
                    label: 'ESPAÑOL',
                    phonetic: 'Es-PA-nyol',
                    selected: selected == 'ES',
                    onTap: () => _select('ES'),
                  ),
                  const SizedBox(height: 14),

                  // Botón QUECHUA
                  _LangBtn(
                    label: 'QUECHUA',
                    phonetic: 'KE-chua',
                    selected: selected == 'QU',
                    onTap: () => _select('QU'),
                  ),
                  const SizedBox(height: 14),

                  // Botón AYMARA
                  _LangBtn(
                    label: 'AYMARA',
                    phonetic: 'Al-ma-ra',
                    selected: selected == 'AY',
                    onTap: () => _select('AY'),
                  ),
                ],
              ),
            ),

            // Bottom Navigation
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

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Elige tu idioma / Idioma', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            for (final e in [('🇵🇪', 'Español', 'ES'), ('🏔️', 'Quechua', 'QU'), ('🌄', 'Aymara', 'AY')])
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Text(e.$1, style: const TextStyle(fontSize: 26)),
                title: Text(e.$2, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                onTap: () {
                  Navigator.pop(context);
                  _select(e.$3);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _LangBtn extends StatelessWidget {
  final String label;
  final String phonetic;
  final bool selected;
  final VoidCallback onTap;

  const _LangBtn({
    required this.label,
    required this.phonetic,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: selected ? kBnDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? kBnDark : const Color(0xFFD1D5DB),
            width: selected ? 2.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: selected ? Colors.white : kBnDark,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              phonetic,
              style: TextStyle(
                fontSize: 14,
                color: selected ? Colors.white60 : const Color(0xFF71717A),
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
