import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../models/app_state.dart';
import '../services/voice_service.dart';
import 'components.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

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
      backgroundColor: kBnBg,
      appBar: AppBar(
        backgroundColor: kBnRed,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // BN Logo
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    'assets/images/bn_logo.png',
                    height: 28,
                    width: 130,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
            // Dynamic Key Status & Simple Mode Toggle
            Row(
              children: [
                Text(
                  state.simpleModeEnabled ? "Modo Clásico" : "Modo Simple",
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: state.simpleModeEnabled,
                    onChanged: (val) => state.toggleSimpleMode(),
                    activeThumbColor: Colors.greenAccent,
                    activeTrackColor: Colors.white30,
                    inactiveThumbColor: Colors.white70,
                    inactiveTrackColor: Colors.white24,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  state.cddActivated ? Icons.gpp_good : Icons.gpp_maybe,
                  color: state.cddActivated ? Colors.greenAccent : Colors.orangeAccent,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  state.cddActivated ? "CDD" : "Sin CDD",
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
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
              Expanded(child: state.simpleModeEnabled ? SimpleDashboardView(state: state) : tabs[_currentIndex]),
            ],
          ),
          const AccessibilityFloatingButton(),
          const VoiceNarrationOverlay(),
        ],
      ),
      bottomNavigationBar: state.simpleModeEnabled
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
                // TTS tab switch feedback
                String sectionKey = "";
                if (index == 0) sectionKey = 'Inicio';
                if (index == 1) sectionKey = 'Operaciones';
                if (index == 2) sectionKey = 'Seguridad';
                if (index == 3) sectionKey = 'Mas';
                
                String sectionTrans = state.t(sectionKey);
                String phrase = "";
                if (state.currentLanguage == 'ES') phrase = "Ingresando a la sección $sectionTrans";
                if (state.currentLanguage == 'QU') phrase = "Yaykuchkan $sectionTrans t'aqaman";
                if (state.currentLanguage == 'AY') phrase = "Mantachkan $sectionTrans chikuru";
                state.speak(phrase);
              },
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home, color: kBnRed),
                  label: state.t('Inicio'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.swap_horiz_outlined),
                  selectedIcon: const Icon(Icons.swap_horiz, color: kBnRed),
                  label: state.t('Operaciones'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.shield_outlined),
                  selectedIcon: const Icon(Icons.shield, color: kBnRed),
                  label: state.t('Seguridad'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.more_horiz_outlined),
                  selectedIcon: const Icon(Icons.more_horiz, color: kBnRed),
                  label: state.t('Mas'),
                ),
              ],
            ),
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
  bool _showBalances = true;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Red Header Gradient card
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kBnRed, kBnRedDark],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${state.t('Hola')}, ${state.name.split(' ')[0]}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20 * state.fontSizeMultiplier,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _showBalances ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _showBalances = !_showBalances;
                        });
                        state.speak(
                          _showBalances 
                              ? (state.currentLanguage == 'ES' ? "Mostrando saldos" : "Qullqi qhawachiq")
                              : (state.currentLanguage == 'ES' ? "Ocultando saldos" : "Qullqi pakachiq")
                        );
                      },
                    ),
                  ],
                ),
                Text(
                  state.t('Bienvenido'),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13 * state.fontSizeMultiplier,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Account Balance Card (Savings)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            state.t('CuentaAhorros'),
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14 * state.fontSizeMultiplier),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "N° ${state.accountNo}",
                              style: TextStyle(color: Colors.white, fontSize: 11 * state.fontSizeMultiplier),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(state.t('SaldoDisp'), style: TextStyle(color: Colors.white70, fontSize: 11 * state.fontSizeMultiplier)),
                                const SizedBox(height: 2),
                                Text(
                                  _showBalances ? "S/ ${state.savingsSoles.toStringAsFixed(2)}" : "S/ ••••••",
                                  style: TextStyle(color: Colors.white, fontSize: 22 * state.fontSizeMultiplier, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(state.t('SaldoContable'), style: TextStyle(color: Colors.white70, fontSize: 11 * state.fontSizeMultiplier)),
                                const SizedBox(height: 2),
                                Text(
                                  _showBalances ? "S/ ${state.savingsContable.toStringAsFixed(2)}" : "S/ ••••••",
                                  style: TextStyle(color: Colors.white70, fontSize: 15 * state.fontSizeMultiplier, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, color: Colors.white24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "CCI: ${state.cci}",
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.white, size: 16),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("CCI copiado al portapapeles")),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // US Dollar Balance
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Saldo Dólares (USD)", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text(
                            _showBalances ? "\$ ${state.savingsDollars.toStringAsFixed(2)}" : "\$ ••••••",
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CTS Account (If exists)
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.business_center, color: Colors.orange.shade800),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Cuenta de CTS",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kBnTextDark),
                              ),
                              const SizedBox(height: 2),
                              const Text("Compensación por Tiempo de Servicio", style: TextStyle(color: kBnTextLight, fontSize: 11)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _showBalances ? "S/ ${state.ctsSoles.toStringAsFixed(2)}" : "S/ ••••••",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: kBnTextDark),
                            ),
                            const Text("Sin Token / CDD", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Exchange Rate & Quick QR Access
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Tipo Cambio
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.currency_exchange, color: kBnRed, size: 16),
                                SizedBox(width: 4),
                                Text("Tipo de Cambio", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                            const Divider(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Compra", style: TextStyle(fontSize: 10, color: kBnTextLight)),
                                    Text("S/ ${state.usdBuy.toStringAsFixed(3)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text("Venta", style: TextStyle(fontSize: 10, color: kBnTextLight)),
                                    Text("S/ ${state.usdSell.toStringAsFixed(3)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // QR BN Button
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          _showQrDialog(context, state);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))
                            ],
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.qr_code_2, color: kBnRed, size: 40),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Mi QR BN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: kBnTextDark)),
                                    Text("Cobrar y Pagar", style: TextStyle(fontSize: 11, color: kBnTextLight)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Quick Operations Buttons
                const SizedBox(height: 20),
                const Text(
                  "Accesos Rápidos",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kBnTextDark),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _quickActionButton(
                      icon: Icons.send_rounded,
                      label: "Transferir",
                      color: Colors.teal.shade700,
                      onTap: () {
                        // Open operations or prompt transfer
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Dirígete a la pestaña 'Operaciones' para transferir")),
                        );
                      },
                    ),
                    _quickActionButton(
                      icon: Icons.payments_outlined,
                      label: "Pagar Luz/Agua",
                      color: Colors.amber.shade800,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Dirígete a la pestaña 'Operaciones' para pagar")),
                        );
                      },
                    ),
                    _quickActionButton(
                      icon: Icons.phone_android_rounded,
                      label: "Recargar Celular",
                      color: Colors.blue.shade700,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Dirígete a la pestaña 'Operaciones' para recargar")),
                        );
                      },
                    ),
                    _quickActionButton(
                      icon: Icons.contact_phone_rounded,
                      label: "Yape y Plin",
                      color: Colors.purple.shade700,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Dirígete a la pestaña 'Operaciones' -> 'Transferencia Celular'")),
                        );
                      },
                    ),
                  ],
                ),

                // Transactions / Movements List (20 movements)
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Últimos Movimientos (20)",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kBnTextDark),
                    ),
                    TextButton(
                      onPressed: () {
                        // Show filter bottom sheet or download certificate mockup
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Constancia consolidada descargada en PDF")),
                        );
                      },
                      child: const Text("Descargar todo", style: TextStyle(color: kBnRed, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: min(20, state.movements.length),
                  itemBuilder: (context, index) {
                    final movement = state.movements[index];
                    return Card(
                      elevation: 0.5,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: movement.isCredit ? Colors.green.shade50 : Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            movement.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                            color: movement.isCredit ? Colors.green : kBnRed,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          movement.description,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: kBnTextDark),
                        ),
                        subtitle: Row(
                          children: [
                            Text(movement.date, style: const TextStyle(fontSize: 11, color: kBnTextLight)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: movement.type == "CTS" ? Colors.orange.shade50 : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                movement.type,
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: movement.type == "CTS" ? Colors.orange.shade800 : kBnTextLight),
                              ),
                            )
                          ],
                        ),
                        trailing: Text(
                          "${movement.isCredit ? '+' : '-'} S/ ${movement.amount.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: movement.isCredit ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _quickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: kBnTextDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // QR Modal Dialog
  void _showQrDialog(BuildContext context, AppState state) {
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
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Image.asset(
                                      'assets/images/bn_logo.png',
                                      height: 12,
                                      fit: BoxFit.contain,
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
                                color: Colors.black.withValues(alpha: 0.05),
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
  String _activeFlow = "menu"; // "menu", "trans_bn", "trans_cell", "trans_inter", "trans_tc", "pay_water", "pay_electricity", "pay_phone", "recharge", "giro", "withdrawal"
  
  @override
  Widget build(BuildContext context) {
    // Back handler
    Widget wrapFlow(Widget flowWidget, String title) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          setState(() {
            _activeFlow = "menu";
          });
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
                setState(() {
                  _activeFlow = "menu";
                });
              },
            ),
          ),
          body: flowWidget,
        ),
      );
    }

    if (_activeFlow == "menu") {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // TRANSFERENCIAS
          const CategoryHeader(title: "Transferencias", icon: Icons.swap_horiz, color: Colors.teal),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _menuItem(
                  icon: Icons.account_balance,
                  title: "A Cuentas Mismo Banco (BN)",
                  desc: "Transfiere a cuentas del Banco de la Nación",
                  onTap: () => setState(() => _activeFlow = "trans_bn"),
                ),
                const Divider(height: 1),
                _menuItem(
                  icon: Icons.phone_android,
                  title: "Transferir a Celular",
                  desc: "Yape, Plin y bancos (Gratis hasta S/500)",
                  onTap: () => setState(() => _activeFlow = "trans_cell"),
                ),
                const Divider(height: 1),
                _menuItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: "Transferencias Interbancarias",
                  desc: "Inmediatas o diferidas por CCI",
                  onTap: () => setState(() => _activeFlow = "trans_inter"),
                ),
                const Divider(height: 1),
                _menuItem(
                  icon: Icons.credit_card,
                  title: "Pago de Tarjeta de Crédito",
                  desc: "Paga tarjetas de crédito de otros bancos",
                  onTap: () => setState(() => _activeFlow = "trans_tc"),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // PAGOS Y RECARGAS
          const CategoryHeader(title: "Pagos y Recargas", icon: Icons.payments, color: Colors.amber),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _menuItem(
                  icon: Icons.water_drop_outlined,
                  title: "Pago de Agua",
                  desc: "Sedapal, Sedalib y otras EPS",
                  onTap: () => setState(() => _activeFlow = "pay_water"),
                ),
                const Divider(height: 1),
                _menuItem(
                  icon: Icons.bolt,
                  title: "Pago de Luz",
                  desc: "Enel, Luz del Sur, Electrocentro, etc.",
                  onTap: () => setState(() => _activeFlow = "pay_electricity"),
                ),
                const Divider(height: 1),
                _menuItem(
                  icon: Icons.phone,
                  title: "Telefonía y Cable",
                  desc: "Movistar, Claro, Win, Entel fijo",
                  onTap: () => setState(() => _activeFlow = "pay_phone"),
                ),
                const Divider(height: 1),
                _menuItem(
                  icon: Icons.smartphone,
                  title: "Recargas de Celular",
                  desc: "Claro, Movistar, Entel, Bitel",
                  onTap: () => setState(() => _activeFlow = "recharge"),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // GIROS Y RETIRO SIN TARJETA
          const CategoryHeader(title: "Servicios MultiRed", icon: Icons.card_membership_rounded, color: Colors.deepOrange),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _menuItem(
                  icon: Icons.send_to_mobile,
                  title: "Emitir Giro MultiRed",
                  desc: "Desde S/4 a S/1,000 · Tarifa fija S/3",
                  onTap: () => setState(() => _activeFlow = "giro"),
                ),
                const Divider(height: 1),
                _menuItem(
                  icon: Icons.no_accounts_outlined,
                  title: "Retiro sin Tarjeta",
                  desc: "Genera código de retiro de 10 min",
                  onTap: () => setState(() => _activeFlow = "withdrawal"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      );
    }
    
    // Sub Flow Widget builders
    switch (_activeFlow) {
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
              color: color.withValues(alpha: 0.9),
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

  void _showBlockDialog(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Bloquear Tarjeta", style: TextStyle(color: kBnRed, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "¿Está seguro de bloquear su tarjeta Multired de forma definitiva? Esta operación inhabilitará retiros y compras de inmediato.",
                style: TextStyle(fontSize: 13),
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
              child: const Text("Cancelar", style: TextStyle(color: kBnTextLight)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kBnRed),
              onPressed: () {
                if (_reasonController.text.isNotEmpty) {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (c) => CddVerificationDialog(
                      operationDetails: "Bloqueo definitivo de tarjeta Multired por: ${_reasonController.text}",
                      onVerified: () {
                        state.blockCard(_reasonController.text);
                        _reasonController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Su tarjeta ha sido BLOQUEADA. Comuníquese al 0-800-10-700 para reposición")),
                        );
                      },
                    ),
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

    return ListView(
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
                    decoration: BoxDecoration(color: kBnRed, borderRadius: BorderRadius.circular(4)),
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
        const Text("Configuración de Tarjeta", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),

        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text("Compras por Internet", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
                subtitle: const Text("Permitir compras en páginas web y apps", style: TextStyle(fontSize: 11)),
                activeThumbColor: kBnRed,
                value: state.isInternetPurchasesEnabled,
                onChanged: (val) {
                  state.toggleCardSetting('internet');
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text("Consumo en el extranjero", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
                subtitle: const Text("Habilita compras y retiros fuera del Perú", style: TextStyle(fontSize: 11)),
                activeThumbColor: kBnRed,
                value: state.isForeignConsumptionEnabled,
                onChanged: (val) {
                  state.toggleCardSetting('foreign');
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text("Transferencias y Retiros", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
                subtitle: const Text("Permite transacciones interbancarias y cajeros", style: TextStyle(fontSize: 11)),
                activeThumbColor: kBnRed,
                value: state.isTransfersEnabled,
                onChanged: (val) {
                  state.toggleCardSetting('transfers');
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text("Notificaciones de Transacción", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
                subtitle: const Text("Recibe notificaciones en tiempo real por cada consumo", style: TextStyle(fontSize: 11)),
                activeThumbColor: kBnRed,
                value: state.isNotificationsEnabled,
                onChanged: (val) {
                  state.toggleCardSetting('notifications');
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text("Afiliado a Transferencias por Celular", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
                subtitle: const Text("Permite recibir y enviar dinero vía Yape/Plin", style: TextStyle(fontSize: 11)),
                activeThumbColor: kBnRed,
                value: state.isCellularTransferAffiliated,
                onChanged: (val) {
                  showDialog(
                    context: context,
                    builder: (c) => CddVerificationDialog(
                      operationDetails: state.isCellularTransferAffiliated
                          ? "Desafiliación del número ${state.phone} de transferencias móviles"
                          : "Afiliación del número ${state.phone} a transferencias móviles",
                      onVerified: () {
                        state.toggleCardSetting('cellular');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.isCellularTransferAffiliated ? "Afiliación exitosa" : "Desafiliación exitosa")),
                        );
                      },
                    ),
                  );
                },
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
          style: TextStyle(color: kBnTextLight, fontSize: 11),
        ),
        const SizedBox(height: 32),
      ],
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
                  backgroundColor: kBnRed.withValues(alpha: 0.1),
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
                onTap: () => _showEditProfileDialog(context, state),
              ),
              const Divider(height: 1),
              _profileItem(
                context: context,
                icon: Icons.map_outlined,
                title: "Ubícanos (Agencias y Cajeros)",
                desc: "Ubica canales MultiRed más cercanos sin sesión",
                onTap: () => _showUbicanosDialog(context),
              ),
              const Divider(height: 1),
              _profileItem(
                context: context,
                icon: Icons.monetization_on_outlined,
                title: "Préstamos MultiRed",
                desc: "Simula o solicita préstamos personales",
                onTap: () => _showLoanDialog(context, state),
              ),
              const Divider(height: 1),
              _profileItem(
                context: context,
                icon: Icons.key_outlined,
                title: "Cambiar Clave de Internet",
                desc: "Cambia tu clave de 6 dígitos periódicamente",
                onTap: () => _showChangeClaveDialog(context, state),
              ),
              const Divider(height: 1),
              _profileItem(
                context: context,
                icon: Icons.headset_mic_outlined,
                title: "Contáctanos",
                desc: "Línea de soporte y atención 24 horas",
                onTap: () => _showContactanosDialog(context),
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

  // Edit Profile dialog
  void _showEditProfileDialog(BuildContext context, AppState state) {
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
                      initialValue: selectedCarrier,
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
  void _showUbicanosDialog(BuildContext context) {
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
                      _locationTile(
                        icon: Icons.apartment,
                        title: "Agencia San Isidro - BN",
                        desc: "Av. Javier Prado Este 2499 · 250m",
                        hours: "Lunes a Viernes 8:00 AM - 5:30 PM",
                        color: kBnRed,
                      ),
                      _locationTile(
                        icon: Icons.atm,
                        title: "Cajero ATM MultiRed",
                        desc: "C.C. La Rambla - Piso 1 · 450m",
                        hours: "Abierto 24 Horas",
                        color: Colors.blue.shade800,
                      ),
                      _locationTile(
                        icon: Icons.store,
                        title: "Agente Corresponsal MultiRed - Bodega Rossi",
                        desc: "Calle Las Begonias 340 · 600m",
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

  Widget _locationTile({
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
  void _showLoanDialog(BuildContext context, AppState state) {
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
  void _showChangeClaveDialog(BuildContext context, AppState state) {
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
                          const SnackBar(content: Text("Clave modificada exitosamente. Úsela en su próximo inicio de sesión")),
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
  void _showContactanosDialog(BuildContext context) {
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
                // Show verification
                showDialog(
                  context: context,
                  builder: (context) => CddVerificationDialog(
                    operationDetails: "Transferencia BN de S/ ${_amountController.text} a la cuenta ${_accountController.text}",
                    onVerified: () {
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
                            {"label": "N° Operación", "value": (100000 + Random().nextInt(900000)).toString()},
                          ],
                        ),
                      );
                      // Clear form
                      _accountController.clear();
                      _amountController.clear();
                      _refController.clear();
                    },
                  ),
                );
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
                      backgroundColor: kBnRed.withValues(alpha: 0.1),
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
            initialValue: _selectedBank,
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
                showDialog(
                  context: context,
                  builder: (context) => CddVerificationDialog(
                    operationDetails: "Envío de S/ ${_amountController.text} vía $_selectedBank al celular ${_phoneController.text}",
                    onVerified: () {
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
                            {"label": "N° Operación", "value": (100000 + Random().nextInt(900000)).toString()},
                          ],
                        ),
                      );
                      
                      _phoneController.clear();
                      _amountController.clear();
                      _nameController.clear();
                    },
                  ),
                );
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
                  selectedColor: kBnRed.withValues(alpha: 0.15),
                  labelStyle: TextStyle(color: _isInmediate ? kBnRed : kBnTextDark, fontWeight: FontWeight.bold, fontSize: 12),
                  onSelected: (val) => setState(() => _isInmediate = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: const Text("Diferida (Gratis < 500)"),
                  selected: !_isInmediate,
                  selectedColor: kBnRed.withValues(alpha: 0.15),
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
                showDialog(
                  context: context,
                  builder: (context) => CddVerificationDialog(
                    operationDetails: "Transferencia Interbancaria ${_isInmediate ? 'Inmediata' : 'Diferida'} de S/ ${_amountController.text} a ${_nameController.text}",
                    onVerified: () {
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
                            {"label": "N° Operación", "value": (100000 + Random().nextInt(900000)).toString()},
                          ],
                        ),
                      );
                      
                      _cciController.clear();
                      _nameController.clear();
                      _amountController.clear();
                    },
                  ),
                );
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
            initialValue: _selectedBank,
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
                showDialog(
                  context: context,
                  builder: (context) => CddVerificationDialog(
                    operationDetails: "Pago de Tarjeta de Crédito $_selectedBank **** ${_cardNoController.text.substring(12)} por S/ ${_amountController.text}",
                    onVerified: () {
                      double amount = double.parse(_amountController.text);
                      state.payCreditCard(_selectedBank, _cardNoController.text, amount);
                      
                      showDialog(
                        context: context,
                        builder: (c) => TransactionReceiptDialog(
                          title: "Pago de Tarjeta de Crédito",
                          receiptDetails: [
                            {"label": "Banco", "value": _selectedBank},
                            {"label": "N° Tarjeta", "value": "**** **** **** ${_cardNoController.text.substring(12)}"},
                            {"label": "Monto Pagado", "value": "S/ ${amount.toStringAsFixed(2)}"},
                            {"label": "Tipo de Pago", "value": "Inmediato"},
                            {"label": "N° Operación", "value": (100000 + Random().nextInt(900000)).toString()},
                          ],
                        ),
                      );
                      
                      _cardNoController.clear();
                      _amountController.clear();
                    },
                  ),
                );
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
            initialValue: _selectedCompany,
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
                  showDialog(
                    context: context,
                    builder: (context) => CddVerificationDialog(
                      operationDetails: "Pago de Servicio $widget.serviceType ($_selectedCompany) - S/ ${_amountController.text}",
                      onVerified: () {
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
                              {"label": "N° Operación", "value": (100000 + Random().nextInt(900000)).toString()},
                            ],
                          ),
                        );
                        
                        setState(() {
                          _isDebtQueried = false;
                        });
                        _supplyCodeController.clear();
                        _amountController.clear();
                      },
                    ),
                  );
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
            initialValue: _selectedOperator,
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
                showDialog(
                  context: context,
                  builder: (context) => CddVerificationDialog(
                    operationDetails: "Recarga celular $_selectedOperator al ${_phoneController.text} por S/ ${_selectedAmount.toStringAsFixed(2)}",
                    onVerified: () {
                      state.rechargeCellular(_selectedOperator, _phoneController.text, _selectedAmount);
                      
                      showDialog(
                        context: context,
                        builder: (c) => TransactionReceiptDialog(
                          title: "Recarga Realizada",
                          receiptDetails: [
                            {"label": "Operador", "value": _selectedOperator},
                            {"label": "N° Celular", "value": _phoneController.text},
                            {"label": "Monto Recargado", "value": "S/ ${_selectedAmount.toStringAsFixed(2)}"},
                            {"label": "N° Operación", "value": (100000 + Random().nextInt(900000)).toString()},
                          ],
                        ),
                      );
                      
                      _phoneController.clear();
                    },
                  ),
                );
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
                showDialog(
                  context: context,
                  builder: (context) => CddVerificationDialog(
                    operationDetails: "Emisión de giro de S/ ${_amountController.text} a favor de ${_nameController.text} DNI ${_dniController.text}",
                    onVerified: () {
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
                    },
                  ),
                );
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
                showDialog(
                  context: context,
                  builder: (context) => CddVerificationDialog(
                    operationDetails: "Generación de código de retiro sin tarjeta por S/ ${_amountController.text}",
                    onVerified: () {
                      double amount = double.parse(_amountController.text);
                      String code = state.generateRetiroSinTarjeta(amount);
                      setState(() {
                        _generatedCode = code;
                      });
                      _startTimer();
                      _amountController.clear();
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class SimpleDashboardView extends StatefulWidget {
  final AppState state;
  const SimpleDashboardView({super.key, required this.state});

  @override
  State<SimpleDashboardView> createState() => _SimpleDashboardViewState();
}

class _SimpleDashboardViewState extends State<SimpleDashboardView> {
  String? _activeSimpleFlow;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final voiceService = Provider.of<VoiceService>(context);
    final lang = state.currentLanguage;

    // Sub flows when clicked
    if (_activeSimpleFlow != null) {
      Widget flowWidget = Container();
      String title = "";
      if (_activeSimpleFlow == "saldos") {
        flowWidget = _SimpleSaldosView(state: state);
        title = state.t('CuentaAhorros');
      } else if (_activeSimpleFlow == "trans_bn") {
        flowWidget = const TransferSameBankFlow();
        title = "Transferir Mismo Banco";
      } else if (_activeSimpleFlow == "trans_inter") {
        flowWidget = const TransferInterbankFlow();
        title = "Transferir Interbancario";
      } else if (_activeSimpleFlow == "trans_cell") {
        flowWidget = const TransferCellularFlow();
        title = "Transferir a Celular (Yape/Plin)";
      } else if (_activeSimpleFlow == "pay_water") {
        flowWidget = const PayServiceFlow(serviceType: "Agua");
        title = "Pagar Agua";
      } else if (_activeSimpleFlow == "pay_electricity") {
        flowWidget = const PayServiceFlow(serviceType: "Luz");
        title = "Pagar Luz";
      } else if (_activeSimpleFlow == "recharge") {
        flowWidget = const RechargeFlow();
        title = "Recargar Celular";
      } else if (_activeSimpleFlow == "giro") {
        flowWidget = const EmitGiroFlow();
        title = "Emitir Giro";
      } else if (_activeSimpleFlow == "withdrawal") {
        flowWidget = const CardlessWithdrawalFlow();
        title = "Retiro sin Tarjeta";
      }

      return Scaffold(
        backgroundColor: const Color(0xFFF4F4F5),
        floatingActionButton: _MicFAB(voiceService: voiceService, lang: lang),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBnRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  state.speak(lang == 'ES' ? "Regresando al menú simple" : "Kutichkani menu simplicitaman");
                  setState(() { _activeSimpleFlow = null; });
                },
                icon: const Icon(Icons.arrow_back),
                label: Text("VOLVER / KUTIY", style: TextStyle(fontSize: 16 * state.fontSizeMultiplier, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                title,
                style: TextStyle(fontSize: 18 * state.fontSizeMultiplier, fontWeight: FontWeight.bold, color: kBnRed),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: flowWidget),
          ],
        ),
      );
    }

    // Main simple menu grid
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F5),
      floatingActionButton: _MicFAB(voiceService: voiceService, lang: lang),
      body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // LANGUAGE SELECTORS BAR
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _buildSegmentButton(
                  label: "ESPAÑOL",
                  isSelected: state.currentLanguage == 'ES',
                  onTap: () => state.setLanguage('ES'),
                  state: state,
                ),
                _buildSegmentButton(
                  label: "QUECHUA",
                  isSelected: state.currentLanguage == 'QU',
                  onTap: () => state.setLanguage('QU'),
                  state: state,
                ),
                _buildSegmentButton(
                  label: "AYMARA",
                  isSelected: state.currentLanguage == 'AY',
                  onTap: () => state.setLanguage('AY'),
                  state: state,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // FONT SIZE BAR (Normal | Grande | Muy Grande)
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _buildSegmentButton(
                  label: "NORMAL",
                  isSelected: state.fontSizeMultiplier == 1.0,
                  onTap: () => state.setFontSizeMultiplier(1.0),
                  state: state,
                  selectedColor: Colors.black87,
                ),
                _buildSegmentButton(
                  label: "GRANDE",
                  isSelected: state.fontSizeMultiplier == 1.3,
                  onTap: () => state.setFontSizeMultiplier(1.3),
                  state: state,
                  selectedColor: Colors.black87,
                ),
                _buildSegmentButton(
                  label: "MUY GRANDE",
                  isSelected: state.fontSizeMultiplier == 1.6,
                  onTap: () => state.setFontSizeMultiplier(1.6),
                  state: state,
                  selectedColor: Colors.black87,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // LARGE RECTANGULAR BUTTONS
          _simpleRectButton(
            icon: Icons.account_balance_wallet,
            label: state.currentLanguage == 'ES' ? "CONSULTAR SALDOS Y MOVIMIENTOS" :
                   state.currentLanguage == 'QU' ? "QULLQI YUPAY QHAWARIY" : "QULLQI UÑJAÑA CHIKURU",
            color: Colors.teal.shade800,
            onTap: () {
              state.speak("Abriendo consulta de saldos y movimientos.");
              setState(() => _activeSimpleFlow = "saldos");
            },
            state: state,
          ),
          const SizedBox(height: 12),
          _simpleRectButton(
            icon: Icons.swap_horiz,
            label: state.currentLanguage == 'ES' ? "TRANSFERIR MISMO BANCO" : "BN ASTACHIY",
            color: Colors.blue.shade800,
            onTap: () {
              state.speak("Abriendo transferencias al mismo banco.");
              setState(() => _activeSimpleFlow = "trans_bn");
            },
            state: state,
          ),
          const SizedBox(height: 12),
          _simpleRectButton(
            icon: Icons.account_balance,
            label: state.currentLanguage == 'ES' ? "TRANSFERIR INTERBANCARIO" : "INTERBANCARIA ASTACHIY",
            color: Colors.indigo.shade800,
            onTap: () {
              state.speak("Abriendo transferencias interbancarias.");
              setState(() => _activeSimpleFlow = "trans_inter");
            },
            state: state,
          ),
          const SizedBox(height: 12),
          _simpleRectButton(
            icon: Icons.phone_android,
            label: state.currentLanguage == 'ES' ? "TRANSFERIR POR CELULAR (YAPE/PLIN)" : "YAPE / PLIN ENVIAR",
            color: Colors.purple.shade800,
            onTap: () {
              state.speak("Abriendo transferencia celular por Yape y Plin.");
              setState(() => _activeSimpleFlow = "trans_cell");
            },
            state: state,
          ),
          const SizedBox(height: 12),
          _simpleRectButton(
            icon: Icons.water_drop,
            label: state.currentLanguage == 'ES' ? "PAGAR RECIBO DE AGUA" : "YAKUTA PAGAY",
            color: Colors.cyan.shade800,
            onTap: () {
              state.speak("Abriendo pago de agua.");
              setState(() => _activeSimpleFlow = "pay_water");
            },
            state: state,
          ),
          const SizedBox(height: 12),
          _simpleRectButton(
            icon: Icons.bolt,
            label: state.currentLanguage == 'ES' ? "PAGAR RECIBO DE LUZ" : "K'ANCHAYTA PAGAY",
            color: Colors.amber.shade900,
            onTap: () {
              state.speak("Abriendo pago de luz.");
              setState(() => _activeSimpleFlow = "pay_electricity");
            },
            state: state,
          ),
          const SizedBox(height: 12),
          _simpleRectButton(
            icon: Icons.smartphone,
            label: state.currentLanguage == 'ES' ? "RECARGAR CELULAR" : "CELULARTA WINAY",
            color: Colors.green.shade800,
            onTap: () {
              state.speak("Abriendo recarga de celular.");
              setState(() => _activeSimpleFlow = "recharge");
            },
            state: state,
          ),
          const SizedBox(height: 12),
          _simpleRectButton(
            icon: Icons.send_to_mobile,
            label: state.currentLanguage == 'ES' ? "EMITIR GIRO MULTIRED" : "GIRO EMITIY",
            color: Colors.deepOrange.shade800,
            onTap: () {
              state.speak("Abriendo emisión de giros.");
              setState(() => _activeSimpleFlow = "giro");
            },
            state: state,
          ),
          const SizedBox(height: 12),
          _simpleRectButton(
            icon: Icons.no_accounts,
            label: state.currentLanguage == 'ES' ? "RETIRO SIN TARJETA" : "RETIRO SIN TARJETA RURAY",
            color: Colors.blueGrey.shade800,
            onTap: () {
              state.speak("Abriendo retiro sin tarjeta.");
              setState(() => _activeSimpleFlow = "withdrawal");
            },
            state: state,
          ),
          const SizedBox(height: 12),
          _simpleRectButton(
            icon: Icons.warning_rounded,
            label: state.isCardBlocked 
                ? (state.currentLanguage == 'ES' ? "DESBLOQUEAR TARJETA" : "TARJETA KAWSARICHIY")
                : (state.currentLanguage == 'ES' ? "BLOQUEAR TARJETA DE INMEDIATO" : "TARJETA HARK'AY KUNANPUNI"),
            color: kBnRed,
            onTap: () {
              if (state.isCardBlocked) {
                state.unblockCard();
                state.speak("Tarjeta desbloqueada.");
              } else {
                state.blockCard("Solicitado en modo simple");
                state.speak("Tarjeta bloqueada por seguridad.");
              }
            },
            state: state,
          ),
          const SizedBox(height: 12),
          _simpleRectButton(
            icon: Icons.exit_to_app,
            label: state.currentLanguage == 'ES' ? "CERRAR SESIÓN / SALIR" : "LLUQSIY / SAQIRIY",
            color: Colors.grey.shade900,
            onTap: () {
              state.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            state: state,
          ),
          const SizedBox(height: 80), // padding for FAB
        ],
      ),
    )); // closes SingleChildScrollView (body) + Scaffold
  }

  Widget _simpleRectButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required AppState state,
  }) {
    List<Color> gradientColors;
    if (color == Colors.teal.shade800) {
      gradientColors = [const Color(0xFF14B8A6), const Color(0xFF0F766E)];
    } else if (color == Colors.blue.shade800) {
      gradientColors = [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)];
    } else if (color == Colors.indigo.shade800) {
      gradientColors = [const Color(0xFF6366F1), const Color(0xFF4338CA)];
    } else if (color == Colors.purple.shade800) {
      gradientColors = [const Color(0xFFA855F7), const Color(0xFF7E22CE)];
    } else if (color == Colors.cyan.shade800) {
      gradientColors = [const Color(0xFF06B6D4), const Color(0xFF0891B2)];
    } else if (color == Colors.amber.shade900) {
      gradientColors = [const Color(0xFFF59E0B), const Color(0xFFD97706)];
    } else if (color == Colors.green.shade800) {
      gradientColors = [const Color(0xFF22C55E), const Color(0xFF15803D)];
    } else if (color == Colors.deepOrange.shade800) {
      gradientColors = [const Color(0xFFF97316), const Color(0xFFC2410C)];
    } else if (color == Colors.blueGrey.shade800) {
      gradientColors = [const Color(0xFF64748B), const Color(0xFF475569)];
    } else if (color == kBnRed) {
      gradientColors = [const Color(0xFFEF4444), const Color(0xFFB91C1C)];
    } else {
      gradientColors = [color, color.withValues(alpha: 0.8)];
    }

    return Container(
      height: 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors[1].withValues(alpha: 0.35),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        onPressed: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15 * state.fontSizeMultiplier,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required AppState state,
    Color selectedColor = kBnRed,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: selectedColor.withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12 * state.fontSizeMultiplier,
              color: isSelected ? Colors.white : Colors.grey.shade700,
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
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
                  "N° ${state.accountNo}",
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

/// Floating Action Button de micrófono para el Modo Simple autenticado.
class _MicFAB extends StatefulWidget {
  final VoiceService voiceService;
  final String lang;

  const _MicFAB({required this.voiceService, required this.lang});

  @override
  State<_MicFAB> createState() => _MicFABState();
}

class _MicFABState extends State<_MicFAB> {
  @override
  Widget build(BuildContext context) {
    final isListening = widget.voiceService.isListening;

    return GestureDetector(
      onTap: () {
        if (isListening) {
          widget.voiceService.stopListeningManual();
        } else {
          widget.voiceService.startListening(context);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isListening ? 64 : 56,
        height: isListening ? 64 : 56,
        decoration: BoxDecoration(
          color: isListening ? Colors.green : const Color(0xFFC8102E),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isListening ? Colors.green : const Color(0xFFC8102E)).withValues(alpha: 0.4),
              blurRadius: isListening ? 24 : 12,
              spreadRadius: isListening ? 4 : 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          isListening ? Icons.mic_none_rounded : Icons.mic_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
