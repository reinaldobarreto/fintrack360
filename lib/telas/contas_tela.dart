import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../configuracao/tema_configuracao.dart';
import '../modelos/conta.dart';
import '../servicos/dados_local_servico.dart';
import '../provedores/autenticacao_provedor.dart';

/// Tela de contas
class ContasTela extends StatefulWidget {
  const ContasTela({super.key});

  @override
  State<ContasTela> createState() => _ContasTelaState();
}

class _ContasTelaState extends State<ContasTela> {
  static const bool _modoLocal = bool.fromEnvironment('USE_LOCAL_DEMO_AUTH', defaultValue: false);
  final DadosLocalServico _dadosLocal = DadosLocalServico();
  // Lista inicial vazia (sem dados mockados)
  List<Conta> _contas = [];

  @override
  void initState() {
    super.initState();
    if (_modoLocal) {
      _carregarContasLocal();
    }
  }

  Future<void> _carregarContasLocal() async {
    final lista = await _dadosLocal.carregarContas();
    if (lista.isNotEmpty) {
      setState(() {
        _contas = lista;
      });
    }
  }

  Future<void> _salvarContasLocal() async {
    await _dadosLocal.salvarContas(_contas);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaConfiguracao.corFundo,
      body: RefreshIndicator(
        onRefresh: _atualizarContas,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _contas.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final conta = _contas[index];
            final ehNegativa = conta.saldoInicial < 0;
            return Card(
              color: TemaConfiguracao.corSuperficie,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: ehNegativa
                          ? TemaConfiguracao.corErro.withOpacity(0.15)
                          : TemaConfiguracao.corSucesso.withOpacity(0.15),
                      child: Icon(
                        ehNegativa ? Icons.trending_down : Icons.trending_up,
                        color: ehNegativa
                            ? TemaConfiguracao.corErro
                            : TemaConfiguracao.corSucesso,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            conta.nome,
                            style: const TextStyle(
                                color: TemaConfiguracao.corTexto,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            conta.descricao ?? '',
                            style: const TextStyle(
                                color: TemaConfiguracao.corTextoSecundario),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'R\$ ${conta.saldoInicial.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: TextStyle(
                            color: ehNegativa
                                ? TemaConfiguracao.corErro
                                : TemaConfiguracao.corSucesso,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.scale(
                              scale: 0.9,
                              child: Switch(
                                value: conta.ativa,
                                activeThumbColor:
                                    TemaConfiguracao.corPrimaria,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                onChanged: (v) {
                                  setState(() {
                                    _contas[index] =
                                        conta.copiarCom(ativa: v);
                                  });
                                  if (_modoLocal) {
                                    _salvarContasLocal();
                                  }
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              iconSize: 20,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _editarConta(conta),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              iconSize: 20,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _excluirConta(conta),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarConta,
        backgroundColor: TemaConfiguracao.corPrimaria,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _atualizarContas() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (_modoLocal) {
      await _carregarContasLocal();
    }
    if (mounted) setState(() {});
  }

  Future<void> _adicionarConta() async {
    final nomeController = TextEditingController();
    final descricaoController = TextEditingController();
    final saldoController = TextEditingController(text: '0,00');
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Conta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome')),
            TextField(
                controller: descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição')),
            TextField(
                controller: saldoController,
                decoration: const InputDecoration(labelText: 'Saldo Inicial')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Adicionar')),
        ],
      ),
    );
    if (ok == true) {
      final saldo =
          double.tryParse(saldoController.text.replaceAll(',', '.')) ?? 0.0;
      final auth = context.read<AutenticacaoProvedor>();
      final usuarioId = auth.usuarioAtual?.id ?? 'local';
      setState(() {
        _contas.add(
          Conta(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            nome: nomeController.text.trim(),
            descricao: descricaoController.text.trim(),
            tipo: TipoConta.contaCorrente,
            saldoInicial: saldo,
            cor: Colors.grey,
            icone: Icons.account_balance,
            ativa: true,
            dataCriacao: DateTime.now(),
            idUsuario: usuarioId,
          ),
        );
      });
      if (_modoLocal) {
        await _salvarContasLocal();
      }
    }
  }

  Future<void> _editarConta(Conta conta) async {
    final nomeController = TextEditingController(text: conta.nome);
    final descricaoController =
        TextEditingController(text: conta.descricao ?? '');
    final saldoController = TextEditingController(
        text: conta.saldoInicial.toStringAsFixed(2).replaceAll('.', ','));
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Conta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome')),
            TextField(
                controller: descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição')),
            TextField(
                controller: saldoController,
                decoration: const InputDecoration(labelText: 'Saldo Inicial')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Salvar')),
        ],
      ),
    );
    if (ok == true) {
      final saldo =
          double.tryParse(saldoController.text.replaceAll(',', '.')) ??
              conta.saldoInicial;
      setState(() {
        final idx = _contas.indexWhere((c) => c.id == conta.id);
        if (idx >= 0) {
          _contas[idx] = conta.copiarCom(
            nome: nomeController.text.trim(),
            descricao: descricaoController.text.trim(),
            saldoInicial: saldo,
          );
        }
      });
      if (_modoLocal) {
        await _salvarContasLocal();
      }
    }
  }

  Future<void> _excluirConta(Conta conta) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Conta'),
        content: Text('Deseja excluir "${conta.nome}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: TemaConfiguracao.corErro),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      setState(() {
        _contas.removeWhere((c) => c.id == conta.id);
      });
      if (_modoLocal) {
        await _salvarContasLocal();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Conta excluída'),
            backgroundColor: TemaConfiguracao.corSucesso),
      );
    }
  }
}
