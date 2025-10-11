import 'package:cloud_firestore/cloud_firestore.dart';

/// Enumeração para os tipos de lançamento
enum TipoLancamento {
  receita('RECEITA', 'Receita'),
  despesa('DESPESA', 'Despesa');

  const TipoLancamento(this.valor, this.descricao);
  final String valor;
  final String descricao;

  static TipoLancamento deString(String valor) {
    switch (valor) {
      case 'RECEITA':
        return TipoLancamento.receita;
      case 'DESPESA':
        return TipoLancamento.despesa;
      default:
        return TipoLancamento.despesa;
    }
  }
}

/// Classe que representa um lançamento financeiro no sistema
class Lancamento {
  final String id; // ID gerado pelo Firestore
  final String descricao; // Descrição do lançamento
  final double valor; // Valor em reais
  final TipoLancamento tipo; // Tipo do lançamento: 'RECEITA' ou 'DESPESA'
  final String idCategoria; // ID da Categoria associada
  final String idConta; // ID da Conta associada
  final DateTime data; // Data do lançamento
  final String idUsuario; // ID do usuário proprietário
  final DateTime dataCriacao; // Data de criação do registro
  final String? observacoes; // Observações adicionais

  Lancamento({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.tipo,
    required this.idCategoria,
    required this.idConta,
    required this.data,
    required this.idUsuario,
    required this.dataCriacao,
    this.observacoes,
  });

  /// Método para converter dados do Firestore (Map) para o objeto Dart
  factory Lancamento.deFirestore(Map<String, dynamic> dados, String id) {
    return Lancamento(
      id: id,
      descricao: dados['descricao'] as String,
      valor: (dados['valor'] as num).toDouble(),
      tipo: TipoLancamento.deString(dados['tipo'] as String),
      idCategoria: dados['idCategoria'] as String,
      idConta: dados['idConta'] as String,
      // Converte o Timestamp do Firestore para DateTime
      data: (dados['data'] as Timestamp).toDate(),
      idUsuario: dados['idUsuario'] as String,
      dataCriacao: (dados['dataCriacao'] as Timestamp).toDate(),
      observacoes: dados['observacoes'] as String?,
    );
  }

  /// Método para converter o objeto Dart para o formato Map do Firestore
  Map<String, dynamic> paraFirestore() {
    return {
      'descricao': descricao,
      'valor': valor,
      'tipo': tipo.valor,
      'idCategoria': idCategoria,
      'idConta': idConta,
      'data': Timestamp.fromDate(data),
      'idUsuario': idUsuario,
      'dataCriacao': Timestamp.fromDate(dataCriacao),
      'observacoes': observacoes,
    };
  }

  /// Cria uma cópia do lançamento com campos alterados
  Lancamento copiarCom({
    String? descricao,
    double? valor,
    TipoLancamento? tipo,
    String? idCategoria,
    String? idConta,
    DateTime? data,
    String? observacoes,
  }) {
    return Lancamento(
      id: id,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
      tipo: tipo ?? this.tipo,
      idCategoria: idCategoria ?? this.idCategoria,
      idConta: idConta ?? this.idConta,
      data: data ?? this.data,
      idUsuario: idUsuario,
      dataCriacao: dataCriacao,
      observacoes: observacoes ?? this.observacoes,
    );
  }

  /// Verifica se é uma receita
  bool get ehReceita => tipo == TipoLancamento.receita;

  /// Verifica se é uma despesa
  bool get ehDespesa => tipo == TipoLancamento.despesa;

  /// Retorna o valor com sinal (positivo para receita, negativo para despesa)
  double get valorComSinal => ehReceita ? valor : -valor;

  /// Formata o valor para exibição
  String get valorFormatado {
    final sinal = ehReceita ? '+' : '-';
    return '$sinal R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Formata a data para exibição
  String get dataFormatada {
    return '${data.day.toString().padLeft(2, '0')}/'
           '${data.month.toString().padLeft(2, '0')}/'
           '${data.year}';
  }

  /// Obtém o mês e ano do lançamento
  String get mesAno {
    return '${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  @override
  String toString() {
    return 'Lancamento(id: $id, descricao: $descricao, valor: $valor, tipo: ${tipo.valor})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Lancamento && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}