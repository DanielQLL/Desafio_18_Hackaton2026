import 'package:flutter/material.dart';
import 'dart:math';
import '../utils/speech_helper.dart';

class Movement {
  final String date;
  final String description;
  final double amount;
  final bool isCredit;
  final String type; // 'Soles' or 'Dolares' or 'CTS'

  Movement({
    required this.date,
    required this.description,
    required this.amount,
    required this.isCredit,
    required this.type,
  });
}

class Giro {
  final String date;
  final String name;
  final String dni;
  final double amount;
  final String giroCode;
  final String giroKey;
  final String status;

  Giro({
    required this.date,
    required this.name,
    required this.dni,
    required this.amount,
    required this.giroCode,
    required this.giroKey,
    this.status = 'Activo',
  });
}

class AppState extends ChangeNotifier {
  // Authentication & Profile State
  bool isLoggedIn = false;
  String dni = "";
  String name = "JUAN CARLOS ALVARADO";
  String email = "j.alvarado@correo.com";
  String phone = "987654321";
  String carrier = "Movistar";
  String cardNo = "4557 8812 3456 7890";
  String clave = "123456";
  bool cddActivated = false;

  // Account Balances
  double savingsSoles = 2450.80;
  double savingsDollars = 120.00;
  double savingsContable = 2500.00;
  double ctsSoles = 8920.40;
  String accountNo = "00-011-123456";
  String cci = "018-011-000011123456-78";

  // Loan Info
  double loanBalance = 12450.00;
  double nextLoanQuota = 385.50;
  String nextLoanQuotaDate = "25/06/2026";
  bool isLoanPreapproved = true;

  // Card & Security Controls
  bool isInternetPurchasesEnabled = true;
  bool isForeignConsumptionEnabled = false;
  bool isTransfersEnabled = true;
  bool isNotificationsEnabled = true;
  bool isCardBlocked = false;
  bool isCellularTransferAffiliated = true;

  // Exchange Rate
  double usdBuy = 3.742;
  double usdSell = 3.785;

  // Accessibility States
  double fontSizeMultiplier = 1.0; // 1.0 (Normal), 1.3 (Grande) or 1.6 (Muy Grande)
  bool ttsEnabled = false;
  String currentLanguage = 'ES'; // 'ES', 'QU' (Quechua), 'AY' (Aymara)
  String lastNarratedText = "";
  bool isNarrating = false;
  bool simpleModeEnabled = false;

  // Saved Contacts for quick cell transfers
  List<Map<String, String>> contacts = [
    {"name": "Maria Fe Romero", "phone": "998877665", "bank": "Yape"},
    {"name": "Carlos Gomez", "phone": "912345678", "bank": "Plin"},
    {"name": "Andrea Castro", "phone": "955443322", "bank": "Banco de la Nación"},
    {"name": "Luis Perez", "phone": "966554433", "bank": "BCP"},
    {"name": "Sofia Diaz", "phone": "944332211", "bank": "Interbank"},
  ];

  // Saved Favorites for bank transfers
  List<Map<String, String>> favorites = [
    {"alias": "Mamá", "name": "Rosa Alvarado", "number": "00-011-998877", "type": "BN"},
    {"alias": "Alquiler", "name": "Inmobiliaria Lima", "number": "018-011-0000222333-11", "type": "CCI"},
  ];

  // Movements (Latest 20)
  List<Movement> movements = [
    Movement(date: "12 Jun 2026", description: "TRANSFERENCIA CELULAR YAPE A: Maria Fe Romero", amount: 50.00, isCredit: false, type: "Soles"),
    Movement(date: "11 Jun 2026", description: "RECARGA CELULAR MOVISTAR 987654321", amount: 20.00, isCredit: false, type: "Soles"),
    Movement(date: "10 Jun 2026", description: "ABONO DE HABERES ESTADO PERUANO", amount: 2500.00, isCredit: true, type: "Soles"),
    Movement(date: "09 Jun 2026", description: "PAGO SERVICIO ENEL COD. 998273", amount: 124.50, isCredit: false, type: "Soles"),
    Movement(date: "08 Jun 2026", description: "TRANSFERENCIA RECIBIDA PLIN DE: Carlos Gomez", amount: 100.00, isCredit: true, type: "Soles"),
    Movement(date: "05 Jun 2026", description: "INTERESES GANADOS AHORROS", amount: 2.40, isCredit: true, type: "Soles"),
    Movement(date: "01 Jun 2026", description: "PAGO SERVICIO SEDAPAL COD. 129038", amount: 45.80, isCredit: false, type: "Soles"),
    Movement(date: "30 May 2026", description: "DEPOSITO EN EFECTIVO AGENTE MULTIRED", amount: 300.00, isCredit: true, type: "Soles"),
    Movement(date: "28 May 2026", description: "COMPRA INTERNET NETFLIX", amount: 44.90, isCredit: false, type: "Soles"),
    Movement(date: "25 May 2026", description: "CUOTA PRESTAMO MULTIRED", amount: 385.50, isCredit: false, type: "Soles"),
    Movement(date: "24 May 2026", description: "ABONO CTS COMPENSACION", amount: 450.00, isCredit: true, type: "CTS"),
    Movement(date: "20 May 2026", description: "COMPRA INTERNET SPOTIFY", amount: 20.90, isCredit: false, type: "Soles"),
    Movement(date: "18 May 2026", description: "PAGO TARJETA DE CREDITO BCP", amount: 180.00, isCredit: false, type: "Soles"),
    Movement(date: "15 May 2026", description: "RETIRO CAJERO MULTIRED", amount: 200.00, isCredit: false, type: "Soles"),
    Movement(date: "10 May 2026", description: "ABONO DE HABERES ESTADO PERUANO", amount: 2500.00, isCredit: true, type: "Soles"),
    Movement(date: "08 May 2026", description: "COMPRA SUPERMERCADOS METRO", amount: 154.20, isCredit: false, type: "Soles"),
    Movement(date: "05 May 2026", description: "INTERESES CTS", amount: 35.80, isCredit: true, type: "CTS"),
    Movement(date: "01 May 2026", description: "TRANSFERENCIA CELULAR A: Luis Perez", amount: 40.00, isCredit: false, type: "Soles"),
    Movement(date: "28 Abr 2026", description: "PAGO CLARO HOGAR", amount: 109.00, isCredit: false, type: "Soles"),
    Movement(date: "25 Abr 2026", description: "CUOTA PRESTAMO MULTIRED", amount: 385.50, isCredit: false, type: "Soles"),
  ];

  // Active Giros
  List<Giro> giros = [];

  // Active Retiro sin tarjeta Code
  String? activeRetiroCode;
  int retiroTimeLeft = 0; // seconds

  // Dictionary of translation mapping
  final Map<String, Map<String, String>> _dict = {
    'DNI': {
      'ES': 'Número de DNI',
      'QU': 'DNI Yupay',
      'AY': 'DNI Jakhu',
    },
    'Ingresar': {
      'ES': 'Ingresar',
      'QU': 'Yaykuy',
      'AY': 'Mantataña',
    },
    'Clave': {
      'ES': 'Clave de Internet (6 dígitos)',
      'QU': 'Internet Imasillu (6 yupaykuna)',
      'AY': 'Internet Imasillu (6 jakhunaka)',
    },
    'Hola': {
      'ES': 'Hola',
      'QU': 'Allillanchu',
      'AY': 'Kamisaraki',
    },
    'Bienvenido': {
      'ES': 'Bienvenido a tu Banca Móvil',
      'QU': 'Banca Móvilniykiman allin hamuy',
      'AY': 'Banca Móvilma wali jutata',
    },
    'SaldoDisp': {
      'ES': 'Saldo Disponible',
      'QU': 'Qullqi kapusuqniyki',
      'AY': 'Qullqima utjiri',
    },
    'SaldoContable': {
      'ES': 'Saldo Contable',
      'QU': 'Qullqi yupasqa',
      'AY': 'Qullqi jakhuta',
    },
    'CuentaAhorros': {
      'ES': 'Cuenta Ahorros Multired',
      'QU': 'Multired Ahorro Huchha',
      'AY': 'Multired Ahorro Jakhu',
    },
    'Inicio': {
      'ES': 'Inicio',
      'QU': 'Qallariy',
      'AY': 'Qalltawi',
    },
    'Operaciones': {
      'ES': 'Operaciones',
      'QU': 'Ruraykuna',
      'AY': 'Lurañanaka',
    },
    'Seguridad': {
      'ES': 'Seguridad',
      'QU': 'Amachay',
      'AY': 'Jark\'aqasiña',
    },
    'Mas': {
      'ES': 'Más',
      'QU': 'Astawan',
      'AY': 'Juk\'ampis',
    },
    'Transferir': {
      'ES': 'Transferir',
      'QU': 'Astachiy',
      'AY': 'Khithaqaña',
    },
    'PagarServicios': {
      'ES': 'Pagar Luz/Agua',
      'QU': 'K\'anchayta/Yakuta pagay',
      'AY': 'Qhana/Uma pagaña',
    },
    'RecargarCel': {
      'ES': 'Recargar Celular',
      'QU': 'Kuyuq rimayta winay',
      'AY': 'Kuyuq rimiri phuqt\'ayaña',
    },
    'YapePlin': {
      'ES': 'Yape y Plin',
      'QU': 'Yape chaskiy',
      'AY': 'Yape uñt\'ayaña',
    },
    'UltMovimientos': {
      'ES': 'Últimos Movimientos (20)',
      'QU': 'Qhipa Kuyuykuna (20)',
      'AY': 'Qhipa Kuyt\'awinaka (20)',
    },
    'OlvidoClave': {
      'ES': '¿Olvidó su clave?',
      'QU': '¿Qunqarqankichu imasilluykita?',
      'AY': '¿Imasilluma armt\'astati?',
    },
    'GenerarClave': {
      'ES': 'Generar Clave',
      'QU': 'Imasillu Ruray',
      'AY': 'Imasillu Luraña',
    },
    'ActivarCDD': {
      'ES': 'Activar CDD',
      'QU': 'CDD Kawsarichiy',
      'AY': 'CDD Nukt\'ayaña',
    },
    'Ubicanos': {
      'ES': 'Ubícanos',
      'QU': 'Tarillawayku',
      'AY': 'Jikxatasipxita',
    },
    'Ayuda24h': {
      'ES': 'Ayuda 24h',
      'QU': 'Yanapay 24h',
      'AY': 'Yanapaña 24h',
    },
    'OptionsLogin': {
      'ES': 'Opciones disponibles: Número de DNI, Clave de Internet, botón de ingresar, recuperar clave, generar clave, activar Clave Dinámica Digital, ubícanos y ayuda telefónica.',
      'QU': 'Atikuy ruraykuna: DNI yupay, Internet Imasillu, yaykuy butun, imasillu ruray, CDD kawsarichiy, Tarillawayku, yanapaypas.',
      'AY': 'Lurañanaka: DNI jakhu, Internet Imasillu, mantataña butun, imasillu luraña, CDD nukt\'ayaña, Jikxatasipxita, yanapañampi.',
    },
    'OptionsHome': {
      'ES': 'Opciones disponibles: Consultar saldo de ahorros y CTS, copiar Código CCI, ver últimos movimientos de cuenta, consultar tipo de cambio, y generar código QR para recibir transferencias.',
      'QU': 'Atikuy ruraykuna: Qullqi kapusuqniyki qhawari, CCI copyay, qhipa kuyuykuna, USD tikray qhawari, QR ruraypas.',
      'AY': 'Lurañanaka: Qullqima utjiri uñjaña, CCI copiaña, qhipa kuyt\'awinaka, USD mayjt\'awi uñjaña, QR lurañampi.',
    },
    'OptionsOperations': {
      'ES': 'Opciones disponibles: Transferencias al mismo banco, transferencias interbancarias inmediatas y diferidas, transferencias a celular por Yape y Plin, pago de servicios públicos de agua y luz, recarga de celular, y emisión de giros nacionales.',
      'QU': 'Atikuy ruraykuna: BN astachiy, interbancaria astachiy, Yape Plin astachiy, yakuta k\'anchayta pagay, celular winay, giros ruraypas.',
      'AY': 'Lurañanaka: BN khithaqaña, interbancaria khithaqaña, Yape Plin khithaqaña, uma qhana pagaña, celular phuqt\'ayaña, giros lurañampi.',
    },
    'OptionsSecurity': {
      'ES': 'Opciones disponibles: Bloqueo de tarjeta de débito, configurar límites y habilitar compras por internet, habilitar consumos en el extranjero, y activar notificaciones de operaciones.',
      'QU': 'Atikuy ruraykuna: Tarjeta hark\'ay, internet rantiy amachay, hawaman rantiy kawsarichiy, willaykuna allichaypas.',
      'AY': 'Lurañanaka: Tarjeta jark\'aña, internet alaña amachaña, anqax alawi nukt\'ayaña, yatiyawinaka lurañampi.',
    },
    'OptionsProfile': {
      'ES': 'Opciones disponibles: Actualizar datos de contacto, simular y solicitar préstamos MultiRed, localizador de oficinas y cajeros automáticos, y ayuda en línea.',
      'QU': 'Atikuy ruraykuna: Perfil allichay, MultiRed prestamo simulay, Tarillawayku mapakuna, yanapay maskaypas.',
      'AY': 'Lurañanaka: Perfil phuqt\'ayaña, MultiRed prestamo simulaña, Jikxatasipxita mapanaka, yanapa uñjañampi.',
    }
  };

  // Translate a key
  String t(String key) {
    if (_dict.containsKey(key)) {
      return _dict[key]![currentLanguage] ?? _dict[key]!['ES']!;
    }
    return key;
  }

  // Accessibility: Font Size toggling
  void toggleFontSize() {
    if (fontSizeMultiplier == 1.0) {
      fontSizeMultiplier = 1.3;
    } else if (fontSizeMultiplier == 1.3) {
      fontSizeMultiplier = 1.6;
    } else {
      fontSizeMultiplier = 1.0;
    }
    String text = "";
    if (fontSizeMultiplier == 1.0) {
      text = currentLanguage == 'ES' ? "Tamaño de letra normal" :
             currentLanguage == 'QU' ? "Allin qillqa sayay" : "Normal qillqa tupu";
    } else if (fontSizeMultiplier == 1.3) {
      text = currentLanguage == 'ES' ? "Tamaño de letra grande" :
             currentLanguage == 'QU' ? "Hatun qillqa sayay" : "Jach'a qillqa tupu";
    } else {
      text = currentLanguage == 'ES' ? "Tamaño de letra muy grande" :
             currentLanguage == 'QU' ? "Ancha hatun qillqa sayay" : "Sinti jach'a qillqa tupu";
    }
    speak(text, force: true);
    notifyListeners();
  }

  void setFontSizeMultiplier(double multiplier) {
    fontSizeMultiplier = multiplier;
    String text = "";
    if (multiplier == 1.0) {
      text = currentLanguage == 'ES' ? "Tamaño de letra normal" :
             currentLanguage == 'QU' ? "Allin qillqa sayay" : "Normal qillqa tupu";
    } else if (multiplier == 1.3) {
      text = currentLanguage == 'ES' ? "Tamaño de letra grande" :
             currentLanguage == 'QU' ? "Hatun qillqa sayay" : "Jach'a qillqa tupu";
    } else {
      text = currentLanguage == 'ES' ? "Tamaño de letra muy grande" :
             currentLanguage == 'QU' ? "Ancha hatun qillqa sayay" : "Sinti jach'a qillqa tupu";
    }
    speak(text, force: true);
    notifyListeners();
  }

  void toggleSimpleMode() {
    simpleModeEnabled = !simpleModeEnabled;
    String text = "";
    if (simpleModeEnabled) {
      text = currentLanguage == 'ES' ? "Modo simplificado activado" :
             currentLanguage == 'QU' ? "Huklla ruraykuna kawsarisqa" : "Modo simple nukt'ayata";
    } else {
      text = currentLanguage == 'ES' ? "Modo simplificado desactivado" :
             currentLanguage == 'QU' ? "Huklla ruraykuna wañuchisqa" : "Modo simple jiwt'ayata";
    }
    speak(text, force: true);
    notifyListeners();
  }

  // Accessibility: Language setup
  void setLanguage(String lang) {
    currentLanguage = lang;
    String speakText = "";
    if (lang == 'ES') speakText = "Idioma cambiado a Español";
    if (lang == 'QU') speakText = "Rimay t'ikrasqa Quechua simiman";
    if (lang == 'AY') speakText = "Arusa mayjt'ayata Aymara aruru";
    speak(speakText, force: true);
    notifyListeners();
  }

  // Accessibility: TTS toggle
  void toggleTts() {
    ttsEnabled = !ttsEnabled;
    if (ttsEnabled) {
      String extraOptionsText = "";
      if (!isLoggedIn) {
        extraOptionsText = t('OptionsLogin');
      } else {
        extraOptionsText = t('OptionsHome');
      }
      speak(
        (currentLanguage == 'ES' ? "Narrador de voz activado. " :
         currentLanguage == 'QU' ? "Kuyuq rimay kawsarisqa. " : "Aru khithiri nukt'ayata. ") + extraOptionsText,
        force: true
      );
    } else {
      isNarrating = false;
    }
    notifyListeners();
  }

  // Speak method
  void speak(String text, {bool force = false}) {
    if (!ttsEnabled && !force) return;
    
    lastNarratedText = text;
    isNarrating = true;
    notifyListeners();

    SpeechHelper.speak(text);

    // Hide animation after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (lastNarratedText == text) {
        isNarrating = false;
        notifyListeners();
      }
    });
  }

  // Login
  bool login(String enteredDni, String enteredClave) {
    if (enteredDni.length == 8 && enteredClave == clave) {
      dni = enteredDni;
      isLoggedIn = true;
      speak("Inicio de sesión exitoso. Bienvenido a su banca móvil.");
      notifyListeners();
      return true;
    }
    return false;
  }

  // Logout
  void logout() {
    isLoggedIn = false;
    speak("Sesión cerrada correctamente.");
    notifyListeners();
  }

  // Change password
  void changeClave(String newClave) {
    clave = newClave;
    notifyListeners();
  }

  // Activate CDD
  void activateCDD() {
    cddActivated = true;
    notifyListeners();
  }

  // Update profile
  void updateProfile(String newPhone, String newCarrier, String newEmail) {
    phone = newPhone;
    carrier = newCarrier;
    email = newEmail;
    notifyListeners();
  }

  // Toggle card settings
  void toggleCardSetting(String setting) {
    switch (setting) {
      case 'internet':
        isInternetPurchasesEnabled = !isInternetPurchasesEnabled;
        break;
      case 'foreign':
        isForeignConsumptionEnabled = !isForeignConsumptionEnabled;
        break;
      case 'transfers':
        isTransfersEnabled = !isTransfersEnabled;
        break;
      case 'notifications':
        isNotificationsEnabled = !isNotificationsEnabled;
        break;
      case 'cellular':
        isCellularTransferAffiliated = !isCellularTransferAffiliated;
        break;
    }
    notifyListeners();
  }

  // Block card
  void blockCard(String reason) {
    isCardBlocked = true;
    notifyListeners();
  }

  // Unblock card (helper)
  void unblockCard() {
    isCardBlocked = false;
    notifyListeners();
  }

  // Add movement (internal helper)
  void _addMovement(String desc, double amt, {bool isCredit = false, String type = "Soles"}) {
    movements.insert(0, Movement(
      date: _formatCurrentDate(),
      description: desc,
      amount: amt,
      isCredit: isCredit,
      type: type,
    ));
    if (movements.length > 30) {
      movements.removeLast();
    }
  }

  // Transfer Same Bank
  bool transferSameBank(String targetAccount, double amount, String reference) {
    if (savingsSoles >= amount) {
      savingsSoles -= amount;
      savingsContable = savingsSoles + 49.20; // maintain contable diff
      _addMovement("TRANSF. MISMO BANCO A CTA: $targetAccount ($reference)", amount);
      notifyListeners();
      return true;
    }
    return false;
  }

  // Transfer Cellular
  bool transferCellular(String contactPhone, String contactName, double amount, String bank) {
    if (savingsSoles >= amount) {
      savingsSoles -= amount;
      savingsContable = savingsSoles + 49.20;
      _addMovement("TRANSF. CELULAR $bank A: $contactName ($contactPhone)", amount);
      notifyListeners();
      return true;
    }
    return false;
  }

  // Transfer Interbank
  bool transferInterbank(String targetCci, String targetName, double amount, bool isInmediate) {
    if (savingsSoles >= amount) {
      savingsSoles -= amount;
      savingsContable = savingsSoles + 49.20;
      String speed = isInmediate ? "INMEDIATA" : "DIFERIDA";
      _addMovement("TRANSF. INTERBANCARIA $speed A: $targetName CCI: $targetCci", amount);
      notifyListeners();
      return true;
    }
    return false;
  }

  // Pay Credit Card other banks
  bool payCreditCard(String bank, String cardNumber, double amount) {
    if (savingsSoles >= amount) {
      savingsSoles -= amount;
      savingsContable = savingsSoles + 49.20;
      _addMovement("PAGO TARJETA CREDITO $bank NUM: **** ${cardNumber.substring(max(0, cardNumber.length - 4))}", amount);
      notifyListeners();
      return true;
    }
    return false;
  }

  // Recharge cell
  bool rechargeCellular(String operatorName, String phoneNumber, double amount) {
    if (savingsSoles >= amount) {
      savingsSoles -= amount;
      savingsContable = savingsSoles + 49.20;
      _addMovement("RECARGA CELULAR $operatorName AL: $phoneNumber", amount);
      notifyListeners();
      return true;
    }
    return false;
  }

  // Pay Service
  bool payService(String serviceType, String company, String code, double amount) {
    if (savingsSoles >= amount) {
      savingsSoles -= amount;
      savingsContable = savingsSoles + 49.20;
      _addMovement("PAGO SERVICIO $serviceType - $company COD: $code", amount);
      notifyListeners();
      return true;
    }
    return false;
  }

  // Emit Giro
  String emitGiro(String beneficiaryName, String beneficiaryDni, double amount) {
    double totalCost = amount + 3.00; // S/3 fee
    if (savingsSoles >= totalCost) {
      savingsSoles -= totalCost;
      savingsContable = savingsSoles + 49.20;

      // Generate random codes
      var rnd = Random();
      String code = (rnd.nextInt(900000) + 100000).toString();
      String key = (rnd.nextInt(9000) + 1000).toString();

      giros.insert(0, Giro(
        date: _formatCurrentDate(),
        name: beneficiaryName,
        dni: beneficiaryDni,
        amount: amount,
        giroCode: code,
        giroKey: key,
      ));

      _addMovement("EMISION DE GIRO A: $beneficiaryName DNI: $beneficiaryDni", totalCost);
      notifyListeners();
      return code;
    }
    return "";
  }

  // Generate Retiro Sin Tarjeta code
  String generateRetiroSinTarjeta(double amount) {
    if (savingsSoles >= amount) {
      var rnd = Random();
      String code = (rnd.nextInt(900000) + 100000).toString();
      activeRetiroCode = code;
      retiroTimeLeft = 600; // 10 minutes (600 seconds)
      
      savingsSoles -= amount;
      savingsContable = savingsSoles + 49.20;
      _addMovement("GEN. RETIRO SIN TARJETA COD: $code", amount);
      notifyListeners();
      return code;
    }
    return "";
  }

  // Request/Amplify Loan
  void addLoan(double amount) {
    loanBalance += amount;
    savingsSoles += amount;
    savingsContable = savingsSoles + 49.20;
    _addMovement("DESEMBOLSO DE PRESTAMO MULTIRED", amount, isCredit: true);
    notifyListeners();
  }

  // Date formatter helper
  String _formatCurrentDate() {
    var now = DateTime.now();
    List<String> months = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Set", "Oct", "Nov", "Dic"];
    return "${now.day} ${months[now.month - 1]} ${now.year}";
  }
}
