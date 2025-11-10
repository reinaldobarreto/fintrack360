import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/usuario.dart';

/// Serviço responsável pela autenticação de usuários
class AutenticacaoServico {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtém o usuário atual autenticado
  User? get usuarioAtual => _auth.currentUser;

  /// Stream do estado de autenticação
  Stream<User?> get estadoAutenticacao => _auth.authStateChanges();

  /// Realiza login com email e senha
  Future<Usuario?> fazerLogin(String email, String senha) async {
    try {
      final UserCredential resultado = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );

      if (resultado.user != null) {
        print('[Auth] Login bem-sucedido uid=' + resultado.user!.uid);
        // Tenta obter/criar documento do usuário no Firestore,
        // mas não bloqueia o login se ocorrer PERMISSION_DENIED.
        Usuario? usuario;
        try {
          usuario = await obterDadosUsuario(resultado.user!.uid);
          if (usuario != null) {
            print('[Firestore] Leitura usuario uid=' + usuario.id + ' sucesso');
          }
        } on FirebaseException catch (fe) {
          // Se as regras do Firestore não estiverem publicadas, continuamos com dados mínimos.
          print('[Firestore] Permissão negada ao obter/criar usuario: code=' + fe.code + ' message=' + (fe.message ?? ''));
          final u = resultado.user!;
          usuario = Usuario(
            id: u.uid,
            nome: u.displayName ?? 'Usuário',
            email: u.email ?? email.trim(),
            tipo: TipoUsuario.usuario,
            ativo: true,
            dataCriacao: DateTime.now(),
            dataUltimoAcesso: DateTime.now(),
          );
        }

        // Atualiza último acesso sem bloquear login em caso de erro
        try {
          await _atualizarUltimoAcesso(resultado.user!.uid);
          print('[Firestore] Write dataUltimoAcesso uid=' + resultado.user!.uid + ' sucesso');
        } catch (e) {
          print('[Firestore] Falha ao atualizar último acesso: ' + e.toString());
        }
        return usuario;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      // Não criar usuário automaticamente em produção.
      // Exigir cadastro manual para qualquer email, inclusive admin.
      throw _tratarErroAutenticacao(e);
    }
  }

  /// Realiza cadastro de novo usuário
  Future<Usuario?> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      final UserCredential resultado = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );

      if (resultado.user != null) {
        // Cria o documento do usuário no Firestore
        final usuario = Usuario(
          id: resultado.user!.uid,
          nome: nome.trim(),
          email: email.trim(),
          tipo: TipoUsuario.usuario, // Usuários novos são sempre do tipo 'USUARIO'
          ativo: true,
          dataCriacao: DateTime.now(),
          dataUltimoAcesso: DateTime.now(),
        );

        // Tenta persistir no Firestore, mas não falha o cadastro se houver PERMISSION_DENIED
        try {
          await _firestore
              .collection('usuarios')
              .doc(resultado.user!.uid)
              .set(usuario.paraFirestore());
          print('[Firestore] Write usuario uid=' + resultado.user!.uid + ' sucesso');
        } on FirebaseException catch (fe) {
          print('[Firestore] Falha ao escrever usuario uid=' + resultado.user!.uid + ' code=' + fe.code + ' message=' + (fe.message ?? ''));
          // Continua o cadastro mesmo com erro de permissão para não bloquear o fluxo
        } catch (e) {
          print('[Firestore] Erro inesperado ao escrever usuario uid=' + resultado.user!.uid + ': ' + e.toString());
        }

        // Atualiza o nome de exibição no Firebase Auth (não bloquear se falhar)
        try {
          await resultado.user!.updateDisplayName(nome);
        } catch (_) {}

        return usuario;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _tratarErroAutenticacao(e);
    }
  }

  /// Envia email de recuperação de senha
  Future<void> enviarEmailRecuperacao(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _tratarErroAutenticacao(e);
    }
  }

  /// Realiza logout
  Future<void> fazerLogout() async {
    await _auth.signOut();
  }

  /// Obtém os dados completos do usuário do Firestore
  Future<Usuario?> obterDadosUsuario(String uid) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('usuarios')
          .doc(uid)
          .get();

      if (doc.exists) {
        return Usuario.deFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      final user = _auth.currentUser;
      if (user != null) {
        final novoUsuario = Usuario(
          id: uid,
          nome: user.displayName ?? 'Usuário',
          email: user.email ?? '',
          // Não promover automaticamente para admin com base no email.
          // Todo usuário criado é do tipo USUARIO por padrão.
          tipo: TipoUsuario.usuario,
          ativo: true,
          dataCriacao: DateTime.now(),
          dataUltimoAcesso: DateTime.now(),
        );
        try {
          await _firestore
              .collection('usuarios')
              .doc(uid)
              .set(novoUsuario.paraFirestore());
          print('[Firestore] Write usuario uid=' + uid + ' (criado automaticamente) sucesso');
        } on FirebaseException catch (fe) {
          print('[Firestore] Erro ao criar usuario uid=' + uid + ' code=' + fe.code + ' message=' + (fe.message ?? ''));
          rethrow;
        } catch (e) {
          print('[Firestore] Erro inesperado ao criar usuario uid=' + uid + ': ' + e.toString());
          rethrow;
        }
        return novoUsuario;
      }
      return null;
    } on FirebaseException catch (e) {
      print('[Firestore] Erro ao obter usuario uid=' + uid + ' code=' + e.code + ' message=' + (e.message ?? ''));
      rethrow;
    } catch (e) {
      print('[Firestore] Erro inesperado ao obter usuario uid=' + uid + ': ' + e.toString());
      throw Exception('Erro ao buscar dados do usuário: $e');
    }
  }

  /// Atualiza a data do último acesso do usuário
  Future<void> _atualizarUltimoAcesso(String uid) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(uid)
          .set({
        'dataUltimoAcesso': Timestamp.fromDate(DateTime.now()),
      }, SetOptions(merge: true));
      print('[Firestore] Write merge dataUltimoAcesso uid=' + uid + ' sucesso');
    } catch (e) {
      // Ignora erros de atualização do último acesso
      print('Erro ao atualizar último acesso: $e');
    }
  }

  /// Cria o usuário administrador padrão
  Future<void> criarUsuarioAdminPadrao() async {
    try {
      const emailAdmin = 'admin@fintrack.com';
      const senhaAdmin = 'admin1234';
      const nomeAdmin = 'Administrador';

      // Verifica se o usuário admin já existe
      final QuerySnapshot query = await _firestore
          .collection('usuarios')
          .where('email', isEqualTo: emailAdmin)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        // Cria o usuário admin no Firebase Auth
        final UserCredential resultado = await _auth.createUserWithEmailAndPassword(
          email: emailAdmin,
          password: senhaAdmin,
        );

        if (resultado.user != null) {
          // Cria o documento do usuário admin no Firestore
          final usuarioAdmin = Usuario(
            id: resultado.user!.uid,
            nome: nomeAdmin,
            email: emailAdmin,
            tipo: TipoUsuario.admin,
            ativo: true,
            dataCriacao: DateTime.now(),
          );

          await _firestore
              .collection('usuarios')
              .doc(resultado.user!.uid)
              .set(usuarioAdmin.paraFirestore());

          // Atualiza o nome de exibição
          await resultado.user!.updateDisplayName(nomeAdmin);

          print('Usuário administrador padrão criado com sucesso');
        }
      } else {
        print('Usuário administrador já existe');
      }
    } catch (e) {
      print('Erro ao criar usuário administrador padrão: $e');
    }
  }

  /// Trata erros de autenticação do Firebase
  String _tratarErroAutenticacao(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuário não encontrado. Crie uma conta para acessar.';
      case 'wrong-password':
        return 'Senha incorreta. Tente novamente.';
      case 'email-already-in-use':
        return 'Este email já está sendo usado por outra conta.';
      case 'weak-password':
        return 'A senha é muito fraca. Use pelo menos 6 caracteres.';
      case 'invalid-email':
        return 'Email inválido. Verifique o formato do email.';
      case 'user-disabled':
        return 'Esta conta foi desabilitada. Entre em contato com o suporte.';
      case 'too-many-requests':
        return 'Muitas tentativas de login. Tente novamente mais tarde.';
      case 'network-request-failed':
        return 'Erro de conexão. Verifique sua internet e tente novamente.';
      default:
        return 'Erro de autenticação: ${e.message ?? 'Erro desconhecido'}';
    }
  }
}