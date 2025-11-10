import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/usuario.dart';

/// Serviço de autenticação local com persistência em SharedPreferences.
class AutenticacaoLocalServico {
  static const String _chaveSessao = 'fintrack_demo_user';
  static const String _chaveUsuarios = 'fintrack_usuarios';

  // Removido: não há usuário ou senha padrão no app.

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

  /// Faz login local; exige que exista um usuário previamente cadastrado.
  Future<Usuario?> fazerLoginLocal(String email, String senha) async {
    final usuarios = await _carregarUsuarios();
    if (usuarios.isEmpty) {
      // Sem usuários cadastrados: orientar criação de conta
      throw Exception('Nenhum usuário encontrado. Crie uma conta para acessar.');
    }

    final usuarioMapa = usuarios.firstWhere(
      (u) => (u['email'] as String).toLowerCase() == email.trim().toLowerCase(),
      orElse: () => {},
    );
    if (usuarioMapa.isEmpty) return null;
    final senhaArmazenada = usuarioMapa['senha'] as String?;
    if (senhaArmazenada == null || senhaArmazenada != senha) return null;
    final usuario = _usuarioDeJson(usuarioMapa);
    await salvarSessao(usuario);
    return usuario;
  }

  /// Cadastra usuário local e persiste no armazenamento.
  Future<Usuario> cadastrarUsuarioLocal({
    required String nome,
    required String email,
    required String senha,
    bool admin = false,
  }) async {
    final usuarios = await _carregarUsuarios();
    if (usuarios.any((u) => (u['email'] as String).toLowerCase() == email.trim().toLowerCase())) {
      throw Exception('Este email já está sendo usado por outra conta.');
    }
    final novo = Usuario(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: nome.trim(),
      email: email.trim(),
      tipo: admin ? TipoUsuario.admin : TipoUsuario.usuario,
      ativo: true,
      dataCriacao: DateTime.now(),
      dataUltimoAcesso: DateTime.now(),
    );
    usuarios.add({..._usuarioParaJson(novo), 'senha': senha});
    await _salvarUsuarios(usuarios);
    await salvarSessao(novo);
    return novo;
  }

  /// Lista usuários cadastrados localmente
  Future<List<Usuario>> listarUsuarios() async {
    final listaMapas = await _carregarUsuarios();
    return listaMapas.map(_usuarioDeJson).toList();
  }

  /// Atualiza os dados de um usuário existente (ex.: ativo)
  Future<void> atualizarUsuario(Usuario usuario) async {
    final usuarios = await _carregarUsuarios();
    final index = usuarios.indexWhere((u) => u['id'] == usuario.id);
    if (index >= 0) {
      // Preserva a senha já armazenada
      final senha = usuarios[index]['senha'];
      usuarios[index] = {..._usuarioParaJson(usuario), 'senha': senha};
      await _salvarUsuarios(usuarios);
      await salvarSessao(usuario);
    }
  }

  // ---------- Persistência de usuários ----------
  Future<List<Map<String, dynamic>>> _carregarUsuarios() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString(_chaveUsuarios);
    if (dados == null || dados.isEmpty) return [];
    try {
      final lista = (jsonDecode(dados) as List<dynamic>).cast<Map<String, dynamic>>();
      return lista;
    } catch (_) {
      return [];
    }
  }

  Future<void> _salvarUsuarios(List<Map<String, dynamic>> usuarios) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveUsuarios, jsonEncode(usuarios));
  }

  Map<String, dynamic> _usuarioParaJson(Usuario u) => {
        'id': u.id,
        'nome': u.nome,
        'email': u.email,
        'tipo': u.tipo.valor,
        'ativo': u.ativo,
        'dataCriacao': u.dataCriacao.toIso8601String(),
        'dataUltimoAcesso': (u.dataUltimoAcesso ?? DateTime.now()).toIso8601String(),
      };

  Usuario _usuarioDeJson(Map<String, dynamic> m) => Usuario(
        id: m['id'] as String,
        nome: m['nome'] as String,
        email: m['email'] as String,
        tipo: TipoUsuario.deString(m['tipo'] as String),
        ativo: (m['ativo'] as bool?) ?? true,
        dataCriacao: DateTime.parse(m['dataCriacao'] as String),
        dataUltimoAcesso: DateTime.tryParse(m['dataUltimoAcesso'] as String? ?? ''),
      );
}