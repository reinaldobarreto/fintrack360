import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../configuracao/tema_configuracao.dart';

/// Componente de gráfico de pizza para mostrar gastos por categoria
class GraficoPizza extends StatefulWidget {
  final List<DadosCategoria> dados;
  const GraficoPizza({super.key, required this.dados});

  @override
  State<GraficoPizza> createState() => _GraficoPizzaState();
}

class _GraficoPizzaState extends State<GraficoPizza> {
  int _secaoTocada = -1;
  

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Gráfico de pizza
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _secaoTocada = -1;
                      return;
                    }
                    _secaoTocada =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: _criarSecoes(),
            ),
          ),
        ),

        const SizedBox(width: 20),

        // Legenda
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.dados.asMap().entries.map((entry) {
              final index = entry.key;
              final categoria = entry.value;
              final ehTocada = index == _secaoTocada;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: categoria.cor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoria.nome,
                            style: TextStyle(
                              fontSize: ehTocada ? 12 : 11,
                              fontWeight: ehTocada
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: ehTocada
                                  ? TemaConfiguracao.corTexto
                                  : TemaConfiguracao.corTextoSecundario,
                            ),
                          ),
                          if (ehTocada)
                            Text(
                              'R\$ ${categoria.valor.toStringAsFixed(2).replaceAll('.', ',')}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: TemaConfiguracao.corTextoSecundario,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Cria as seções do gráfico de pizza
  List<PieChartSectionData> _criarSecoes() {
    if (widget.dados.isEmpty) {
      return <PieChartSectionData>[];
    }
    final total = widget.dados.fold<double>(
      0,
      (sum, categoria) => sum + categoria.valor,
    );
    if (total == 0) {
      return <PieChartSectionData>[];
    }
    return widget.dados.asMap().entries.map((entry) {
      final index = entry.key;
      final categoria = entry.value;
      final ehTocada = index == _secaoTocada;
      final percentual = (categoria.valor / total * 100);

      return PieChartSectionData(
        color: categoria.cor,
        value: categoria.valor,
        title: ehTocada ? '${percentual.toInt()}%' : '',
        radius: ehTocada ? 60 : 50,
        titleStyle: TextStyle(
          fontSize: ehTocada ? 14 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.6,
      );
    }).toList();
  }
}

/// Classe para representar dados de uma categoria
class DadosCategoria {
  final String nome;
  final double valor;
  final Color cor;
  DadosCategoria({required this.nome, required this.valor, required this.cor});
}
