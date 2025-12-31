import 'package:flutter/material.dart';
import 'package:gestor_financiero/errors/app_exceptions.dart';
import 'package:gestor_financiero/services/api_client.dart';
import 'package:gestor_financiero/services/usuario_service.dart';
import 'package:gestor_financiero/ui/app_alerts.dart';

class RegisterScreen extends StatefulWidget {
  final ApiClient api;
  const RegisterScreen({super.key, required this.api});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final usuarioCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final pass2Ctrl = TextEditingController();

  bool loading = false;
  bool ver1 = false;
  bool ver2 = false;

  late final UsuarioService usuarioService;

  @override
  void initState() {
    super.initState();
    usuarioService = UsuarioService(widget.api);
  }

  Future<void> registrar() async {
    FocusScope.of(context).unfocus();

    final u = usuarioCtrl.text.trim();
    final p1 = passCtrl.text;
    final p2 = pass2Ctrl.text;

    if (u.isEmpty || p1.isEmpty || p2.isEmpty) {
      AppAlerts.error(context, 'Completá todos los campos');
      return;
    }

    if (p1 != p2) {
      AppAlerts.error(context, 'Las contraseñas no coinciden');
      return;
    }

    setState(() => loading = true);

    try {
      await usuarioService.crearUsuario(u, p1);

      if (!mounted) return;

      AppAlerts.success(context, 'Usuario creado exitosamente.');
      Navigator.pop(context); // vuelve al login
    } on AppException catch (e) {
      setState(() => loading = false);
      AppAlerts.error(context, e.message);
    } catch (_) {
      setState(() => loading = false);
      AppAlerts.error(context, 'Error inesperado');
    }
  }

  @override
  void dispose() {
    usuarioCtrl.dispose();
    passCtrl.dispose();
    pass2Ctrl.dispose();
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
                    // Header (mismo estilo que login)
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          child: Icon(Icons.person_add_alt_1, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Crear usuario',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Registrate para comenzar',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Card (mismo formato)
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
                              obscureText: !ver1,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: const Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => ver1 = !ver1),
                                  icon: Icon(
                                    ver1
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            TextField(
                              controller: pass2Ctrl,
                              obscureText: !ver2,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => loading ? null : registrar(),
                              decoration: InputDecoration(
                                labelText: 'Repetir contraseña',
                                prefixIcon: const Icon(Icons.lock_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => ver2 = !ver2),
                                  icon: Icon(
                                    ver2
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: loading ? null : registrar,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme
                                      .colorScheme
                                      .primary, // 💜 morado de la app
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
                                              .white, // visible sobre morado
                                        ),
                                      )
                                    : const Text(
                                        'Crear cuenta',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Volver (mismo estilo que el link del login)
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Ya tengo cuenta'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Tip: elegí una contraseña segura para proteger tus datos.',
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
