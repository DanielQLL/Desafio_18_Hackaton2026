import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import 'components.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _dniController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppState>(context, listen: false);
      if (state.ttsEnabled) {
        state.speak(state.t('OptionsLogin'));
      }
    });
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate network request
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          final state = Provider.of<AppState>(context, listen: false);
          bool success = state.login(_dniController.text, _passwordController.text);
          setState(() {
            _isLoading = false;
          });

          if (success) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: kBnRed,
                content: Text(
                  "DNI o Clave incorrectos. Intente de nuevo.",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: kBnBg,
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
                    child: IntrinsicHeight(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 40),
                            // Top Logo
                            Center(
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: const BoxDecoration(
                                  color: kBnRed,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  "BN",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Center(
                              child: Text(
                                "Banco de la Nación",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: kBnRed,
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                state.t('Bienvenido'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: kBnTextLight,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            
                            // Input fields
                            BnTextField(
                              label: state.t('DNI'),
                              placeholder: "Escriba su DNI de 8 dígitos",
                              controller: _dniController,
                              keyboardType: TextInputType.number,
                              maxLength: 8,
                              prefixIcon: Icons.badge_outlined,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return "El DNI es obligatorio";
                                }
                                if (val.length != 8) {
                                  return "El DNI debe tener 8 dígitos";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            BnTextField(
                              label: state.t('Clave'),
                              placeholder: "Ingrese su clave de 6 dígitos",
                              controller: _passwordController,
                              isPassword: true,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              prefixIcon: Icons.lock_outline,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return "La clave es obligatoria";
                                }
                                if (val.length != 6) {
                                  return "La clave debe tener 6 dígitos";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            
                            // "La olvidé" link
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  state.speak("Abriendo recuperación de clave.");
                                  _showRecoverClaveDialog(context, state);
                                },
                                child: Text(
                                  state.t('OlvidoClave'),
                                  style: TextStyle(
                                    color: kBnRed,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13 * state.fontSizeMultiplier,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Ingresar Button
                            BnButton(
                              text: state.t('Ingresar'),
                              isLoading: _isLoading,
                              onPressed: _handleLogin,
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Generate key & CDD buttons
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton.icon(
                                    onPressed: () {
                                      state.speak("Abriendo generación de clave de internet.");
                                      _showGenerateClaveDialog(context, state);
                                    },
                                    icon: const Icon(Icons.key, size: 16, color: kBnRed),
                                    label: Text(
                                      state.t('GenerarClave'),
                                      style: TextStyle(
                                        color: kBnRed, 
                                        fontWeight: FontWeight.bold, 
                                        fontSize: 12.5 * state.fontSizeMultiplier,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(width: 1.2, height: 20, color: Colors.grey[300]),
                                Expanded(
                                  child: TextButton.icon(
                                    onPressed: () {
                                      state.speak("Abriendo vinculación de Clave Dinámica Digital.");
                                      _showCddActivationDialog(context, state);
                                    },
                                    icon: const Icon(Icons.security, size: 16, color: kBnRed),
                                    label: Text(
                                      state.t('ActivarCDD'),
                                      style: TextStyle(
                                        color: kBnRed, 
                                        fontWeight: FontWeight.bold, 
                                        fontSize: 12.5 * state.fontSizeMultiplier,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const Spacer(),
                            
                            // Bottom utilities: Ubícanos & Soporte 24h
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _utilityIcon(
                                    icon: Icons.map_outlined,
                                    label: state.t('Ubicanos'),
                                    onTap: () {
                                      state.speak("Abriendo mapa de agencias y cajeros cercanos.");
                                      _showUbicanosDialog(context);
                                    },
                                    fontSizeMultiplier: state.fontSizeMultiplier,
                                  ),
                                  _utilityIcon(
                                    icon: Icons.headset_mic_outlined,
                                    label: state.t('Ayuda24h'),
                                    onTap: () {
                                      state.speak("Abriendo canales de atención telefónica.");
                                      _showContactanosDialog(context);
                                    },
                                    fontSizeMultiplier: state.fontSizeMultiplier,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const AccessibilityFloatingButton(),
            const VoiceNarrationOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _utilityIcon({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required double fontSizeMultiplier,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: kBnRed, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: kBnTextDark,
                fontWeight: FontWeight.bold,
                fontSize: 11.5 * fontSizeMultiplier,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog: Generate Key
  void _showGenerateClaveDialog(BuildContext context, AppState state) {
    final dniC = TextEditingController();
    final cardC = TextEditingController();
    final emailC = TextEditingController();
    final keyC = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Generar Clave de Internet", style: TextStyle(color: kBnRed, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Crea tu clave de internet de 6 dígitos para acceder a la app.",
                  style: TextStyle(fontSize: 12, color: kBnTextLight),
                ),
                const SizedBox(height: 16),
                BnTextField(
                  label: "Número de DNI",
                  placeholder: "DNI de 8 dígitos",
                  controller: dniC,
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                ),
                const SizedBox(height: 12),
                BnTextField(
                  label: "Tarjeta de Débito (16 dígitos)",
                  placeholder: "4557 8812 XXXX XXXX",
                  controller: cardC,
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                ),
                const SizedBox(height: 12),
                BnTextField(
                  label: "Correo Electrónico",
                  placeholder: "ejemplo@correo.com",
                  controller: emailC,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                BnTextField(
                  label: "Cree su Clave (6 dígitos)",
                  placeholder: "******",
                  controller: keyC,
                  isPassword: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: kBnTextLight)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kBnRed),
              onPressed: () {
                if (dniC.text.length == 8 && cardC.text.length == 16 && emailC.text.contains("@") && keyC.text.length == 6) {
                  state.clave = keyC.text;
                  state.dni = dniC.text;
                  state.cardNo = "${cardC.text.substring(0, 4)} ${cardC.text.substring(4, 8)} ${cardC.text.substring(8, 12)} ${cardC.text.substring(12)}";
                  state.email = emailC.text;
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Clave generada exitosamente. Se ha enviado un email de confirmación. Inicie sesión ahora."),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Complete todos los campos de forma correcta")),
                  );
                }
              },
              child: const Text("Generar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Dialog: Recover Key
  void _showRecoverClaveDialog(BuildContext context, AppState state) {
    final dniC = TextEditingController();
    final cardC = TextEditingController();
    final newKeyC = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Recuperar Clave", style: TextStyle(color: kBnRed, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Valide su identidad y defina una nueva clave de internet de 6 dígitos.",
                  style: TextStyle(fontSize: 12, color: kBnTextLight),
                ),
                const SizedBox(height: 16),
                BnTextField(
                  label: "Número de DNI",
                  placeholder: "DNI de 8 dígitos",
                  controller: dniC,
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                ),
                const SizedBox(height: 12),
                BnTextField(
                  label: "Tarjeta de Débito (16 dígitos)",
                  placeholder: "Ingrese número de su tarjeta",
                  controller: cardC,
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                ),
                const SizedBox(height: 12),
                BnTextField(
                  label: "Nueva Clave (6 dígitos)",
                  placeholder: "******",
                  controller: newKeyC,
                  isPassword: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: kBnTextLight)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kBnRed),
              onPressed: () {
                if (dniC.text.length == 8 && cardC.text.length == 16 && newKeyC.text.length == 6) {
                  state.clave = newKeyC.text;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Clave restablecida exitosamente. Constancia enviada a su correo. Inicie sesión ahora."),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Complete los datos de forma correcta")),
                  );
                }
              },
              child: const Text("Restablecer", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Dialog: Activar CDD (Clave Dinámica Digital)
  void _showCddActivationDialog(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Activar Clave Dinámica Digital", style: TextStyle(color: kBnRed, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "La Clave Dinámica Digital (CDD) vincula de forma segura este dispositivo a sus transacciones bancarias, permitiendo:",
                style: TextStyle(fontSize: 12, color: kBnTextDark),
              ),
              const SizedBox(height: 12),
              _bulletItem("Confirmar transferencias de forma inmediata sin token físico."),
              _bulletItem("Autocompletar la clave a través de notificaciones push."),
              _bulletItem("Tener mayor seguridad contra clonaciones y fraudes."),
              const SizedBox(height: 16),
              const Text(
                "Nota: Requiere preafiliación previa en cualquier agencia del Banco de la Nación.",
                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: kBnTextLight),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar", style: TextStyle(color: kBnTextLight)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kBnRed),
              onPressed: () {
                state.activateCDD();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("¡Clave Dinámica Digital vinculada a este dispositivo de forma exitosa!"),
                  ),
                );
              },
              child: const Text("Vincular Dispositivo", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _bulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontWeight: FontWeight.bold, color: kBnRed)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 11.5, color: kBnTextDark))),
        ],
      ),
    );
  }

  // Branch locator dialog helper (for unlogged users)
  void _showUbicanosDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(16),
            height: 480,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Ubícanos MultiRed", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kBnRed)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Text(
                  "Visualiza agencias, cajeros (ATM) y agentes cercanos a tu ubicación",
                  style: TextStyle(fontSize: 11, color: kBnTextLight),
                ),
                const SizedBox(height: 12),
                
                // Simulated Map Graphic
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 40, top: 50,
                        child: Icon(Icons.location_on, color: kBnRed, size: 28),
                      ),
                      Positioned(
                        right: 60, top: 30,
                        child: Icon(Icons.location_on, color: Colors.blue.shade800, size: 28),
                      ),
                      Positioned(
                        left: 90, bottom: 40,
                        child: Icon(Icons.location_on, color: Colors.green.shade800, size: 28),
                      ),
                      const Center(
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.my_location, size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // List of nearest locations
                Expanded(
                  child: ListView(
                    children: [
                      _locationTile(
                        icon: Icons.apartment,
                        title: "Agencia Central Lima - BN",
                        desc: "Av. República de Panamá 3664 · 1.2km",
                        hours: "Lunes a Viernes 8:00 AM - 5:30 PM",
                        color: kBnRed,
                      ),
                      _locationTile(
                        icon: Icons.atm,
                        title: "Cajero ATM MultiRed",
                        desc: "Estación Metro Javier Prado · 800m",
                        hours: "Abierto 24 Horas",
                        color: Colors.blue.shade800,
                      ),
                      _locationTile(
                        icon: Icons.store,
                        title: "Agente Corresponsal MultiRed - Farmacia Mas",
                        desc: "Calle Las Orquídeas 120 · 400m",
                        hours: "Lunes a Sábado 8:00 AM - 10:00 PM",
                        color: Colors.green.shade800,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _locationTile({
    required IconData icon,
    required String title,
    required String desc,
    required String hours,
    required Color color,
  }) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                  Text(desc, style: const TextStyle(fontSize: 10, color: kBnTextLight)),
                  Text(hours, style: TextStyle(fontSize: 9, color: Colors.green.shade800, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hotline help dialog
  void _showContactanosDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Contáctanos BN", style: TextStyle(color: kBnRed, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.headset_mic, size: 48, color: kBnRed),
              const SizedBox(height: 12),
              const Text(
                "Central de ayuda y reporte de tarjetas las 24 horas del día.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: const Text("Línea Gratuita Nacional", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: const Text("0-800-10-700", style: TextStyle(fontSize: 12, color: kBnTextLight)),
                trailing: const Icon(Icons.call),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Llamando a Línea Gratuita...")),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar", style: TextStyle(color: kBnTextLight)),
            )
          ],
        );
      },
    );
  }
}
