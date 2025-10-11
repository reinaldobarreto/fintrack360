import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../modelos/usuario.dart';
import '../servicos/autenticacao_servico.dart';

/// Provedor de autenticação para gerenciamento de estado
class AutenticacaoProvedor extends ChangeNotifier {
  final AutenticacaoServico _authServico = AutenticacaoServico();
  
  Usuario? _usuarioAtual;
  bool _carregando = false;
  String? _mensagemErro;

  /// Getters
  Usuario? get usuarioAtual => _usuarioAtual;
  bool get carregando => _carregando;
  String? get mensagemErro => _mensagemErro;
  bool get estaAutenticado => _usuarioAtual != null;
  bool get ehAdmin => _usuarioAtual?.ehAdmin ?? false;

  /// Construtor - configura listener do estado de autenticação
  AutenticacaoProvedor() {
    _configurarListenerAutenticacao();
  }

  /// Configura o listener para mudanças no estado de autenticação
  void _configurarListenerAutenticacao() {
    _authServico.estadoAutenticacao.listen((User? user) async {
      if (user != null) {
        // Usuário logado - busca dados completos
        await _carregarDadosUsuario(user.uid);
      } else {
        // Usuário deslogado
        _usuarioAtual = null;
        notifyListeners();
      }
    });
  }

  /// Carrega os dados completos do usuário
  Future<void> _carregarDadosUsuario(String uid) async {
    try {
      _usuarioAtual = await _authServico.obterDadosUsuario(uid);
      notifyListeners();
    } catch (e) {
      _mensagemErro = 'Erro ao carregar dados do usuário: $e';
      notifyListeners();
    }
  }

  /// Realiza login
  Future<bool> fazerLogin(String email, String senha) async {
    _definirCarregando(true);
    _limparErro();

    try {
      final usuario = await _authServico.fazerLogin(email, senha);
      if (usuario != null) {
        _usuarioAtual = usuario;
        _definirCarregando(false);
        return true;
      } else {
        _mensagemErro = 'Falha no login. Tente novamente.';
        _definirCarregando(false);
        return false;
      }
    } catch (e) {
      _mensagemErro = e.toString();
      _definirCarregando(false);
      return false;
    }
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
      final usuario = await _authServico.cadastrarUsuario(
        nome: nome,
        email: email,
        senha: senha,
      );
      
      if (usuario != null) {
        _usuarioAtual = usuario;
        _definirCarregando(false);
        return true;
      } else {
        _mensagemErro = 'Falha no cadastro. Tente novamente.';
        _definirCarregando(false);
        return false;
      }
    } catch (e) {
      _mensagemErro = e.toString();
      _definirCarregando(false);
      return false;
    }
  }

  /// Login rápido de demonstração (modo debug)
  Future<void> loginDemo() async {
    _definirCarregando(true);
    _limparErro();
    try {
      _usuarioAtual = Usuario(
        id: 'demo',
        nome: 'Demo Admin',
        email: 'admin@fintrack.com',
        tipo: TipoUsuario.admin,
        ativo: true,
        dataCriacao: DateTime.now(),
        dataUltimoAcesso: DateTime.now(),
      );
    } finally {
      _definirCarregando(false);
      notifyListeners();
    }
  }

  /// Envia email de recuperação de senha
  Future<bool> enviarEmailRecuperacao(String email) async {
    _definirCarregando(true);
    _limparErro();

    try {
      await _authServico.enviarEmailRecuperacao(email);
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
      await _authServico.fazerLogout();
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
      await _carregarDadosUsuario(_usuarioAtual!.id);
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

  @override
  void dispose() {
    super.dispose();
  }
}