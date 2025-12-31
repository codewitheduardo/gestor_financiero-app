import 'package:flutter/material.dart';
import 'package:gestor_financiero/errors/app_exceptions.dart';
import 'package:gestor_financiero/screens/home_screen.dart';
import 'package:gestor_financiero/screens/register_screen.dart';
import 'package:gestor_financiero/services/api_client.dart';
import 'package:gestor_financiero/services/auth_serivce.dart';
import 'package:gestor_financiero/state/session.dart';
import 'package:gestor_financiero/ui/app_alerts.dart';

class LoginScreen extends StatefulWidget {
  final Session session;
  final ApiClient api;

  const LoginScreen({super.key, required this.session, required this.api});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usuarioCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool loading = false;
  String? error;

  late final AuthService auth;
  bool verPassword = false;

  @override
  void initState() {
    super.initState();
    auth = AuthService(widget.api);
  }

  Future<void> doLogin() async {
    if (loading) return; // evita doble tap

    FocusScope.of(context).unfocus();

    setState(() {
      loading = true;
    });

    try {
      final token = await auth.login(usuarioCtrl.text.trim(), passCtrl.text);

      await widget.session.setToken(token);
      await widget.session.setUsername(usuarioCtrl.text.trim());
      widget.api.token = token;

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(session: widget.session, api: widget.api),
        ),
      );
    } on UnauthorizedException catch (e) {
      AppAlerts.error(context, e.message);
    } on AppException catch (e) {
      AppAlerts.error(context, e.message);
    } catch (_) {
      AppAlerts.error(context, 'Error inesperado');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    usuarioCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.15),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          child: Icon(Icons.account_balance_wallet, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'SUMA',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Ingresá para continuar',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: usuarioCtrl,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: 'Usuario',
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: passCtrl,
                              obscureText: !verPassword,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => loading ? null : doLogin(),
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: const Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(
                                    () => verPassword = !verPassword,
                                  ),
                                  icon: Icon(
                                    verPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            if (error != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: theme.colorScheme.error.withOpacity(
                                    0.12,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: theme.colorScheme.error,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        error!,
                                        style: TextStyle(
                                          color: theme.colorScheme.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: loading ? null : doLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme
                                      .colorScheme
                                      .primary, // ✅ MORADO DE LA APP
                                  foregroundColor: theme
                                      .colorScheme
                                      .onPrimary, // texto blanco
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: loading
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors
                                              .white, // se ve bien sobre morado
                                        ),
                                      )
                                    : const Text(
                                        'Entrar',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Registro
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        RegisterScreen(api: widget.api),
                                  ),
                                );
                              },
                              child: const Text(
                                '¿No tenés cuenta? Crear usuario',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Tip: tus datos quedan guardados en el dispositivo para mantener la sesión iniciada.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
