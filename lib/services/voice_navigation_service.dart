import 'dart:convert';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────────────────────
// VOICE NAVIGATION SERVICE
// Maps spoken words → app navigation intents
//
// Two-tier approach:
//   1. Local keyword matching (instant, offline, no API)
//   2. Gemini AI fallback for ambiguous phrases (requires free API key)
// ─────────────────────────────────────────────────────────────────────────────

/// Supported navigation destinations
enum VoiceDestination {
  home,           // Mis cuentas / saldos
  transferCell,   // Transferir por celular / Yape / Plin / QR
  transferAccounts, // Transferir a cuentas / banco / interbancario
  pagosRecargas,  // Pagos de servicios / agua / luz / teléfono / recargas
  giros,          // Giros MultiRed
  retiroSinTarjeta, // Retiro sin tarjeta
  loans,          // Préstamos / crédito
  security,       // Seguridad / bloqueo / clave dinámica
  editProfile,    // Perfil / datos personales / actualización
  contactanos,    // Contactar / ayuda / atención
  ubicanos,       // Ubicar / agencias / cajeros
  changeClave,    // Cambiar clave / contraseña
  logout,         // Cerrar sesión / salir
  socialPlans,    // Planes sociales / bonos
  unknown,        // No se pudo determinar
}

class VoiceNavigationResult {
  final VoiceDestination destination;
  final String transcription;
  final String confirmationMessage; // What the app says back to confirm
  final bool usedAI; // true if Gemini was used

  const VoiceNavigationResult({
    required this.destination,
    required this.transcription,
    required this.confirmationMessage,
    this.usedAI = false,
  });
}

class VoiceNavigationService {
  /// Gemini API key — get a free one at https://aistudio.google.com/app/apikey
  static const String _geminiApiKey = 'AQ.Ab8RN6L-sQuKIICONACYjvDFWm7Nc4OG2GulK4m2Rvc5x8CK-Q';

  static const String _geminiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  /// Main entry point: given a spoken phrase, return where to navigate
  static Future<VoiceNavigationResult> resolve(String transcription, String language) async {
    final text = transcription.toLowerCase().trim();

    // Step 1: Try local matching first (fast, offline)
    final localResult = _localMatch(text, language);
    if (localResult != VoiceDestination.unknown) {
      return VoiceNavigationResult(
        destination: localResult,
        transcription: transcription,
        confirmationMessage: _confirmationFor(localResult, language),
        usedAI: false,
      );
    }

    // Step 2: If local fails AND Gemini key is configured, use AI
    if (_geminiApiKey.isNotEmpty) {
      try {
        final aiResult = await _geminiMatch(text, language);
        return VoiceNavigationResult(
          destination: aiResult,
          transcription: transcription,
          confirmationMessage: _confirmationFor(aiResult, language),
          usedAI: true,
        );
      } catch (_) {
        // AI failed, return unknown
      }
    }

    return VoiceNavigationResult(
      destination: VoiceDestination.unknown,
      transcription: transcription,
      confirmationMessage: language == 'ES'
          ? 'No entendí el comando. Diga por ejemplo: "transferir", "mis cuentas" o "pagar agua".'
          : 'Mana entendinichu. Niway: "astachiy", "qollqe" o "unu pagay".',
    );
  }

  // ── LOCAL KEYWORD MATCHING ────────────────────────────────────────────────
  static VoiceDestination _localMatch(String text, String lang) {
    // HOME / SALDOS
    if (_anyOf(text, [
      'saldo', 'cuenta', 'movimiento', 'inicio', 'home', 'principal',
      'mis cuentas', 'mi cuenta', 'balance', 'cuanto tengo', 'cuánta plata',
      'plata', 'dinero', 'ver mi plata', 'cuánto dinero tengo', 'cuánta plata tengo',
      'dónde veo mi saldo', 'cómo veo mi saldo', 'revisar saldo', 'ver mis cuentas',
      // Quechua / Aymara
      'qollqe', 'qallariy', 'yupay', 'uñjaña',
    ])) return VoiceDestination.home;

    // TRANSFERIR POR CELULAR O QR
    if (_anyOf(text, [
      'yape', 'plin', 'bcp', 'celular', 'transferir celular', 'enviar celular',
      'transferencia celular', 'qr', 'código qr', 'escanear', 'ver mi qr',
      'transferir por celular', 'mandar al celular', 'mostrar mi qr',
      'cómo escaneo un qr', 'quiero pagar con qr', 'dónde veo mi qr',
      'dónde está mi qr', 'donde esta mi qr',
      'pasar plata por celular', 'enviar plata al celular',
      'apachiy celular', 'celular apachiri',
    ])) return VoiceDestination.transferCell;

    // TRANSFERIR A CUENTAS
    if (_anyOf(text, [
      'transferir', 'transferencia', 'transferir cuenta', 'mismo banco',
      'interbancaria', 'interbancario', 'cci', 'otro banco', 'enviar dinero',
      'mandar dinero', 'transferir banco', 'pago tarjeta', 'tarjeta credito',
      'bn transferir', 'transferir bn', 'pasar plata', 'enviar plata',
      'mandar plata a cuenta', 'cómo transfiero dinero', 'quiero transferir',
      'astachiy', 'qollqe apachiy',
    ])) return VoiceDestination.transferAccounts;

    // PAGOS Y RECARGAS
    if (_anyOf(text, [
      'agua', 'sedapal', 'sedalib', 'recibo agua',
      'luz', 'enel', 'electro', 'recibo luz', 'electricidad',
      'teléfono', 'telefono', 'cable', 'movistar', 'claro', 'entel', 'bitel',
      'recarga', 'recargar', 'recarga celular', 'saldo celular',
      'pagar', 'pagos', 'servicio', 'servicios', 'recibos',
      'cómo pago mi luz', 'quiero pagar el agua', 'cómo hago una recarga',
      'pagay', 'unu pagay', 'luz pagay',
    ])) return VoiceDestination.pagosRecargas;

    // GIROS
    if (_anyOf(text, [
      'giro', 'giros', 'multired', 'enviar giro', 'emitir giro',
      'giro multired', 'mandar plata por giro', 'enviar dinero a provincia',
      'cómo mando un giro', 'quiero enviar un giro',
      'giro emitiy', 'giro luraña',
    ])) return VoiceDestination.giros;

    // RETIRO SIN TARJETA
    if (_anyOf(text, [
      'retiro', 'retirar', 'sin tarjeta', 'retiro sin tarjeta',
      'código retiro', 'efectivo', 'cajero sin tarjeta', 'sacar plata',
      'sacar dinero', 'cómo saco plata sin tarjeta', 'quiero retirar efectivo',
      'tarjeta illajpi', 'tarjeta janiwa',
    ])) return VoiceDestination.retiroSinTarjeta;

    // PLANES SOCIALES
    if (_anyOf(text, [
      'planes sociales', 'planes', 'bono', 'bonos', 'social', 'ingreso solidario',
      'pensión', 'pension 65', 'juntos', 'qali warma', 'bono yanapay', 'yanapay',
    ])) return VoiceDestination.socialPlans;

    // PRÉSTAMOS
    if (_anyOf(text, [
      'préstamo', 'prestamo', 'préstamos', 'credito', 'crédito',
      'solicitar prestamo', 'simular prestamo', 'cuota',
      'mañakuy', 'qollqe mañakuy',
    ])) return VoiceDestination.loans;

    // SEGURIDAD
    if (_anyOf(text, [
      'seguridad', 'bloquear', 'bloqueo', 'tarjeta bloqueada',
      'clave dinámica', 'cdd', 'token', 'límite', 'limite', 'configurar',
      'waqaychay', 'jark\'aqaña',
    ])) return VoiceDestination.security;

    // PERFIL / DATOS
    if (_anyOf(text, [
      'perfil', 'mis datos', 'actualizar datos', 'datos personales',
      'editar perfil', 'mi información', 'información personal',
      'kikin', 'yatiyäwinaka',
    ])) return VoiceDestination.editProfile;

    // CONTÁCTANOS
    if (_anyOf(text, [
      'contacto', 'contactar', 'ayuda', 'soporte', 'atención al cliente',
      'llamar', 'número', '0800', 'teléfono banco',
    ])) return VoiceDestination.contactanos;

    // UBÍCANOS
    if (_anyOf(text, [
      'ubicar', 'ubicanos', 'agencia', 'cajero', 'sucursal',
      'donde está', 'más cercano', 'mapa',
    ])) return VoiceDestination.ubicanos;

    // CAMBIAR CLAVE
    if (_anyOf(text, [
      'cambiar clave', 'clave internet', 'contraseña', 'cambiar contraseña',
      'nueva clave', 'clave banca', 'cambiar pin',
    ])) return VoiceDestination.changeClave;

    // CERRAR SESIÓN
    if (_anyOf(text, [
      'salir', 'cerrar sesión', 'cerrar sesion', 'logout', 'salir de la app',
      'terminar', 'desconectar',
      'lluqsiy', 'mistuña',
    ])) return VoiceDestination.logout;

    return VoiceDestination.unknown;
  }

  static bool _anyOf(String text, List<String> keywords) {
    for (final kw in keywords) {
      if (text.contains(kw)) return true;
    }
    return false;
  }

  // ── GEMINI AI MATCHING ────────────────────────────────────────────────────
  static Future<VoiceDestination> _geminiMatch(String text, String lang) async {
    const prompt = '''
Eres el asistente de navegación de una app bancaria peruana (Banco de la Nación).
El usuario dijo: "{TEXT}"

Determina a cuál de estas secciones quiere ir (responde SOLO con el identificador exacto):
- home → ver saldos y movimientos de cuenta
- transferCell → transferir por celular, Yape, Plin, QR
- transferAccounts → transferir a cuentas BN, interbancaria, pago tarjeta crédito
- pagosRecargas → pagar agua, luz, teléfono, cable, recargar celular
- giros → emitir giro MultiRed
- retiroSinTarjeta → retiro sin tarjeta en cajero
- loans → solicitar o simular préstamos
- socialPlans → planes sociales, bonos, pensión 65, juntos
- security → seguridad, bloqueo de tarjeta, clave dinámica
- editProfile → editar perfil, actualizar datos personales
- contactanos → contactar al banco, ayuda
- ubicanos → ubicar agencias y cajeros
- changeClave → cambiar clave de internet
- logout → cerrar sesión
- unknown → no se puede determinar

Responde SOLO con uno de los identificadores anteriores, sin explicación.
''';

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt.replaceAll('{TEXT}', text)}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.1,
        'maxOutputTokens': 20,
      }
    });

    final response = await http.post(
      Uri.parse('$_geminiEndpoint?key=$_geminiApiKey'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final answer = (json['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '')
          .trim()
          .toLowerCase();
      return _stringToDestination(answer);
    }
    return VoiceDestination.unknown;
  }

  static VoiceDestination _stringToDestination(String s) {
    switch (s) {
      case 'home': return VoiceDestination.home;
      case 'transfercell': case 'transferCell': return VoiceDestination.transferCell;
      case 'transferaccounts': case 'transferAccounts': return VoiceDestination.transferAccounts;
      case 'pagosrecargas': case 'pagosRecargas': return VoiceDestination.pagosRecargas;
      case 'giros': return VoiceDestination.giros;
      case 'retirosintarjeta': case 'retiroSinTarjeta': return VoiceDestination.retiroSinTarjeta;
      case 'loans': return VoiceDestination.loans;
      case 'socialplans': case 'socialPlans': return VoiceDestination.socialPlans;
      case 'security': return VoiceDestination.security;
      case 'editprofile': case 'editProfile': return VoiceDestination.editProfile;
      case 'contactanos': return VoiceDestination.contactanos;
      case 'ubicanos': return VoiceDestination.ubicanos;
      case 'changeclave': case 'changeClave': return VoiceDestination.changeClave;
      case 'logout': return VoiceDestination.logout;
      default: return VoiceDestination.unknown;
    }
  }

  // ── CONFIRMATION MESSAGES ─────────────────────────────────────────────────
  static String _confirmationFor(VoiceDestination dest, String lang) {
    final Map<VoiceDestination, Map<String, String>> messages = {
      VoiceDestination.home: {
        'ES': 'Abriendo Mis Cuentas y movimientos.',
        'QU': 'Qallariy kutichkani.',
        'AY': 'Qallta chikuruxa.',
      },
      VoiceDestination.transferCell: {
        'ES': 'Abriendo Transferencia por Celular o QR.',
        'QU': 'Celular astachiy kicharikushan.',
        'AY': 'Celular apachiri lukaña.',
      },
      VoiceDestination.transferAccounts: {
        'ES': 'Abriendo Transferencias a Cuentas.',
        'QU': 'Cuenta nisqaman astachiy.',
        'AY': 'Cuenta nayra apachiri.',
      },
      VoiceDestination.pagosRecargas: {
        'ES': 'Abriendo Pagos y Recargas.',
        'QU': 'Pagos y Recargas kicharikushan.',
        'AY': 'Pagos y Recargas lukaña.',
      },
      VoiceDestination.socialPlans: {
        'ES': 'Abriendo información de Planes Sociales y Bonos.',
        'QU': 'Bonos qollqe kichasqa.',
        'AY': 'Bono yatiyäwi lukaña.',
      },
      VoiceDestination.giros: {
        'ES': 'Abriendo Giros MultiRed.',
        'QU': 'Giro MultiRed kicharikushan.',
        'AY': 'Giro MultiRed lukaña.',
      },
      VoiceDestination.retiroSinTarjeta: {
        'ES': 'Abriendo Retiro sin Tarjeta.',
        'QU': 'Tarjeta illajpi orqoy kicharikushan.',
        'AY': 'Tarjeta janiwa oraqaña lukaña.',
      },
      VoiceDestination.loans: {
        'ES': 'Abriendo Préstamos.',
        'QU': 'Préstamo mañakuy kicharikushan.',
        'AY': 'Préstamo mañaña lukaña.',
      },
      VoiceDestination.security: {
        'ES': 'Abriendo Configuración y Seguridad.',
        'QU': 'Waqaychay t\'aqa kicharikushan.',
        'AY': 'Jark\'aqaña chikuru lukaña.',
      },
      VoiceDestination.editProfile: {
        'ES': 'Abriendo Editar Perfil.',
        'QU': 'Perfil allichay kicharikushan.',
        'AY': 'Perfil askichaña lukaña.',
      },
      VoiceDestination.contactanos: {
        'ES': 'Abriendo Contáctanos.',
        'QU': 'Contacto kicharikushan.',
        'AY': 'Contacto lukaña.',
      },
      VoiceDestination.ubicanos: {
        'ES': 'Abriendo Ubícanos: agencias y cajeros.',
        'QU': 'Agencia mashkay kicharikushan.',
        'AY': 'Agencia maskiña lukaña.',
      },
      VoiceDestination.changeClave: {
        'ES': 'Abriendo Cambio de Clave de Internet.',
        'QU': 'Llave tikray kicharikushan.',
        'AY': 'Llavi tikraña lukaña.',
      },
      VoiceDestination.logout: {
        'ES': 'Cerrando sesión. Hasta pronto.',
        'QU': 'Lluqsichkani. Tupananchikkama.',
        'AY': 'Mistuña. Jikisiñkama.',
      },
    };

    final msgs = messages[dest];
    if (msgs == null) return '';
    return msgs[lang] ?? msgs['ES'] ?? '';
  }
}
