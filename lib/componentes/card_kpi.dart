import 'package:flutter/material.dart';
import '../configuracao/tema_configuracao.dart';

/// Card para exibir KPIs (Key Performance Indicators) no dashboard
class CardKPI extends StatelessWidget {
  final String titulo;
  final double valor;
  final IconData icone;
  final Color cor;
  final String? tendencia;

  const CardKPI({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icone,
    required this.cor,
    this.tendencia,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TemaConfiguracao.corSuperficie,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho com ícone e título
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icone,
                  color: cor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    color: TemaConfiguracao.corTextoSecundario,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Valor principal
          Text(
            'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: TemaConfiguracao.corTexto,
            ),
          ),

          // Tendência (se fornecida)
          if (tendencia != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  tendencia!.startsWith('+')
                      ? Icons.trending_up
                      : Icons.trending_down,
                  size: 16,
                  color: tendencia!.startsWith('+')
                      ? TemaConfiguracao.corSucesso
                      : TemaConfiguracao.corErro,
                ),
                const SizedBox(width: 4),
                Text(
                  tendencia!,
                  style: TextStyle(
                    fontSize: 12,
                    color: tendencia!.startsWith('+')
                        ? TemaConfiguracao.corSucesso
                        : TemaConfiguracao.corErro,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
