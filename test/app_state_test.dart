import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/app_state.dart';

void main() {
  test('AppState can speak without web-only dependencies', () {
    final state = AppState();

    expect(() => state.speak('Hola', force: true), returnsNormally);
  });
}
