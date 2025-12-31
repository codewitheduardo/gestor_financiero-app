import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gestor_financiero/errors/app_exceptions.dart';
import 'package:gestor_financiero/models/movimiento.dart';
import 'package:gestor_financiero/services/api_client.dart';
import 'package:gestor_financiero/services/movimiento_service.dart';
import 'package:gestor_financiero/ui/app_alerts.dart';

class DashboardScreen extends StatefulWidget {
  final ApiClient api;
  const DashboardScreen({super.key, required this.api});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final MovimientoService service;

  bool loading = true;
  List<Movimiento> items = [];

  double totalIngresos = 0;
  double totalSalidas = 0;

  int month = DateTime.now().month;
  int year = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    service = MovimientoService(widget.api);
    cargar();
  }

  Future<void> cargar() async {
    setState(() => loading = true);
    try {
      items = await service.obtenerPorMesAnio(month, year);

      totalIngresos = items
          .where((m) => m.esEntrada)
          .fold(0.0, (s, m) => s + m.montoUYU);

      totalSalidas = items
          .where((m) => m.esSalida)
          .fold(0.0, (s, m) => s + m.montoUYU);
    } on AppException catch (e) {
      AppAlerts.error(context, e.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  double get balance => totalIngresos - totalSalidas;

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
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: cargar,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          // 🔹 HEADER
                          Row(
                            children: const [
                              CircleAvatar(
                                radius: 24,
                                child: Icon(Icons.dashboard, size: 26),
                              ),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dashboard',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Resumen financiero',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // 🔹 MES ACTUAL
                          Text(
                            'Resumen de ${meses[month - 1]} $year',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // 🔹 RESUMEN
                          _ResumenCard(
                            ingresos: totalIngresos,
                            salidas: totalSalidas,
                            balance: balance,
                          ),

                          const SizedBox(height: 20),

                          // 🔹 GRÁFICO
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const Text(
                                    'Ingresos / Salidas',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _PieIngresosSalidas(
                                    ingresos: totalIngresos,
                                    salidas: totalSalidas,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // 🔹 ÚLTIMOS MOVIMIENTOS
                          const Text(
                            'Últimos movimientos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),

                          if (items.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text('No hay movimientos'),
                              ),
                            )
                          else
                            ...items.take(5).map((m) => _MovimientoItem(m: m)),
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

class _ResumenCard extends StatelessWidget {
  final double ingresos;
  final double salidas;
  final double balance;

  const _ResumenCard({
    required this.ingresos,
    required this.salidas,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _Row('Ingresos', ingresos, Colors.green),
            _Row('Salidas', salidas, Colors.red),
            const Divider(),
            _Row(
              'Balance',
              balance,
              balance >= 0 ? Colors.green : Colors.red,
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool bold;

  const _Row(this.label, this.value, this.color, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          Text(
            'UYU ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PieIngresosSalidas extends StatelessWidget {
  final double ingresos;
  final double salidas;

  const _PieIngresosSalidas({required this.ingresos, required this.salidas});

  @override
  Widget build(BuildContext context) {
    final total = ingresos + salidas;

    if (total == 0) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Sin datos')),
      );
    }

    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 40,
          sectionsSpace: 2,
          sections: [
            PieChartSectionData(
              value: ingresos,
              color: Colors.green,
              radius: 60,
              title: '${((ingresos / total) * 100).toStringAsFixed(1)}%',
              titleStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: salidas,
              color: Colors.red,
              radius: 60,
              title: '${((salidas / total) * 100).toStringAsFixed(1)}%',
              titleStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovimientoItem extends StatelessWidget {
  final Movimiento m;
  const _MovimientoItem({required this.m});

  @override
  Widget build(BuildContext context) {
    final esSalida = m.esSalida;
    final color = esSalida ? Colors.red : Colors.green;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            esSalida ? Icons.arrow_upward : Icons.arrow_downward,
            color: color,
          ),
        ),
        title: Text(m.descripcion),
        subtitle: Text(m.nombreTipo),
        trailing: Text(
          '${esSalida ? '-' : '+'}${m.montoUYU.toStringAsFixed(2)}',
          style: TextStyle(fontWeight: FontWeight.w800, color: color),
        ),
      ),
    );
  }
}
