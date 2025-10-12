import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../configuracao/tema_configuracao.dart';
import '../componentes/card_kpi.dart';
import '../componentes/grafico_pizza.dart';
import '../componentes/grafico_barras.dart';

/// Tela de dashboard com gráficos e KPIs financeiros
class DashboardTela extends StatefulWidget {
  const DashboardTela({super.key});

  @override
  State<DashboardTela> createState() => _DashboardTelaState();
}

class _DashboardTelaState extends State<DashboardTela> {
  String _periodoSelecionado = 'Este mês';

  final List<String> _periodos = [
    'Esta semana',
    'Este mês',
    'Últimos 3 meses',
    'Este ano',
  ];

  // Dados mockados para demonstração
  final double _totalReceitas = 5420.50;
  final double _totalDespesas = 3280.75;
  final double _saldoAtual = 2139.75;
  final double _metaMensal = 5000.00;

  @override
  Widget build(BuildContext context) {
    final saldoPositivo = _saldoAtual >= 0;
    final statusFinanceiro = saldoPositivo ? 'Lucro' : 'No vermelho';
    final corStatus =
        saldoPositivo ? TemaConfiguracao.corSucesso : TemaConfiguracao.corErro;

    return Scaffold(
      backgroundColor: TemaConfiguracao.corFundo,
      body: RefreshIndicator(
        onRefresh: _atualizarDados,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seletor de período
              _buildSeletorPeriodo(),

              const SizedBox(height: 20),

              // Status financeiro
              _buildStatusFinanceiro(statusFinanceiro, corStatus),

              const SizedBox(height: 20),

              // KPIs principais
              _buildKPIsPrincipais(),

              const SizedBox(height: 30),

              // Gráfico de receitas vs despesas
              _buildGraficoReceitasDespesas(),

              const SizedBox(height: 30),

              // Gráfico de categorias
              _buildGraficoCategorias(),

              const SizedBox(height: 30),

              // Progresso da meta
              _buildProgressoMeta(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói o seletor de período
  Widget _buildSeletorPeriodo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: TemaConfiguracao.corSuperficie,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TemaConfiguracao.corPrimaria.withOpacity(0.3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _periodoSelecionado,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: TemaConfiguracao.corPrimaria,
          ),
          style: const TextStyle(
            color: TemaConfiguracao.corTexto,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: TemaConfiguracao.corSuperficie,
          items: _periodos.map((periodo) {
            return DropdownMenuItem(
              value: periodo,
              child: Text(periodo),
            );
          }).toList(),
          onChanged: (valor) {
            setState(() {
              _periodoSelecionado = valor!;
            });
            _atualizarDados();
          },
        ),
      ),
    );
  }

  /// Constrói o indicador de status financeiro
  Widget _buildStatusFinanceiro(String status, Color cor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cor.withOpacity(0.1),
            cor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            status == 'Lucro' ? Icons.trending_up : Icons.trending_down,
            size: 40,
            color: cor,
          ),
          const SizedBox(height: 8),
          Text(
            status,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: cor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'R\$ ${_saldoAtual.toStringAsFixed(2).replaceAll('.', ',')}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: TemaConfiguracao.corTexto,
            ),
          ),
          const Text(
            'Saldo atual',
            style: TextStyle(
              fontSize: 14,
              color: TemaConfiguracao.corTextoSecundario,
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói os KPIs principais
  Widget _buildKPIsPrincipais() {
    return Row(
      children: [
        Expanded(
          child: CardKPI(
            titulo: 'Receitas',
            valor: _totalReceitas,
            icone: Icons.arrow_upward,
            cor: TemaConfiguracao.corSucesso,
            tendencia: '+12%',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CardKPI(
            titulo: 'Despesas',
            valor: _totalDespesas,
            icone: Icons.arrow_downward,
            cor: TemaConfiguracao.corErro,
            tendencia: '-5%',
          ),
        ),
      ],
    );
  }

  /// Constrói o gráfico de receitas vs despesas
  Widget _buildGraficoReceitasDespesas() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TemaConfiguracao.corSuperficie,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Receitas vs Despesas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TemaConfiguracao.corTexto,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: GraficoBarras(
              receitas: _totalReceitas,
              despesas: _totalDespesas,
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói o gráfico de categorias
  Widget _buildGraficoCategorias() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TemaConfiguracao.corSuperficie,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gastos por Categoria',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TemaConfiguracao.corTexto,
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: GraficoPizza(),
          ),
        ],
      ),
    );
  }

  /// Constrói o indicador de progresso da meta
  Widget _buildProgressoMeta() {
    final progresso = _totalReceitas / _metaMensal;
    final progressoPercentual = (progresso * 100).clamp(0, 100);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TemaConfiguracao.corSuperficie,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Meta Mensal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: TemaConfiguracao.corTexto,
                ),
              ),
              Text(
                '${progressoPercentual.toInt()}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: TemaConfiguracao.corPrimaria,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progresso,
            backgroundColor:
                TemaConfiguracao.corTextoSecundario.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(
                TemaConfiguracao.corPrimaria),
            minHeight: 8,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'R\$ ${_totalReceitas.toStringAsFixed(2).replaceAll('.', ',')}',
                style: const TextStyle(
                  fontSize: 14,
                  color: TemaConfiguracao.corTextoSecundario,
                ),
              ),
              Text(
                'R\$ ${_metaMensal.toStringAsFixed(2).replaceAll('.', ',')}',
                style: const TextStyle(
                  fontSize: 14,
                  color: TemaConfiguracao.corTextoSecundario,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Atualiza os dados do dashboard
  Future<void> _atualizarDados() async {
    // Simula carregamento de dados
    await Future.delayed(const Duration(seconds: 1));

    // Aqui seria implementada a lógica para buscar dados reais
    // baseado no período selecionado

    if (mounted) {
      setState(() {
        // Dados atualizados
      });
    }
  }
}
