# Banco de la Nación App — Módulo Inclusivo 🏦

Proyecto desarrollado para la hackathon **Transformagob 2026**. Esta aplicación es una modernización de la Banca Móvil del Banco de la Nación del Perú, enfocada radicalmente en la **accesibilidad, la inclusión lingüística y la reducción de la brecha digital** para los adultos mayores y poblaciones vulnerables.

## 🌟 Características Principales

*   **Modo Simple Adaptativo:** Una interfaz limpia, con botones de alto contraste y tipografía extragrande, diseñada para usuarios que se sienten abrumados por las interfaces bancarias tradicionales.
*   **Soporte Trilingüe Inclusivo:** Toda la interfaz y el asistente de voz están completamente traducidos a **Español, Quechua y Aymara**, permitiendo a las poblaciones rurales realizar operaciones bancarias en su idioma nativo.
*   **Asistente de Voz Integrado:** Un sistema robusto de `Speech-to-Text` (STT) que permite navegar por la aplicación, realizar consultas y confirmar transacciones utilizando comandos de voz.
*   **Narrador de Pantalla (TTS):** Lectura automática de saldos, opciones y confirmaciones en el idioma seleccionado, ideal para personas con visión reducida.
*   **Autenticación Biométrica Segura:** Flujos simplificados de login usando huella dactilar para evitar el uso complejo de contraseñas y tokens físicos en poblaciones mayores.

## 🛠️ Stack Tecnológico

*   **Framework:** Flutter (Dart)
*   **State Management:** Provider
*   **Voice Recognition:** `speech_to_text` package
*   **Text-to-Speech:** `flutter_tts` package
*   **Platform:** Optimizada para Android (API 31+)

## 🚀 Instalación y Despliegue

### Requisitos Previos
*   Flutter SDK (v3.22.0 o superior)
*   Dart SDK (v3.4.0 o superior)
*   Android Studio o VS Code con plugins de Flutter
*   Dispositivo Android físico (Recomendado para probar el asistente de voz)

### Pasos
1. Clona el repositorio:
   ```bash
   git clone https://github.com/tu-usuario/bn_app_inclusiva.git
   cd bn_app_inclusiva
   ```
2. Instala las dependencias:
   ```bash
   flutter pub get
   ```
3. Ejecuta la aplicación en tu dispositivo conectado:
   ```bash
   flutter run
   ```

> **Nota para Evaluadores:** Recomendamos probar la aplicación en un dispositivo físico real, ya que los emuladores pueden no tener acceso directo al hardware del micrófono, lo cual es indispensable para la experiencia del asistente de voz.

## 💡 Motivación e Impacto

El proyecto nace para solucionar una problemática real del Perú: la **exclusión financiera por barreras tecnológicas y lingüísticas**. Millones de peruanos, especialmente en zonas rurales, encuentran las aplicaciones bancarias confusas, con letras muy pequeñas o en un idioma que no es su lengua materna. 

Este prototipo demuestra que con una arquitectura de software accesible, el **Banco de la Nación** puede empoderar a todos sus usuarios para que realicen operaciones (retiros sin tarjeta, transferencias, pago de servicios) de manera independiente y segura.

---
*Construido con pasión para **Transformagob 2026**.*
