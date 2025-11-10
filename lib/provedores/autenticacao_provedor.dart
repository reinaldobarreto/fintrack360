import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../modelos/usuario.dart';
import '../servicos/autenticacao_local_servico.dart';

/// Provedor de autenticação para gerenciamento de estado
class AutenticacaoProvedor extends ChangeNotifier {
  final AutenticacaoLocalServico _localServico = AutenticacaoLocalServico();

  Usuario? _usuarioAtual;
  bool _carregando = false;
  String? _mensagemErro;

  /// Getters
  Usuario? get usuarioAtual => _usuarioAtual;
  bool get carregando => _carregando;
  String? get mensagemErro => _mensagemErro;
  bool get estaAutenticado => _usuarioAtual != null;
  bool get ehAdmin => _usuarioAtual?.ehAdmin ?? false;

  /// Construtor - restaura sessão local
  AutenticacaoProvedor() {
    _restaurarSessaoLocal();
  }

  /// Restaura sessão local
  Future<void> _restaurarSessaoLocal() async {
    try {
      final usuario = await _localServico.carregarSessao();
      if (usuario != null) {
        _usuarioAtual = usuario;
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Realiza login
  Future<bool> fazerLogin(String email, String senha) async {
    _definirCarregando(true);
    _limparErro();

    try {
      final usuario = await _localServico.fazerLoginLocal(email, senha);
      if (usuario != null) {
        _usuarioAtual = usuario;
        await _localServico.salvarSessao(usuario);
        _definirCarregando(false);
        return true;
      }
      _mensagemErro = 'Falha no login. Verifique suas credenciais.';
      _definirCarregando(false);
      return false;
    } catch (e) {
      _mensagemErro = e.toString();
      _definirCarregando(false);
      return false;
    }
  }

  /// Gera um nome amigável quando não existe displayName no Auth
  String _gerarNomeFallback(String? displayName, String? email) {
    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName.trim();
    }
    if (email == null || email.isEmpty) return 'Usuário';
    final base = email.split('@').first;
    if (base.isEmpty) return 'Usuário';
    final texto = base.replaceAll(RegExp(r'[._-]+'), ' ').trim();
    return texto
        .split(' ')
        .map((p) => p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1))
        .where((p) => p.isNotEmpty)
        .join(' ');
  }

  /// Realiza cadastro
  Future<bool> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
  }) async {
    _definirCarregando(true);
    _limparErro();

    try {
      final usuario = await _localServico.cadastrarUsuarioLocal(
        nome: nome,
        email: email,
        senha: senha,
      );

      _usuarioAtual = usuario;
      await _localServico.salvarSessao(usuario);
      _definirCarregando(false);
      return true;
    } catch (e) {
      _mensagemErro = e.toString();
      _definirCarregando(false);
      return false;
    }
  }

  // Login de demonstração removido: acesso somente com usuários cadastrados

  /// Envia email de recuperação de senha
  Future<bool> enviarEmailRecuperacao(String email) async {
    _definirCarregando(true);
    _limparErro();

    try {
      // Ambiente local: não há envio de email.
      // Você pode implementar um fluxo de redefinição salvando uma nova senha localmente.
      _definirCarregando(false);
      return true;
    } catch (e) {
      _mensagemErro = e.toString();
      _definirCarregando(false);
      return false;
    }
  }

  /// Realiza logout
  Future<void> fazerLogout() async {
    _definirCarregando(true);

    try {
      await _localServico.limparSessao();
      _usuarioAtual = null;
    } catch (e) {
      _mensagemErro = 'Erro ao fazer logout: $e';
    } finally {
      _definirCarregando(false);
    }
  }

  /// Atualiza os dados do usuário atual
  Future<void> atualizarDadosUsuario() async {
    if (_usuarioAtual != null) {
      // Em ambiente local, recarrega a sessão armazenada
      final recarregado = await _localServico.carregarSessao();
      if (recarregado != null) {
        _usuarioAtual = recarregado;
        notifyListeners();
      }
    }
  }

  /// Define o estado de carregamento
  void _definirCarregando(bool valor) {
    _carregando = valor;
    notifyListeners();
  }

  /// Limpa a mensagem de erro
  void _limparErro() {
    _mensagemErro = null;
    notifyListeners();
  }

  /// Limpa a mensagem de erro manualmente
  void limparMensagemErro() {
    _limparErro();
  }

  /// Verifica se o usuário tem permissão de administrador
  bool temPermissaoAdmin() {
    return _usuarioAtual?.ehAdmin ?? false;
  }

  /// Verifica se o usuário está ativo
  bool usuarioEstaAtivo() {
    return _usuarioAtual?.estaAtivo ?? false;
  }
}
