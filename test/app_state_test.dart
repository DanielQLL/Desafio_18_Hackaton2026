import 'package:flutter_test/flutter_test.dart';
import 'package:banco_de_la_nacion_app/models/app_state.dart';

void main() {
  test('AppState can speak without web-only dependencies', () {
    final state = AppState();

    expect(() => state.speak('Hola', force: true), returnsNormally);
  });
}
