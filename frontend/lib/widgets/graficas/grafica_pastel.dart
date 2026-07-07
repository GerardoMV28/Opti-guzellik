import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/colors.dart';

class GraficaPastel extends StatelessWidget {
  final Map<String, double> datos;
  final String titulo;

  const GraficaPastel({
    Key? key,
    required this.datos,
    required this.titulo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Verificar si hay datos
    if (datos.isEmpty) {
      return _buildEmptyState();
    }

    // ✅ Verificar que la suma total no sea cero
    final total = datos.values.reduce((a, b) => a + b);
    if (total == 0) {
      return _buildEmptyState();
    }

    final List<PieChartSectionData> secciones = [];
    final colores = [
      AppColors.azulReal,
      AppColors.turquesa,
      AppColors.azulCobalto,
      Colors.orange,
      Colors.purple,
      Colors.green,
    ];

    int index = 0;

    datos.forEach((key, value) {
      final porcentaje = (value / total * 100).toStringAsFixed(1);
      secciones.add(
        PieChartSectionData(
          value: value,
          title: '$porcentaje%',
          radius: 80,
          color: colores[index % colores.length],
          titleStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      index++;
    });

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.azulReal,
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: secciones,
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: datos.keys.map((key) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    key,
                    style: TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.azulReal,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.pie_chart, size: 48, color: Colors.grey[400]),
                    SizedBox(height: 12),
                    Text(
                      'No hay datos suficientes para mostrar',
                      style: TextStyle(color: Colors.grey[600]),
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
}