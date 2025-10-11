import 'package:flutter/material.dart';
import '../configuracao/tema_configuracao.dart';
import '../modelos/lancamento.dart';

/// Card para exibir um lançamento financeiro
class CardLancamento extends StatelessWidget {
  final Lancamento lancamento;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const CardLancamento({
    super.key,
    required this.lancamento,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final ehReceita = lancamento.ehReceita;
    final cor = ehReceita ? TemaConfiguracao.corSucesso : TemaConfiguracao.corErro;
    final icone = ehReceita ? Icons.arrow_upward : Icons.arrow_downward;

    return Card(
      elevation: 2,
      color: TemaConfiguracao.corSuperficie,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: cor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícone do tipo de lançamento
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  icone,
                  color: cor,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Informações do lançamento
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Descrição
                    Text(
                      lancamento.descricao,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: TemaConfiguracao.corTexto,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Data
                    Text(
                      lancamento.dataFormatada,
                      style: TextStyle(
                        fontSize: 12,
                        color: TemaConfiguracao.corTextoSecundario,
                      ),
                    ),
                    
                    // Observações (se houver)
                    if (lancamento.observacoes != null && lancamento.observacoes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        lancamento.observacoes!,
                        style: TextStyle(
                          fontSize: 12,
                          color: TemaConfiguracao.corTextoSecundario,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Valor e ações
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Valor
                  Text(
                    '${ehReceita ? '+' : '-'} ${lancamento.valorFormatado}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: cor,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Botão de excluir
                  if (onDelete != null)
                    InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: TemaConfiguracao.corTextoSecundario,
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