import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../provedores/autenticacao_provedor.dart';
import '../configuracao/tema_configuracao.dart';
import 'login_tela.dart';
import 'principal_tela.dart';

/// Tela de splash inicial da aplicação
class SplashTela extends StatefulWidget {
  const SplashTela({super.key, this.sucessoMensagem});

  /// Mensagem de sucesso opcional que pode ser repassada à PrincipalTela
  final String? sucessoMensagem;

  @override
  State<SplashTela> createState() => _SplashTelaState();
}

class _SplashTelaState extends State<SplashTela> {
  @override
  void initState() {
    super.initState();
    _verificarAutenticacao();
  }

  /// Verifica o estado de autenticação e navega para a tela apropriada
  Future<void> _verificarAutenticacao() async {
    // Aguarda um tempo mínimo para mostrar o splash
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvedor = Provider.of<AutenticacaoProvedor>(context, listen: false);
    
    // Aguarda a verificação do estado de autenticação
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    if (authProvedor.estaAutenticado) {
      // Usuário autenticado - vai para tela principal
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PrincipalTela(
            sucessoMensagem: widget.sucessoMensagem,
          ),
        ),
      );
    } else {
      // Usuário não autenticado - vai para tela de login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginTela()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaConfiguracao.corFundo,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo da aplicação
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: TemaConfiguracao.corPrimaria,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: TemaConfiguracao.corPrimaria.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                size: 60,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Nome da aplicação
            Text(
              'FinTrack360',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: TemaConfiguracao.corTexto,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Subtítulo
            Text(
              'Sistema Financeiro Pessoal',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: TemaConfiguracao.corTextoSecundario,
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 50),
            
            // Indicador de carregamento
            const SpinKitWave(
              color: TemaConfiguracao.corPrimaria,
              size: 40.0,
            ),
            
            const SizedBox(height: 20),
            
            // Texto de carregamento
            Text(
              'Carregando...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: TemaConfiguracao.corTextoSecundario,
              ),
            ),
          ],
        ),
      ),
    );
  }
}