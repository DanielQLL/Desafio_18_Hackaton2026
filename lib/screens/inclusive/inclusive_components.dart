import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';

// ─── Paleta de colores exacta del mockup ───────────
const Color kBnRed = Color(0xFFC8102E);
const Color kBnDark = Color(0xFF1A1A1A);
const Color kBnGrey = Color(0xFF71717A);
const Color kBnLightGrey = Color(0xFFF4F4F5);
const Color kBnBorder = Color(0xFFE4E4E7);
const Color kBnBg = Color(0xFFF4F4F5);

// ─── Logo BN oficial ─────────────────────────────────
class BnLogo extends StatelessWidget {
  final double height;
  const BnLogo({super.key, this.height = 36});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/bn_logo.png',
      height: height,
      fit: BoxFit.contain,
    );
  }
}

// ─── Barra de progreso segmentada ───────────────────
class BnStepBar extends StatelessWidget {
  final int pasoActual;
  final int totalPasos;
  const BnStepBar({super.key, required this.pasoActual, required this.totalPasos});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalPasos, (i) {
        final done = i + 1 <= pasoActual;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 4,
            decoration: BoxDecoration(
              color: done ? kBnRed : const Color(0xFFE4E4E7),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Header del módulo inclusivo (fiel al mockup) ────
class BnInclusiveHeader extends StatelessWidget {
  final String tituloPaso;
  final int paso;
  final int totalPasos;
  final VoidCallback? onBack;
  final VoidCallback? onLanguageTap;

  const BnInclusiveHeader({
    super.key,
    required this.tituloPaso,
    required this.paso,
    this.totalPasos = 5,
    this.onBack,
    this.onLanguageTap,
  });

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final langLabel = state.currentLanguage == 'ES'
        ? 'Español'
        : state.currentLanguage == 'QU'
            ? 'Quechua'
            : 'Aymara';

    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Fila del logo y botón HC
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                if (onBack != null) ...[
                  GestureDetector(
                    onTap: onBack,
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: kBnDark),
                  ),
                  const SizedBox(width: 10),
                ],
                const BnLogo(height: 34),
                const Spacer(),
                // Botón HC con sol
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F5),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE4E4E7)),
                  ),
                  child: const Center(
                    child: Icon(Icons.light_mode_outlined, size: 20, color: kBnGrey),
                  ),
                ),
              ],
            ),
          ),
          // Línea roja
          Container(height: 2.5, color: kBnRed),
          // Fila del dropdown del idioma
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onLanguageTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFD4D4D8)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language_rounded, size: 16, color: kBnGrey),
                      const SizedBox(width: 6),
                      Text(
                        langLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: kBnDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: kBnGrey),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Fila de título de paso y progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        tituloPaso.toUpperCase(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: kBnGrey,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Paso $paso de $totalPasos',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: kBnGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                BnStepBar(pasoActual: paso, totalPasos: totalPasos),
              ],
            ),
          ),
          // Línea divisoria inferior
          Container(height: 1, color: const Color(0xFFE4E4E7)),
        ],
      ),
    );
  }
}

// ─── Burbuja del asistente de voz ──────────────────
class BnVoiceBubble extends StatelessWidget {
  final String texto;
  final VoidCallback? onTap;
  const BnVoiceBubble({super.key, required this.texto, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE4E4E7), width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: kBnRed,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ASISTENTE DE VOZ',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: kBnGrey,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    texto,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kBnDark,
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
  }
}

// ─── Bottom Navigation unificada ────────────────────
class BnBottomNav extends StatelessWidget {
  final int currentIndex;
  final VoidCallback? onInicio;
  final VoidCallback? onAyuda;

  const BnBottomNav({
    super.key,
    required this.currentIndex,
    this.onInicio,
    this.onAyuda,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE4E4E7), width: 1)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: onInicio,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.home_outlined,
                  color: currentIndex == 0 ? kBnRed : kBnGrey,
                  size: 26,
                ),
                const SizedBox(height: 2),
                Text(
                  'Inicio',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: currentIndex == 0 ? kBnRed : kBnGrey,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAyuda ?? () {
              Navigator.pushNamed(context, '/inclusive/ayuda');
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.help_outline_rounded,
                  color: currentIndex == 1 ? kBnRed : kBnGrey,
                  size: 26,
                ),
                const SizedBox(height: 2),
                Text(
                  'Ayuda',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: currentIndex == 1 ? kBnRed : kBnGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
