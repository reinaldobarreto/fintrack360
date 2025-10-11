import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../provedores/autenticacao_provedor.dart';
import '../configuracao/tema_configuracao.dart';
import '../utilitarios/mensagens.dart';
import 'principal_tela.dart';

/// Tela de cadastro de novos usuários
class CadastroTela extends StatefulWidget {
  const CadastroTela({super.key});

  @override
  State<CadastroTela> createState() => _CadastroTelaState();
}

class _CadastroTelaState extends State<CadastroTela> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  bool _senhaVisivel = false;
  bool _confirmarSenhaVisivel = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  /// Realiza o cadastro do usuário
  Future<void> _fazerCadastro() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvedor = Provider.of<AutenticacaoProvedor>(context, listen: false);
    
    final sucesso = await authProvedor.cadastrarUsuario(
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      senha: _senhaController.text,
    );

    if (!mounted) return;

    if (sucesso) {
      // Cadastro bem-sucedido - navegar para tela principal com mensagem de sucesso
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const PrincipalTela(
            sucessoMensagem: 'Cadastro realizado com sucesso',
          ),
        ),
      );
    } else {
      // Mostrar erro centralizado
      MensagensUtil.mostrarErro(
        context,
        authProvedor.mensagemErro ?? 'Erro ao fazer cadastro',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaConfiguracao.corFundo,
      appBar: AppBar(
        title: const Text('Criar Conta'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Título e subtítulo
              Center(
                child: Column(
                  children: [
                    Text(
                      'Bem-vindo!',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: TemaConfiguracao.corTexto,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Crie sua conta para começar',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: TemaConfiguracao.corTextoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
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

              // Formulário de cadastro
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Campo de nome
                    TextFormField(
                      controller: _nomeController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nome completo',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: MultiValidator([
                        RequiredValidator(errorText: 'Nome é obrigatório'),
                        MinLengthValidator(2, errorText: 'Nome deve ter pelo menos 2 caracteres'),
                      ]),
                    ),
                    
                    const SizedBox(height: 20),
                    
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
                      validator: MultiValidator([
                        RequiredValidator(errorText: 'Senha é obrigatória'),
                        MinLengthValidator(6, errorText: 'Senha deve ter pelo menos 6 caracteres'),
                      ]),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Campo de confirmar senha
                    TextFormField(
                      controller: _confirmarSenhaController,
                      obscureText: !_confirmarSenhaVisivel,
                      decoration: InputDecoration(
                        labelText: 'Confirmar senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _confirmarSenhaVisivel ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _confirmarSenhaVisivel = !_confirmarSenhaVisivel;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirmação de senha é obrigatória';
                        }
                        if (value != _senhaController.text) {
                          return 'Senhas não coincidem';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Botão de cadastro
                    Consumer<AutenticacaoProvedor>(
                      builder: (context, authProvedor, child) {
                        return SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: authProvedor.carregando ? null : _fazerCadastro,
                            child: authProvedor.carregando
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                    ),
                                  )
                                : const Text('Criar Conta'),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Link para voltar ao login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Já tem uma conta? ',
                          style: TextStyle(
                            color: TemaConfiguracao.corTextoSecundario,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
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
              
              const SizedBox(height: 40),
              
              // Termos de uso
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TemaConfiguracao.corSuperficie,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Ao criar uma conta, você concorda com nossos Termos de Uso e Política de Privacidade.',
                  style: TextStyle(
                    color: TemaConfiguracao.corTextoSecundario,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}