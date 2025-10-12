import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/usuario.dart';

/// Serviço simples para gerenciar sessão local (Flutter Web/SharedPreferences)
class AutenticacaoLocalServico {
  static const String _chaveSessao = 'fintrack_demo_user';

  /// Salva a sessão localmente
  Future<void> salvarSessao(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    final mapa = {
      'id': usuario.id,
      'nome': usuario.nome,
      'email': usuario.email,
      'tipo': usuario.tipo.valor,
      'ativo': usuario.ativo,
      'dataCriacao': usuario.dataCriacao.toIso8601String(),
      'dataUltimoAcesso': (usuario.dataUltimoAcesso ?? DateTime.now()).toIso8601String(),
    };
    await prefs.setString(_chaveSessao, jsonEncode(mapa));
  }

  /// Carrega a sessão local, se existir
  Future<Usuario?> carregarSessao() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString(_chaveSessao);
    if (dados == null) return null;
    try {
      final mapa = jsonDecode(dados) as Map<String, dynamic>;
      return Usuario(
        id: mapa['id'] as String,
        nome: mapa['nome'] as String,
        email: mapa['email'] as String,
        tipo: TipoUsuario.deString(mapa['tipo'] as String),
        ativo: (mapa['ativo'] as bool?) ?? true,
        dataCriacao: DateTime.parse(mapa['dataCriacao'] as String),
        dataUltimoAcesso: DateTime.tryParse(mapa['dataUltimoAcesso'] as String? ?? ''),
      );
    } catch (_) {
      return null;
    }
  }

  /// Limpa a sessão local
  Future<void> limparSessao() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveSessao);
  }
}