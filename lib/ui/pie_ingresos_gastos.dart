import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieIngresosGastos extends StatelessWidget {
  final double ingresos;
  final double salidas;

  const PieIngresosGastos({
    super.key,
    required this.ingresos,
    required this.salidas,
  });

  @override
  Widget build(BuildContext context) {
    final total = ingresos + salidas;

    if (total == 0) {
      return const Center(child: Text('Sin datos'));
    }

    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              value: ingresos,
              title: '${((ingresos / total) * 100).toStringAsFixed(1)}%',
              color: Colors.green,
              radius: 60,
              titleStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: salidas,
              title: '${((salidas / total) * 100).toStringAsFixed(1)}%',
              color: Colors.red,
              radius: 60,
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
