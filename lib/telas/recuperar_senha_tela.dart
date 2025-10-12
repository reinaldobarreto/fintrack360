import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../provedores/autenticacao_provedor.dart';
import '../configuracao/tema_configuracao.dart';
import '../utilitarios/mensagens.dart';

/// Tela de recuperação de senha
class RecuperarSenhaTela extends StatefulWidget {
  const RecuperarSenhaTela({super.key});

  @override
  State<RecuperarSenhaTela> createState() => _RecuperarSenhaTelaState();
}

class _RecuperarSenhaTelaState extends State<RecuperarSenhaTela> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailEnviado = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Envia email de recuperação de senha
  Future<void> _enviarEmailRecuperacao() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvedor =
        Provider.of<AutenticacaoProvedor>(context, listen: false);

    final sucesso =
        await authProvedor.enviarEmailRecuperacao(_emailController.text.trim());

    if (!mounted) return;

    if (sucesso) {
      setState(() {
        _emailEnviado = true;
      });

      MensagensUtil.mostrarSucesso(
        context,
        'Email de recuperação enviado com sucesso!',
      );
    } else {
      MensagensUtil.mostrarErro(
        context,
        authProvedor.mensagemErro ?? 'Erro ao enviar email',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaConfiguracao.corFundo,
      appBar: AppBar(
        title: const Text('Recuperar Senha'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Ícone e título
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: TemaConfiguracao.corSecundaria.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.lock_reset,
                        size: 40,
                        color: TemaConfiguracao.corSecundaria,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _emailEnviado ? 'Email Enviado!' : 'Esqueceu sua senha?',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: TemaConfiguracao.corTexto,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _emailEnviado
                          ? 'Verifique sua caixa de entrada e siga as instruções para redefinir sua senha.'
                          : 'Digite seu email e enviaremos um link para redefinir sua senha.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: TemaConfiguracao.corTextoSecundario,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              if (!_emailEnviado) ...[
                // Formulário de recuperação
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
                          helperText: 'Digite o email da sua conta',
                        ),
                        validator: MultiValidator([
                          RequiredValidator(errorText: 'Email é obrigatório'),
                          EmailValidator(errorText: 'Digite um email válido'),
                        ]).call,
                      ),

                      const SizedBox(height: 30),

                      // Botão de enviar
                      Consumer<AutenticacaoProvedor>(
                        builder: (context, authProvedor, child) {
                          return SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: authProvedor.carregando
                                  ? null
                                  : _enviarEmailRecuperacao,
                              child: authProvedor.carregando
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.black),
                                      ),
                                    )
                                  : const Text('Enviar Email'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Ações após email enviado
                Column(
                  children: [
                    // Botão para reenviar email
                    Consumer<AutenticacaoProvedor>(
                      builder: (context, authProvedor, child) {
                        return SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: authProvedor.carregando
                                ? null
                                : _enviarEmailRecuperacao,
                            child: authProvedor.carregando
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Reenviar Email'),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Informações adicionais
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: TemaConfiguracao.corSuperficie,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              TemaConfiguracao.corSecundaria.withOpacity(0.3),
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: TemaConfiguracao.corSecundaria,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Dicas importantes:',
                                style: TextStyle(
                                  color: TemaConfiguracao.corSecundaria,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• Verifique também a pasta de spam\n'
                            '• O link expira em 1 hora\n'
                            '• Caso não receba, tente reenviar',
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
              ],

              const SizedBox(height: 40),

              // Link para voltar ao login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Lembrou da senha? ',
                    style: TextStyle(
                      color: TemaConfiguracao.corTextoSecundario,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Fazer login',
                      style: TextStyle(
                        color: TemaConfiguracao.corSecundaria,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
