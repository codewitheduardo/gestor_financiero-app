import 'package:flutter/material.dart';
import 'package:gestor_financiero/errors/app_exceptions.dart';
import 'package:gestor_financiero/models/tipo_gasto.dart';
import 'package:gestor_financiero/models/tipo_ingreso.dart';
import 'package:gestor_financiero/services/api_client.dart';
import 'package:gestor_financiero/services/movimiento_service.dart';
import 'package:gestor_financiero/services/tipo_gasto_service.dart';
import 'package:gestor_financiero/services/tipo_ingreso_service.dart';
import 'package:gestor_financiero/ui/app_alerts.dart';
import '../models/movimiento.dart';

const Map<String, String> monedas = {
  'UYU': 'Peso uruguayo',
  'USD': 'Dólar estadounidense',
  'EUR': 'Euro',
  'ARS': 'Peso argentino',
  'BRL': 'Real brasileño',
};

String simboloMoneda(String moneda) {
  switch (moneda) {
    case 'USD':
      return '\$';
    case 'EUR':
      return '€';
    case 'ARS':
      return '\$';
    case 'BRL':
      return 'R\$';
    case 'UYU':
    default:
      return '\$';
  }
}

class MovimientosScreen extends StatefulWidget {
  final ApiClient api;
  const MovimientosScreen({super.key, required this.api});

  @override
  State<MovimientosScreen> createState() => _MovimientosScreenState();
}

class _MovimientosScreenState extends State<MovimientosScreen> {
  late final MovimientoService service;
  late final TipoGastoService tipoGastoService;
  late final TipoIngresoService tipoIngresoService;

  bool loading = true;
  List<Movimiento> items = [];

  int month = DateTime.now().month;
  int year = DateTime.now().year;

  // filtros
  int filtroMovimiento = 0; // 0=Todos | 1=Entradas | 2=Salidas
  int? filtroTipoGastoId;
  int? filtroTipoIngresoId;

  // listas para dropdowns
  List<TipoGasto> tiposGasto = [];
  List<TipoIngreso> tiposIngreso = [];

  List<Movimiento> get itemsFiltrados {
    Iterable<Movimiento> q = items;

    // filtro entrada / salida
    if (filtroMovimiento == 1) {
      q = q.where((m) => m.esEntrada);
    } else if (filtroMovimiento == 2) {
      q = q.where((m) => m.esSalida);
    }

    // filtro por tipo
    if (filtroMovimiento == 2 && filtroTipoGastoId != null) {
      q = q.where((m) => m.tipoGastoId == filtroTipoGastoId);
    }

    if (filtroMovimiento == 1 && filtroTipoIngresoId != null) {
      q = q.where((m) => m.tipoIngresoId == filtroTipoIngresoId);
    }

    return q.toList();
  }

  @override
  void initState() {
    super.initState();
    service = MovimientoService(widget.api);
    tipoGastoService = TipoGastoService(widget.api);
    tipoIngresoService = TipoIngresoService(widget.api);
    cargar();
    cargarTipos();
  }

  Future<void> cargar() async {
    setState(() => loading = true);
    try {
      items = await service.obtenerPorMesAnio(month, year);
    } on AppException catch (e) {
      AppAlerts.error(context, e.message);
    } catch (_) {
      AppAlerts.error(context, 'Error inesperado');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> cargarTipos() async {
    try {
      tiposGasto = await tipoGastoService.obtenerActivos();
      tiposIngreso = await tipoIngresoService.obtenerActivos();
      if (mounted) setState(() {});
    } on AppException catch (e) {
      AppAlerts.error(context, e.message);
    } catch (_) {
      // no bloquea la pantalla si falla
    }
  }

  Future<void> eliminarConfirm(Movimiento m) async {
    final theme = Theme.of(context);

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar movimiento'),
        content: Text('¿Eliminar "${m.descripcion}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
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
      await service.eliminar(m.id);
      AppAlerts.success(context, 'Eliminado');
      await cargar();
    } on AppException catch (e) {
      AppAlerts.error(context, e.message);
    } catch (_) {
      AppAlerts.error(context, 'Error inesperado');
    }
  }

  Future<void> crearDialog() async {
    final theme = Theme.of(context);

    // inputs
    bool esSalida = true;
    String moneda = 'UYU';
    DateTime fecha = DateTime.now();

    final montoCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    // ids seleccionados
    int? tipoGastoId;
    int? tipoIngresoId;

    // asegurar dropdowns listos (por si abren antes de cargarTipos())
    List<TipoGasto> listaGasto = tiposGasto;
    List<TipoIngreso> listaIngreso = tiposIngreso;

    if (listaGasto.isEmpty || listaIngreso.isEmpty) {
      try {
        listaGasto = await tipoGastoService.obtenerActivos();
        listaIngreso = await tipoIngresoService.obtenerActivos();
      } on AppException catch (e) {
        AppAlerts.error(context, e.message);
        return;
      }
    }

    if (listaGasto.isNotEmpty) tipoGastoId = listaGasto.first.id;
    if (listaIngreso.isNotEmpty) tipoIngresoId = listaIngreso.first.id;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('Nuevo movimiento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // salida/ingreso
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Salida')),
                    ButtonSegment(value: false, label: Text('Ingreso')),
                  ],
                  selected: {esSalida},
                  onSelectionChanged: (s) => setLocal(() {
                    esSalida = s.first;
                  }),
                ),
                const SizedBox(height: 12),

                // moneda
                DropdownButtonFormField<String>(
                  value: moneda,
                  decoration: const InputDecoration(labelText: 'Moneda'),
                  items: monedas.entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text('${e.key} - ${e.value}'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setLocal(() => moneda = v ?? 'UYU'),
                ),
                const SizedBox(height: 12),

                // tipo (según esSalida)
                if (esSalida)
                  DropdownButtonFormField<int>(
                    value: tipoGastoId,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de gasto',
                    ),
                    items: listaGasto
                        .map(
                          (t) => DropdownMenuItem(
                            value: t.id,
                            child: Text(t.nombre),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setLocal(() => tipoGastoId = v),
                  )
                else
                  DropdownButtonFormField<int>(
                    value: tipoIngresoId,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de ingreso',
                    ),
                    items: listaIngreso
                        .map(
                          (t) => DropdownMenuItem(
                            value: t.id,
                            child: Text(t.nombre),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setLocal(() => tipoIngresoId = v),
                  ),

                const SizedBox(height: 12),

                // monto
                TextField(
                  controller: montoCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Monto'),
                ),
                const SizedBox(height: 12),

                // descripcion
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                const SizedBox(height: 10),

                // fecha
                Row(
                  children: [
                    const Text('Fecha: '),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: fecha,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setLocal(() => fecha = picked);
                      },
                      child: Text('${fecha.day}/${fecha.month}/${fecha.year}'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );

    if (ok != true) return;

    final monto = double.tryParse(montoCtrl.text.replaceAll(',', '.'));
    final desc = descCtrl.text.trim();

    if (monto == null || monto <= 0) {
      AppAlerts.error(context, 'Monto inválido');
      return;
    }
    if (desc.isEmpty) {
      AppAlerts.error(context, 'La descripción es obligatoria');
      return;
    }
    if (esSalida && tipoGastoId == null) {
      AppAlerts.error(context, 'Seleccioná un tipo de gasto');
      return;
    }
    if (!esSalida && tipoIngresoId == null) {
      AppAlerts.error(context, 'Seleccioná un tipo de ingreso');
      return;
    }

    try {
      await service.crear(
        esSalida: esSalida,
        moneda: moneda,
        descripcion: desc,
        monto: monto,
        fecha: fecha,
        tipoGastoId: tipoGastoId,
        tipoIngresoId: tipoIngresoId,
      );

      AppAlerts.success(context, 'Movimiento creado');
      await cargar();
    } on AppException catch (e) {
      AppAlerts.error(context, e.message);
    } catch (_) {
      AppAlerts.error(context, 'Error inesperado');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    final anios = List.generate(8, (i) => DateTime.now().year - 4 + i);

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
                  // header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Row(
                      children: const [
                        CircleAvatar(
                          radius: 24,
                          child: Icon(Icons.swap_horiz, size: 26),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Movimientos',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Ingresos y salidas',
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // filtros mes/año
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: month,
                                decoration: const InputDecoration(
                                  labelText: 'Mes',
                                  isDense: true,
                                ),
                                items: List.generate(
                                  12,
                                  (i) => DropdownMenuItem(
                                    value: i + 1,
                                    child: Text(meses[i]),
                                  ),
                                ),
                                onChanged: (v) =>
                                    setState(() => month = v ?? month),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: year,
                                decoration: const InputDecoration(
                                  labelText: 'Año',
                                  isDense: true,
                                ),
                                items: anios
                                    .map(
                                      (y) => DropdownMenuItem(
                                        value: y,
                                        child: Text(y.toString()),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => year = v ?? year),
                              ),
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              tooltip: 'Aplicar',
                              onPressed: cargar,
                              icon: const Icon(Icons.search),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // filtros adicionales
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            DropdownButtonFormField<int>(
                              value: filtroMovimiento,
                              decoration: const InputDecoration(
                                labelText: 'Mostrar',
                                isDense: true,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 0,
                                  child: Text('Todos'),
                                ),
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text('Solo entradas'),
                                ),
                                DropdownMenuItem(
                                  value: 2,
                                  child: Text('Solo salidas'),
                                ),
                              ],
                              onChanged: (v) {
                                setState(() {
                                  filtroMovimiento = v ?? 0;
                                  filtroTipoGastoId = null;
                                  filtroTipoIngresoId = null;
                                });
                              },
                            ),
                            const SizedBox(height: 12),

                            if (filtroMovimiento == 2)
                              DropdownButtonFormField<int?>(
                                value: filtroTipoGastoId,
                                decoration: const InputDecoration(
                                  labelText: 'Tipo de gasto',
                                  isDense: true,
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('Todos'),
                                  ),
                                  ...tiposGasto.map(
                                    (t) => DropdownMenuItem(
                                      value: t.id,
                                      child: Text(t.nombre),
                                    ),
                                  ),
                                ],
                                onChanged: (v) =>
                                    setState(() => filtroTipoGastoId = v),
                              ),

                            if (filtroMovimiento == 1)
                              DropdownButtonFormField<int?>(
                                value: filtroTipoIngresoId,
                                decoration: const InputDecoration(
                                  labelText: 'Tipo de ingreso',
                                  isDense: true,
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('Todos'),
                                  ),
                                  ...tiposIngreso.map(
                                    (t) => DropdownMenuItem(
                                      value: t.id,
                                      child: Text(t.nombre),
                                    ),
                                  ),
                                ],
                                onChanged: (v) =>
                                    setState(() => filtroTipoIngresoId = v),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // lista + FAB
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
                                  child: Builder(
                                    builder: (_) {
                                      final list = itemsFiltrados;

                                      if (list.isEmpty) {
                                        return ListView(
                                          children: const [
                                            SizedBox(height: 120),
                                            Center(
                                              child: Text('No hay movimientos'),
                                            ),
                                          ],
                                        );
                                      }

                                      return ListView.separated(
                                        padding: const EdgeInsets.all(16),
                                        itemCount: list.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 10),
                                        itemBuilder: (_, i) {
                                          final m = list[i];
                                          final esSalida = m.esSalida;

                                          // verde / rojo
                                          final colorMonto = esSalida
                                              ? theme.colorScheme.error
                                              : Colors.green;

                                          return Card(
                                            elevation: 1,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: ListTile(
                                              title: Text(
                                                m.descripcion,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              subtitle: Text(
                                                '${m.fecha.day}/${m.fecha.month}/${m.fecha.year}'
                                                ' • ${m.nombreTipo.isNotEmpty ? m.nombreTipo : m.tipoMovimiento}'
                                                ' • ${m.moneda}',
                                              ),
                                              leading: CircleAvatar(
                                                radius: 18,
                                                child: Icon(
                                                  esSalida
                                                      ? Icons.arrow_upward
                                                      : Icons.arrow_downward,
                                                  size: 18,
                                                ),
                                              ),
                                              trailing: PopupMenuButton<String>(
                                                onSelected: (v) {
                                                  if (v == 'del') {
                                                    eliminarConfirm(m);
                                                  }
                                                },
                                                itemBuilder: (_) => [
                                                  PopupMenuItem(
                                                    value: 'del',
                                                    child: Text(
                                                      'Eliminar',
                                                      style: TextStyle(
                                                        color: theme
                                                            .colorScheme
                                                            .error,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      '${esSalida ? '-' : '+'}${simboloMoneda(m.moneda)}${m.monto.toStringAsFixed(2)}',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: colorMonto,
                                                      ),
                                                    ),
                                                    Text(
                                                      'UYU ${m.montoUYU.toStringAsFixed(2)}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                        ),

                        Positioned(
                          bottom: 32,
                          right: 32,
                          child: FloatingActionButton(
                            backgroundColor: theme.colorScheme.primary,
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
