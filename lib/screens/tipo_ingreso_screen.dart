import 'package:flutter/material.dart';
import 'package:gestor_financiero/errors/app_exceptions.dart';
import 'package:gestor_financiero/services/api_client.dart';
import 'package:gestor_financiero/services/tipo_ingreso_service.dart';
import 'package:gestor_financiero/ui/app_alerts.dart';
import '../models/tipo_ingreso.dart';

class TipoIngresoScreen extends StatefulWidget {
  final ApiClient api;
  const TipoIngresoScreen({super.key, required this.api});

  @override
  State<TipoIngresoScreen> createState() => _TipoIngresoScreenState();
}

class _TipoIngresoScreenState extends State<TipoIngresoScreen> {
  late final TipoIngresoService service;
  bool loading = true;
  List<TipoIngreso> items = [];

  @override
  void initState() {
    super.initState();
    service = TipoIngresoService(widget.api);
    cargar();
  }

  Future<void> cargar() async {
    setState(() => loading = true);
    try {
      items = await service.obtenerTodos();
    } on AppException catch (e) {
      AppAlerts.error(context, e.message);
    } catch (_) {
      AppAlerts.error(context, 'Error inesperado');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> crearDialog() async {
    final theme = Theme.of(context);
    final ctrl = TextEditingController();

    final nombre = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nuevo tipo de ingreso'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary, // 💜
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Crear'),
          ),
        ],
      ),
    );

    if (nombre == null || nombre.isEmpty) return;

    try {
      await service.crear(nombre);
      AppAlerts.success(context, 'Creado');
      await cargar();
    } on AppException catch (e) {
      AppAlerts.error(context, e.message);
    }
  }

  Future<void> editarDialog(TipoIngreso ti) async {
    final theme = Theme.of(context);
    final ctrl = TextEditingController(text: ti.nombre);
    bool activo = ti.activo;

    final result = await showDialog<(String, bool)>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('Editar tipo de ingreso'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Activo'),
                value: activo,
                onChanged: (v) => setLocal(() => activo = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary, // 💜
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () =>
                  Navigator.pop(context, (ctrl.text.trim(), activo)),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (result == null) return;
    final (nombre, nuevoActivo) = result;
    if (nombre.isEmpty) return;

    try {
      await service.editar(id: ti.id, nombre: nombre, activo: nuevoActivo);
      AppAlerts.success(context, 'Actualizado');
      await cargar();
    } on AppException catch (e) {
      AppAlerts.error(context, e.message);
    }
  }

  Future<void> eliminarConfirm(TipoIngreso ti) async {
    final theme = Theme.of(context);

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar'),
        content: Text('¿Eliminar "${ti.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error, // 🔴
              foregroundColor: theme.colorScheme.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await service.eliminar(ti.id);
      AppAlerts.success(context, 'Eliminado');
      await cargar();
    } on AppException catch (e) {
      AppAlerts.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
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
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Row(
                      children: const [
                        CircleAvatar(
                          radius: 24,
                          child: Icon(Icons.savings, size: 26),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tipos de ingreso',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Administrá tus categorías',
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Stack(
                      children: [
                        Card(
                          margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: loading
                              ? const Center(child: CircularProgressIndicator())
                              : RefreshIndicator(
                                  onRefresh: cargar,
                                  child: items.isEmpty
                                      ? ListView(
                                          children: const [
                                            SizedBox(height: 120),
                                            Center(
                                              child: Text(
                                                'No hay tipos de ingreso',
                                              ),
                                            ),
                                          ],
                                        )
                                      : ListView.separated(
                                          padding: const EdgeInsets.all(16),
                                          itemCount: items.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(height: 10),
                                          itemBuilder: (_, i) {
                                            final ti = items[i];
                                            return Card(
                                              elevation: 1,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              child: ListTile(
                                                title: Text(
                                                  ti.nombre,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  ti.activo
                                                      ? 'Activo'
                                                      : 'Inactivo',
                                                ),
                                                leading: CircleAvatar(
                                                  radius: 18,
                                                  child: Icon(
                                                    ti.activo
                                                        ? Icons.check
                                                        : Icons.block,
                                                    size: 18,
                                                  ),
                                                ),
                                                trailing:
                                                    PopupMenuButton<String>(
                                                      onSelected: (v) {
                                                        if (v == 'edit')
                                                          editarDialog(ti);
                                                        if (v == 'del')
                                                          eliminarConfirm(ti);
                                                      },
                                                      itemBuilder: (_) =>
                                                          const [
                                                            PopupMenuItem(
                                                              value: 'edit',
                                                              child: Text(
                                                                'Editar',
                                                              ),
                                                            ),
                                                            PopupMenuItem(
                                                              value: 'del',
                                                              child: Text(
                                                                'Eliminar',
                                                              ),
                                                            ),
                                                          ],
                                                    ),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                        ),

                        Positioned(
                          bottom: 32,
                          right: 32,
                          child: FloatingActionButton(
                            backgroundColor: theme.colorScheme.primary, // 💜
                            foregroundColor: theme.colorScheme.onPrimary,
                            onPressed: crearDialog,
                            child: const Icon(Icons.add),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
