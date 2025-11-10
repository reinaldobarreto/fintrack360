import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../configuracao/tema_configuracao.dart';
import '../componentes/card_kpi.dart';
import '../componentes/grafico_pizza.dart';
import '../componentes/grafico_barras.dart';
import '../servicos/dados_local_servico.dart';
import '../modelos/lancamento.dart';
import '../modelos/categoria.dart';

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

  // Serviços e dados reais
  final DadosLocalServico _dadosLocal = DadosLocalServico();
  List<Lancamento> _lancamentos = [];
  List<Categoria> _categorias = [];

  // Indicadores calculados a partir dos lançamentos
  double _totalReceitas = 0.0;
  double _totalDespesas = 0.0;
  double _saldoAtual = 0.0;
  double? _metaMensal;

  // Dados agregados para o gráfico de pizza (gastos por categoria)
  List<DadosCategoria> _dadosCategoriasPizza = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gastos por Categoria',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TemaConfiguracao.corTexto,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: GraficoPizza(dados: _dadosCategoriasPizza),
          ),
        ],
      ),
    );
  }

  /// Constrói o indicador de progresso da meta
  Widget _buildProgressoMeta() {
    if (_metaMensal == null || (_metaMensal ?? 0) <= 0) {
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
              'Meta Mensal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: TemaConfiguracao.corTexto,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nenhuma meta definida. Defina uma meta para acompanhar seu progresso.',
              style: TextStyle(
                fontSize: 14,
                color: TemaConfiguracao.corTextoSecundario,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _definirMetaMensal,
                icon: const Icon(Icons.flag_outlined,
                    color: TemaConfiguracao.corPrimaria),
                label: const Text(
                  'Definir meta',
                  style: TextStyle(color: TemaConfiguracao.corPrimaria),
                ),
              ),
            )
          ],
        ),
      );
    }

    final meta = _metaMensal ?? 1;
    final progresso = (_totalReceitas / meta).clamp(0, 1);
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
            value: progresso.toDouble(),
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
                'R\$ ${meta.toStringAsFixed(2).replaceAll('.', ',')}',
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

  Future<void> _definirMetaMensal() async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Definir meta mensal'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Valor da meta (R\$)',
            hintText: 'Ex: 5000,00',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final texto = controller.text.trim().replaceAll(',', '.');
      final valor = double.tryParse(texto);
      if (valor != null && valor > 0) {
        await _dadosLocal.salvarMetaMensal(valor);
        if (mounted) {
          setState(() {
            _metaMensal = valor;
          });
        }
      }
    }
  }

  /// Atualiza os dados do dashboard
  Future<void> _atualizarDados() async {
    await _carregarDados();
  }

  /// Carrega lançamentos e categorias, e calcula agregações para o dashboard
  Future<void> _carregarDados() async {
    try {
      final lancamentosCarregados = await _dadosLocal.carregarLancamentos();
      final categoriasCarregadas = await _dadosLocal.carregarCategorias();
      final metaCarregada = await _dadosLocal.carregarMetaMensal();

      // Opcional: aplicar filtro por período selecionado
      final lancamentos = lancamentosCarregados;

      // Calcula totais
      double receitas = 0.0;
      double despesas = 0.0;
      for (final l in lancamentos) {
        if (l.tipo == TipoLancamento.receita) {
          receitas += l.valor;
        } else if (l.tipo == TipoLancamento.despesa) {
          despesas += l.valor;
        }
      }

      // Agrega despesas por categoria para o gráfico de pizza
      final Map<String, double> totalPorCategoria = {};
      for (final l in lancamentos.where((x) => x.tipo == TipoLancamento.despesa)) {
        final catId = l.idCategoria ?? 'sem-categoria';
        totalPorCategoria[catId] = (totalPorCategoria[catId] ?? 0.0) + l.valor;
      }

      // Mapeia ids para nomes e cores a partir das categorias
      final Map<String, Categoria> mapaCategorias = {
        for (final c in categoriasCarregadas) c.id: c
      };
      final dadosPizza = <DadosCategoria>[];
      totalPorCategoria.forEach((catId, total) {
        final cat = mapaCategorias[catId];
        final nome = cat?.nome ?? 'Outros';
        final cor = cat?.cor ?? Colors.grey;
        dadosPizza.add(DadosCategoria(nome: nome, valor: total, cor: cor));
      });

      if (mounted) {
        setState(() {
          _lancamentos = lancamentos;
          _categorias = categoriasCarregadas;
          _totalReceitas = receitas;
          _totalDespesas = despesas;
          _saldoAtual = receitas - despesas;
          _dadosCategoriasPizza = dadosPizza;
          _metaMensal = metaCarregada;
        });
      }
    } catch (e) {
      // Em caso de erro, mantém valores em zero
      if (mounted) {
        setState(() {
          _lancamentos = [];
          _categorias = [];
          _totalReceitas = 0.0;
          _totalDespesas = 0.0;
          _saldoAtual = 0.0;
          _dadosCategoriasPizza = [];
        });
      }
    }
  }
}
