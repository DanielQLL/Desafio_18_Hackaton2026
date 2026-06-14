import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/voice_service.dart';
import '../models/app_state.dart';

class InclusiveLayout extends StatefulWidget {
  final Widget child;

  const InclusiveLayout({super.key, required this.child});

  @override
  State<InclusiveLayout> createState() => _InclusiveLayoutState();
}

class _InclusiveLayoutState extends State<InclusiveLayout> {
  Timer? _inactivityTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _inactivityTimer = Timer(const Duration(seconds: 30), _handleAutoLogout);
  }

  void _resetTimer() {
    _inactivityTimer?.cancel();
    _startTimer();
  }

  void _handleAutoLogout() {
    if (!mounted) return;

    final voiceService = Provider.of<VoiceService>(context, listen: false);
    final state = Provider.of<AppState>(context, listen: false);
    final lang = state.currentLanguage;

    String logoutMsg = "Cerrando sesión por seguridad";
    if (lang == 'QU') {
      logoutMsg = "Hawka wisqasqa sesion securityrayku";
    } else if (lang == 'AY') {
      logoutMsg = "Sesion jist'antaña sumanki securitytaki";
    }

    voiceService.speak(logoutMsg);
    state.logout();

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _resetTimer(),
      onPointerMove: (_) => _resetTimer(),
      onPointerCancel: (_) => _resetTimer(),
      onPointerUp: (_) => _resetTimer(),
      // Each inclusive screen manages its own mic UI — no duplicate FAB here
      child: widget.child,
    );
  }
}
