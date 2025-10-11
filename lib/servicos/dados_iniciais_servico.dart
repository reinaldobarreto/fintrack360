import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/categoria.dart';
import '../modelos/conta.dart';
import '../servicos/autenticacao_servico.dart';

/// Serviço responsável por configurar os dados iniciais do sistema
class DadosIniciaisServico {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AutenticacaoServico _authServico = AutenticacaoServico();

  /// Configura todos os dados iniciais do sistema
  Future<void> configurarDadosIniciais() async {
    try {
      // 1. Criar usuário administrador padrão
      await _authServico.criarUsuarioAdminPadrao();

      // 2. Criar categorias padrão
      await _criarCategoriasPadrao();

      // 3. Buscar o usuário admin para criar a conta padrão
      final usuarioAdmin = await _buscarUsuarioAdmin();
      if (usuarioAdmin != null) {
        await _criarContaPadrao(usuarioAdmin);
      }

      print('Dados iniciais configurados com sucesso');
    } catch (e) {
      print('Erro ao configurar dados iniciais: $e');
      rethrow;
    }
  }

  /// Cria as categorias padrão do sistema
  Future<void> _criarCategoriasPadrao() async {
    try {
      final batch = _firestore.batch();
      final categoriasPadrao = Categoria.categoriasPadrao;

      for (final categoriaData in categoriasPadrao) {
        // Verifica se a categoria já existe
        final query = await _firestore
            .collection('categorias')
            .where('nome', isEqualTo: categoriaData['nome'])
            .where('idUsuarioCriador', isNull: true)
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          // Cria nova categoria
          final docRef = _firestore.collection('categorias').doc();
          final categoria = {
            ...categoriaData,
            'ativa': true,
            'dataCriacao': Timestamp.fromDate(DateTime.now()),
            'idUsuarioCriador': null, // Categoria do sistema
          };
          
          batch.set(docRef, categoria);
        }
      }

      await batch.commit();
      print('Categorias padrão criadas com sucesso');
    } catch (e) {
      print('Erro ao criar categorias padrão: $e');
    }
  }

  /// Busca o usuário administrador
  Future<String?> _buscarUsuarioAdmin() async {
    try {
      final query = await _firestore
          .collection('usuarios')
          .where('email', isEqualTo: 'admin@fintrack.com')
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.id;
      }
      return null;
    } catch (e) {
      print('Erro ao buscar usuário admin: $e');
      return null;
    }
  }

  /// Cria a conta padrão para o usuário administrador
  Future<void> _criarContaPadrao(String idUsuarioAdmin) async {
    try {
      // Verifica se já existe uma conta padrão para o admin
      final query = await _firestore
          .collection('contas')
          .where('idUsuario', isEqualTo: idUsuarioAdmin)
          .where('nome', isEqualTo: 'Conta Corrente')
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        // Cria a conta padrão
        final contaData = {
          ...Conta.contaPadrao,
          'idUsuario': idUsuarioAdmin,
          'dataCriacao': Timestamp.fromDate(DateTime.now()),
        };

        await _firestore.collection('contas').add(contaData);
        print('Conta padrão criada para o usuário admin');
      } else {
        print('Conta padrão já existe para o usuário admin');
      }
    } catch (e) {
      print('Erro ao criar conta padrão: $e');
    }
  }

  /// Verifica se os dados iniciais já foram configurados
  Future<bool> dadosIniciaisConfigurados() async {
    try {
      // Verifica se existe pelo menos uma categoria padrão
      final categorias = await _firestore
          .collection('categorias')
          .where('idUsuarioCriador', isNull: true)
          .limit(1)
          .get();

      // Verifica se existe o usuário admin
      final usuarios = await _firestore
          .collection('usuarios')
          .where('email', isEqualTo: 'admin@fintrack.com')
          .limit(1)
          .get();

      return categorias.docs.isNotEmpty && usuarios.docs.isNotEmpty;
    } catch (e) {
      print('Erro ao verificar dados iniciais: $e');
      return false;
    }
  }

  /// Força a reconfiguração dos dados iniciais (apenas para desenvolvimento)
  Future<void> reconfigurarDadosIniciais() async {
    try {
      print('Reconfigurando dados iniciais...');
      await configurarDadosIniciais();
    } catch (e) {
      print('Erro ao reconfigurar dados iniciais: $e');
      rethrow;
    }
  }
}