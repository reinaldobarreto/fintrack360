import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../provedores/autenticacao_provedor.dart';
import '../configuracao/tema_configuracao.dart';
import '../utilitarios/mensagens.dart';
import 'cadastro_tela.dart';
import 'recuperar_senha_tela.dart';
import 'principal_tela.dart';

/// Tela de login da aplicação
class LoginTela extends StatefulWidget {
  const LoginTela({super.key});

  @override
  State<LoginTela> createState() => _LoginTelaState();
}

class _LoginTelaState extends State<LoginTela> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _senhaVisivel = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  /// Realiza o login do usuário
  Future<void> _fazerLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvedor = Provider.of<AutenticacaoProvedor>(context, listen: false);
    
    final sucesso = await authProvedor.fazerLogin(
      _emailController.text.trim(),
      _senhaController.text,
    );

    if (!mounted) return;

    if (sucesso) {
      // Login bem-sucedido - navegar para tela principal com mensagem de sucesso
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const PrincipalTela(
            sucessoMensagem: 'Login realizado com sucesso',
          ),
        ),
      );
    } else {
      // Mostrar erro centralizado
      MensagensUtil.mostrarErro(
        context,
        authProvedor.mensagemErro ?? 'Erro ao fazer login',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaConfiguracao.corFundo,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              
              // Logo e título
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: TemaConfiguracao.corPrimaria,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: TemaConfiguracao.corPrimaria.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        size: 50,
                        color: Colors.black,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Text(
                      'FinTrack360',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: TemaConfiguracao.corTexto,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Entre na sua conta',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: TemaConfiguracao.corTextoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 50),
              
              // Alerta de erro (quando houver)
              Consumer<AutenticacaoProvedor>(
                builder: (context, authProvedor, child) {
                  final mensagem = authProvedor.mensagemErro;
                  if (mensagem == null || authProvedor.carregando) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: TemaConfiguracao.corErro.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: TemaConfiguracao.corErro),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.error_outline, color: TemaConfiguracao.corErro),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            mensagem,
                            style: TextStyle(color: TemaConfiguracao.corErro),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Formulário de login
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Campo de email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: MultiValidator([
                        RequiredValidator(errorText: 'Email é obrigatório'),
                        EmailValidator(errorText: 'Digite um email válido'),
                      ]),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Campo de senha
                    TextFormField(
                      controller: _senhaController,
                      obscureText: !_senhaVisivel,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _senhaVisivel ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _senhaVisivel = !_senhaVisivel;
                            });
                          },
                        ),
                      ),
                      validator: RequiredValidator(errorText: 'Senha é obrigatória'),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Botão de login
                    Consumer<AutenticacaoProvedor>(
                      builder: (context, authProvedor, child) {
                        return SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: authProvedor.carregando ? null : _fazerLogin,
                            child: authProvedor.carregando
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                    ),
                                  )
                                : const Text('Entrar'),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Link para recuperar senha
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RecuperarSenhaTela(),
                          ),
                        );
                      },
                      child: Text(
                        'Esqueceu sua senha?',
                        style: TextStyle(
                          color: TemaConfiguracao.corSecundaria,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Divisor
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: TemaConfiguracao.corTextoSecundario.withOpacity(0.3),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'ou',
                            style: TextStyle(
                              color: TemaConfiguracao.corTextoSecundario,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: TemaConfiguracao.corTextoSecundario.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Botão para criar conta
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CadastroTela(),
                            ),
                          );
                        },
                        child: const Text('Criar nova conta'),
                      ),
                    ),

                    // Botão para pular login em modo debug
                    if (kDebugMode) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: TextButton.icon(
                          icon: const Icon(Icons.developer_mode),
                          label: const Text('Pular login (debug)'),
                          onPressed: () async {
                            final authProvedor = Provider.of<AutenticacaoProvedor>(context, listen: false);
                            await authProvedor.loginDemo();
                            if (!mounted) return;
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => PrincipalTela(
                                  sucessoMensagem: 'Login demo ativo',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Informação sobre conta admin padrão
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TemaConfiguracao.corSuperficie,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: TemaConfiguracao.corPrimaria.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: TemaConfiguracao.corPrimaria,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Conta Administrador Padrão',
                          style: TextStyle(
                            color: TemaConfiguracao.corPrimaria,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email: admin@fintrack.com\nSenha: admin123',
                      style: TextStyle(
                        color: TemaConfiguracao.corTextoSecundario,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}