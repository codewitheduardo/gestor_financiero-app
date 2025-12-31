import 'package:flutter/material.dart';
import 'package:gestor_financiero/screens/dashboard_screen.dart';
import 'package:gestor_financiero/screens/login_screen.dart';
import 'package:gestor_financiero/screens/movimientos_screen.dart';
import 'package:gestor_financiero/screens/tipo_gasto_screen.dart';
import 'package:gestor_financiero/screens/tipo_ingreso_screen.dart';
import 'package:gestor_financiero/services/api_client.dart';
import 'package:gestor_financiero/state/session.dart';

class HomeScreen extends StatefulWidget {
  final Session session;
  final ApiClient api;

  const HomeScreen({super.key, required this.session, required this.api});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex =
      0; // 0 = dashboard, 1 = gasto, 2 = ingreso, 3 = movimientos

  Future<void> logout(BuildContext context) async {
    await widget.session.clear();
    widget.api.token = null;

    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(session: widget.session, api: widget.api),
      ),
      (_) => false,
    );
  }

  Widget get body {
    switch (selectedIndex) {
      case 0:
        return DashboardScreen(api: widget.api);
      case 1:
        return TipoGastoScreen(api: widget.api);
      case 2:
        return TipoIngresoScreen(api: widget.api);
      case 3:
        return MovimientosScreen(api: widget.api);
      default:
        return DashboardScreen(api: widget.api);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.account_balance_wallet, size: 26),
            SizedBox(width: 8),
            Text('SUMA', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),

      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              // 🔹 Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.18),
                      theme.colorScheme.surface,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.session.username ?? 'Usuario',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.session.isLoggedIn
                                ? 'Sesión activa'
                                : 'Sin sesión',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // 🔹 Gestión
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Gestión',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              ),

              _DrawerItem(
                icon: Icons.dashboard,
                text: 'Dashboard',
                selected: selectedIndex == 0,
                onTap: () {
                  setState(() => selectedIndex = 0);
                  Navigator.pop(context);
                },
              ),

              _DrawerItem(
                icon: Icons.category,
                text: 'Tipos de gasto',
                selected: selectedIndex == 1,
                onTap: () {
                  setState(() => selectedIndex = 1);
                  Navigator.pop(context);
                },
              ),

              _DrawerItem(
                icon: Icons.savings,
                text: 'Tipos de ingreso',
                selected: selectedIndex == 2,
                onTap: () {
                  setState(() => selectedIndex = 2);
                  Navigator.pop(context);
                },
              ),

              _DrawerItem(
                icon: Icons.swap_horiz,
                text: 'Movimientos',
                selected: selectedIndex == 3,
                onTap: () {
                  setState(() => selectedIndex = 3);
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 10),
              const Divider(),

              // 🔹 Cuenta
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Cuenta',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              ),

              _DrawerItem(
                icon: Icons.settings,
                text: 'Configuración',
                selected: false,
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Próximamente 👀')),
                  );
                },
              ),

              const Spacer(),
              const Divider(),

              _DrawerItem(
                icon: Icons.logout,
                text: 'Cerrar sesión',
                danger: true,
                selected: false,
                onTap: () => logout(context),
              ),
            ],
          ),
        ),
      ),

      body: body,
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool selected;
  final bool danger;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.text,
    required this.selected,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bg = selected
        ? theme.colorScheme.primary.withOpacity(0.10)
        : Colors.transparent;

    final fg = danger
        ? theme.colorScheme.error
        : (selected ? theme.colorScheme.primary : null);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          leading: Icon(icon, color: fg),
          title: Text(
            text,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: fg,
            ),
          ),
          trailing: selected ? Icon(Icons.chevron_right, color: fg) : null,
          onTap: onTap,
        ),
      ),
    );
  }
}
