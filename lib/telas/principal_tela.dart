import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provedores/autenticacao_provedor.dart';
import '../configuracao/tema_configuracao.dart';
import '../modelos/usuario.dart';
import 'dashboard_tela.dart';
import 'lancamentos_tela.dart';
import 'categorias_tela.dart';
import 'contas_tela.dart';
import 'admin_tela.dart';
import 'perfil_tela.dart';
import 'login_tela.dart';

/// Tela principal da aplicação com navegação por abas
class PrincipalTela extends StatefulWidget {
  const PrincipalTela({super.key, this.sucessoMensagem});

  /// Mensagem de sucesso a ser exibida ao entrar nesta tela (ex: pós-login/cadastro)
  final String? sucessoMensagem;

  @override
  State<PrincipalTela> createState() => _PrincipalTelaState();
}

class _PrincipalTelaState extends State<PrincipalTela> {
  int _indiceAtual = 0;
  bool _sucessoMostrado = false;

  @override
  void initState() {
    super.initState();
    // Exibe uma mensagem de sucesso (se fornecida) após a construção do layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_sucessoMostrado && widget.sucessoMensagem != null && widget.sucessoMensagem!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(widget.sucessoMensagem!)),
              ],
            ),
            backgroundColor: TemaConfiguracao.corSucesso,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _sucessoMostrado = true;
      }
    });
  }

  /// Lista de telas para usuários normais
  final List<Widget> _telasUsuario = [
    const DashboardTela(),
    const LancamentosTela(),
    const CategoriasTela(),
    const ContasTela(),
    const PerfilTela(),
  ];

  /// Lista de telas para administradores
  final List<Widget> _telasAdmin = [
    const DashboardTela(),
    const LancamentosTela(),
    const CategoriasTela(),
    const ContasTela(),
    const AdminTela(),
    const PerfilTela(),
  ];

  /// Itens da barra de navegação para usuários normais
  final List<BottomNavigationBarItem> _itensUsuario = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.dashboard_outlined),
      activeIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.receipt_long_outlined),
      activeIcon: Icon(Icons.receipt_long),
      label: 'Lançamentos',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.category_outlined),
      activeIcon: Icon(Icons.category),
      label: 'Categorias',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.account_balance_outlined),
      activeIcon: Icon(Icons.account_balance),
      label: 'Contas',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Perfil',
    ),
  ];

  /// Itens da barra de navegação para administradores
  final List<BottomNavigationBarItem> _itensAdmin = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.dashboard_outlined),
      activeIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.receipt_long_outlined),
      activeIcon: Icon(Icons.receipt_long),
      label: 'Lançamentos',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.category_outlined),
      activeIcon: Icon(Icons.category),
      label: 'Categorias',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.account_balance_outlined),
      activeIcon: Icon(Icons.account_balance),
      label: 'Contas',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.admin_panel_settings_outlined),
      activeIcon: Icon(Icons.admin_panel_settings),
      label: 'Admin',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Perfil',
    ),
  ];

  /// Realiza logout do usuário
  Future<void> _fazerLogout() async {
    final authProvedor = Provider.of<AutenticacaoProvedor>(context, listen: false);
    
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Logout'),
        content: const Text('Deseja realmente sair da aplicação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await authProvedor.fazerLogout();
      
      if (!mounted) return;
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginTela()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AutenticacaoProvedor>(
      builder: (context, authProvedor, child) {
        final usuario = authProvedor.usuarioAtual;
        final ehAdmin = usuario?.ehAdmin ?? false;
        
        final telas = ehAdmin ? _telasAdmin : _telasUsuario;
        final itens = ehAdmin ? _itensAdmin : _itensUsuario;
        
        // Ajustar índice se necessário (para evitar overflow quando admin vira usuário)
        if (_indiceAtual >= telas.length) {
          _indiceAtual = 0;
        }

        return Scaffold(
          backgroundColor: TemaConfiguracao.corFundo,
          appBar: AppBar(
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: TemaConfiguracao.corPrimaria,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('FinTrack360'),
                      Text(
                        'Olá, ' + (usuario?.nome ?? 'Usuário'),
                        style: TextStyle(
                          color: TemaConfiguracao.corTextoSecundario,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              // Indicador de tipo de usuário
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ehAdmin 
                      ? TemaConfiguracao.corPrimaria.withOpacity(0.2)
                      : TemaConfiguracao.corSecundaria.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  ehAdmin ? 'ADMIN' : 'USER',
                  style: TextStyle(
                    color: ehAdmin 
                        ? TemaConfiguracao.corPrimaria
                        : TemaConfiguracao.corSecundaria,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // Menu de opções
              PopupMenuButton<String>(
                icon: CircleAvatar(
                  backgroundColor: TemaConfiguracao.corSecundaria,
                  radius: 16,
                  child: Text(
                    usuario?.nome.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'perfil':
                      setState(() {
                        _indiceAtual = telas.length - 1; // Última aba (Perfil)
                      });
                      break;
                    case 'logout':
                      _fazerLogout();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'perfil',
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline),
                        const SizedBox(width: 8),
                        Text(usuario?.nome ?? 'Usuário'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Sair', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: IndexedStack(
            index: _indiceAtual,
            children: telas,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _indiceAtual,
            onTap: (index) {
              setState(() {
                _indiceAtual = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            items: itens,
            selectedItemColor: TemaConfiguracao.corPrimaria,
            unselectedItemColor: TemaConfiguracao.corTextoSecundario,
            backgroundColor: TemaConfiguracao.corSuperficie,
            elevation: 8,
            selectedFontSize: 12,
            unselectedFontSize: 10,
          ),
        );
      },
    );
  }
}