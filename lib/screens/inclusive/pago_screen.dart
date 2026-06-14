import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import 'inclusive_components.dart';
import '../../widgets/confirmacion_widget.dart';
import '../../widgets/inclusive_layout.dart';

/// PANTALLA — Pagar Luz o Agua (adaptada al diseño mockup)
class PagoScreen extends StatefulWidget {
  const PagoScreen({super.key});
  @override
  State<PagoScreen> createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
  String? _servicio;
  final _codigoCtrl = TextEditingController();
  bool _confirmando = false;
  bool _pagado = false;

  static const _servicios = {
    'luz': {'empresa': 'ENEL Distribución', 'monto': 124.50},
    'agua': {'empresa': 'SEDAPAL', 'monto': 45.80},
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = Provider.of<AppState>(context, listen: false);
      s.speak(
        s.currentLanguage == 'ES'
            ? '¿Qué servicio quieres pagar? Toca Luz o Agua.'
            : '¿Imatam paganki? K\'anchay o Yakuta.',
        force: true,
      );
    });
  }

  @override
  void dispose() {
    _codigoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final lang = state.currentLanguage;

    // Estado: Pagado
    if (_pagado) {
      return InclusiveLayout(
        child: Scaffold(
          backgroundColor: kBnBg,
          body: SafeArea(
            child: Column(
            children: [
              const BnInclusiveHeader(
                tituloPaso: 'Pago realizado',
                paso: 5,
                totalPasos: 5,
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F5E9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 64),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          lang == 'ES' ? '¡Pago realizado!' : '¡Pagasqaña!',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF4CAF50)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          lang == 'ES'
                              ? 'Tu pago fue registrado correctamente.'
                              : 'Pagayki allinmi registrasqa.',
                          style: const TextStyle(fontSize: 16, color: kBnGrey, height: 1.4, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 36),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kBnDark,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 2,
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                lang == 'ES' ? 'VOLVER AL MENÚ' : 'KUTIY MENUMAN',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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

    // Estado: Confirmando pago
    if (_confirmando) {
      final srv = _servicios[_servicio!]!;
      return ConfirmacionWidget(
        pregunta: lang == 'ES'
            ? '¿Quieres pagar tu ${_servicio == "luz" ? "Luz" : "Agua"}?'
            : '¿${_servicio == "luz" ? "K'anchay" : "Yakuta"} pagankichu?',
        descripcion: '${srv["empresa"]}\nMonto: S/ ${(srv["monto"] as double).toStringAsFixed(2)}',
        textoSi: lang == 'ES' ? 'SÍ, PAGAR' : 'ARÍ, PAGAY',
        textoNo: lang == 'ES' ? 'NO, ME EQUIVOQUÉ' : 'MANAN, KUTIY',
        onSi: () {
          state.payService(
            _servicio == 'luz' ? 'LUZ' : 'AGUA',
            srv["empresa"] as String,
            _codigoCtrl.text,
            srv["monto"] as double,
          );
          state.speak(lang == 'ES' ? '¡Pago realizado!' : 'Pagasqaña!', force: true);
          setState(() {
            _confirmando = false;
            _pagado = true;
          });
        },
        onNo: () => setState(() => _confirmando = false),
      );
    }

    // Estado: Selección de servicio
    final bubbleText = lang == 'ES'
        ? '¿Qué servicio quieres pagar hoy? Toca Luz o Agua.'
        : '¿Imatam paganki? K\'anchay o Yakuta.';

    return InclusiveLayout(
      child: Scaffold(
        backgroundColor: kBnBg,
        body: SafeArea(
          child: Column(
          children: [
            BnInclusiveHeader(
              tituloPaso: 'Pagar servicios',
              paso: 4,
              totalPasos: 5,
              onLanguageTap: () => Navigator.pushReplacementNamed(context, '/inclusive/language'),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                children: [
                  BnVoiceBubble(texto: bubbleText, onTap: () => state.speak(bubbleText, force: true)),
                  const SizedBox(height: 24),

                  // Tarjetas de servicio
                  Row(
                    children: [
                      Expanded(
                        child: _ServicioCard(
                          icono: Icons.bolt_rounded,
                          nombre: lang == 'ES' ? 'Luz' : 'K\'anchay',
                          empresa: 'ENEL',
                          monto: 'S/ 124.50',
                          color: const Color(0xFFEAB308), // Color amarillo
                          selected: _servicio == 'luz',
                          onTap: () {
                            setState(() => _servicio = 'luz');
                            state.speak('Luz. ENEL. Ciento veinticuatro soles.', force: true);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ServicioCard(
                          icono: Icons.water_drop_rounded,
                          nombre: lang == 'ES' ? 'Agua' : 'Yakuy',
                          empresa: 'SEDAPAL',
                          monto: 'S/ 45.80',
                          color: const Color(0xFF0284C7), // Color azul cielo
                          selected: _servicio == 'agua',
                          onTap: () {
                            setState(() => _servicio = 'agua');
                            state.speak('Agua. SEDAPAL. Cuarenta y cinco soles.', force: true);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Caja de entrada para el código
                  Text(
                    lang == 'ES' ? 'Tu número de recibo' : 'Recibopa numeron',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: kBnDark),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _codigoCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    decoration: InputDecoration(
                      hintText: lang == 'ES' ? 'Escribe aquí tu número' : 'Churay kaypi numerota',
                      hintStyle: const TextStyle(fontSize: 14, color: kBnGrey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFD4D4D8)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFD4D4D8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: kBnRed, width: 2.0),
                      ),
                      prefixIcon: const Icon(Icons.receipt_long_rounded, color: kBnRed),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Botón continuar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBnDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                      onPressed: () {
                        if (_servicio == null || _codigoCtrl.text.isEmpty) {
                          state.speak(
                            lang == 'ES'
                                ? 'Por favor, elige luz o agua y escribe tu número de recibo.'
                                : 'Luz o yakuta akllay.',
                            force: true,
                          );
                          return;
                        }
                        setState(() => _confirmando = true);
                      },
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          lang == 'ES' ? 'IR A PAGAR' : 'PAGAYMAN RIY',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
}

class _ServicioCard extends StatelessWidget {
  final IconData icono;
  final String nombre, empresa, monto;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ServicioCard({
    required this.icono,
    required this.nombre,
    required this.empresa,
    required this.monto,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? color : const Color(0xFFD4D4D8), width: 1.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icono, color: selected ? Colors.white : color, size: 36),
            const SizedBox(height: 8),
            Text(
              nombre,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: selected ? Colors.white : kBnDark,
              ),
            ),
            Text(
              empresa,
              style: TextStyle(
                fontSize: 12,
                color: selected ? Colors.white70 : kBnGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              monto,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
