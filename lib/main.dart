import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/app_state.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/inclusive/language_screen.dart';
import 'screens/inclusive/biometric_screen.dart';
import 'screens/inclusive/menu_inclusivo.dart';
import 'screens/inclusive/saldo_screen.dart';
import 'screens/inclusive/retiro_screen.dart';
import 'screens/inclusive/pago_screen.dart';
import 'screens/inclusive/error_screen.dart';
// NUEVA RUTA AGREGADA PARA CUMPLIR EL PROCESO O4.4 (Transferencias)
import 'screens/inclusive/transferencia_screen.dart'; 
import 'screens/inclusive/ayuda_screen.dart';
import 'services/voice_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProvider(create: (context) => VoiceService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banco de la Nación App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // 1. CORRECCIÓN DE TIPOGRAFÍA OBLIGATORIA (MANUAL DE MARCA)
        fontFamily: 'Arial',
        
        // 2. CORRECCIÓN DE COLOR ROJO CORPORATIVO EXACTO
        primaryColor: const Color(0xFFC8102E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC8102E),
          primary: const Color(0xFFC8102E),
          // Verde UOB para botones gigantes de "SÍ"
          secondary: const Color(0xFFA4C100), 
          surface: const Color(0xFFF5F5F5),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFC8102E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/inclusive/language': (context) => const LanguageScreen(),
        '/inclusive/biometric': (context) => const BiometricScreen(),
        '/inclusive/menu': (context) => const MenuInclusivo(),
        '/inclusive/saldo': (context) => const SaldoScreen(),
        '/inclusive/retiro': (context) => const RetiroScreen(),
        '/inclusive/pago': (context) => const PagoScreen(),
        '/inclusive/transferencia': (context) => const TransferenciaScreen(),
        '/inclusive/ayuda': (context) => const AyudaScreen(),
        '/inclusive/error': (context) => const InclusiveErrorScreen(),
      },
    );
  }
}