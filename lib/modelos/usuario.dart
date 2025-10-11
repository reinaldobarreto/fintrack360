import 'package:cloud_firestore/cloud_firestore.dart';

/// Enumeração para os tipos de usuário
enum TipoUsuario {
  admin('ADMIN'),
  usuario('USUARIO');

  const TipoUsuario(this.valor);
  final String valor;

  static TipoUsuario deString(String valor) {
    switch (valor) {
      case 'ADMIN':
        return TipoUsuario.admin;
      case 'USUARIO':
        return TipoUsuario.usuario;
      default:
        return TipoUsuario.usuario;
    }
  }
}

/// Modelo que representa um usuário do sistema
class Usuario {
  final String id;
  final String nome;
  final String email;
  final TipoUsuario tipo;
  final bool ativo;
  final DateTime dataCriacao;
  final DateTime? dataUltimoAcesso;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.tipo,
    required this.ativo,
    required this.dataCriacao,
    this.dataUltimoAcesso,
  });

  /// Cria um usuário a partir dos dados do Firestore
  factory Usuario.deFirestore(Map<String, dynamic> dados, String id) {
    return Usuario(
      id: id,
      nome: dados['nome'] as String,
      email: dados['email'] as String,
      tipo: TipoUsuario.deString(dados['tipo'] as String),
      ativo: dados['ativo'] as bool? ?? true,
      dataCriacao: (dados['dataCriacao'] as Timestamp).toDate(),
      dataUltimoAcesso: dados['dataUltimoAcesso'] != null
          ? (dados['dataUltimoAcesso'] as Timestamp).toDate()
          : null,
    );
  }

  /// Converte o usuário para o formato do Firestore
  Map<String, dynamic> paraFirestore() {
    return {
      'nome': nome,
      'email': email,
      'tipo': tipo.valor,
      'ativo': ativo,
      'dataCriacao': Timestamp.fromDate(dataCriacao),
      'dataUltimoAcesso': dataUltimoAcesso != null
          ? Timestamp.fromDate(dataUltimoAcesso!)
          : null,
    };
  }

  /// Cria uma cópia do usuário com campos alterados
  Usuario copiarCom({
    String? nome,
    String? email,
    TipoUsuario? tipo,
    bool? ativo,
    DateTime? dataUltimoAcesso,
  }) {
    return Usuario(
      id: id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      tipo: tipo ?? this.tipo,
      ativo: ativo ?? this.ativo,
      dataCriacao: dataCriacao,
      dataUltimoAcesso: dataUltimoAcesso ?? this.dataUltimoAcesso,
    );
  }

  /// Verifica se o usuário é administrador
  bool get ehAdmin => tipo == TipoUsuario.admin;

  /// Verifica se o usuário está ativo
  bool get estaAtivo => ativo;

  @override
  String toString() {
    return 'Usuario(id: $id, nome: $nome, email: $email, tipo: ${tipo.valor}, ativo: $ativo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Usuario && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}