import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../models/app_state.dart';
import 'components.dart';
import '../widgets/voice_navigation_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    
    // Check if card is blocked. If so, show a warning banner but let them see dashboard.
    // However, if they try to do operations, they'll be blocked.
    
    final List<Widget> tabs = [
      const HomeTab(),
      const OperationsTab(),
      const SecurityTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      backgroundColor: state.simpleModeEnabled ? kBnBg : const Color(0xFF121317),
      drawer: state.simpleModeEnabled ? null : const NormalNavigationDrawer(),
      appBar: (state.simpleModeEnabled)
          ? AppBar(
              backgroundColor: kBnRed,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "BN",
                          style: TextStyle(
                            color: kBnRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Banco de la Nación",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  // Vista Adulto Mayor removed from header, moved to sidebar
                ],
              ),
            )
          : (state.showAccountDetails && state.currentTab == 0)
              ? null
              : (state.currentTab == 2)
                  ? null
                  : AppBar(
                      backgroundColor: const Color(0xFF121317),
                      elevation: 0,
                      leading: state.currentTab == 0
                          ? Builder(
                              builder: (context) => IconButton(
                                icon: const Icon(Icons.menu, color: Color(0xFFFF4D2D)),
                                onPressed: () => Scaffold.of(context).openDrawer(),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.arrow_back, color: Color(0xFFFF4D2D)),
                              onPressed: () => state.setTab(0),
                            ),
                      title: Text(
                        state.currentTab == 0
                            ? state.t('MisCuentas')
                            : state.currentTab == 1
                                ? state.t('Operaciones')
                                : state.currentTab == 2
                                    ? state.t('Seguridad')
                                    : state.t('MiPerfil'),
                        style: const TextStyle(
                          color: Color(0xFFFF4D2D),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      actions: state.currentTab == 0
                          ? [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: InkWell(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MiQrScreen())),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFFFF4D2D).withValues(alpha: 0.3)),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.qr_code_2, color: Color(0xFFFF4D2D), size: 16),
                                        SizedBox(width: 4),
                                        Text(
                                          "MI QR",
                                          style: TextStyle(
                                            color: Color(0xFFFF4D2D),
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.star, color: Color(0xFFFF4D2D)),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Añadido a favoritos")),
                                  );
                                },
                              ),
                            ]
                          : [],
                    ),
      body: SafeArea(
        child: Stack(
        children: [
          Column(
            children: [
              if (state.isCardBlocked)
                Container(
                  color: Colors.black87,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Su tarjeta Multired está BLOQUEADA por seguridad.",
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: () => state.unblockCard(),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
                        child: const Text("Desbloquear", style: TextStyle(color: Colors.lightBlueAccent, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              Expanded(child: state.simpleModeEnabled ? SimpleDashboardView(state: state) : tabs[state.currentTab]),
            ],
          ),
        ],
      )),
      bottomNavigationBar: null,
    );
  }
}

// ------------------ TABS ------------------

// 1. HOME TAB
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _showFullNumbers = false;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    const darkBg = Color(0xFF121317);
    const brandOrange = Color(0xFFFF4D2D);
    const brandGreen = Color(0xFF2EC38D);
    const brandGray = Color(0xFF1E1F23);
    const textMuted = Color(0xFF9CA3AF);
    const separator = Color(0xFF2A2A2A);

    if (state.showAccountDetails) {
      // SCREEN 2: ACCOUNT DETAILS VIEW
      return Container(
        color: darkBg,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sticky-like custom header (since Scaffold AppBar is null)
              Container(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
                color: darkBg,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: brandOrange, size: 24),
                          onPressed: () {
                            state.setShowAccountDetails(false);
                          },
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Cuenta ahorro",
                          style: TextStyle(
                            color: brandOrange,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.credit_card_outlined, color: brandOrange, size: 24),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Mostrando tarjetas vinculadas")),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Account Identification Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _showFullNumbers = !_showFullNumbers;
                        });
                        state.speak(
                          _showFullNumbers
                              ? "Mostrando número de cuenta y CCI completo"
                              : "Ocultando números de cuenta y CCI"
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _showFullNumbers ? Icons.visibility : Icons.visibility_off,
                            color: brandOrange,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Mostrar el Nº Cuenta y el CCI",
                            style: TextStyle(
                              color: brandOrange,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Nº Cuenta: ${_showFullNumbers ? state.accountNo : "**-***-**4921"}",
                      style: const TextStyle(
                        color: textMuted,
                        fontSize: 13,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Nº Cuenta Interbancario (CCI): ${_showFullNumbers ? state.cci : "***-***-*********4921-12"}",
                      style: const TextStyle(
                        color: textMuted,
                        fontSize: 13,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Balance Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const Text(
                      "S/ 1,450.25",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Saldo disponible",
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Saldo contable: S/ 1,450.25",
                      style: TextStyle(
                        color: brandGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Transaction List Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Mis movimientos",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Movements List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: min(6, state.movements.length),
                      itemBuilder: (context, index) {
                        final movement = state.movements[index];
                        final isNegative = !movement.isCredit;
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: separator, width: 1),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      movement.description.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    if (movement.category.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        movement.category.toUpperCase(),
                                        style: const TextStyle(
                                          color: textMuted,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${isNegative ? '-' : ''} S/ ${movement.amount.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color: isNegative ? brandOrange : Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    movement.date,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              // Mimicking the home indicator of mobile devices
              Center(
                child: Container(
                  width: 120,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    }

    // SCREEN 1: MAIN HOME VIEW
    return Container(
      color: darkBg,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Currency Exchange rate banner
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.monetization_on, color: brandOrange, size: 18),
                  SizedBox(width: 6),
                  Text(
                    "Dí“LAR REF. COMPRA 3.35 VENTA 3.44",
                    style: TextStyle(
                      color: brandOrange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.expand_more, color: brandOrange, size: 16),
                ],
              ),
            ),

            // Greeting Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.t('Hola') + "!",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          state.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    "DOMINGO, 14 DE JUNIO DE 2026",
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Accounts List Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.only(bottom: 8),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFF343539), width: 1),
                  ),
                ),
                child: const Text(
                  "Mis cuentas en soles",
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Main Account Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: brandGray,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
                ),
                elevation: 0,
                child: InkWell(
                  onTap: () {
                    state.setShowAccountDetails(true);
                    state.speak("Ingresando al detalle de la cuenta de ahorros");
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Cuenta Ahorro",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "**_***_**0636",
                              style: TextStyle(
                                color: textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  "S/ 200.50",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  state.t('SaldoDisp').toUpperCase(),
                                  style: const TextStyle(
                                    color: textMuted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.chevron_right,
                              color: brandOrange,
                              size: 24,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),



            // Promotional Banners Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // Banner 1: Pagos con QR
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00BFA5), Color(0xFF00897B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "¡Realiza pagos más rápidos pagando con QR!",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF00897B),
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MiQrScreen()));
                                },
                                child: const Text(
                                  "Hazlo aquí",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Transform.rotate(
                          angle: -0.2,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.qr_code_2,
                              color: Color(0xFF00897B),
                              size: 42,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Banner 2: Afiliación celular
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.15),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Transform.rotate(
                          angle: 0.2,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: brandGray,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.smartphone,
                              color: brandOrange,
                              size: 42,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                "Afilia un celular para realizar tus operaciones",
                                style: TextStyle(
                                  color: brandGray,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: brandOrange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  state.setTab(1);
                                  state.setOperationsFlow("trans_cell");
                                },
                                child: const Text(
                                  "Hazlo aquí",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// QR Modal Dialog
void showQrDialog(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: DefaultTabController(
            length: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              height: 440,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: kBnRed,
                    unselectedLabelColor: kBnTextLight,
                    indicatorColor: kBnRed,
                    tabs: [
                      Tab(text: "Recibir Pago (Mi QR)"),
                      Tab(text: "Escanear QR"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // TAB 1: GENERATE QR
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Presenta este código para recibir transferencias",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: kBnTextLight),
                            ),
                            const SizedBox(height: 16),
                            // Simulated QR Code Graphic
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!, width: 2),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Mock QR Grid
                                  Icon(Icons.qr_code, size: 160, color: Colors.grey[900]),
                                  // Center logo
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      "BN",
                                      style: TextStyle(color: kBnRed, fontWeight: FontWeight.bold, fontSize: 10),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              "Ahorros: ${state.accountNo}",
                              style: const TextStyle(fontSize: 11, color: kBnTextLight),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("QR guardado en Galería")),
                                    );
                                  },
                                  icon: const Icon(Icons.download, size: 16, color: kBnRed),
                                  label: const Text("Descargar", style: TextStyle(color: kBnRed, fontSize: 12)),
                                ),
                                const SizedBox(width: 16),
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Enlace para compartir copiado")),
                                    );
                                  },
                                  icon: const Icon(Icons.share, size: 16, color: kBnRed),
                                  label: const Text("Compartir", style: TextStyle(color: kBnRed, fontSize: 12)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // TAB 2: ESCANEAR QR
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Escanea el código QR de otro cliente BN o sube una imagen de tu galería",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: kBnTextLight),
                            ),
                            const SizedBox(height: 16),
                            // Simulated Camera View finder
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: kBnRed, width: 2),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.center_focus_weak,
                                  color: kBnRed,
                                  size: 48,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            BnButton(
                              text: "Subir desde Galería",
                              icon: Icons.photo_library_outlined,
                              isSecondary: true,
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("QR leído exitosamente: Destinatario: Andrea Castro")),
                                );
                                // Send user directly to transfer screen
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// 2. OPERATIONS TAB
class OperationsTab extends StatefulWidget {
  const OperationsTab({super.key});

  @override
  State<OperationsTab> createState() => _OperationsTabState();
}

class _OperationsTabState extends State<OperationsTab> {
  // To handle subviews inside the Operations tab (e.g. transfer form, recharge form, pay utility)
  // We can use a stack or simple navigator/conditional rendering. 
  // Conditional rendering makes it look like a smooth SPA!
  
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final activeFlow = state.operationsFlow;
    
    // Back handler
    Widget wrapFlow(Widget flowWidget, String title) {
      return WillPopScope(
        onWillPop: () async {
          state.setTab(0);
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: kBnTextDark,
            elevation: 1,
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                state.setTab(0);
              },
            ),
          ),
          body: flowWidget,
        ),
      );
    }

    if (activeFlow == "menu") {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => state.setOperationsFlow("trans_bn"),
              child: const Text("Ir a Transferencias"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => state.setOperationsFlow("pay_water"),
              child: const Text("Ir a Pago de Agua"),
            ),
          ],
        ),
      );
    }
    
    // Sub Flow Widget builders
    switch (activeFlow) {
      case "trans_bn":
        return wrapFlow(const TransferSameBankFlow(), "Transferencia Mismo Banco");
      case "trans_cell":
        return wrapFlow(const TransferCellularFlow(), "Transferencia a Celular");
      case "trans_inter":
        return wrapFlow(const TransferInterbankFlow(), "Transferencia Interbancaria");
      case "trans_tc":
        return wrapFlow(const PayCreditCardFlow(), "Pago de Tarjeta de Crédito");
      case "pay_water":
        return wrapFlow(const PayServiceFlow(serviceType: "Agua"), "Pago de Agua");
      case "pay_electricity":
        return wrapFlow(const PayServiceFlow(serviceType: "Luz"), "Pago de Luz");
      case "pay_phone":
        return wrapFlow(const PayServiceFlow(serviceType: "Teléfono"), "Pago de Telefonía");
      case "recharge":
        return wrapFlow(const RechargeFlow(), "Recarga de Celular");
      case "giro":
        return wrapFlow(const EmitGiroFlow(), "Girar Dinero");
      case "withdrawal":
        return wrapFlow(const CardlessWithdrawalFlow(), "Retiro sin Tarjeta");
      default:
        return Container();
    }
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required String desc,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: kBnRed),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: kBnTextDark)),
      subtitle: Text(desc, style: const TextStyle(fontSize: 11, color: kBnTextLight)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: kBnTextLight),
      onTap: onTap,
    );
  }
}

class CategoryHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const CategoryHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color.withOpacity(0.9),
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// 3. SECURITY TAB
class SecurityTab extends StatefulWidget {
  const SecurityTab({super.key});

  @override
  State<SecurityTab> createState() => _SecurityTabState();
}

class _SecurityTabState extends State<SecurityTab> {
  final _reasonController = TextEditingController();

  // Timer & Code for CDD
  Timer? _timer;
  int _secondsLeft = 30;
  String _token = "820 415";

  // Card Limits
  double _atmLimit = 1500.0;
  double _posLimit = 5000.0;

  // Transfer Limits & wallets
  double _cellLimit = 500.0;
  String _preferredWallet = "Yape";

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _reasonController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsLeft > 1) {
            _secondsLeft--;
          } else {
            _secondsLeft = 30;
            final random = Random();
            final code = 100000 + random.nextInt(900000);
            final s = code.toString();
            _token = "${s.substring(0, 3)} ${s.substring(3)}";
          }
        });
      }
    });
  }

  void _showBlockDialog(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1F23),
          title: const Text("Bloquear Tarjeta", style: TextStyle(color: Color(0xFFFF4D2D), fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "¿Está seguro de bloquear su tarjeta Multired de forma definitiva? Esta operación inhabilitará retiros y compras de inmediato.",
                style: TextStyle(fontSize: 13, color: Colors.white70),
              ),
              const SizedBox(height: 16),
              BnTextField(
                label: "Motivo del bloqueo",
                placeholder: "Ej. Robo, pérdida, fraude",
                controller: _reasonController,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4D2D)),
              onPressed: () {
                if (_reasonController.text.isNotEmpty) {
                  Navigator.pop(context);
                  state.blockCard(_reasonController.text);
                  _reasonController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Su tarjeta ha sido BLOQUEADA. Comuníquese al 0-800-10-700 para reposición")),
                  );
                }
              },
              child: const Text("Bloquear", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    const darkBg = Color(0xFF121212);
    const appOrange = Color(0xFFF2522E);
    const appCyan = Color(0xFF77CBD4);
    const appBorder = Color(0xFF2A2A2A);

    if (state.securitySubFlow == "menu") {
      return Container(
        color: darkBg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Custom Header matching HTML mockup but with back arrow to Tab 0
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: appBorder, width: 1),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: appOrange, size: 28),
                    onPressed: () {
                      state.setTab(0);
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Configuración y seguridad",
                    style: TextStyle(
                      color: appOrange,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Settings list items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _menuItem(
                    icon: Icons.credit_card_off_outlined,
                    title: "Bloqueo de tarjetas",
                    color: appOrange,
                    isActive: true,
                    onTap: () {
                      state.setSecuritySubFlow("bloqueo");
                      state.speak("Ingresando a bloqueo de tarjetas");
                    },
                  ),
                  _menuItem(
                    icon: Icons.lock_open_outlined,
                    title: "Clave Dinámica Digital",
                    color: appCyan,
                    isActive: false,
                    onTap: () {
                      state.setSecuritySubFlow("cdd");
                      state.speak("Ingresando a clave dinámica digital");
                    },
                  ),
                  _menuItem(
                    icon: Icons.credit_card_outlined,
                    title: "Configurar tarjetas",
                    color: appCyan,
                    isActive: false,
                    onTap: () {
                      state.setSecuritySubFlow("config_tarjetas");
                      state.speak("Ingresando a configurar tarjetas");
                    },
                  ),
                  _menuItem(
                    icon: Icons.contact_phone_outlined,
                    title: "Configurar transferencia a contacto",
                    color: appCyan,
                    isActive: false,
                    onTap: () {
                      state.setSecuritySubFlow("config_transfer");
                      state.speak("Ingresando a configurar transferencia a contacto");
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // SUB-FLOWS
    if (state.securitySubFlow == "bloqueo") {
      return Container(
        color: darkBg,
        child: Column(
          children: [
            _subHeader(
              title: "Bloqueo de tarjetas",
              color: appOrange,
              onBack: () => state.setSecuritySubFlow("menu"),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Plastic card simulation
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF333333), Color(0xFF111111)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "MultiRed Débito",
                              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFFF4D2D), borderRadius: BorderRadius.circular(4)),
                              child: const Text("VISA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          state.cardNo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              state.name,
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                            const Text(
                              "VAL 12/28",
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  BnButton(
                    text: "Bloquear Tarjeta Definitivo",
                    icon: Icons.lock,
                    onPressed: () => _showBlockDialog(context, state),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "El bloqueo es irreversible. En caso de pérdida, robo o sospecha de fraude, proceda de inmediato. También puede comunicarse a la línea gratuita 0-800-10-700 (24 horas).",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (state.securitySubFlow == "config_tarjetas") {
      return Container(
        color: darkBg,
        child: Column(
          children: [
            _subHeader(
              title: "Configurar tarjetas",
              color: appCyan,
              onBack: () => state.setSecuritySubFlow("menu"),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: const Color(0xFF1E1F23),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text("Compras por Internet", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white)),
                          subtitle: const Text("Permitir compras en páginas web y apps", style: TextStyle(fontSize: 11, color: Colors.grey)),
                          activeColor: appOrange,
                          value: state.isInternetPurchasesEnabled,
                          onChanged: (val) {
                            state.toggleCardSetting('internet');
                          },
                        ),
                        const Divider(height: 1, color: appBorder),
                        SwitchListTile(
                          title: const Text("Consumo en el extranjero", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white)),
                          subtitle: const Text("Habilita compras y retiros fuera del Perú", style: TextStyle(fontSize: 11, color: Colors.grey)),
                          activeColor: appOrange,
                          value: state.isForeignConsumptionEnabled,
                          onChanged: (val) {
                            state.toggleCardSetting('foreign');
                          },
                        ),
                        const Divider(height: 1, color: appBorder),
                        SwitchListTile(
                          title: const Text("Transferencias y Retiros", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white)),
                          subtitle: const Text("Permite transacciones interbancarias y cajeros", style: TextStyle(fontSize: 11, color: Colors.grey)),
                          activeColor: appOrange,
                          value: state.isTransfersEnabled,
                          onChanged: (val) {
                            state.toggleCardSetting('transfers');
                          },
                        ),
                        const Divider(height: 1, color: appBorder),
                        SwitchListTile(
                          title: const Text("Notificaciones de Transacción", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white)),
                          subtitle: const Text("Recibe notificaciones en tiempo real por cada consumo", style: TextStyle(fontSize: 11, color: Colors.grey)),
                          activeColor: appOrange,
                          value: state.isNotificationsEnabled,
                          onChanged: (val) {
                            state.toggleCardSetting('notifications');
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Límites diarios de tarjeta",
                    style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    color: const Color(0xFF1E1F23),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Límite Diario Cajero (ATM)", style: TextStyle(color: Colors.white70, fontSize: 13)),
                              Text("S/ ${_atmLimit.toStringAsFixed(0)}", style: const TextStyle(color: appCyan, fontSize: 14, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Slider(
                            min: 0,
                            max: 3000,
                            divisions: 30,
                            activeColor: appCyan,
                            inactiveColor: appBorder,
                            value: _atmLimit,
                            onChanged: (val) {
                              setState(() {
                                _atmLimit = val;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Límite Diario Compras (POS)", style: TextStyle(color: Colors.white70, fontSize: 13)),
                              Text("S/ ${_posLimit.toStringAsFixed(0)}", style: const TextStyle(color: appCyan, fontSize: 14, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Slider(
                            min: 0,
                            max: 10000,
                            divisions: 20,
                            activeColor: appCyan,
                            inactiveColor: appBorder,
                            value: _posLimit,
                            onChanged: (val) {
                              setState(() {
                                _posLimit = val;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          BnButton(
                            text: "Guardar límites",
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Límites de tarjeta guardados correctamente")),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (state.securitySubFlow == "cdd") {
      return Container(
        color: darkBg,
        child: Column(
          children: [
            _subHeader(
              title: "Clave Dinámica Digital",
              color: appCyan,
              onBack: () => state.setSecuritySubFlow("menu"),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1F23),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: appBorder, width: 1),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          state.cddActivated ? Icons.gpp_good : Icons.gpp_maybe,
                          color: state.cddActivated ? Colors.greenAccent : appOrange,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.cddActivated ? "Clave Dinámica Activada" : "Clave Dinámica Inactiva",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.cddActivated
                              ? "Tu dispositivo está autorizado para autorizar transferencias y pagos de manera segura."
                              : "Activa la Clave Dinámica Digital (CDD) para autorizar todas tus operaciones desde esta app.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 24),
                        if (state.cddActivated) ...[
                          const Text(
                            "Tu código dinámico actual es:",
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _token.split('').map((char) {
                              if (char == ' ') return const SizedBox(width: 16);
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E3035),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: appBorder),
                                ),
                                child: Text(
                                  char,
                                  style: const TextStyle(
                                    color: appCyan,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  value: _secondsLeft / 30,
                                  valueColor: const AlwaysStoppedAnimation<Color>(appCyan),
                                  backgroundColor: appBorder,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Se actualizará en $_secondsLeft segundos",
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: state.cddActivated ? Colors.redAccent : appOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            if (state.cddActivated) {
                              state.deactivateCdd();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Clave Dinámica Digital desactivada")),
                              );
                            } else {
                              state.activateCdd();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Clave Dinámica Digital activada exitosamente")),
                              );
                            }
                          },
                          child: Text(
                            state.cddActivated ? "Desactivar CDD" : "Activar CDD",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (state.securitySubFlow == "config_transfer") {
      return Container(
        color: darkBg,
        child: Column(
          children: [
            _subHeader(
              title: "Configurar transferencias",
              color: appCyan,
              onBack: () => state.setSecuritySubFlow("menu"),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: const Color(0xFF1E1F23),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text("Afiliado a Transferencias por Celular", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white)),
                            subtitle: const Text("Permite recibir y enviar dinero vía Yape/Plin", style: TextStyle(fontSize: 11, color: Colors.grey)),
                            activeColor: appOrange,
                            value: state.isCellularTransferAffiliated,
                            onChanged: (val) {
                              state.toggleCardSetting('cellular');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.isCellularTransferAffiliated ? "Afiliación exitosa" : "Desafiliación exitosa")),
                              );
                            },
                          ),
                          const Divider(height: 1, color: appBorder),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Número celular afiliado:", style: TextStyle(color: Colors.white70, fontSize: 13)),
                                Text(state.phone, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (state.isCellularTransferAffiliated) ...[
                    const SizedBox(height: 24),
                    const Text(
                      "Wallet digital preferido",
                      style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _preferredWallet = "Yape";
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: _preferredWallet == "Yape" ? const Color(0xFF241411) : const Color(0xFF1E1F23),
                                border: Border.all(
                                  color: _preferredWallet == "Yape" ? appOrange : appBorder,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Image.network(
                                    "https://lh3.googleusercontent.com/aida-public/AB6AXuDFHjR22Fq2H78mG_JzZ1DkEPLhH7xGZlhxZsk", // mock logo placeholder or text
                                    width: 48,
                                    height: 48,
                                    errorBuilder: (c, e, s) => const Icon(Icons.wallet, color: Colors.purpleAccent, size: 48),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text("YAPE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _preferredWallet = "Plin";
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: _preferredWallet == "Plin" ? const Color(0xFF241411) : const Color(0xFF1E1F23),
                                border: Border.all(
                                  color: _preferredWallet == "Plin" ? appOrange : appBorder,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Image.network(
                                    "https://lh3.googleusercontent.com/aida-public/AB6AXuDFHjR22Fq2H78mG_JzZ1DkEPLhH7xGZlhxZsk", // mock
                                    width: 48,
                                    height: 48,
                                    errorBuilder: (c, e, s) => const Icon(Icons.wallet_giftcard, color: Colors.tealAccent, size: 48),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text("PLIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Límite diario de transferencias móviles",
                      style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: const Color(0xFF1E1F23),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Límite diario móvil", style: TextStyle(color: Colors.white70, fontSize: 13)),
                                Text("S/ ${_cellLimit.toStringAsFixed(0)}", style: const TextStyle(color: appCyan, fontSize: 14, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Slider(
                              min: 0,
                              max: 1000,
                              divisions: 20,
                              activeColor: appCyan,
                              inactiveColor: appBorder,
                              value: _cellLimit,
                              onChanged: (val) {
                                setState(() {
                                  _cellLimit = val;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            BnButton(
                              text: "Guardar configuración",
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Configuración de transferencias guardada")),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox();
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF241411) : Colors.transparent,
          border: const Border(
            bottom: BorderSide(color: Color(0xFF2A2A2A), width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(icon, color: color, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _subHeader({
    required String title,
    required Color color,
    required VoidCallback onBack,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF2A2A2A), width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFF2522E), size: 28),
            onPressed: onBack,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// 4. PROFILE / HELP TAB
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // User profile Card info
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: kBnRed.withOpacity(0.1),
                  child: const Text(
                    "JA",
                    style: TextStyle(color: kBnRed, fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kBnTextDark),
                      ),
                      const SizedBox(height: 4),
                      Text("DNI: ${state.dni}", style: const TextStyle(color: kBnTextLight, fontSize: 12)),
                      Text("Celular: ${state.phone} (${state.carrier})", style: const TextStyle(color: kBnTextLight, fontSize: 12)),
                      Text("Email: ${state.email}", style: const TextStyle(color: kBnTextLight, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              _profileItem(
                context: context,
                icon: Icons.edit_outlined,
                title: "Editar Perfil",
                desc: "Actualizar teléfono, operador y correo",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen())),
              ),
              const Divider(height: 1),
              _profileItem(
                context: context,
                icon: Icons.map_outlined,
                title: "Ubícanos (Agencias y Cajeros)",
                desc: "Ubica canales MultiRed más cercanos sin sesión",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UbicanosScreen())),
              ),
              const Divider(height: 1),
              _profileItem(
                context: context,
                icon: Icons.monetization_on_outlined,
                title: "Préstamos MultiRed",
                desc: "Simula o solicita préstamos personales",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoanScreen())),
              ),
              const Divider(height: 1),
              _profileItem(
                context: context,
                icon: Icons.key_outlined,
                title: "Cambiar Clave de Internet",
                desc: "Cambia tu clave de 6 dígitos periódicamente",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangeClaveScreen())),
              ),
              const Divider(height: 1),
              _profileItem(
                context: context,
                icon: Icons.headset_mic_outlined,
                title: "Contáctanos",
                desc: "Línea de soporte y atención 24 horas",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactanosScreen())),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        BnButton(
          text: "Cerrar Sesión de Forma Segura",
          isSecondary: true,
          icon: Icons.logout,
          onPressed: () {
            state.logout();
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _profileItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String desc,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: kBnRed),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: kBnTextDark)),
      subtitle: Text(desc, style: const TextStyle(fontSize: 11, color: kBnTextLight)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: kBnTextLight),
      onTap: onTap,
    );
  }
}

// Edit Profile dialog
void showEditProfileDialog(BuildContext context, AppState state) {
    final phoneController = TextEditingController(text: state.phone);
    final emailController = TextEditingController(text: state.email);
    String selectedCarrier = state.carrier;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Editar Perfil", style: TextStyle(color: kBnRed, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BnTextField(
                      label: "Número Celular",
                      placeholder: "Escribe tu celular",
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 9,
                    ),
                    const SizedBox(height: 12),
                    const Text("Operador Móvil", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: selectedCarrier,
                      items: ["Movistar", "Claro", "Entel", "Bitel"].map((c) {
                        return DropdownMenuItem(value: c, child: Text(c));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedCarrier = val;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    BnTextField(
                      label: "Correo Electrónico",
                      placeholder: "Escribe tu email",
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar", style: TextStyle(color: kBnTextLight)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kBnRed),
                  onPressed: () {
                    if (phoneController.text.length == 9 && emailController.text.contains("@")) {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (c) => CddVerificationDialog(
                          operationDetails: "Actualizar datos de perfil (Celular: ${phoneController.text}, Email: ${emailController.text})",
                          onVerified: () {
                            state.updateProfile(phoneController.text, selectedCarrier, emailController.text);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Perfil actualizado exitosamente")),
                            );
                          },
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Por favor rellene los datos correctamente")),
                      );
                    }
                  },
                  child: const Text("Guardar", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

// Ubícanos simulated locator
void showUbicanosDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(16),
            height: 480,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Ubícanos MultiRed", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kBnRed)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Text(
                  "Visualiza agencias, cajeros (ATM) y agentes cercanos a tu ubicación",
                  style: TextStyle(fontSize: 11, color: kBnTextLight),
                ),
                const SizedBox(height: 12),
                
                // Simulated Map Graphic
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Grid map patterns mockup
                      Positioned(
                        left: 40, top: 50,
                        child: Icon(Icons.location_on, color: kBnRed, size: 28),
                      ),
                      Positioned(
                        right: 60, top: 30,
                        child: Icon(Icons.location_on, color: Colors.blue.shade800, size: 28),
                      ),
                      Positioned(
                        left: 90, bottom: 40,
                        child: Icon(Icons.location_on, color: Colors.green.shade800, size: 28),
                      ),
                      const Center(
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.my_location, size: 12, color: Colors.white),
                        ),
                      ),
                      // Mock road text
                      Positioned(
                        bottom: 10, left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          color: Colors.white70,
                          child: const Text("Av. Javier Prado Este", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // List of nearest locations
                Expanded(
                  child: ListView(
                    children: [
                      locationTile(
                        icon: Icons.apartment,
                        title: "Agencia San Isidro - BN",
                        desc: "Av. Javier Prado Este 2499 Â· 250m",
                        hours: "Lunes a Viernes 8:00 AM - 5:30 PM",
                        color: kBnRed,
                      ),
                      locationTile(
                        icon: Icons.atm,
                        title: "Cajero ATM MultiRed",
                        desc: "C.C. La Rambla - Piso 1 Â· 450m",
                        hours: "Abierto 24 Horas",
                        color: Colors.blue.shade800,
                      ),
                      locationTile(
                        icon: Icons.store,
                        title: "Agente Corresponsal MultiRed - Bodega Rossi",
                        desc: "Calle Las Begonias 340 Â· 600m",
                        hours: "Lunes a Sábado 9:00 AM - 9:00 PM",
                        color: Colors.green.shade800,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

Widget locationTile({
  required IconData icon,
  required String title,
  required String desc,
  required String hours,
  required Color color,
}) {
  return Card(
    elevation: 0.5,
    margin: const EdgeInsets.only(bottom: 6),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                Text(desc, style: const TextStyle(fontSize: 10, color: kBnTextLight)),
                Text(hours, style: TextStyle(fontSize: 9, color: Colors.green.shade800, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// Loans Simulator Dialog
void showLoanDialog(BuildContext context, AppState state) {
    double selectedAmount = 5000;
    int selectedMonths = 12;
    double interestRate = 0.145; // 14.5% annual

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            double calculateQuota() {
              double r = interestRate / 12;
              double quota = (selectedAmount * r) / (1 - pow(1 + r, -selectedMonths));
              return quota;
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Préstamos MultiRed", style: TextStyle(color: kBnRed, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "¡Felicidades! Tienes un préstamo preaprobado. Simula tus cuotas aquí:",
                      style: TextStyle(fontSize: 12, color: kBnTextDark),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Monto a solicitar:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text("S/ ${selectedAmount.toStringAsFixed(0)}", style: const TextStyle(color: kBnRed, fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    Slider(
                      value: selectedAmount,
                      min: 1000,
                      max: 20000,
                      divisions: 19,
                      activeColor: kBnRed,
                      inactiveColor: Colors.grey[300],
                      onChanged: (val) {
                        setDialogState(() {
                          selectedAmount = val;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Plazo de pago:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text("$selectedMonths meses", style: const TextStyle(color: kBnRed, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    Slider(
                      value: selectedMonths.toDouble(),
                      min: 6,
                      max: 36,
                      divisions: 5, // 6, 12, 18, 24, 30, 36
                      activeColor: kBnRed,
                      inactiveColor: Colors.grey[300],
                      onChanged: (val) {
                        setDialogState(() {
                          selectedMonths = val.round();
                        });
                      },
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Cuota mensual estimada:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(
                            "S/ ${calculateQuota().toStringAsFixed(2)}",
                            style: const TextStyle(color: kBnRed, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text("Tasa Efectiva Anual (TEA): 14.50%", style: TextStyle(fontSize: 10, color: kBnTextLight)),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar", style: TextStyle(color: kBnTextLight)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kBnRed),
                  onPressed: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (c) => CddVerificationDialog(
                        operationDetails: "Desembolso de Préstamo MultiRed por S/ ${selectedAmount.toStringAsFixed(2)} a $selectedMonths meses",
                        onVerified: () {
                          state.addLoan(selectedAmount);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Préstamo de S/ ${selectedAmount.toStringAsFixed(2)} desembolsado en su Cuenta Ahorros")),
                          );
                        },
                      ),
                    );
                  },
                  child: const Text("Solicitar Desembolso", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

// Change Password
void showChangeClaveDialog(BuildContext context, AppState state) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Cambiar Clave de Internet", style: TextStyle(color: kBnRed, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BnTextField(
                label: "Clave Actual (6 dígitos)",
                placeholder: "******",
                controller: currentController,
                isPassword: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              const SizedBox(height: 12),
              BnTextField(
                label: "Nueva Clave (6 dígitos)",
                placeholder: "******",
                controller: newController,
                isPassword: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              const SizedBox(height: 12),
              BnTextField(
                label: "Confirmar Nueva Clave",
                placeholder: "******",
                controller: confirmController,
                isPassword: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: kBnTextLight)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kBnRed),
              onPressed: () {
                if (currentController.text == state.clave &&
                    newController.text.length == 6 &&
                    newController.text == confirmController.text) {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (c) => CddVerificationDialog(
                      operationDetails: "Cambio de clave de internet de 6 dígitos",
                      onVerified: () {
                        state.changeClave(newController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Clave modificada exitosamente. íšsela en su próximo inicio de sesión")),
                        );
                      },
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Verifique que la clave actual sea correcta y las nuevas coincidan")),
                  );
                }
              },
              child: const Text("Cambiar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

// Contact support hotline dialog
void showContactanosDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Contáctanos BN", style: TextStyle(color: kBnRed, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.headset_mic, size: 48, color: kBnRed),
              const SizedBox(height: 12),
              const Text(
                "Nuestros asesores están disponibles las 24 horas del día, los 7 días de la semana para ayudarte.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: const Text("Línea Gratuita Nacional", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: const Text("0-800-10-700", style: TextStyle(fontSize: 12, color: kBnTextLight)),
                trailing: const Icon(Icons.call),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Llamando a Línea Gratuita: 0-800-10-700...")),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: const Text("Central Telefónica Lima", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: const Text("(01) 440-5305 / 519-2000", style: TextStyle(fontSize: 12, color: kBnTextLight)),
                trailing: const Icon(Icons.call),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Llamando a Central Telefónica...")),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar", style: TextStyle(color: kBnTextLight)),
            )
          ],
        );
      },
    );
  }

// ------------------ OPERATIONAL SUB-FLOWS ------------------

// 1. Same bank transfer flow
class TransferSameBankFlow extends StatefulWidget {
  const TransferSameBankFlow({super.key});

  @override
  State<TransferSameBankFlow> createState() => _TransferSameBankFlowState();
}

class _TransferSameBankFlowState extends State<TransferSameBankFlow> {
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();
  final _refController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Complete los datos para realizar la transferencia a otra cuenta BN.", style: TextStyle(fontSize: 13, color: kBnTextLight)),
          const SizedBox(height: 16),
          BnTextField(
            label: "Cuenta de Ahorros Destino BN",
            placeholder: "Ej: 00-011-998877",
            controller: _accountController,
            keyboardType: TextInputType.text,
            prefixIcon: Icons.account_balance_wallet_outlined,
            validator: (val) {
              if (val == null || val.isEmpty) return "Ingrese el número de cuenta";
              return null;
            },
          ),
          const SizedBox(height: 16),
          BnTextField(
            label: "Monto (Soles)",
            placeholder: "0.00",
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.monetization_on_outlined,
            validator: (val) {
              if (val == null || val.isEmpty) return "Ingrese el monto";
              double? amount = double.tryParse(val);
              if (amount == null || amount <= 0) return "Ingrese un monto mayor a cero";
              if (amount > state.savingsSoles) return "Saldo insuficiente";
              if (amount > 10000) return "Límite diario excedido (S/ 10,000)";
              return null;
            },
          ),
          const SizedBox(height: 16),
          BnTextField(
            label: "Concepto / Referencia",
            placeholder: "Ej. Pago de almuerzo",
            controller: _refController,
            validator: (val) {
              if (val == null || val.isEmpty) return "Ingrese una referencia";
              return null;
            },
          ),
          const SizedBox(height: 32),
          BnButton(
            text: "Siguiente",
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                FocusScope.of(context).unfocus();
                double amount = double.parse(_amountController.text);
                state.transferSameBank(_accountController.text, amount, _refController.text);
                
                // Show receipt
                showDialog(
                  context: context,
                  builder: (c) => TransactionReceiptDialog(
                    title: "Transferencia a Cuenta BN",
                    receiptDetails: [
                      {"label": "Destinatario", "value": "ANDREA CASTRO ROJAS"},
                      {"label": "Cuenta Destino", "value": _accountController.text},
                      {"label": "Monto", "value": "S/ ${amount.toStringAsFixed(2)}"},
                      {"label": "Concepto", "value": _refController.text},
                      {"label": "Fecha y Hora", "value": DateTime.now().toString().substring(0, 19)},
                      {"label": "Nº Operación", "value": (100000 + Random().nextInt(900000)).toString()},
                    ],
                  ),
                );
                // Clear form
                _accountController.clear();
                _amountController.clear();
                _refController.clear();
              }
            },
          )
        ],
      ),
    );
  }
}

// 2. Transfer cellular flow (Yape/Plin/BN)
class TransferCellularFlow extends StatefulWidget {
  const TransferCellularFlow({super.key});

  @override
  State<TransferCellularFlow> createState() => _TransferCellularFlowState();
}

class _TransferCellularFlowState extends State<TransferCellularFlow> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedBank = "Yape";
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Envía dinero usando solo el número de celular del destinatario.", style: TextStyle(fontSize: 13, color: kBnTextLight)),
          const SizedBox(height: 16),
          
          // Select from contact list shortcuts
          const Text("Destinatarios Frecuentes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.contacts.length,
              itemBuilder: (context, index) {
                final c = state.contacts[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: ActionChip(
                    avatar: CircleAvatar(
                      backgroundColor: kBnRed.withOpacity(0.1),
                      child: Text(c["name"]!.substring(0, 1), style: const TextStyle(color: kBnRed, fontSize: 11)),
                    ),
                    label: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(c["name"]!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                        Text("${c["phone"]} (${c["bank"]})", style: const TextStyle(fontSize: 8, color: kBnTextLight)),
                      ],
                    ),
                    onPressed: () {
                      setState(() {
                        _phoneController.text = c["phone"]!;
                        _nameController.text = c["name"]!;
                        _selectedBank = c["bank"]!;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 24),
          
          BnTextField(
            label: "Número de Celular",
            placeholder: "Ej: 987654321",
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 9,
            prefixIcon: Icons.smartphone,
            validator: (val) {
              if (val == null || val.isEmpty) return "Ingrese el celular";
              if (val.length != 9) return "Debe tener 9 dígitos";
              return null;
            },
          ),
          const SizedBox(height: 12),
          BnTextField(
            label: "Nombre del Destinatario (Opcional)",
            placeholder: "Ej. Maria Fe Romero",
            controller: _nameController,
          ),
          const SizedBox(height: 16),
          const Text("Destino de Billetera / Banco", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedBank,
            items: ["Yape", "Plin", "Banco de la Nación", "BCP", "Interbank", "BBVA", "Scotiabank"].map((b) {
              return DropdownMenuItem(value: b, child: Text(b));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedBank = val);
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),
          BnTextField(
            label: "Monto a Transferir (Soles)",
            placeholder: "0.00",
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.monetization_on_outlined,
            validator: (val) {
              if (val == null || val.isEmpty) return "Ingrese el monto";
              double? amount = double.tryParse(val);
              if (amount == null || amount <= 0) return "Monto no válido";
              if (amount > state.savingsSoles) return "Saldo insuficiente";
              if (_selectedBank == "Banco de la Nación" && amount > 10000) {
                return "Monto máximo BN es S/ 10,000";
              }
              if (_selectedBank != "Banco de la Nación" && amount > 500) {
                return "Monto máximo otras billeteras es S/ 500";
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          const Text(
            "Transferencias a otros bancos/billeteras son gratuitas hasta S/500 diarios. Monto mínimo S/0.20.",
            style: TextStyle(fontSize: 10, color: kBnTextLight, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 24),
          BnButton(
            text: "Enviar Transferencia",
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                FocusScope.of(context).unfocus();
                String name = _nameController.text.isEmpty ? "Destinatario Móvil" : _nameController.text;
                double amount = double.parse(_amountController.text);
                state.transferCellular(_phoneController.text, name, amount, _selectedBank);
                
                showDialog(
                  context: context,
                  builder: (c) => TransactionReceiptDialog(
                    title: "Transferencia a Celular ($_selectedBank)",
                    receiptDetails: [
                      {"label": "Destinatario", "value": name},
                      {"label": "Celular", "value": _phoneController.text},
                      {"label": "Billetera/Banco", "value": _selectedBank},
                      {"label": "Monto", "value": "S/ ${amount.toStringAsFixed(2)}"},
                      {"label": "Comisión", "value": "Gratuito (TIN Especial)"},
                      {"label": "Nº Operación", "value": (100000 + Random().nextInt(900000)).toString()},
                    ],
                  ),
                );
                
                _phoneController.clear();
                _amountController.clear();
                _nameController.clear();
              }
            },
          )
        ],
      ),
    );
  }
}

// 3. Interbank transfer flow (CCI)
class TransferInterbankFlow extends StatefulWidget {
  const TransferInterbankFlow({super.key});

  @override
  State<TransferInterbankFlow> createState() => _TransferInterbankFlowState();
}

class _TransferInterbankFlowState extends State<TransferInterbankFlow> {
  final _cciController = TextEditingController();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isInmediate = true;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Transfiere a cuentas de otros bancos usando el CCI (20 dígitos).", style: TextStyle(fontSize: 13, color: kBnTextLight)),
          const SizedBox(height: 16),
          BnTextField(
            label: "CCI Destino (Código Cuenta Interbancaria)",
            placeholder: "Ej: 018-011-000000000000-00",
            controller: _cciController,
            keyboardType: TextInputType.text,
            prefixIcon: Icons.account_balance,
            validator: (val) {
              if (val == null || val.isEmpty) return "Ingrese el CCI";
              // Clean spaces or hyphens for verification if needed
              if (val.replaceAll("-", "").replaceAll(" ", "").length != 20) {
                return "Debe contener exactamente 20 dígitos";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          BnTextField(
            label: "Nombre del Beneficiario",
            placeholder: "Nombre completo del titular",
            controller: _nameController,
            validator: (val) {
              if (val == null || val.isEmpty) return "Ingrese el nombre del titular";
              return null;
            },
          ),
          const SizedBox(height: 16),
          BnTextField(
            label: "Monto (Soles)",
            placeholder: "0.00",
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.monetization_on_outlined,
            validator: (val) {
              if (val == null || val.isEmpty) return "Ingrese el monto";
              double? amount = double.tryParse(val);
              if (amount == null || amount <= 0) return "Ingrese un monto mayor a cero";
              if (amount > state.savingsSoles) return "Saldo insuficiente";
              return null;
            },
          ),
          const SizedBox(height: 16),
          const Text("Modalidad de Transferencia", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text("Inmediata (24h)"),
                  selected: _isInmediate,
                  selectedColor: kBnRed.withOpacity(0.15),
                  labelStyle: TextStyle(color: _isInmediate ? kBnRed : kBnTextDark, fontWeight: FontWeight.bold, fontSize: 12),
                  onSelected: (val) => setState(() => _isInmediate = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: const Text("Diferida (Gratis < 500)"),
                  selected: !_isInmediate,
                  selectedColor: kBnRed.withOpacity(0.15),
                  labelStyle: TextStyle(color: !_isInmediate ? kBnRed : kBnTextDark, fontWeight: FontWeight.bold, fontSize: 12),
                  onSelected: (val) => setState(() => _isInmediate = false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          BnButton(
            text: "Proceder",
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                FocusScope.of(context).unfocus();
                double amount = double.parse(_amountController.text);
                state.transferInterbank(_cciController.text, _nameController.text, amount, _isInmediate);
                
                showDialog(
                  context: context,
                  builder: (c) => TransactionReceiptDialog(
                    title: "Transferencia Interbancaria",
                    receiptDetails: [
                      {"label": "Titular Destino", "value": _nameController.text},
                      {"label": "CCI", "value": _cciController.text},
                      {"label": "Monto", "value": "S/ ${amount.toStringAsFixed(2)}"},
                      {"label": "Modalidad", "value": _isInmediate ? "Inmediata" : "Diferida"},
                      {"label": "Comisión", "value": _isInmediate ? "S/ 3.50" : (amount <= 500 ? "Gratis" : "S/ 1.50")},
                      {"label": "Nº Operación", "value": (100000 + Random().nextInt(900000)).toString()},
                    ],
                  ),
                );
                
                _cciController.clear();
                _nameController.clear();
                _amountController.clear();
              }
            },
          )
        ],
      ),
    );
  }
}

// 4. Pay credit card flow
class PayCreditCardFlow extends StatefulWidget {
  const PayCreditCardFlow({super.key});

  @override
  State<PayCreditCardFlow> createState() => _PayCreditCardFlowState();
}

class _PayCreditCardFlowState extends State<PayCreditCardFlow> {
  final _cardNoController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedBank = "BCP";
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Paga las cuotas de tus tarjetas de crédito de otros bancos nacionales.", style: TextStyle(fontSize: 13, color: kBnTextLight)),
          const SizedBox(height: 16),
          const Text("Banco Emisor", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedBank,
            items: ["BCP", "BBVA", "Interbank", "Scotiabank", "Banco Falabella", "Banco Ripley"].map((b) {
              return DropdownMenuItem(value: b, child: Text(b));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedBank = val);
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),
          BnTextField(
            label: "Número de Tarjeta de Crédito",
            placeholder: "Ej: 4557 1234 5678 9012",
            controller: _cardNoController,
            keyboardType: TextInputType.number,
            maxLength: 16,
            prefixIcon: Icons.credit_card,
            validator: (val) {
              if (val == null || val.isEmpty) return "Ingrese el número de tarjeta";
              if (val.length != 16) return "Debe tener 16 dígitos";
              return null;
            },
          ),
          const SizedBox(height: 16),
          BnTextField(
            label: "Monto a Pagar (Soles)",
            placeholder: "0.00",
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.monetization_on_outlined,
            validator: (val) {
              if (val == null || val.isEmpty) return "Ingrese el monto";
              double? amount = double.tryParse(val);
              if (amount == null || amount <= 0) return "Monto no válido";
              if (amount > state.savingsSoles) return "Saldo insuficiente";
              return null;
            },
          ),
          const SizedBox(height: 32),
          BnButton(
            text: "Realizar Pago",
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                FocusScope.of(context).unfocus();
                double amount = double.parse(_amountController.text);
                state.payCreditCard(_selectedBank, _cardNoController.text, amount);
                
                showDialog(
                  context: context,
                  builder: (c) => TransactionReceiptDialog(
                    title: "Pago de Tarjeta de Crédito",
                    receiptDetails: [
                      {"label": "Banco", "value": _selectedBank},
                      {"label": "Nº Tarjeta", "value": "**** **** **** ${_cardNoController.text.substring(12)}"},
                      {"label": "Monto Pagado", "value": "S/ ${amount.toStringAsFixed(2)}"},
                      {"label": "Tipo de Pago", "value": "Inmediato"},
                      {"label": "Nº Operación", "value": (100000 + Random().nextInt(900000)).toString()},
                    ],
                  ),
                );
                
                _cardNoController.clear();
                _amountController.clear();
              }
            },
          )
        ],
      ),
    );
  }
}

// 5. Pay service flow (generic layout for Water, Electricity, Phone)
class PayServiceFlow extends StatefulWidget {
  final String serviceType; // "Agua", "Luz", "Teléfono"

  const PayServiceFlow({
    super.key,
    required this.serviceType,
  });

  @override
  State<PayServiceFlow> createState() => _PayServiceFlowState();
}

class _PayServiceFlowState extends State<PayServiceFlow> {
  final _supplyCodeController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCompany = "";
  final _formKey = GlobalKey<FormState>();

  bool _isDebtQueried = false;
  double _queriedDebt = 0.00;
  bool _querying = false;

  final Map<String, List<String>> _companies = {
    "Agua": ["Sedapal", "Sedalib", "Sedapar", "EPS Grau", "SedaAyacucho"],
    "Luz": ["Enel Distribución", "Luz del Sur", "Electrocentro", "Seal", "Hidrandina"],
    "Teléfono": ["Movistar Hogar", "Claro Hogar", "Win Internet", "Entel Fijo"],
  };

  @override
  void initState() {
    super.initState();
    _selectedCompany = _companies[widget.serviceType]![0];
  }

  void _queryDebt() {
    if (_supplyCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ingrese el código de suministro")),
      );
      return;
    }
    setState(() {
      _querying = true;
    });
    // Simulate API delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _querying = false;
          _isDebtQueried = true;
          // Generate a random debt between 20 and 200 soles
          _queriedDebt = (25 + Random().nextInt(150)) + 0.80;
          _amountController.text = _queriedDebt.toStringAsFixed(2);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text("Paga tu recibo de ${widget.serviceType.toLowerCase()} desde tu cuenta de ahorros.", style: const TextStyle(fontSize: 13, color: kBnTextLight)),
          const SizedBox(height: 16),
          Text("Empresa Proveedora", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedCompany,
            items: _companies[widget.serviceType]!.map((c) {
              return DropdownMenuItem(value: c, child: Text(c));
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedCompany = val;
                  _isDebtQueried = false;
                });
              }
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),
          BnTextField(
            label: "Código de Suministro / Cliente",
            placeholder: "Ej: 1902834",
            controller: _supplyCodeController,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.tag,
            validator: (val) {
              if (val == null || val.isEmpty) return "Ingrese el código";
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          if (!_isDebtQueried)
            BnButton(
              text: "Consultar Deuda",
              icon: Icons.search,
              isLoading: _querying,
              onPressed: _queryDebt,
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Deuda Total Pendiente:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
                  Text(
                    "S/ ${_queriedDebt.toStringAsFixed(2)}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green.shade800),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            BnTextField(
              label: "Monto a Pagar",
              placeholder: "0.00",
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.monetization_on_outlined,
              validator: (val) {
                if (val == null || val.isEmpty) return "Ingrese el monto";
                double? amount = double.tryParse(val);
                if (amount == null || amount <= 0) return "Monto no válido";
                if (amount > state.savingsSoles) return "Saldo insuficiente";
                return null;
              },
            ),
            const SizedBox(height: 24),
            BnButton(
              text: "Confirmar Pago",
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  FocusScope.of(context).unfocus();
                  double amount = double.parse(_amountController.text);
                  state.payService(widget.serviceType, _selectedCompany, _supplyCodeController.text, amount);
                  
                  showDialog(
                    context: context,
                    builder: (c) => TransactionReceiptDialog(
                      title: "Pago de Servicio Realizado",
                      receiptDetails: [
                        {"label": "Servicio", "value": widget.serviceType},
                        {"label": "Empresa", "value": _selectedCompany},
                        {"label": "Suministro/Cliente", "value": _supplyCodeController.text},
                        {"label": "Monto Pagado", "value": "S/ ${amount.toStringAsFixed(2)}"},
                        {"label": "Nº Operación", "value": (100000 + Random().nextInt(900000)).toString()},
                      ],
                    ),
                  );
                  
                  setState(() {
                    _isDebtQueried = false;
                  });
                  _supplyCodeController.clear();
                  _amountController.clear();
                }
              },
            ),
          ]
        ],
      ),
    );
  }
}

// 6. Cell recharge flow
class RechargeFlow extends StatefulWidget {
  const RechargeFlow({super.key});

  @override
  State<RechargeFlow> createState() => _RechargeFlowState();
}

class _RechargeFlowState extends State<RechargeFlow> {
  final _phoneController = TextEditingController();
  String _selectedOperator = "Movistar";
  double _selectedAmount = 10.00;
  final _formKey = GlobalKey<FormState>();

  final List<double> _presetAmounts = [5.00, 10.00, 15.00, 20.00, 30.00, 50.00];

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Recarga saldo de celular al instante debitando de tu cuenta BN.", style: TextStyle(fontSize: 13, color: kBnTextLight)),
          const SizedBox(height: 16),
          const Text("Operador Móvil", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedOperator,
            items: ["Movistar", "Claro", "Entel", "Bitel"].map((op) {
              return DropdownMenuItem(value: op, child: Text(op));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedOperator = val);
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),
          BnTextField(
            label: "Número de Celular a Recargar",
            placeholder: "Ej: 987654321",
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 9,
            prefixIcon: Icons.smartphone,
            validator: (val) {
              if (val == null || val.isEmpty) return "Ingrese el celular";
              if (val.length != 9) return "Debe tener 9 dígitos";
              return null;
            },
          ),
          const SizedBox(height: 20),
          const Text("Monto de Recarga (Soles)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          
          // Presets wrap grid
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _presetAmounts.map((amt) {
              bool isSelected = _selectedAmount == amt;
              return ChoiceChip(
                label: Text("S/ ${amt.toStringAsFixed(0)}"),
                selected: isSelected,
                selectedColor: kBnRed,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : kBnTextDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                onSelected: (val) {
                  if (val) {
                    setState(() {
                      _selectedAmount = amt;
                    });
                  }
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: 32),
          BnButton(
            text: "Recargar",
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (_selectedAmount > state.savingsSoles) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Saldo insuficiente en su cuenta")),
                  );
                  return;
                }
                FocusScope.of(context).unfocus();
                state.rechargeCellular(_selectedOperator, _phoneController.text, _selectedAmount);
                
                showDialog(
                  context: context,
                  builder: (c) => TransactionReceiptDialog(
                    title: "Recarga Realizada",
                    receiptDetails: [
                      {"label": "Operador", "value": _selectedOperator},
                      {"label": "Nº Celular", "value": _phoneController.text},
                      {"label": "Monto Recargado", "value": "S/ ${_selectedAmount.toStringAsFixed(2)}"},
                      {"label": "Nº Operación", "value": (100000 + Random().nextInt(900000)).toString()},
                    ],
                  ),
                );
                
                _phoneController.clear();
              }
            },
          )
        ],
      ),
    );
  }
}

// 7. Emit giro flow
class EmitGiroFlow extends StatefulWidget {
  const EmitGiroFlow({super.key});

  @override
  State<EmitGiroFlow> createState() => _EmitGiroFlowState();
}

class _EmitGiroFlowState extends State<EmitGiroFlow> {
  final _dniController = TextEditingController();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Emita un giro nacional cobrable al instante en cualquier ventanilla o agente MultiRed del país.",
            style: TextStyle(fontSize: 13, color: kBnTextLight),
          ),
          const SizedBox(height: 16),
          BnTextField(
            label: "DNI del Beneficiario",
            placeholder: "8 dígitos",
            controller: _dniController,
            keyboardType: TextInputType.number,
            maxLength: 8,
            prefixIcon: Icons.badge_outlined,
            validator: (val) {
              if (val == null || val.isEmpty) return "Ingrese el DNI";
              if (val.length != 8) return "Debe tener 8 dígitos";
              return null;
            },
          ),
          const SizedBox(height: 16),
          BnTextField(
            label: "Nombres y Apellidos del Beneficiario",
            placeholder: "Escriba nombres completos",
            controller: _nameController,
            validator: (val) {
              if (val == null || val.isEmpty) return "Ingrese los nombres del beneficiario";
              return null;
            },
          ),
          const SizedBox(height: 16),
          BnTextField(
            label: "Monto del Giro (Soles)",
            placeholder: "De S/ 4 a S/ 1,000",
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.monetization_on_outlined,
            validator: (val) {
              if (val == null || val.isEmpty) return "Ingrese el monto";
              double? amount = double.tryParse(val);
              if (amount == null || amount < 4 || amount > 1000) {
                return "Monto debe estar entre S/ 4 y S/ 1,000";
              }
              if ((amount + 3.00) > state.savingsSoles) {
                return "Saldo insuficiente (incluye tarifa de S/ 3.00)";
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8)),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Tarifa por emisión de giro: S/ 3.00 fijos (debitados de su cuenta).",
                    style: TextStyle(fontSize: 11, color: kBnTextDark, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          BnButton(
            text: "Emitir Giro",
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                FocusScope.of(context).unfocus();
                double amount = double.parse(_amountController.text);
                String code = state.emitGiro(_nameController.text, _dniController.text, amount);
                
                // Find the newly generated giro details
                final g = state.giros.firstWhere((x) => x.giroCode == code);
                
                showDialog(
                  context: context,
                  builder: (c) => Dialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.send_rounded, color: kBnRed, size: 54),
                          const SizedBox(height: 12),
                          const Text("Giro Emitido Exitosamente", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: kBnRed)),
                          const Divider(height: 24),
                          const Text("ENTREGUE ESTAS CLAVES A SU BENEFICIARIO", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kBnTextLight)),
                          const SizedBox(height: 16),
                          
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            color: Colors.grey[100],
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Código de Giro:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text(g.giroCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: kBnRed, letterSpacing: 1.5)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            color: Colors.grey[100],
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Clave de Cobro (4 dig):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text(g.giroKey, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: kBnRed, letterSpacing: 2)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Beneficiario:", style: TextStyle(fontSize: 12)),
                              Text(g.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("DNI:", style: TextStyle(fontSize: 12)),
                              Text(g.dni, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Monto del Giro:", style: TextStyle(fontSize: 12)),
                              Text("S/ ${g.amount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Tarifa Cobrada:", style: TextStyle(fontSize: 12)),
                              const Text("S/ 3.00", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          const Divider(height: 24),
                          const Text("El cobro puede realizarse en agencias BN o Agentes MultiRed a nivel nacional.", textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: kBnTextLight)),
                          const SizedBox(height: 20),
                          BnButton(
                            text: "Compartir Claves",
                            icon: Icons.share,
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Claves del giro enviadas por WhatsApp")),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          BnButton(
                            text: "Listo",
                            isSecondary: true,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                
                _dniController.clear();
                _nameController.clear();
                _amountController.clear();
              }
            },
          )
        ],
      ),
    );
  }
}

// 8. Cardless withdrawal flow
class CardlessWithdrawalFlow extends StatefulWidget {
  const CardlessWithdrawalFlow({super.key});

  @override
  State<CardlessWithdrawalFlow> createState() => _CardlessWithdrawalFlowState();
}

class _CardlessWithdrawalFlowState extends State<CardlessWithdrawalFlow> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  Timer? _countdownTimer;
  int _secondsLeft = 0;
  String? _generatedCode;
  
  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _secondsLeft = 600; // 10 minutes
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        setState(() {
          _generatedCode = null;
          timer.cancel();
        });
      }
    });
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    String minStr = minutes.toString().padLeft(2, '0');
    String secStr = seconds.toString().padLeft(2, '0');
    return "$minStr:$secStr";
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    if (_generatedCode != null) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.atm_rounded, color: kBnRed, size: 64),
            const SizedBox(height: 16),
            const Text(
              "Retiro sin Tarjeta Generado",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kBnRed),
            ),
            const SizedBox(height: 24),
            const Text(
              "Ingrese este código de autorización en cualquier cajero automático BN o Agente MultiRed:",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: kBnTextDark),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                _generatedCode!,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: kBnRed,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer_outlined, color: Colors.orange, size: 20),
                const SizedBox(width: 6),
                Text(
                  "Válido por: ${_formatTime(_secondsLeft)}",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "Por seguridad, expira a los 10 minutos.",
              style: TextStyle(fontSize: 11, color: kBnTextLight),
            ),
            const Divider(height: 40),
            BnButton(
              text: "Finalizar",
              onPressed: () {
                setState(() {
                  _generatedCode = null;
                });
                _countdownTimer?.cancel();
              },
            ),
          ],
        ),
      );
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Retire dinero en efectivo de cajeros MultiRed o Agentes autorizados sin usar su tarjeta de débito.",
            style: TextStyle(fontSize: 13, color: kBnTextLight),
          ),
          const SizedBox(height: 20),
          BnTextField(
            label: "Monto a Retirar (Soles)",
            placeholder: "Ej. 100.00",
            controller: _amountController,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.monetization_on_outlined,
            validator: (val) {
              if (val == null || val.isEmpty) return "Ingrese el monto";
              double? amount = double.tryParse(val);
              if (amount == null || amount <= 0) return "Ingrese un monto válido";
              if (amount > state.savingsSoles) return "Saldo insuficiente";
              if (amount % 10 != 0) return "El monto debe ser múltiplo de S/ 10";
              if (amount > 500) return "Monto máximo por retiro es S/ 500";
              return null;
            },
          ),
          const SizedBox(height: 12),
          const Text(
            "El cajero entregará billetes de S/20 o S/50. Asegúrese de ingresar múltiplos válidos.",
            style: TextStyle(fontSize: 11, color: kBnTextLight, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 32),
          BnButton(
            text: "Generar Código de Retiro",
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                FocusScope.of(context).unfocus();
                double amount = double.parse(_amountController.text);
                String code = state.generateRetiroSinTarjeta(amount);
                setState(() {
                  _generatedCode = code;
                });
                _startTimer();
                _amountController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}

class SimpleDashboardView extends StatelessWidget {
  final AppState state;
  const SimpleDashboardView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // â”€â”€ Controls bar (language + font size) pinned at the very top â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    Widget controlsBar = Container(
      color: kBnRed,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Language row
          Row(
            children: [
              _langBtn(context, 'ES', 'ESPAí‘OL'),
              const SizedBox(width: 6),
              _langBtn(context, 'QU', 'QUECHUA'),
              const SizedBox(width: 6),
              _langBtn(context, 'AY', 'AYMARA'),
            ],
          ),
          const SizedBox(height: 6),
          // Font size row
          Row(
            children: [
              _fontBtn(context, 1.0, 'A', 'NORMAL'),
              const SizedBox(width: 6),
              _fontBtn(context, 1.3, 'A+', 'GRANDE'),
              const SizedBox(width: 6),
              _fontBtn(context, 1.6, 'A++', 'MUY GRANDE'),
            ],
          ),
        ],
      ),
    );

    // â”€â”€ Main scrollable button list â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    Widget _btn({
      required IconData icon,
      required String labelES,
      required String labelQU,
      required String labelAY,
      required Color color,
      required VoidCallback onTap,
    }) {
      final label = state.currentLanguage == 'ES'
          ? labelES
          : state.currentLanguage == 'QU'
              ? labelQU
              : labelAY;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SizedBox(
          height: 82,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
            onPressed: onTap,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14 * state.fontSizeMultiplier,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white60, size: 18),
              ],
            ),
          ),
        ),
      );
    }

    Widget buttonList = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Volver a Vista Normal ──────────────────────────────────────────
          _btn(
            icon: Icons.restore,
            labelES: "VOLVER A VISTA NORMAL",
            labelQU: "KUTIY NORMALMAN",
            labelAY: "KUTIÑA NORMALMAN",
            color: Colors.grey.shade700,
            onTap: () {
              state.speak(state.currentLanguage == 'ES' ? "Volviendo a vista normal." : "Kutiy normalman.");
              state.toggleSimpleMode();
            },
          ),
          // ── Saldos ─────────────────────────────────────────────────────────
          _btn(
            icon: Icons.account_balance_wallet,
            labelES: "VER MI PLATA Y MOVIMIENTOS",
            labelQU: "QULLQI YUPAY QHAWARIY",
            labelAY: "QULLQI Uí‘JAí‘A CHIKURU",
            color: Colors.teal.shade800,
            onTap: () {
              state.speak(state.currentLanguage == 'ES'
                  ? "Abriendo su cuenta para ver cuánta plata tiene."
                  : "Qolqe qhaway.");
              state.setTab(0);
              state.toggleSimpleMode(); // regresa al modo clásico para ver HomeTab
              // pequeña demora para que toggleSimpleMode surta efecto
            },
          ),
          // â”€â”€ Transferir mismo banco â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          _btn(
            icon: Icons.swap_horiz,
            labelES: "MANDAR PLATA AL MISMO BANCO",
            labelQU: "BN ASTACHIY",
            labelAY: "BN APACHIRI",
            color: Colors.blue.shade800,
            onTap: () {
              state.speak(state.currentLanguage == 'ES'
                  ? "Abriendo sección para mandar plata al mismo banco."
                  : "BN astachiy.");
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const TransferAccountsScreen(),
              ));
            },
          ),
          // â”€â”€ Transferir por celular â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          _btn(
            icon: Icons.phone_android,
            labelES: "MANDAR PLATA POR CELULAR (YAPE/PLIN)",
            labelQU: "YAPE / PLIN ENVIAR",
            labelAY: "CELULAR APACHIRI",
            color: Colors.purple.shade800,
            onTap: () {
              state.speak(state.currentLanguage == 'ES'
                  ? "Abriendo sección para mandar plata por celular a Yape o Plin."
                  : "Yape Plin apachiy.");
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const TransferCellularScreen(),
              ));
            },
          ),
          // â”€â”€ Pagar agua â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          _btn(
            icon: Icons.water_drop,
            labelES: "PAGAR RECIBO DE AGUA",
            labelQU: "YAKUTA PAGAY",
            labelAY: "UNO PAGAí‘A",
            color: Colors.cyan.shade800,
            onTap: () {
              state.speak(state.currentLanguage == 'ES'
                  ? "Abriendo pago de agua."
                  : "Unu pagay.");
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const PagosRecargasScreen(),
              ));
            },
          ),
          // â”€â”€ Pagar luz â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          _btn(
            icon: Icons.bolt,
            labelES: "PAGAR RECIBO DE LUZ",
            labelQU: "K'ANCHAYTA PAGAY",
            labelAY: "LUSAT PAGAí‘A",
            color: Colors.amber.shade900,
            onTap: () {
              state.speak(state.currentLanguage == 'ES'
                  ? "Abriendo pago de luz."
                  : "Luz pagay.");
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const PagosRecargasScreen(),
              ));
            },
          ),
          // â”€â”€ Recargar celular â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          _btn(
            icon: Icons.smartphone,
            labelES: "RECARGAR CELULAR",
            labelQU: "CELULARTA WINAY",
            labelAY: "CELULAR WINJAí‘A",
            color: Colors.green.shade800,
            onTap: () {
              state.speak(state.currentLanguage == 'ES'
                  ? "Abriendo recarga de celular."
                  : "Celular recarga.");
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const PagosRecargasScreen(),
              ));
            },
          ),
          // â”€â”€ Emitir giro â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          _btn(
            icon: Icons.send_to_mobile,
            labelES: "EMITIR GIRO MULTIRED",
            labelQU: "GIRO EMITIY",
            labelAY: "GIRO LURAí‘A",
            color: Colors.deepOrange.shade800,
            onTap: () {
              state.speak(state.currentLanguage == 'ES'
                  ? "Abriendo emisión de giro MultiRed."
                  : "Giro emitiy.");
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const GirosScreen(),
              ));
            },
          ),
          // â”€â”€ Retiro sin tarjeta â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          _btn(
            icon: Icons.no_accounts,
            labelES: "RETIRO SIN TARJETA",
            labelQU: "TARJETA ILLAJPI ORQOY",
            labelAY: "TARJETA JANIWA ORAQAí‘A",
            color: Colors.blueGrey.shade800,
            onTap: () {
              state.speak(state.currentLanguage == 'ES'
                  ? "Abriendo retiro sin tarjeta."
                  : "Retiro sin tarjeta.");
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const RetiroSinTarjetaScreen(),
              ));
            },
          ),
          // â”€â”€ Préstamos â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          _btn(
            icon: Icons.monetization_on_outlined,
            labelES: "SOLICITAR PRí‰STAMO",
            labelQU: "QOLLQE MAí‘AKUY",
            labelAY: "QULLQI MAí‘Aí‘A",
            color: Colors.indigo.shade800,
            onTap: () {
              state.speak(state.currentLanguage == 'ES'
                  ? "Abriendo simulador de préstamos."
                  : "Préstamo mañakuy.");
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const LoanScreen(),
              ));
            },
          ),
          // â”€â”€ Bloquear tarjeta â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          _btn(
            icon: state.isCardBlocked ? Icons.lock_open : Icons.warning_rounded,
            labelES: state.isCardBlocked ? "DESBLOQUEAR TARJETA" : "BLOQUEAR TARJETA DE INMEDIATO",
            labelQU: state.isCardBlocked ? "TARJETA KAWSARICHIY" : "TARJETA HARK'AY KUNANPUNI",
            labelAY: state.isCardBlocked ? "TARJETA KATAí‘A" : "TARJETA JARK'ANTAí‘A",
            color: kBnRed,
            onTap: () {
              if (state.isCardBlocked) {
                state.unblockCard();
                state.speak(state.currentLanguage == 'ES' ? "Tarjeta desbloqueada." : "Tarjeta kawsarichisqa.");
              } else {
                state.blockCard("Solicitado en modo fácil");
                state.speak(state.currentLanguage == 'ES' ? "Tarjeta bloqueada por seguridad." : "Tarjeta harkarisqa.");
              }
            },
          ),
          // â”€â”€ Cerrar sesión â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          _btn(
            icon: Icons.exit_to_app,
            labelES: "CERRAR SESIí“N / SALIR",
            labelQU: "LLUQSIY / SAQIRIY",
            labelAY: "MISTUí‘A / SARTAí‘A",
            color: Colors.grey.shade800,
            onTap: () {
              state.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        controlsBar,
        Expanded(child: buttonList),
      ],
    );
  }

  // â”€â”€ Helper: language button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _langBtn(BuildContext context, String lang, String label) {
    final isActive = state.currentLanguage == lang;
    return Expanded(
      child: GestureDetector(
        onTap: () => state.setLanguage(lang),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 34,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white24,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? kBnRed : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11 * state.fontSizeMultiplier,
            ),
          ),
        ),
      ),
    );
  }

  // â”€â”€ Helper: font size button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _fontBtn(BuildContext context, double mult, String symbol, String label) {
    final isActive = state.fontSizeMultiplier == mult;
    return Expanded(
      child: GestureDetector(
        onTap: () => state.setFontSizeMultiplier(mult),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 30,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white24,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            "$symbol  $label",
            style: TextStyle(
              color: isActive ? kBnRed : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }
}

class _SimpleSaldosView extends StatelessWidget {
  final AppState state;
  const _SimpleSaldosView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Balance card
        Card(
          elevation: 4,
          color: kBnRed,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.t('CuentaAhorros'),
                  style: TextStyle(color: Colors.white, fontSize: 16 * state.fontSizeMultiplier, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Nº ${state.accountNo}",
                  style: TextStyle(color: Colors.white70, fontSize: 13 * state.fontSizeMultiplier),
                ),
                const SizedBox(height: 20),
                Text(
                  state.t('SaldoDisp'),
                  style: TextStyle(color: Colors.white70, fontSize: 12 * state.fontSizeMultiplier),
                ),
                Text(
                  "S/ ${state.savingsSoles.toStringAsFixed(2)}",
                  style: TextStyle(color: Colors.white, fontSize: 26 * state.fontSizeMultiplier, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  state.t('SaldoContable'),
                  style: TextStyle(color: Colors.white70, fontSize: 12 * state.fontSizeMultiplier),
                ),
                Text(
                  "S/ ${state.savingsContable.toStringAsFixed(2)}",
                  style: TextStyle(color: Colors.white70, fontSize: 18 * state.fontSizeMultiplier, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // CTS card
        Card(
          elevation: 2,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "CUENTA CTS",
                  style: TextStyle(color: kBnTextDark, fontSize: 16 * state.fontSizeMultiplier, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  "Saldo Disponible CTS",
                  style: TextStyle(color: kBnTextLight, fontSize: 12 * state.fontSizeMultiplier),
                ),
                Text(
                  "S/ ${state.ctsSoles.toStringAsFixed(2)}",
                  style: TextStyle(color: kBnTextDark, fontSize: 22 * state.fontSizeMultiplier, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class NormalNavigationDrawer extends StatelessWidget {
  const NormalNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    const themeColor = Color(0xFF1A1A1B);
    const accentTeal = Color(0xFF40E0D0);
    const accentOrange = Color(0xFFF25B2A);

    // Navigation helper
    void navigateTo(int tabIndex, {String flow = "menu", String securitySubFlow = "menu", VoidCallback? postNavigation}) {
      state.setTab(tabIndex);
      state.setOperationsFlow(flow);
      state.setSecuritySubFlow(securitySubFlow);
      Navigator.pop(context); // Close drawer
      if (postNavigation != null) {
        Future.delayed(const Duration(milliseconds: 150), postNavigation);
      }
    }

    return Drawer(
      child: Container(
        color: themeColor,
        child: Column(
          children: [
            // USER HEADER
            Padding(
              padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Avatar Box
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400, width: 1.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              state.name.isNotEmpty ? state.name[0] : "C",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Edit overlay icon
                          Positioned(
                            top: -4,
                            right: -4,
                            child: CircleAvatar(
                              radius: 8,
                              backgroundColor: Colors.grey.shade700,
                              child: const Icon(
                                Icons.edit,
                                size: 9,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // User greeting
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "¡Hola!",
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "CARLOS\nALBERTO R.",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Mi QR Button
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const MiQrScreen()));
                    },
                    child: Container(
                      width: 64,
                      height: 56,
                      decoration: BoxDecoration(
                        border: Border.all(color: accentTeal, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code, color: accentTeal, size: 22),
                          SizedBox(height: 2),
                          Text(
                            "Mi QR",
                            style: TextStyle(
                              color: accentTeal,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // MENU ITEMS LIST
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  // 0. Toggle Adulto Mayor (High Contrast)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade400,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            "ACTIVAR VISTA ADULTO MAYOR",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Switch(
                          value: state.simpleModeEnabled,
                          onChanged: (val) {
                            Navigator.pop(context); // Close drawer
                            Future.delayed(const Duration(milliseconds: 200), () => state.toggleSimpleMode());
                          },
                          activeColor: Colors.white,
                          activeTrackColor: Colors.green.shade800,
                          inactiveThumbColor: Colors.grey.shade300,
                          inactiveTrackColor: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // 1. Mis cuentas
                  _drawerItem(
                    iconWidget: const Icon(Icons.analytics_outlined, size: 22),
                    title: "Mis cuentas",
                    isSelected: state.currentTab == 0,
                    onTap: () => navigateTo(0),
                  ),
                  // 2. Actualización de datos
                  _drawerItem(
                    iconWidget: const Icon(Icons.person_outline, size: 22),
                    title: "Actualización de datos",
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                    },
                  ),
                  // 3. Transferir por celular o QR
                  _drawerItem(
                    iconWidget: const Icon(Icons.phone_android_outlined, size: 22),
                    title: "Transferir por Celular (Yape, Plin, BCP)",
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const TransferCellularScreen()));
                    },
                  ),
                  // 4. Transferir a cuentas
                  _drawerItem(
                    iconWidget: const Icon(Icons.swap_horiz, size: 22),
                    title: "Transferir a cuentas",
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const TransferAccountsScreen()));
                    },
                  ),
                  // 5. Giros
                  _drawerItem(
                    iconWidget: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade400, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "S/",
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: "Giros",
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const GirosScreen()));
                    },
                  ),
                  // 6. Pagos y recargas
                  _drawerItem(
                    iconWidget: const Icon(Icons.payments_outlined, size: 22),
                    title: "Pagos y recargas",
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PagosRecargasScreen()));
                    },
                  ),
                  // 7. Retiro sin tarjeta
                  _drawerItem(
                    iconWidget: const Icon(Icons.credit_card_outlined, size: 22),
                    title: "Retiro sin tarjeta",
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RetiroSinTarjetaScreen()));
                    },
                  ),
                  // 8. Préstamos
                  _drawerItem(
                    iconWidget: const Icon(Icons.monetization_on_outlined, size: 22),
                    title: "Préstamos",
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoanScreen()));
                    },
                  ),
                  // 9. Planes Sociales
                  _drawerItem(
                    iconWidget: const Icon(Icons.volunteer_activism_outlined, size: 22),
                    title: "Planes Sociales y Bonos",
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SocialPlansScreen()));
                    },
                  ),
                  // 9. Configuración y seguridad
                  _drawerItem(
                    iconWidget: const Icon(Icons.lock_outline, size: 22),
                    title: "Configuración y seguridad",
                    isSelected: state.currentTab == 2 && state.securitySubFlow == "menu",
                    onTap: () => navigateTo(2, securitySubFlow: "menu"),
                  ),
                  if (state.currentTab == 2) ...[
                    _drawerSubItem(
                      iconWidget: const Icon(Icons.credit_card_off_outlined, size: 18),
                      title: "Bloqueo de tarjetas",
                      isSelected: state.currentTab == 2 && state.securitySubFlow == "bloqueo",
                      onTap: () => navigateTo(2, securitySubFlow: "bloqueo"),
                    ),
                    _drawerSubItem(
                      iconWidget: const Icon(Icons.lock_open_outlined, size: 18),
                      title: "Clave Dinámica Digital",
                      isSelected: state.currentTab == 2 && state.securitySubFlow == "cdd",
                      onTap: () => navigateTo(2, securitySubFlow: "cdd"),
                    ),
                    _drawerSubItem(
                      iconWidget: const Icon(Icons.credit_card_outlined, size: 18),
                      title: "Configurar tarjetas",
                      isSelected: state.currentTab == 2 && state.securitySubFlow == "config_tarjetas",
                      onTap: () => navigateTo(2, securitySubFlow: "config_tarjetas"),
                    ),
                    _drawerSubItem(
                      iconWidget: const Icon(Icons.contact_phone_outlined, size: 18),
                      title: "Configurar transferencias",
                      isSelected: state.currentTab == 2 && state.securitySubFlow == "config_transfer",
                      onTap: () => navigateTo(2, securitySubFlow: "config_transfer"),
                    ),
                  ],
                  // 10. Ubícanos
                  _drawerItem(
                    iconWidget: const Icon(Icons.location_on_outlined, size: 22),
                    title: "Ubícanos",
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const UbicanosScreen()));
                    },
                  ),
                  // 11. Cambiar clave de internet
                  _drawerItem(
                    iconWidget: const Icon(Icons.key_outlined, size: 22),
                    title: "Cambiar clave de internet",
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangeClaveScreen()));
                    },
                  ),
                ],
              ),
            ),
            
            // FOOTER ACTION
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white10, width: 1)),
              ),
              child: InkWell(
                onTap: () {
                  state.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: accentOrange, size: 22),
                    SizedBox(width: 16),
                    Text(
                      "Cerrar Sesión",
                      style: TextStyle(
                        color: accentOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required Widget iconWidget,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final activeOrange = const Color(0xFFF25B2A);
    return ListTile(
      leading: Theme(
        data: ThemeData(
          iconTheme: IconThemeData(
            color: isSelected ? activeOrange : Colors.grey.shade400,
          ),
        ),
        child: iconWidget,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? activeOrange : Colors.grey.shade200,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  Widget _drawerSubItem({
    required Widget iconWidget,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final activeOrange = const Color(0xFFF25B2A);
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: ListTile(
        leading: Theme(
          data: ThemeData(
            iconTheme: IconThemeData(
              color: isSelected ? activeOrange : Colors.grey.shade500,
            ),
          ),
          child: iconWidget,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? activeOrange : Colors.grey.shade300,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}

class MiQrScreen extends StatelessWidget {
  const MiQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    const brandOrange = Color(0xFFFF4D00);
    const darkBg = Color(0xFF0C0C0C);

    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: brandOrange, size: 28),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Mi QR",
                    style: TextStyle(
                      color: brandOrange,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      // Instruction text
                      const Text(
                        "Muestra tu QR para recibir pagos o transferencias sin necesidad de brindar tu número celular",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // QR Code Container
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            "https://previews.123rf.com/images/nadalbg/nadalbg1701/nadalbg170100088/70157015-simple-qr-code.jpg",
                            width: 240,
                            height: 240,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 240,
                                height: 240,
                                color: Colors.grey[200],
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.qr_code,
                                  size: 160,
                                  color: Colors.black,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // User Name
                      Text(
                        state.name.isNotEmpty
                            ? state.name.toUpperCase()
                            : "CONDORI PIMENTEL DENISSE GERALDINE",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 64),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Compartir
                          Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Compartiendo QR...")),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: brandOrange, width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.share_outlined,
                                    color: brandOrange,
                                    size: 32,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Compartir",
                                style: TextStyle(
                                  color: brandOrange,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          // Descargar
                          Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Descargando QR...")),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: brandOrange, width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.download_outlined,
                                    color: brandOrange,
                                    size: 32,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Descargar",
                                style: TextStyle(
                                  color: brandOrange,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late String _selectedCarrier;

  @override
  void initState() {
    super.initState();
    final state = Provider.of<AppState>(context, listen: false);
    _phoneController = TextEditingController(text: state.phone);
    _emailController = TextEditingController(text: state.email);
    _selectedCarrier = state.carrier;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      state.speak(
        state.currentLanguage == 'ES' ? "Actualización de Datos. Aquí puede cambiar su número de celular, operador y correo electrónico." :
        state.currentLanguage == 'QU' ? "Kikin willakuykuna. Kaypi allichay karu rimayta, chaski willakuyta." :
        "Kikin yatiyí¤winaka. Akana askichaña kikin yatiyí¤winakama."
      );
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    const darkBg = Color(0xFF121212);
    const appOrange = Color(0xFFF2522E);
    const appBorder = Color(0xFF2A2A2A);

    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: appBorder, width: 1)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: appOrange, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Actualización de Datos",
                    style: TextStyle(color: appOrange, fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  BnTextField(
                    label: "Número Celular",
                    placeholder: "Escribe tu celular",
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 9,
                  ),
                  const SizedBox(height: 16),
                  const Text("Operador Móvil", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    dropdownColor: const Color(0xFF1E1F23),
                    value: _selectedCarrier,
                    style: const TextStyle(color: Colors.white),
                    items: ["Movistar", "Claro", "Entel", "Bitel"].map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCarrier = val;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: appBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: appOrange),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  BnTextField(
                    label: "Correo Electrónico",
                    placeholder: "Escribe tu email",
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 40),
                  BnButton(
                    text: "Guardar",
                    onPressed: () {
                      if (_phoneController.text.length == 9 && _emailController.text.contains("@")) {
                        state.updateProfile(_phoneController.text, _selectedCarrier, _emailController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Perfil actualizado exitosamente")),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Por favor rellene los datos correctamente")),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UbicanosScreen extends StatelessWidget {
  const UbicanosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const darkBg = Color(0xFF121212);
    const appOrange = Color(0xFFF2522E);
    const appBorder = Color(0xFF2A2A2A);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppState>(context, listen: false);
      state.speak(
        state.currentLanguage == 'ES' ? "Ubícanos. Aquí puede buscar agencias, cajeros y agentes MultiRed más cercanos." :
        state.currentLanguage == 'QU' ? "Ubícanos. Mask'ay MultiRed agenciakunata otaq cajerokunata." :
        "Ubícanos. Thaqhaña agencianaka, cajeronaka MultiRed."
      );
    });

    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: appBorder, width: 1)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: appOrange, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Ubícanos MultiRed",
                    style: TextStyle(color: appOrange, fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                "Visualiza agencias, cajeros (ATM) y agentes cercanos a tu ubicación",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            Container(
              height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue.shade900.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: appBorder),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 40, top: 50,
                    child: Icon(Icons.location_on, color: appOrange, size: 32),
                  ),
                  Positioned(
                    right: 60, top: 30,
                    child: const Icon(Icons.location_on, color: Colors.blue, size: 32),
                  ),
                  Positioned(
                    left: 90, bottom: 40,
                    child: const Icon(Icons.location_on, color: Colors.green, size: 32),
                  ),
                  const Center(
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.my_location, size: 12, color: Colors.white),
                    ),
                  ),
                  Positioned(
                    bottom: 10, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      color: Colors.black54,
                      child: const Text("Av. Javier Prado Este", style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _locationCard(
                    icon: Icons.apartment,
                    title: "Agencia San Isidro - BN",
                    desc: "Av. Javier Prado Este 2499 Â· 250m",
                    hours: "Lunes a Viernes 8:00 AM - 5:30 PM",
                    color: appOrange,
                  ),
                  _locationCard(
                    icon: Icons.atm,
                    title: "Cajero ATM MultiRed",
                    desc: "C.C. La Rambla - Piso 1 Â· 450m",
                    hours: "Abierto 24 Horas",
                    color: Colors.blue,
                  ),
                  _locationCard(
                    icon: Icons.store,
                    title: "Agente Corresponsal MultiRed - Bodega Rossi",
                    desc: "Calle Las Begonias 340 Â· 600m",
                    hours: "Lunes a Sábado 9:00 AM - 9:00 PM",
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _locationCard({
    required IconData icon,
    required String title,
    required String desc,
    required String hours,
    required Color color,
  }) {
    return Card(
      color: const Color(0xFF1E1F23),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(hours, style: const TextStyle(fontSize: 11, color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoanScreen extends StatefulWidget {
  const LoanScreen({super.key});

  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {
  double _selectedAmount = 5000;
  int _selectedMonths = 12;
  final double _interestRate = 0.145; // 14.5% annual

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppState>(context, listen: false);
      state.speak(
        state.currentLanguage == 'ES' ? "Préstamos MultiRed. Aquí puede simular sus cuotas mensuales y solicitar el desembolso." :
        state.currentLanguage == 'QU' ? "Préstamos MultiRed. Kaypi simula cuotakunata." :
        "Préstamos MultiRed. Akana simula cuotanaka."
      );
    });
  }

  double _calculateQuota() {
    double r = _interestRate / 12;
    double quota = (_selectedAmount * r) / (1 - pow(1 + r, -_selectedMonths));
    return quota;
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    const darkBg = Color(0xFF121212);
    const appOrange = Color(0xFFF2522E);
    const appBorder = Color(0xFF2A2A2A);

    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: appBorder, width: 1)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: appOrange, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Préstamos MultiRed",
                    style: TextStyle(color: appOrange, fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    "¡Felicidades! Tienes un préstamo preaprobado. Simula tus cuotas aquí:",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Monto a solicitar:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text("S/ ${_selectedAmount.toStringAsFixed(0)}", style: const TextStyle(color: appOrange, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  Slider(
                    value: _selectedAmount,
                    min: 1000,
                    max: 20000,
                    divisions: 19,
                    activeColor: appOrange,
                    inactiveColor: appBorder,
                    onChanged: (val) {
                      setState(() {
                        _selectedAmount = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Plazo de pago:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text("$_selectedMonths meses", style: const TextStyle(color: appOrange, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  Slider(
                    value: _selectedMonths.toDouble(),
                    min: 6,
                    max: 36,
                    divisions: 5,
                    activeColor: appOrange,
                    inactiveColor: appBorder,
                    onChanged: (val) {
                      setState(() {
                        _selectedMonths = val.round();
                      });
                    },
                  ),
                  const Divider(color: appBorder, height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1F23),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: appBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Cuota mensual estimada:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70)),
                        Text(
                          "S/ ${_calculateQuota().toStringAsFixed(2)}",
                          style: const TextStyle(color: appOrange, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text("Tasa Efectiva Anual (TEA): 14.50%", style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 40),
                  BnButton(
                    text: "Solicitar Desembolso",
                    onPressed: () {
                      state.addLoan(_selectedAmount);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Préstamo de S/ ${_selectedAmount.toStringAsFixed(2)} desembolsado en su Cuenta Ahorros")),
                      );
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChangeClaveScreen extends StatefulWidget {
  const ChangeClaveScreen({super.key});

  @override
  State<ChangeClaveScreen> createState() => _ChangeClaveScreenState();
}

class _ChangeClaveScreenState extends State<ChangeClaveScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppState>(context, listen: false);
      state.speak(
        state.currentLanguage == 'ES' ? "Cambiar Clave de Internet. Ingrese su clave actual y defina su nueva clave de seis dígitos." :
        state.currentLanguage == 'QU' ? "Llawi t'ikray. Churay mosoq llaveta." :
        "Llavi mayjt'ayaña. Uchaña k'ilimata llavi."
      );
    });
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    const darkBg = Color(0xFF121212);
    const appOrange = Color(0xFFF2522E);
    const appBorder = Color(0xFF2A2A2A);

    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: appBorder, width: 1)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: appOrange, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Cambiar Clave de Internet",
                    style: TextStyle(color: appOrange, fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  BnTextField(
                    label: "Clave Actual (6 dígitos)",
                    placeholder: "******",
                    controller: _currentController,
                    isPassword: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                  ),
                  const SizedBox(height: 16),
                  BnTextField(
                    label: "Nueva Clave (6 dígitos)",
                    placeholder: "******",
                    controller: _newController,
                    isPassword: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                  ),
                  const SizedBox(height: 16),
                  BnTextField(
                    label: "Confirmar Nueva Clave",
                    placeholder: "******",
                    controller: _confirmController,
                    isPassword: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                  ),
                  const SizedBox(height: 40),
                  BnButton(
                    text: "Cambiar Clave",
                    onPressed: () {
                      if (_currentController.text == state.clave &&
                          _newController.text.length == 6 &&
                          _newController.text == _confirmController.text) {
                        state.changeClave(_newController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Clave modificada exitosamente. íšsela en su próximo inicio de sesión")),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Verifique que la clave actual sea correcta y las nuevas coincidan")),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactanosScreen extends StatelessWidget {
  const ContactanosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const darkBg = Color(0xFF121212);
    const appOrange = Color(0xFFF2522E);
    const appBorder = Color(0xFF2A2A2A);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppState>(context, listen: false);
      state.speak(
        state.currentLanguage == 'ES' ? "Contáctanos. Puede comunicarse con la línea de atención gratuita nacional las veinticuatro horas." :
        state.currentLanguage == 'QU' ? "Contáctanos. Rimay yanapakuywan." :
        "Contáctanos. Arukiyaña yanapawimpi."
      );
    });

    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: appBorder, width: 1)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: appOrange, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Contáctanos BN",
                    style: TextStyle(color: appOrange, fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 20),
                  const Icon(Icons.headset_mic, size: 64, color: appOrange),
                  const SizedBox(height: 16),
                  const Text(
                    "Nuestros asesores están disponibles las 24 horas del día, los 7 días de la semana para ayudarte.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.4),
                  ),
                  const SizedBox(height: 40),
                  Card(
                    color: const Color(0xFF1E1F23),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.phone, color: Colors.green, size: 28),
                      title: const Text("Línea Gratuita Nacional", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                      subtitle: const Text("0-800-10-700", style: TextStyle(fontSize: 13, color: Colors.grey)),
                      trailing: const Icon(Icons.call, color: Colors.greenAccent),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Llamando a Línea Gratuita: 0-800-10-700...")),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// INDEPENDENT OPERATION SCREENS (drawer â†’ full-screen, isolated navigation)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

// Shared constants for operation screens
const _opBg = Color(0xFF121212);
const _opOrange = Color(0xFFF2522E);
const _opBorder = Color(0xFF2A2A2A);

/// Reusable header for operation screens
Widget _opHeader(BuildContext context, String title) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: _opBorder, width: 1)),
    ),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: _opOrange, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: _opOrange, fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );
}

// â”€â”€ 1. TRANSFERIR POR CELULAR O QR â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class TransferCellularScreen extends StatefulWidget {
  const TransferCellularScreen({super.key});
  @override
  State<TransferCellularScreen> createState() => _TransferCellularScreenState();
}

class _TransferCellularScreenState extends State<TransferCellularScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppState>(context, listen: false);
      state.speak(
        state.currentLanguage == 'ES'
            ? "Transferir por Celular o QR. Ingrese el número de celular o escanee el QR del destinatario. El monto máximo gratuito es de quinientos soles."
            : state.currentLanguage == 'QU'
                ? "Celular o QR nisqapi qollqe apachiy. Apachiy celular numeroniyoj."
                : "Celular o QR nayra qullqi apachiri. Uchaña celular nayra.",
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _opBg,
      body: SafeArea(
        child: Column(
          children: [
            _opHeader(context, "Transferir por Celular o QR"),
            const Expanded(child: TransferCellularFlow()),
          ],
        ),
      ),
    );
  }
}

// â”€â”€ 2. TRANSFERIR A CUENTAS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
/// Shows a sub-menu: BN, Interbancaria, Pago Tarjeta Crédito
class TransferAccountsScreen extends StatefulWidget {
  const TransferAccountsScreen({super.key});
  @override
  State<TransferAccountsScreen> createState() => _TransferAccountsScreenState();
}

class _TransferAccountsScreenState extends State<TransferAccountsScreen> {
  String? _subFlow; // null = menu, 'bn' | 'inter' | 'tc'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppState>(context, listen: false);
      state.speak(
        state.currentLanguage == 'ES'
            ? "Transferir a Cuentas. Elija transferencia al mismo banco, transferencia interbancaria por CCI, o pago de tarjeta de crédito."
            : state.currentLanguage == 'QU'
                ? "Cuenta nisqaman qollqe apachiy. Akllay banco ukupi o interbancario."
                : "Cuenta nayra qullqi apachiri. Akaña banco ukana o interbancario.",
      );
    });
  }

  Widget _subMenuTile({required IconData icon, required String title, required String desc, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: _opBorder, width: 1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: _opOrange, size: 26),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If a sub-flow is active, show it with its own back button
    if (_subFlow != null) {
      Widget flow;
      String subTitle;
      switch (_subFlow) {
        case 'bn':
          flow = const TransferSameBankFlow();
          subTitle = "Transferencia Mismo Banco (BN)";
          break;
        case 'inter':
          flow = const TransferInterbankFlow();
          subTitle = "Transferencia Interbancaria";
          break;
        case 'tc':
          flow = const PayCreditCardFlow();
          subTitle = "Pago de Tarjeta de Crédito";
          break;
        default:
          flow = const SizedBox();
          subTitle = "";
      }

      return Scaffold(
        backgroundColor: _opBg,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: _opBorder, width: 1)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: _opOrange, size: 28),
                      onPressed: () => setState(() => _subFlow = null),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(subTitle,
                          style: const TextStyle(color: _opOrange, fontSize: 18, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
              Expanded(child: flow),
            ],
          ),
        ),
      );
    }

    // Main menu
    return Scaffold(
      backgroundColor: _opBg,
      body: SafeArea(
        child: Column(
          children: [
            _opHeader(context, "Transferir a Cuentas"),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Seleccione el tipo de transferencia que desea realizar",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),
            _subMenuTile(
              icon: Icons.account_balance,
              title: "A Cuentas Mismo Banco (BN)",
              desc: "Transfiere a cuentas del Banco de la Nación",
              onTap: () {
                final state = Provider.of<AppState>(context, listen: false);
                state.speak("Transferencia al mismo banco. Ingrese la cuenta destino BN, el monto y el concepto.");
                setState(() => _subFlow = 'bn');
              },
            ),
            _subMenuTile(
              icon: Icons.account_balance_wallet_outlined,
              title: "Transferencias Interbancarias",
              desc: "Inmediatas o diferidas por CCI a otros bancos",
              onTap: () {
                final state = Provider.of<AppState>(context, listen: false);
                state.speak("Transferencia interbancaria. Ingrese el CCI de veinte dígitos, nombre del beneficiario y monto.");
                setState(() => _subFlow = 'inter');
              },
            ),
            _subMenuTile(
              icon: Icons.credit_card,
              title: "Pago de Tarjeta de Crédito",
              desc: "Paga tarjetas de crédito de otros bancos",
              onTap: () {
                final state = Provider.of<AppState>(context, listen: false);
                state.speak("Pago de tarjeta de crédito. Seleccione el banco, ingrese el número de tarjeta y el monto a pagar.");
                setState(() => _subFlow = 'tc');
              },
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€ 3. GIROS MULTIRED â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class GirosScreen extends StatefulWidget {
  const GirosScreen({super.key});
  @override
  State<GirosScreen> createState() => _GirosScreenState();
}

class _GirosScreenState extends State<GirosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppState>(context, listen: false);
      state.speak(
        state.currentLanguage == 'ES'
            ? "Giros MultiRed. Emite un giro desde cuatro hasta mil soles. La tarifa es fija de tres soles. Ingrese el DNI, nombre del destinatario y el monto."
            : state.currentLanguage == 'QU'
                ? "Giro MultiRed. Qollqe apachiy. Qollqe rantin kimsa sol."
                : "Giro MultiRed. Qullqi apachiri. Kimsa sol rantin.",
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _opBg,
      body: SafeArea(
        child: Column(
          children: [
            _opHeader(context, "Giros MultiRed"),
            const Expanded(child: EmitGiroFlow()),
          ],
        ),
      ),
    );
  }
}

// â”€â”€ 4. PAGOS Y RECARGAS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
/// Shows a sub-menu: Agua, Luz, Teléfono/Cable, Recargas de Celular
class PagosRecargasScreen extends StatefulWidget {
  const PagosRecargasScreen({super.key});
  @override
  State<PagosRecargasScreen> createState() => _PagosRecargasScreenState();
}

class _PagosRecargasScreenState extends State<PagosRecargasScreen> {
  String? _subFlow; // null = menu, 'water' | 'electricity' | 'phone' | 'recharge'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppState>(context, listen: false);
      state.speak(
        state.currentLanguage == 'ES'
            ? "Pagos y Recargas. Puede pagar servicios de agua, luz, telefonía y cable, o recargar el saldo de su celular."
            : state.currentLanguage == 'QU'
                ? "Pagos y Recargas. Paray unu, luz, telefono o celular recarga."
                : "Pagos y Recargas. Paga una, luz, telefono o celular recarga.",
      );
    });
  }

  Widget _subMenuTile({required IconData icon, required Color iconColor, required String title, required String desc, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: _opBorder, width: 1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sub-flow active
    if (_subFlow != null) {
      Widget flow;
      String subTitle;
      switch (_subFlow) {
        case 'water':
          flow = const PayServiceFlow(serviceType: "Agua");
          subTitle = "Pago de Agua";
          break;
        case 'electricity':
          flow = const PayServiceFlow(serviceType: "Luz");
          subTitle = "Pago de Luz";
          break;
        case 'phone':
          flow = const PayServiceFlow(serviceType: "Teléfono");
          subTitle = "Pago de Telefonía y Cable";
          break;
        case 'recharge':
          flow = const RechargeFlow();
          subTitle = "Recarga de Celular";
          break;
        default:
          flow = const SizedBox();
          subTitle = "";
      }

      return Scaffold(
        backgroundColor: _opBg,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: _opBorder, width: 1)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: _opOrange, size: 28),
                      onPressed: () => setState(() => _subFlow = null),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(subTitle,
                          style: const TextStyle(color: _opOrange, fontSize: 18, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
              Expanded(child: flow),
            ],
          ),
        ),
      );
    }

    // Main menu
    return Scaffold(
      backgroundColor: _opBg,
      body: SafeArea(
        child: Column(
          children: [
            _opHeader(context, "Pagos y Recargas"),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Seleccione el servicio que desea pagar o recargar",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),
            _subMenuTile(
              icon: Icons.water_drop_outlined,
              iconColor: Colors.blue,
              title: "Pago de Agua",
              desc: "Sedapal, Sedalib y otras EPS",
              onTap: () {
                final state = Provider.of<AppState>(context, listen: false);
                state.speak("Pago de agua. Ingrese su código de suministro y el monto a pagar.");
                setState(() => _subFlow = 'water');
              },
            ),
            _subMenuTile(
              icon: Icons.bolt,
              iconColor: Colors.amber,
              title: "Pago de Luz",
              desc: "Enel, Luz del Sur, Electrocentro y más",
              onTap: () {
                final state = Provider.of<AppState>(context, listen: false);
                state.speak("Pago de luz. Ingrese su código de suministro y el monto a pagar.");
                setState(() => _subFlow = 'electricity');
              },
            ),
            _subMenuTile(
              icon: Icons.phone,
              iconColor: Colors.teal,
              title: "Telefonía y Cable",
              desc: "Movistar, Claro, Win, Entel fijo",
              onTap: () {
                final state = Provider.of<AppState>(context, listen: false);
                state.speak("Pago de telefonía y cable. Ingrese su código de cliente y el monto.");
                setState(() => _subFlow = 'phone');
              },
            ),
            _subMenuTile(
              icon: Icons.smartphone,
              iconColor: Colors.green,
              title: "Recargas de Celular",
              desc: "Claro, Movistar, Entel, Bitel al instante",
              onTap: () {
                final state = Provider.of<AppState>(context, listen: false);
                state.speak("Recarga de celular. Seleccione el operador, ingrese el número y elija el monto de recarga.");
                setState(() => _subFlow = 'recharge');
              },
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€ 5. RETIRO SIN TARJETA â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class RetiroSinTarjetaScreen extends StatefulWidget {
  const RetiroSinTarjetaScreen({super.key});
  @override
  State<RetiroSinTarjetaScreen> createState() => _RetiroSinTarjetaScreenState();
}

class _RetiroSinTarjetaScreenState extends State<RetiroSinTarjetaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppState>(context, listen: false);
      state.speak(
        state.currentLanguage == 'ES'
            ? "Retiro sin Tarjeta. Genere un código de retiro válido por diez minutos para retirar efectivo en cualquier cajero MultiRed sin usar su tarjeta."
            : state.currentLanguage == 'QU'
                ? "Tarjeta illajpi qollqe orqoy. Codigo churay diez minutospi cajero MultiRedpi."
                : "Tarjeta janiwa qullqi oraqaña. Codigo uchaña diez minuto cajero MultiRedpi.",
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _opBg,
      body: SafeArea(
        child: Column(
          children: [
            _opHeader(context, "Retiro sin Tarjeta"),
            const Expanded(child: CardlessWithdrawalFlow()),
          ],
        ),
      ),
    );
  }
}

// ── 12. PLANES SOCIALES ───────────────────────────────────────────
class SocialPlansScreen extends StatefulWidget {
  const SocialPlansScreen({super.key});
  @override
  State<SocialPlansScreen> createState() => _SocialPlansScreenState();
}

class _SocialPlansScreenState extends State<SocialPlansScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppState>(context, listen: false);
      state.speak(
        state.currentLanguage == 'ES'
            ? 'Sección de Planes Sociales y Bonos. Aquí puedes ver tus próximos ingresos programados.'
            : state.currentLanguage == 'QU'
                ? 'Bonos qollqe. Kaypi qaway proximos bonos.'
                : 'Bono yatiyäwi. Uñjaña jutiri bonos.'
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F5),
      body: SafeArea(
        child: Column(
          children: [
            _opHeader(context, 'Planes Sociales y Bonos'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text('Próximos ingresos programados', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pensión 65', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFC8102E))),
                        const SizedBox(height: 8),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('Monto a recibir:', style: TextStyle(color: Colors.grey)), Text('S/ 250.00', style: TextStyle(fontWeight: FontWeight.bold))]),
                        const SizedBox(height: 4),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('Fecha estimada:', style: TextStyle(color: Colors.grey)), Text('20/07/2026', style: TextStyle(fontWeight: FontWeight.bold))]),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC8102E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Center(child: Text('Ver cronograma', style: TextStyle(color: Colors.white)))),
                      ]
                    )
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bono Yanapay (Finalizado)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('Monto cobrado:', style: TextStyle(color: Colors.grey)), Text('S/ 350.00', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))]),
                        const SizedBox(height: 4),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('Fecha de cobro:', style: TextStyle(color: Colors.grey)), Text('10/05/2024', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))]),
                      ]
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
