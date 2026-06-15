import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';

// Brand colors
const Color kBnRed = Color(0xFFC8102E);
const Color kBnRedLight = Color(0xFFE31B23);
const Color kBnRedDark = Color(0xFF8B0000);
const Color kBnBg = Color(0xFFF8F9FA);
const Color kBnWhite = Colors.white;
const Color kBnTextDark = Color(0xFF212529);
const Color kBnTextLight = Color(0xFF6C757D);

// Premium Styled button
class BnButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;

  const BnButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? Colors.white : kBnRed,
          foregroundColor: isSecondary ? kBnRed : Colors.white,
          side: isSecondary ? const BorderSide(color: kBnRed, width: 1.5) : null,
          elevation: isSecondary ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16 * state.fontSizeMultiplier,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Styled Text Field
class BnTextField extends StatefulWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final int? maxLength;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final bool enabled;

  const BnTextField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.prefixIcon,
    this.validator,
    this.enabled = true,
  });

  @override
  State<BnTextField> createState() => _BnTextFieldState();
}

class _BnTextFieldState extends State<BnTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14 * state.fontSizeMultiplier,
            fontWeight: FontWeight.w600,
            color: kBnTextDark,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          keyboardType: widget.keyboardType,
          maxLength: widget.maxLength,
          enabled: widget.enabled,
          style: TextStyle(fontSize: 15 * state.fontSizeMultiplier),
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: TextStyle(color: kBnTextLight, fontSize: 14 * state.fontSizeMultiplier),
            prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon, color: kBnRed) : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: kBnTextLight,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: widget.enabled ? Colors.white : Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            counterText: "",
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kBnRed, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          validator: widget.validator,
        ),
      ],
    );
  }
}

// CDD validation dialog simulation
class CddVerificationDialog extends StatefulWidget {
  final String operationDetails;
  final VoidCallback onVerified;

  const CddVerificationDialog({
    super.key,
    required this.operationDetails,
    required this.onVerified,
  });

  @override
  State<CddVerificationDialog> createState() => _CddVerificationDialogState();
}

class _CddVerificationDialogState extends State<CddVerificationDialog> {
  bool _showingPushNotification = false;
  bool _autocompleting = false;
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Simulate push notification popping up after 1.5 seconds if CDD is active
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showingPushNotification = true;
        });
      }
    });
  }

  void _triggerAutocomplete() {
    setState(() {
      _autocompleting = true;
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _codeController.text = "834 912";
          _showingPushNotification = false;
          _autocompleting = false;
        });
        // Auto verify after filling
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            Navigator.pop(context);
            widget.onVerified();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                const Icon(
                  Icons.lock_person_rounded,
                  color: kBnRed,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Clave Dinámica Digital",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: kBnRed,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.operationDetails,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: kBnTextLight,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Ingrese el código de 6 dígitos enviado a su app o espere la Clave Dinámica Digital",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: kBnTextDark),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 160,
                      child: TextField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 7,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                        decoration: const InputDecoration(
                          hintText: "000 000",
                          counterText: "",
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_autocompleting)
                  const Column(
                    children: [
                      CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(kBnRed)),
                      SizedBox(height: 8),
                      Text("Autocompletando clave...", style: TextStyle(fontSize: 12, color: kBnTextLight)),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancelar", style: TextStyle(color: kBnTextLight)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kBnRed,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            if (_codeController.text.isNotEmpty) {
                              Navigator.pop(context);
                              widget.onVerified();
                            }
                          },
                          child: const Text("Confirmar", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          // Simulated Push Notification Banner overlay on top of dialog
          if (_showingPushNotification)
            Positioned(
              top: -85,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _triggerAutocomplete,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: kBnRed,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.security,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Banca Móvil BN",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      "Ahora",
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  "Toca aquí para autocompletar tu Clave Dinámica: 834 912",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

// Receipt/Constancia display utility
class TransactionReceiptDialog extends StatelessWidget {
  final String title;
  final List<Map<String, String>> receiptDetails;

  const TransactionReceiptDialog({
    super.key,
    required this.title,
    required this.receiptDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 12),
            const Text(
              "Operación Exitosa",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kBnTextDark,
              ),
            ),
            const Divider(height: 30, thickness: 1.2),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: receiptDetails.length,
                separatorBuilder: (c, i) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = receiptDetails[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["label"] ?? "",
                        style: const TextStyle(
                          color: kBnTextLight,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item["value"] ?? "",
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            color: kBnTextDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const Divider(height: 30, thickness: 1.2),
            const Text(
              "La constancia ha sido enviada a su correo electrónico registrado.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kBnTextLight,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: BnButton(
                    text: "Compartir",
                    isSecondary: true,
                    icon: Icons.share,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Constancia compartida correctamente")),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BnButton(
                    text: "Entendido",
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// Floating accessibility button
class AccessibilityFloatingButton extends StatelessWidget {
  const AccessibilityFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    return Positioned(
      bottom: 86,
      right: 16,
      child: FloatingActionButton(
        mini: true,
        backgroundColor: kBnRed,
        foregroundColor: Colors.white,
        tooltip: "Accesibilidad / Accesibilidad nisqa",
        onPressed: () => _showAccessibilityOptions(context, state),
        child: const Icon(Icons.accessibility_new_rounded, size: 22),
      ),
    );
  }

  void _showAccessibilityOptions(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Accesibilidad / Yanapakuy",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kBnRed),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const Divider(),
                  
                  // Text Size Toggle
                  ListTile(
                    leading: const Icon(Icons.text_fields_rounded, color: kBnRed),
                    title: const Text("Agrandar Letras", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(
                      state.fontSizeMultiplier > 1.0 ? "Tamaño Grande Activado" : "Tamaño Normal",
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Switch(
                      value: state.fontSizeMultiplier > 1.0,
                      activeColor: kBnRed,
                      onChanged: (val) {
                        state.toggleFontSize();
                        setSheetState(() {});
                      },
                    ),
                  ),
                  
                  // TTS Voice Toggle
                  ListTile(
                    leading: const Icon(Icons.volume_up_rounded, color: kBnRed),
                    title: const Text("Narrador de Voz (Lectura)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(
                      state.ttsEnabled ? "Lectura de opciones activa" : "Lectura desactivada",
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Switch(
                      value: state.ttsEnabled,
                      activeColor: kBnRed,
                      onChanged: (val) {
                        state.toggleTts();
                        setSheetState(() {});
                      },
                    ),
                  ),
                  
                  // Language selector
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    child: Text(
                      "Idioma de Aplicación / Simi / Aru:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: kBnTextDark),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _langButton(context, state, "Español", "ES", setSheetState),
                        _langButton(context, state, "Quechua", "QU", setSheetState),
                        _langButton(context, state, "Aymara", "AY", setSheetState),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _langButton(
    BuildContext context,
    AppState state,
    String label,
    String code,
    StateSetter setSheetState,
  ) {
    bool isSelected = state.currentLanguage == code;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : kBnTextDark,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      selectedColor: kBnRed,
      backgroundColor: Colors.grey[200],
      checkmarkColor: Colors.white,
      onSelected: (val) {
        if (val) {
          state.setLanguage(code);
          setSheetState(() {});
        }
      },
    );
  }
}

// Voice Narration Caption Overlay
class VoiceNarrationOverlay extends StatelessWidget {
  const VoiceNarrationOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    if (!state.isNarrating) return const SizedBox.shrink();

    return Positioned(
      top: 10,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 4))
            ],
          ),
          child: Row(
            children: [
              // Equalizer Voice animation
              const Icon(Icons.mic, color: Colors.greenAccent, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.currentLanguage == 'ES' ? "Asistente de Voz" :
                      state.currentLanguage == 'QU' ? "Rimay Yanapakuq" : "Aru Yanapiri",
                      style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.lastNarratedText,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

