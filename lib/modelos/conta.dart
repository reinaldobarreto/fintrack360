import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Enumeração para os tipos de conta
enum TipoConta {
  contaCorrente('CONTA_CORRENTE', 'Conta Corrente'),
  poupanca('POUPANCA', 'Poupança'),
  cartaoCredito('CARTAO_CREDITO', 'Cartão de Crédito'),
  dinheiro('DINHEIRO', 'Dinheiro'),
  investimento('INVESTIMENTO', 'Investimento');

  const TipoConta(this.valor, this.descricao);
  final String valor;
  final String descricao;

  static TipoConta deString(String valor) {
    switch (valor) {
      case 'CONTA_CORRENTE':
        return TipoConta.contaCorrente;
      case 'POUPANCA':
        return TipoConta.poupanca;
      case 'CARTAO_CREDITO':
        return TipoConta.cartaoCredito;
      case 'DINHEIRO':
        return TipoConta.dinheiro;
      case 'INVESTIMENTO':
        return TipoConta.investimento;
      default:
        return TipoConta.contaCorrente;
    }
  }
}

/// Modelo que representa uma conta financeira
class Conta {
  final String id;
  final String nome;
  final String descricao;
  final TipoConta tipo;
  final double saldoInicial;
  final Color cor;
  final IconData icone;
  final bool ativa;
  final DateTime dataCriacao;
  final String idUsuario;

  Conta({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.tipo,
    required this.saldoInicial,
    required this.cor,
    required this.icone,
    required this.ativa,
    required this.dataCriacao,
    required this.idUsuario,
  });

  /// Cria uma conta a partir dos dados do Firestore
  factory Conta.deFirestore(Map<String, dynamic> dados, String id) {
    return Conta(
      id: id,
      nome: dados['nome'] as String,
      descricao: dados['descricao'] as String? ?? '',
      tipo: TipoConta.deString(dados['tipo'] as String),
      saldoInicial: (dados['saldoInicial'] as num).toDouble(),
      cor: Color(dados['cor'] as int),
      icone: IconData(
        dados['iconeCode'] as int,
        fontFamily: dados['iconeFontFamily'] as String?,
      ),
      ativa: dados['ativa'] as bool? ?? true,
      dataCriacao: (dados['dataCriacao'] as Timestamp).toDate(),
      idUsuario: dados['idUsuario'] as String,
    );
  }

  /// Converte a conta para o formato do Firestore
  Map<String, dynamic> paraFirestore() {
    return {
      'nome': nome,
      'descricao': descricao,
      'tipo': tipo.valor,
      'saldoInicial': saldoInicial,
      'cor': cor.value,
      'iconeCode': icone.codePoint,
      'iconeFontFamily': icone.fontFamily,
      'ativa': ativa,
      'dataCriacao': Timestamp.fromDate(dataCriacao),
      'idUsuario': idUsuario,
    };
  }

  /// Cria uma cópia da conta com campos alterados
  Conta copiarCom({
    String? nome,
    String? descricao,
    TipoConta? tipo,
    double? saldoInicial,
    Color? cor,
    IconData? icone,
    bool? ativa,
  }) {
    return Conta(
      id: id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      tipo: tipo ?? this.tipo,
      saldoInicial: saldoInicial ?? this.saldoInicial,
      cor: cor ?? this.cor,
      icone: icone ?? this.icone,
      ativa: ativa ?? this.ativa,
      dataCriacao: dataCriacao,
      idUsuario: idUsuario,
    );
  }

  /// Verifica se a conta está ativa
  bool get estaAtiva => ativa;

  /// Obtém o ícone padrão baseado no tipo da conta
  static IconData obterIconePadrao(TipoConta tipo) {
    switch (tipo) {
      case TipoConta.contaCorrente:
        return Icons.account_balance;
      case TipoConta.poupanca:
        return Icons.savings;
      case TipoConta.cartaoCredito:
        return Icons.credit_card;
      case TipoConta.dinheiro:
        return Icons.attach_money;
      case TipoConta.investimento:
        return Icons.trending_up;
    }
  }

  /// Obtém a cor padrão baseada no tipo da conta
  static Color obterCorPadrao(TipoConta tipo) {
    switch (tipo) {
      case TipoConta.contaCorrente:
        return Colors.blue;
      case TipoConta.poupanca:
        return Colors.green;
      case TipoConta.cartaoCredito:
        return Colors.orange;
      case TipoConta.dinheiro:
        return Colors.teal;
      case TipoConta.investimento:
        return Colors.purple;
    }
  }

  @override
  String toString() {
    return 'Conta(id: $id, nome: $nome, tipo: ${tipo.descricao}, saldoInicial: $saldoInicial)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Conta && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Dados para criar a conta padrão do sistema
  static Map<String, dynamic> get contaPadrao => {
    'nome': 'Conta Corrente',
    'descricao': 'Conta corrente principal',
    'tipo': TipoConta.contaCorrente.valor,
    'saldoInicial': 0.0,
    'cor': obterCorPadrao(TipoConta.contaCorrente).value,
    'iconeCode': obterIconePadrao(TipoConta.contaCorrente).codePoint,
    'iconeFontFamily': obterIconePadrao(TipoConta.contaCorrente).fontFamily,
    'ativa': true,
  };
}