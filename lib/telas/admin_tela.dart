import 'package:flutter/material.dart';

import '../configuracao/tema_configuracao.dart';
import '../modelos/usuario.dart';

/// Tela de administração de usuários
class AdminTela extends StatefulWidget {
  const AdminTela({super.key});

  @override
  State<AdminTela> createState() => _AdminTelaState();
}

class _AdminTelaState extends State<AdminTela> {
  // Dados mockados de usuários
  final List<Usuario> _usuarios = [
    Usuario(
      id: 'u1',
      nome: 'Admin',
      email: 'admin@fintrack.com',
      tipo: TipoUsuario.admin,
      ativo: true,
      dataCriacao: DateTime.now(),
    ),
    Usuario(
      id: 'u2',
      nome: 'Maria Silva',
      email: 'maria@exemplo.com',
      tipo: TipoUsuario.usuario,
      ativo: true,
      dataCriacao: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaConfiguracao.corFundo,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _usuarios.length,
        itemBuilder: (context, index) {
          final usuario = _usuarios[index];
          return Card(
            color: TemaConfiguracao.corSuperficie,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: usuario.ehAdmin
                    ? TemaConfiguracao.corPrimaria.withOpacity(0.2)
                    : TemaConfiguracao.corSecundaria.withOpacity(0.2),
                child: Text(
                  usuario.nome.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                usuario.nome,
                style: const TextStyle(
                    color: TemaConfiguracao.corTexto,
                    fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                usuario.email,
                style:
                    const TextStyle(color: TemaConfiguracao.corTextoSecundario),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: usuario.ehAdmin
                          ? TemaConfiguracao.corPrimaria.withOpacity(0.2)
                          : TemaConfiguracao.corSecundaria.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      usuario.ehAdmin ? 'ADMIN' : 'USER',
                      style: TextStyle(
                        color: usuario.ehAdmin
                            ? TemaConfiguracao.corPrimaria
                            : TemaConfiguracao.corSecundaria,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: usuario.ativo,
                    activeThumbColor: TemaConfiguracao.corPrimaria,
                    onChanged: (v) {
                      setState(() {
                        _usuarios[index] = usuario.copiarCom(ativo: v);
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Redefinir senha',
                    onPressed: () => _redefinirSenha(usuario),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _redefinirSenha(Usuario usuario) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Link de redefinição enviado para ${usuario.email}'),
        backgroundColor: TemaConfiguracao.corSucesso,
      ),
    );
  }
}
