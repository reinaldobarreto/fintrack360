import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Modelo que representa uma categoria de lançamentos financeiros
class Categoria {
  final String id;
  final String nome;
  final String descricao;
  final IconData icone;
  final Color cor;
  final bool ativa;
  final DateTime dataCriacao;
  final String? idUsuarioCriador; // null para categorias padrão do sistema

  Categoria({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.icone,
    required this.cor,
    required this.ativa,
    required this.dataCriacao,
    this.idUsuarioCriador,
  });

  /// Cria uma categoria a partir dos dados do Firestore
  factory Categoria.deFirestore(Map<String, dynamic> dados, String id) {
    return Categoria(
      id: id,
      nome: dados['nome'] as String,
      descricao: dados['descricao'] as String? ?? '',
      icone: IconData(
        dados['iconeCode'] as int,
        fontFamily: dados['iconeFontFamily'] as String?,
      ),
      cor: Color(dados['cor'] as int),
      ativa: dados['ativa'] as bool? ?? true,
      dataCriacao: (dados['dataCriacao'] as Timestamp).toDate(),
      idUsuarioCriador: dados['idUsuarioCriador'] as String?,
    );
  }

  /// Converte a categoria para o formato do Firestore
  Map<String, dynamic> paraFirestore() {
    return {
      'nome': nome,
      'descricao': descricao,
      'iconeCode': icone.codePoint,
      'iconeFontFamily': icone.fontFamily,
      'cor': cor.value,
      'ativa': ativa,
      'dataCriacao': Timestamp.fromDate(dataCriacao),
      'idUsuarioCriador': idUsuarioCriador,
    };
  }

  /// Cria uma cópia da categoria com campos alterados
  Categoria copiarCom({
    String? nome,
    String? descricao,
    IconData? icone,
    Color? cor,
    bool? ativa,
  }) {
    return Categoria(
      id: id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      icone: icone ?? this.icone,
      cor: cor ?? this.cor,
      ativa: ativa ?? this.ativa,
      dataCriacao: dataCriacao,
      idUsuarioCriador: idUsuarioCriador,
    );
  }

  /// Verifica se é uma categoria padrão do sistema
  bool get ehCategoriaDoSistema => idUsuarioCriador == null;

  /// Verifica se a categoria está ativa
  bool get estaAtiva => ativa;

  @override
  String toString() {
    return 'Categoria(id: $id, nome: $nome, ativa: $ativa)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Categoria && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Categorias padrão do sistema para economia doméstica
  static List<Map<String, dynamic>> get categoriasPadrao => [
    {
      'nome': 'Carro',
      'descricao': 'Gastos relacionados ao automóvel',
      'iconeCode': Icons.directions_car.codePoint,
      'iconeFontFamily': Icons.directions_car.fontFamily,
      'cor': Colors.blue.value,
    },
    {
      'nome': 'Combustível',
      'descricao': 'Gastos com combustível',
      'iconeCode': Icons.local_gas_station.codePoint,
      'iconeFontFamily': Icons.local_gas_station.fontFamily,
      'cor': Colors.orange.value,
    },
    {
      'nome': 'Comidas',
      'descricao': 'Gastos com alimentação',
      'iconeCode': Icons.restaurant.codePoint,
      'iconeFontFamily': Icons.restaurant.fontFamily,
      'cor': Colors.green.value,
    },
    {
      'nome': 'Impostos',
      'descricao': 'Pagamento de impostos e taxas',
      'iconeCode': Icons.account_balance.codePoint,
      'iconeFontFamily': Icons.account_balance.fontFamily,
      'cor': Colors.red.value,
    },
    {
      'nome': 'Casa',
      'descricao': 'Gastos domésticos e moradia',
      'iconeCode': Icons.home.codePoint,
      'iconeFontFamily': Icons.home.fontFamily,
      'cor': Colors.brown.value,
    },
    {
      'nome': 'Moto',
      'descricao': 'Gastos relacionados à motocicleta',
      'iconeCode': Icons.motorcycle.codePoint,
      'iconeFontFamily': Icons.motorcycle.fontFamily,
      'cor': Colors.purple.value,
    },
    {
      'nome': 'Salário',
      'descricao': 'Receita de salário',
      'iconeCode': Icons.work.codePoint,
      'iconeFontFamily': Icons.work.fontFamily,
      'cor': Colors.teal.value,
    },
    {
      'nome': 'Freelance',
      'descricao': 'Receita de trabalhos freelance',
      'iconeCode': Icons.laptop.codePoint,
      'iconeFontFamily': Icons.laptop.fontFamily,
      'cor': Colors.indigo.value,
    },
  ];
}