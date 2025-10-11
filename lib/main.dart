import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'configuracao/firebase_configuracao.dart';
import 'configuracao/tema_configuracao.dart';
import 'provedores/autenticacao_provedor.dart';
import 'servicos/dados_iniciais_servico.dart';
import 'telas/splash_tela.dart';
import 'telas/login_tela.dart';
import 'telas/cadastro_tela.dart';
import 'telas/principal_tela.dart';
import 'telas/dashboard_tela.dart';
import 'telas/lancamentos_tela.dart';
import 'telas/categorias_tela.dart';
import 'telas/contas_tela.dart';
import 'telas/admin_tela.dart';
import 'telas/perfil_tela.dart';

void main() async {
  // Garante que os widgets estejam inicializados
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializa o Firebase
    await FirebaseConfiguracao.inicializar();
    print('Firebase inicializado com sucesso');

    // Configura dados iniciais do sistema
    final dadosIniciaisServico = DadosIniciaisServico();
    final dadosConfigurados = await dadosIniciaisServico.dadosIniciaisConfigurados();
    
    if (!dadosConfigurados) {
      print('Configurando dados iniciais...');
      await dadosIniciaisServico.configurarDadosIniciais();
    } else {
      print('Dados iniciais já configurados');
    }

    // Inicia a aplicação
    runApp(const FinTrack360App());
  } catch (e) {
    print('Erro na inicialização: $e');
    // Em caso de erro, ainda tenta iniciar a aplicação
    runApp(const FinTrack360App());
  }
}

/// Aplicação principal do FinTrack360
class FinTrack360App extends StatelessWidget {
  const FinTrack360App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provedor de autenticação
        ChangeNotifierProvider(
          create: (context) => AutenticacaoProvedor(),
        ),
        // Aqui serão adicionados outros provedores conforme necessário
      ],
      child: MaterialApp(
        title: 'FinTrack360',
        debugShowCheckedModeBanner: false,
        
        // Configuração do tema
        theme: TemaConfiguracao.temaEscuro,
        
        // Configuração de localização
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt', 'BR'), // Português do Brasil
        ],
        locale: const Locale('pt', 'BR'),
        
        // Tela inicial
        home: const SplashTela(),
        
        // Rotas principais do app
        routes: {
          '/splash': (context) => const SplashTela(),
          '/login': (context) => const LoginTela(),
          '/cadastro': (context) => const CadastroTela(),
          '/principal': (context) => const PrincipalTela(),
          '/dashboard': (context) => const DashboardTela(),
          '/lancamentos': (context) => const LancamentosTela(),
          '/categorias': (context) => const CategoriasTela(),
          '/contas': (context) => const ContasTela(),
          '/admin': (context) => const AdminTela(),
          '/perfil': (context) => const PerfilTela(),
        },
      ),
    );
  }
}
