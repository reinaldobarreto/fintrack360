import 'package:flutter/material.dart';
import '../configuracao/tema_configuracao.dart';
import '../modelos/lancamento.dart';
import '../componentes/card_lancamento.dart';
import 'adicionar_lancamento_tela.dart';
import '../servicos/dados_local_servico.dart';

/// Tela de lançamentos financeiros
class LancamentosTela extends StatefulWidget {
  const LancamentosTela({super.key});

  @override
  State<LancamentosTela> createState() => _LancamentosTelaState();
}

class _LancamentosTelaState extends State<LancamentosTela> {
  static const bool _modoLocal = bool.fromEnvironment('USE_LOCAL_DEMO_AUTH', defaultValue: false);
  final DadosLocalServico _dadosLocal = DadosLocalServico();
  String _filtroSelecionado = 'Todos';
  String _periodoSelecionado = 'Este mês';

  final List<String> _filtros = ['Todos', 'Receitas', 'Despesas'];
  final List<String> _periodos = [
    'Esta semana',
    'Este mês',
    'Últimos 3 meses',
    'Este ano'
  ];

  // Lista inicial vazia (sem dados mockados)
  List<Lancamento> _lancamentos = [];

  @override
  void initState() {
    super.initState();
    if (_modoLocal) {
      _carregarLancamentosLocal();
    }
  }

  Future<void> _carregarLancamentosLocal() async {
    final lista = await _dadosLocal.carregarLancamentos();
    setState(() {
      _lancamentos = lista;
    });
  }

  Future<void> _salvarLancamentosLocal() async {
    await _dadosLocal.salvarLancamentos(_lancamentos);
  }

  @override
  Widget build(BuildContext context) {
    final lancamentosFiltrados = _filtrarLancamentos();

    return Scaffold(
      backgroundColor: TemaConfiguracao.corFundo,
      body: Column(
        children: [
          // Filtros
          _buildFiltros(),

          // Lista de lançamentos
          Expanded(
            child: lancamentosFiltrados.isEmpty
                ? _buildListaVazia()
                : RefreshIndicator(
                    onRefresh: _atualizarLancamentos,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: lancamentosFiltrados.length,
                      itemBuilder: (context, index) {
                        final lancamento = lancamentosFiltrados[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CardLancamento(
                            lancamento: lancamento,
                            onTap: () => _editarLancamento(lancamento),
                            onDelete: () => _excluirLancamento(lancamento),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarLancamento,
        backgroundColor: TemaConfiguracao.corPrimaria,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Constrói a seção de filtros
  Widget _buildFiltros() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TemaConfiguracao.corSuperficie,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Filtro por tipo
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Filtrar por:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: TemaConfiguracao.corTextoSecundario,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: TemaConfiguracao.corFundo,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: TemaConfiguracao.corPrimaria.withOpacity(0.3),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _filtroSelecionado,
                    isDense: true,
                    style: const TextStyle(
                      color: TemaConfiguracao.corTexto,
                      fontSize: 14,
                    ),
                    dropdownColor: TemaConfiguracao.corSuperficie,
                    items: _filtros.map((filtro) {
                      return DropdownMenuItem(
                        value: filtro,
                        child: Text(filtro),
                      );
                    }).toList(),
                    onChanged: (valor) {
                      setState(() {
                        _filtroSelecionado = valor!;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Filtro por período
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Período:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: TemaConfiguracao.corTextoSecundario,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: TemaConfiguracao.corFundo,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: TemaConfiguracao.corSecundaria.withOpacity(0.3),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _periodoSelecionado,
                    isDense: true,
                    style: const TextStyle(
                      color: TemaConfiguracao.corTexto,
                      fontSize: 14,
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
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Constrói a tela de lista vazia
  Widget _buildListaVazia() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: TemaConfiguracao.corTextoSecundario.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhum lançamento encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: TemaConfiguracao.corTextoSecundario,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Toque no botão + para adicionar seu primeiro lançamento',
            style: TextStyle(
              fontSize: 14,
              color: TemaConfiguracao.corTextoSecundario,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Filtra os lançamentos baseado nos filtros selecionados
  List<Lancamento> _filtrarLancamentos() {
    List<Lancamento> filtrados = List.from(_lancamentos);

    // Filtrar por tipo
    if (_filtroSelecionado == 'Receitas') {
      filtrados = filtrados.where((l) => l.ehReceita).toList();
    } else if (_filtroSelecionado == 'Despesas') {
      filtrados = filtrados.where((l) => l.ehDespesa).toList();
    }

    // Aqui seria implementado o filtro por período
    // baseado no _periodoSelecionado

    // Ordenar por data (mais recente primeiro)
    filtrados.sort((a, b) => b.data.compareTo(a.data));

    return filtrados;
  }

  /// Adiciona um novo lançamento
  void _adicionarLancamento() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => const AdicionarLancamentoTela(),
      ),
    )
        .then((resultado) {
      if (resultado == true) {
        _atualizarLancamentos();
      }
    });
  }

  /// Edita um lançamento existente
  void _editarLancamento(Lancamento lancamento) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => AdicionarLancamentoTela(lancamento: lancamento),
      ),
    )
        .then((resultado) {
      if (resultado == true) {
        _atualizarLancamentos();
      }
    });
  }

  /// Exclui um lançamento
  Future<void> _excluirLancamento(Lancamento lancamento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
            'Deseja realmente excluir o lançamento "${lancamento.descricao}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: TemaConfiguracao.corErro,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() {
        _lancamentos.removeWhere((l) => l.id == lancamento.id);
      });
      if (_modoLocal) {
        await _salvarLancamentosLocal();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lançamento excluído com sucesso'),
          backgroundColor: TemaConfiguracao.corSucesso,
        ),
      );
    }
  }

  /// Atualiza a lista de lançamentos
  Future<void> _atualizarLancamentos() async {
    // Simula carregamento de dados
    await Future.delayed(const Duration(seconds: 1));
    if (_modoLocal) {
      await _carregarLancamentosLocal();
    }

    if (mounted) {
      setState(() {
        // Dados atualizados
      });
    }
  }
}
