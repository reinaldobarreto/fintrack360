import 'package:flutter/material.dart';

import '../configuracao/tema_configuracao.dart';

/// Utilitário para exibir mensagens de feedback consistentes
class MensagensUtil {
  static void mostrarSucesso(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(mensagem)),
          ],
        ),
        backgroundColor: TemaConfiguracao.corSucesso,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void mostrarErro(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(mensagem)),
          ],
        ),
        backgroundColor: TemaConfiguracao.corErro,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}