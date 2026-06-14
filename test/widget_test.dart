import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:banco_de_la_nacion_app/models/app_state.dart';
import 'package:banco_de_la_nacion_app/services/voice_service.dart';
import 'package:banco_de_la_nacion_app/screens/login_screen.dart';

void main() {
  testWidgets('App renders login screen and show inclusive entrance button', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
          ChangeNotifierProvider(create: (_) => VoiceService()),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Verify that the login screen displays the inclusive entry text.
    expect(find.text('Ingresar con Asistente de Voz'), findsOneWidget);
    expect(find.text('Para adultos mayores · Quechua · Aymara'), findsOneWidget);
  });
}
