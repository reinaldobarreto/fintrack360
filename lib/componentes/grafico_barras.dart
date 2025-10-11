import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../configuracao/tema_configuracao.dart';

/// Componente de gráfico de barras para mostrar receitas vs despesas
class GraficoBarras extends StatelessWidget {
  final double receitas;
  final double despesas;

  const GraficoBarras({
    super.key,
    required this.receitas,
    required this.despesas,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _calcularMaxY(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final valor = rod.toY;
              final tipo = group.x == 0 ? 'Receitas' : 'Despesas';
              return BarTooltipItem(
                '$tipo\nR\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}',
                TextStyle(
                  color: TemaConfiguracao.corTexto,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: _criarTitulosInferiores,
              reservedSize: 38,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              interval: _calcularIntervalo(),
              getTitlesWidget: _criarTitulosEsquerda,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: _criarGruposBarras(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calcularIntervalo(),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: TemaConfiguracao.corTextoSecundario.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
      ),
    );
  }

  /// Calcula o valor máximo do eixo Y
  double _calcularMaxY() {
    final maxValor = receitas > despesas ? receitas : despesas;
    return (maxValor * 1.2).ceilToDouble();
  }

  /// Calcula o intervalo para os títulos do eixo Y
  double _calcularIntervalo() {
    final maxY = _calcularMaxY();
    return (maxY / 5).ceilToDouble();
  }

  /// Cria os títulos inferiores (eixo X)
  Widget _criarTitulosInferiores(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = Text(
          'Receitas',
          style: style.copyWith(color: TemaConfiguracao.corSucesso),
        );
        break;
      case 1:
        text = Text(
          'Despesas',
          style: style.copyWith(color: TemaConfiguracao.corErro),
        );
        break;
      default:
        text = const Text('', style: style);
        break;
    }
    
    return SideTitleWidget(
      meta: meta,
      space: 16,
      child: text,
    );
  }

  /// Cria os títulos da esquerda (eixo Y)
  Widget _criarTitulosEsquerda(double value, TitleMeta meta) {
    final style = TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 10,
      color: TemaConfiguracao.corTextoSecundario,
    );
    
    String text;
    if (value >= 1000) {
      text = '${(value / 1000).toStringAsFixed(1)}k';
    } else {
      text = value.toInt().toString();
    }
    
    return SideTitleWidget(
      meta: meta,
      space: 8,
      child: Text(text, style: style),
    );
  }

  /// Cria os grupos de barras
  List<BarChartGroupData> _criarGruposBarras() {
    return [
      // Barra de receitas
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: receitas,
            color: TemaConfiguracao.corSucesso,
            width: 40,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            gradient: LinearGradient(
              colors: [
                TemaConfiguracao.corSucesso,
                TemaConfiguracao.corSucesso.withOpacity(0.7),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ],
      ),
      
      // Barra de despesas
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: despesas,
            color: TemaConfiguracao.corErro,
            width: 40,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            gradient: LinearGradient(
              colors: [
                TemaConfiguracao.corErro,
                TemaConfiguracao.corErro.withOpacity(0.7),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ],
      ),
    ];
  }
}