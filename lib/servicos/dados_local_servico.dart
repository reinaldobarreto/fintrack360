import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/categoria.dart';
import '../modelos/conta.dart';
import '../modelos/lancamento.dart';

/// Serviço de dados local usando SharedPreferences para persistir
class DadosLocalServico {
  static const String _chaveCategorias = 'fintrack_categorias';
  static const String _chaveContas = 'fintrack_contas';
  static const String _chaveLancamentos = 'fintrack_lancamentos';
  static const String _chaveMetaMensal = 'fintrack_meta_mensal';

  // Categorias
  Future<List<Categoria>> carregarCategorias() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString(_chaveCategorias);
    if (dados == null || dados.isEmpty) return [];
    try {
      final lista = (jsonDecode(dados) as List<dynamic>).cast<Map<String, dynamic>>();
      return lista.map(_categoriaDeJson).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> salvarCategorias(List<Categoria> categorias) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = categorias.map(_categoriaParaJson).toList();
    await prefs.setString(_chaveCategorias, jsonEncode(lista));
  }

  // Contas
  Future<List<Conta>> carregarContas() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString(_chaveContas);
    if (dados == null || dados.isEmpty) return [];
    try {
      final lista = (jsonDecode(dados) as List<dynamic>).cast<Map<String, dynamic>>();
      return lista.map(_contaDeJson).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> salvarContas(List<Conta> contas) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = contas.map(_contaParaJson).toList();
    await prefs.setString(_chaveContas, jsonEncode(lista));
  }

  // Lançamentos
  Future<List<Lancamento>> carregarLancamentos() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString(_chaveLancamentos);
    if (dados == null || dados.isEmpty) return [];
    try {
      final lista = (jsonDecode(dados) as List<dynamic>).cast<Map<String, dynamic>>();
      return lista.map(_lancamentoDeJson).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> salvarLancamentos(List<Lancamento> lancamentos) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = lancamentos.map(_lancamentoParaJson).toList();
    await prefs.setString(_chaveLancamentos, jsonEncode(lista));
  }

  // Meta Mensal
  Future<double?> carregarMetaMensal() async {
    final prefs = await SharedPreferences.getInstance();
    // Usa getDouble se disponível; caso contrário tenta converter de string
    final valorDouble = prefs.getDouble(_chaveMetaMensal);
    if (valorDouble != null) return valorDouble;
    final valorString = prefs.getString(_chaveMetaMensal);
    if (valorString == null || valorString.isEmpty) return null;
    return double.tryParse(valorString);
  }

  Future<void> salvarMetaMensal(double valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_chaveMetaMensal, valor);
  }

  // -- Conversões --
  Map<String, dynamic> _categoriaParaJson(Categoria c) => {
        'id': c.id,
        'nome': c.nome,
        'descricao': c.descricao,
        'iconeCode': c.icone.codePoint,
        'iconeFontFamily': c.icone.fontFamily,
        'cor': c.cor.value,
        'ativa': c.ativa,
        'dataCriacao': c.dataCriacao.toIso8601String(),
        'idUsuarioCriador': c.idUsuarioCriador,
      };

  Categoria _categoriaDeJson(Map<String, dynamic> m) => Categoria(
        id: (m['id'] as String?) ?? DateTime.now().millisecondsSinceEpoch.toString(),
        nome: (m['nome'] as String?) ?? 'Categoria',
        descricao: (m['descricao'] as String?) ?? '',
        icone: IconData(
          (m['iconeCode'] as int?) ?? Icons.category.codePoint,
          fontFamily: m['iconeFontFamily'] as String?,
        ),
        cor: Color((m['cor'] as int?) ?? Colors.grey.value),
        ativa: (m['ativa'] as bool?) ?? true,
        dataCriacao: _parseData(m['dataCriacao'] as String?),
        idUsuarioCriador: m['idUsuarioCriador'] as String?,
      );

  Map<String, dynamic> _contaParaJson(Conta c) => {
        'id': c.id,
        'nome': c.nome,
        'descricao': c.descricao,
        'tipo': c.tipo.valor,
        'saldoInicial': c.saldoInicial,
        'cor': c.cor.value,
        'iconeCode': c.icone.codePoint,
        'iconeFontFamily': c.icone.fontFamily,
        'ativa': c.ativa,
        'dataCriacao': c.dataCriacao.toIso8601String(),
        'idUsuario': c.idUsuario,
      };

  Conta _contaDeJson(Map<String, dynamic> m) => Conta(
        id: (m['id'] as String?) ?? DateTime.now().millisecondsSinceEpoch.toString(),
        nome: (m['nome'] as String?) ?? 'Conta',
        descricao: (m['descricao'] as String?) ?? '',
        tipo: TipoConta.deString((m['tipo'] as String?) ?? 'CONTA_CORRENTE'),
        saldoInicial: ((m['saldoInicial'] as num?) ?? 0.0).toDouble(),
        cor: Color((m['cor'] as int?) ?? Colors.blue.value),
        icone: IconData(
          (m['iconeCode'] as int?) ?? Icons.account_balance.codePoint,
          fontFamily: m['iconeFontFamily'] as String?,
        ),
        ativa: (m['ativa'] as bool?) ?? true,
        dataCriacao: _parseData(m['dataCriacao'] as String?),
        idUsuario: (m['idUsuario'] as String?) ?? 'user1',
      );

  Map<String, dynamic> _lancamentoParaJson(Lancamento l) => {
        'id': l.id,
        'descricao': l.descricao,
        'valor': l.valor,
        'tipo': l.tipo.valor,
        'idCategoria': l.idCategoria,
        'idConta': l.idConta,
        'data': l.data.toIso8601String(),
        'idUsuario': l.idUsuario,
        'dataCriacao': l.dataCriacao.toIso8601String(),
        'observacoes': l.observacoes,
      };

  Lancamento _lancamentoDeJson(Map<String, dynamic> m) => Lancamento(
        id: (m['id'] as String?) ?? DateTime.now().millisecondsSinceEpoch.toString(),
        descricao: (m['descricao'] as String?) ?? '',
        valor: ((m['valor'] as num?) ?? 0.0).toDouble(),
        tipo: TipoLancamento.deString((m['tipo'] as String?) ?? 'DESPESA'),
        idCategoria: (m['idCategoria'] as String?) ?? '',
        idConta: (m['idConta'] as String?) ?? '',
        data: _parseData(m['data'] as String?),
        idUsuario: (m['idUsuario'] as String?) ?? 'user1',
        dataCriacao: _parseData(m['dataCriacao'] as String?),
        observacoes: m['observacoes'] as String?,
      );

  DateTime _parseData(String? s) {
    if (s == null || s.isEmpty) return DateTime.now();
    return DateTime.tryParse(s) ?? DateTime.now();
  }
}