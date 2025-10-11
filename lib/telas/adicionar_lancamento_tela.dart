import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../configuracao/tema_configuracao.dart';
import '../modelos/lancamento.dart';
import '../modelos/categoria.dart';
import '../modelos/conta.dart';

/// Tela para adicionar ou editar lançamentos financeiros
class AdicionarLancamentoTela extends StatefulWidget {
  final Lancamento? lancamento;

  const AdicionarLancamentoTela({
    super.key,
    this.lancamento,
  });

  @override
  State<AdicionarLancamentoTela> createState() => _AdicionarLancamentoTelaState();
}

class _AdicionarLancamentoTelaState extends State<AdicionarLancamentoTela> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _observacoesController = TextEditingController();
  
  TipoLancamento _tipoSelecionado = TipoLancamento.despesa;
  String? _categoriaSelecionada;
  String? _contaSelecionada;
  DateTime _dataSelecionada = DateTime.now();
  
  bool get _ehEdicao => widget.lancamento != null;

  // Dados mockados para demonstração
  final List<Categoria> _categorias = [
    Categoria(
      id: 'cat1',
      nome: 'Alimentação',
      descricao: 'Gastos com comida',
      icone: Icons.restaurant,
      cor: Colors.orange,
      ativa: true,
      dataCriacao: DateTime.now(),
      idUsuarioCriador: 'user1',
    ),
    Categoria(
      id: 'cat2',
      nome: 'Transporte',
      descricao: 'Gastos com transporte',
      icone: Icons.directions_car,
      cor: Colors.blue,
      ativa: true,
      dataCriacao: DateTime.now(),
      idUsuarioCriador: 'user1',
    ),
    Categoria(
      id: 'cat3',
      nome: 'Salário',
      descricao: 'Receitas de trabalho',
      icone: Icons.work,
      cor: Colors.green,
      ativa: true,
      dataCriacao: DateTime.now(),
      idUsuarioCriador: 'user1',
    ),
  ];

  final List<Conta> _contas = [
    Conta(
      id: 'conta1',
      nome: 'Conta Corrente',
      descricao: 'Banco Principal',
      tipo: TipoConta.contaCorrente,
      saldoInicial: 1000.0,
      cor: Colors.blue,
      icone: Icons.account_balance,
      ativa: true,
      dataCriacao: DateTime.now(),
      idUsuario: 'user1',
    ),
    Conta(
      id: 'conta2',
      nome: 'Poupança',
      descricao: 'Conta Poupança',
      tipo: TipoConta.poupanca,
      saldoInicial: 5000.0,
      cor: Colors.green,
      icone: Icons.savings,
      ativa: true,
      dataCriacao: DateTime.now(),
      idUsuario: 'user1',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _inicializarDados();
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  /// Inicializa os dados se for edição
  void _inicializarDados() {
    if (_ehEdicao) {
      final lancamento = widget.lancamento!;
      _descricaoController.text = lancamento.descricao;
      _valorController.text = lancamento.valor.toStringAsFixed(2).replaceAll('.', ',');
      _observacoesController.text = lancamento.observacoes ?? '';
      _tipoSelecionado = lancamento.tipo;
      _categoriaSelecionada = lancamento.idCategoria;
      _contaSelecionada = lancamento.idConta;
      _dataSelecionada = lancamento.data;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaConfiguracao.corFundo,
      appBar: AppBar(
        title: Text(_ehEdicao ? 'Editar Lançamento' : 'Novo Lançamento'),
        actions: [
          TextButton(
            onPressed: _salvarLancamento,
            child: Text(
              'Salvar',
              style: TextStyle(
                color: TemaConfiguracao.corPrimaria,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Seletor de tipo (Receita/Despesa)
              _buildSeletorTipo(),
              
              const SizedBox(height: 24),
              
              // Campo de descrição
              TextFormField(
                controller: _descricaoController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: RequiredValidator(errorText: 'Descrição é obrigatória'),
              ),
              
              const SizedBox(height: 20),
              
              // Campo de valor
              TextFormField(
                controller: _valorController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  prefixIcon: Icon(Icons.attach_money),
                  prefixText: 'R\$ ',
                ),
                validator: MultiValidator([
                  RequiredValidator(errorText: 'Valor é obrigatório'),
                  PatternValidator(r'^[0-9]+([,][0-9]{1,2})?$', 
                      errorText: 'Digite um valor válido (ex: 100,50)'),
                ]),
              ),
              
              const SizedBox(height: 20),
              
              // Seletor de categoria
              DropdownButtonFormField<String>(
                value: _categoriaSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _categorias.map((categoria) {
                  return DropdownMenuItem(
                    value: categoria.id,
                    child: Text(categoria.nome),
                  );
                }).toList(),
                onChanged: (valor) {
                  setState(() {
                    _categoriaSelecionada = valor;
                  });
                },
                validator: RequiredValidator(errorText: 'Categoria é obrigatória'),
              ),
              
              const SizedBox(height: 20),
              
              // Seletor de conta
              DropdownButtonFormField<String>(
                value: _contaSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Conta',
                  prefixIcon: Icon(Icons.account_balance_outlined),
                ),
                items: _contas.map((conta) {
                  return DropdownMenuItem(
                    value: conta.id,
                    child: Text(conta.nome),
                  );
                }).toList(),
                onChanged: (valor) {
                  setState(() {
                    _contaSelecionada = valor;
                  });
                },
                validator: RequiredValidator(errorText: 'Conta é obrigatória'),
              ),
              
              const SizedBox(height: 20),
              
              // Seletor de data
              InkWell(
                onTap: _selecionarData,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    '${_dataSelecionada.day.toString().padLeft(2, '0')}/'
                    '${_dataSelecionada.month.toString().padLeft(2, '0')}/'
                    '${_dataSelecionada.year}',
                    style: TextStyle(
                      color: TemaConfiguracao.corTexto,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Campo de observações
              TextFormField(
                controller: _observacoesController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observações (opcional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Botão de salvar
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _salvarLancamento,
                  child: Text(_ehEdicao ? 'Atualizar' : 'Adicionar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói o seletor de tipo (Receita/Despesa)
  Widget _buildSeletorTipo() {
    return Container(
      decoration: BoxDecoration(
        color: TemaConfiguracao.corSuperficie,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TemaConfiguracao.corPrimaria.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _tipoSelecionado = TipoLancamento.receita;
                });
              },
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _tipoSelecionado == TipoLancamento.receita
                      ? TemaConfiguracao.corSucesso.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  border: _tipoSelecionado == TipoLancamento.receita
                      ? Border.all(color: TemaConfiguracao.corSucesso)
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      color: _tipoSelecionado == TipoLancamento.receita
                          ? TemaConfiguracao.corSucesso
                          : TemaConfiguracao.corTextoSecundario,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Receita',
                      style: TextStyle(
                        color: _tipoSelecionado == TipoLancamento.receita
                            ? TemaConfiguracao.corSucesso
                            : TemaConfiguracao.corTextoSecundario,
                        fontWeight: _tipoSelecionado == TipoLancamento.receita
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _tipoSelecionado = TipoLancamento.despesa;
                });
              },
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _tipoSelecionado == TipoLancamento.despesa
                      ? TemaConfiguracao.corErro.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  border: _tipoSelecionado == TipoLancamento.despesa
                      ? Border.all(color: TemaConfiguracao.corErro)
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_downward,
                      color: _tipoSelecionado == TipoLancamento.despesa
                          ? TemaConfiguracao.corErro
                          : TemaConfiguracao.corTextoSecundario,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Despesa',
                      style: TextStyle(
                        color: _tipoSelecionado == TipoLancamento.despesa
                            ? TemaConfiguracao.corErro
                            : TemaConfiguracao.corTextoSecundario,
                        fontWeight: _tipoSelecionado == TipoLancamento.despesa
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Seleciona a data do lançamento
  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
    );

    if (data != null) {
      setState(() {
        _dataSelecionada = data;
      });
    }
  }

  /// Salva o lançamento
  void _salvarLancamento() {
    if (!_formKey.currentState!.validate()) return;

    // Converter valor de string para double
    final valorTexto = _valorController.text.replaceAll(',', '.');
    final valor = double.tryParse(valorTexto);

    if (valor == null || valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Digite um valor válido'),
          backgroundColor: TemaConfiguracao.corErro,
        ),
      );
      return;
    }

    // Aqui seria implementada a lógica para salvar no Firebase
    // Por enquanto, apenas simula o salvamento

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_ehEdicao 
            ? 'Lançamento atualizado com sucesso' 
            : 'Lançamento adicionado com sucesso'),
        backgroundColor: TemaConfiguracao.corSucesso,
      ),
    );

    Navigator.of(context).pop(true);
  }
}