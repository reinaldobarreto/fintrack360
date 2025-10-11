import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../configuracao/tema_configuracao.dart';
import '../provedores/autenticacao_provedor.dart';
import '../modelos/usuario.dart';

/// Tela de perfil do usuário
class PerfilTela extends StatelessWidget {
  const PerfilTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AutenticacaoProvedor>(
      builder: (context, auth, child) {
        final Usuario? usuario = auth.usuarioAtual;
        return Scaffold(
          backgroundColor: TemaConfiguracao.corFundo,
          body: usuario == null
              ? _buildNaoAutenticado(context)
              : _buildPerfil(context, usuario),
        );
      },
    );
  }

  Widget _buildNaoAutenticado(BuildContext context) {
    return Center(
      child: Text(
        'Usuário não autenticado',
        style: TextStyle(color: TemaConfiguracao.corTextoSecundario),
      ),
    );
  }

  Widget _buildPerfil(BuildContext context, Usuario usuario) {
    final nomeController = TextEditingController(text: usuario.nome);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: TemaConfiguracao.corSecundaria,
                child: Text(
                  usuario.nome.substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    usuario.nome,
                    style: TextStyle(color: TemaConfiguracao.corTexto, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    usuario.email,
                    style: TextStyle(color: TemaConfiguracao.corTextoSecundario),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),
          Text(
            'Informações',
            style: TextStyle(color: TemaConfiguracao.corTexto, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nomeController,
            decoration: const InputDecoration(labelText: 'Nome'),
          ),
          const SizedBox(height: 8),
          TextField(
            readOnly: true,
            decoration: InputDecoration(labelText: 'Email', hintText: usuario.email),
          ),

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Dados atualizados'),
                  backgroundColor: TemaConfiguracao.corSucesso,
                ),
              );
            },
            child: const Text('Salvar alterações'),
          ),

          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Link para alterar senha enviado'),
                  backgroundColor: TemaConfiguracao.corPrimaria,
                ),
              );
            },
            child: const Text('Alterar senha'),
          ),
        ],
      ),
    );
  }
}