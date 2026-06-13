import 'package:flutter/material.dart';
import 'components.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _statusText = "Iniciando sistema de seguridad...";

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();

    _runStartupChecks();
  }

  void _runStartupChecks() async {
    // Step 1: Initial secure boot simulation
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _statusText = "Verificando versión de la aplicación...";
      });
    }

    // Step 2: Version verification simulation
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _statusText = "Comprobando Clave Dinámica Digital...";
      });
    }

    // Step 3: Finish and navigate
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBnRed,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Circular Emblem Logo BN
              Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "BN",
                    style: TextStyle(
                      color: kBnRed,
                      fontWeight: FontWeight.w900,
                      fontSize: 44,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Banco de la Nación",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  letterSpacing: 0.5,
                ),
              ),
              const Text(
                "El banco de todos los peruanos",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const Spacer(),
              
              // Animated progress indicator
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _statusText,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "v4.8.2 · Conexión Encriptada SSL",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
