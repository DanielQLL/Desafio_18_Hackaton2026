import 'package:flutter/material.dart';
import '../screens/inclusive/inclusive_components.dart';
import 'inclusive_layout.dart';

/// PANTALLA 5 — Confirmación SÍ / NO (fiel al mockup Screen 5)
class ConfirmacionWidget extends StatelessWidget {
  final String pregunta;
  final String descripcion;
  final String textoSi;
  final String textoNo;
  final VoidCallback onSi;
  final VoidCallback onNo;

  const ConfirmacionWidget({
    super.key,
    required this.pregunta,
    required this.descripcion,
    this.textoSi = 'SÍ, QUIERO',
    this.textoNo = 'NO, ME EQUIVOQUÉ',
    required this.onSi,
    required this.onNo,
  });

  @override
  Widget build(BuildContext context) {
    return InclusiveLayout(
      child: Scaffold(
        backgroundColor: kBnBg,
        body: SafeArea(
        child: Column(
          children: [
            // Header
            const BnInclusiveHeader(
              tituloPaso: 'Confirmar retiro',
              paso: 4,
              totalPasos: 5,
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                children: [
                  // Asistente de Voz
                  BnVoiceBubble(texto: pregunta),
                  const SizedBox(height: 32),

                  // Ícono retro de cajero/tarjeta
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kBnDark, width: 2.5),
                      ),
                      child: const Icon(
                        Icons.credit_card_off_outlined,
                        size: 64,
                        color: kBnDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Descripción / Duración de la clave
                  Text(
                    descripcion,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: kBnGrey,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Fila de dos botones gigantes (SÍ / NO)
                  Row(
                    children: [
                      // Botón SÍ (Verde)
                      Expanded(
                        child: GestureDetector(
                          onTap: onSi,
                          child: Container(
                            height: 180,
                            decoration: BoxDecoration(
                              color: const Color(0xFF84CC16), // Verde lima vibrante
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF84CC16).withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: kBnDark,
                                  size: 44,
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  textoSi,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: kBnDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Botón NO (Rojo)
                      Expanded(
                        child: GestureDetector(
                          onTap: onNo,
                          child: Container(
                            height: 180,
                            decoration: BoxDecoration(
                              color: const Color(0xFFB91C1C), // Rojo vibrante
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFB91C1C).withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.cancel_outlined,
                                  color: Colors.white,
                                  size: 44,
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  textoNo,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom Nav
            BnBottomNav(
              currentIndex: 0,
              onInicio: onNo,
              onAyuda: () {},
            ),
          ],
        ),
      ),
    ));
  }
}
