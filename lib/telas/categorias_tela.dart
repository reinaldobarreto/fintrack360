import 'package:flutter/material.dart';

import '../configuracao/tema_configuracao.dart';
import '../modelos/categoria.dart';

/// Tela de categorias financeiras
class CategoriasTela extends StatefulWidget {
  const CategoriasTela({super.key});

  @override
  State<CategoriasTela> createState() => _CategoriasTelaState();
}

class _CategoriasTelaState extends State<CategoriasTela> {
  // Dados mockados para demonstração
  final List<Categoria> _categorias = [
    Categoria(
      id: 'cat1',
      nome: 'Alimentação',
      descricao: 'Gastos com comida',
      icone: Icons.restaurant,
      cor: Colors.orange,
      ativa: true,
      dataCriacao: DateTime.now(),
      idUsuarioCriador: 'user1',
    ),
    Categoria(
      id: 'cat2',
      nome: 'Transporte',
      descricao: 'Gastos com deslocamento',
      icone: Icons.directions_car,
      cor: Colors.blue,
      ativa: true,
      dataCriacao: DateTime.now(),
      idUsuarioCriador: 'user1',
    ),
  ];

  // Busca e filtro
  final TextEditingController _buscaController = TextEditingController();
  bool _filtroAtivas = true; // exibir apenas ativas por padrão

  // Paleta de cores e ícones disponíveis
  final List<Color> _coresDisponiveis = const [
    Colors.orange,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.brown,
    Colors.cyan,
    Colors.pink,
    Colors.grey,
  ];

  final List<IconData> _iconesDisponiveis = const [
    Icons.category,
    Icons.shopping_cart,
    Icons.restaurant,
    Icons.local_cafe,
    Icons.directions_car,
    Icons.directions_bike,
    Icons.motorcycle,
    Icons.home,
    Icons.work,
    Icons.laptop,
    Icons.health_and_safety,
    Icons.sports_soccer,
    Icons.movie,
    Icons.flight,
    Icons.paid,
  ];

  @override
  Widget build(BuildContext context) {
    // Aplica busca e filtro
    final textoBusca = _buscaController.text.trim().toLowerCase();
    final categoriasFiltradas = _categorias.where((c) {
      final passaBusca =
          textoBusca.isEmpty || c.nome.toLowerCase().contains(textoBusca);
      final passaFiltroAtivas = !_filtroAtivas || c.ativa;
      return passaBusca && passaFiltroAtivas;
    }).toList();

    return Scaffold(
      backgroundColor: TemaConfiguracao.corFundo,
      body: RefreshIndicator(
        onRefresh: _atualizarCategorias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho com busca e filtros
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _buscaController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Buscar categorias',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilterChip(
                    label: const Text('Ativas'),
                    selected: _filtroAtivas,
                    onSelected: (v) => setState(() => _filtroAtivas = v),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Contadores
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: const Icon(Icons.category, size: 18),
                    label: Text('Total: ${_categorias.length}'),
                  ),
                  Chip(
                    avatar: const Icon(Icons.check_circle,
                        size: 18, color: Colors.green),
                    label: Text(
                        'Ativas: ${_categorias.where((c) => c.ativa).length}'),
                  ),
                  Chip(
                    avatar:
                        const Icon(Icons.cancel, size: 18, color: Colors.red),
                    label: Text(
                        'Inativas: ${_categorias.where((c) => !c.ativa).length}'),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Lista filtrada
              Expanded(
                child: ListView.builder(
                  itemCount: categoriasFiltradas.length,
                  itemBuilder: (context, index) {
                    final categoria = categoriasFiltradas[index];
                    return Card(
                      color: TemaConfiguracao.corSuperficie,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: categoria.cor.withOpacity(0.2),
                          child: Icon(categoria.icone, color: categoria.cor),
                        ),
                        title: Text(
                          categoria.nome,
                          style: const TextStyle(
                            color: TemaConfiguracao.corTexto,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          categoria.descricao ?? '',
                          style: const TextStyle(
                              color: TemaConfiguracao.corTextoSecundario),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: categoria.ativa,
                              activeThumbColor: TemaConfiguracao.corPrimaria,
                              onChanged: (v) {
                                setState(() {
                                  final idx = _categorias
                                      .indexWhere((c) => c.id == categoria.id);
                                  if (idx >= 0) {
                                    _categorias[idx] =
                                        categoria.copiarCom(ativa: v);
                                  }
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _editarCategoria(categoria),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _excluirCategoria(categoria),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarCategoria,
        backgroundColor: TemaConfiguracao.corPrimaria,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _atualizarCategorias() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() {});
  }

  Future<void> _adicionarCategoria() async {
    final nomeController = TextEditingController();
    final descricaoController = TextEditingController();
    Color corSelecionada = _coresDisponiveis.first;
    IconData iconeSelecionado = _iconesDisponiveis.first;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Categoria'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              const SizedBox(height: 12),
              // Seleção de cor
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _coresDisponiveis.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cor = _coresDisponiveis[index];
                    final selecionada = corSelecionada == cor;
                    return GestureDetector(
                      onTap: () => setState(() => corSelecionada = cor),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: cor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                selecionada ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              // Seleção de ícone
              SizedBox(
                height: 84,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: _iconesDisponiveis.length,
                  itemBuilder: (context, index) {
                    final icone = _iconesDisponiveis[index];
                    final selecionado = iconeSelecionado == icone;
                    return InkWell(
                      onTap: () => setState(() => iconeSelecionado = icone),
                      child: Container(
                        decoration: BoxDecoration(
                          color: selecionado
                              ? corSelecionada.withOpacity(0.2)
                              : TemaConfiguracao.corSuperficie,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selecionado
                                ? corSelecionada
                                : Colors.transparent,
                          ),
                        ),
                        child: Icon(icone,
                            color: selecionado
                                ? corSelecionada
                                : TemaConfiguracao.corTexto),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Adicionar')),
        ],
      ),
    );
    if (ok == true) {
      final nome = nomeController.text.trim();
      // Validações simples
      if (nome.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Informe um nome para a categoria'),
              backgroundColor: TemaConfiguracao.corErro),
        );
        return;
      }
      if (_categorias.any((c) => c.nome.toLowerCase() == nome.toLowerCase())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Já existe uma categoria com esse nome'),
              backgroundColor: TemaConfiguracao.corErro),
        );
        return;
      }
      setState(() {
        _categorias.add(
          Categoria(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            nome: nome,
            descricao: descricaoController.text.trim(),
            icone: iconeSelecionado,
            cor: corSelecionada,
            ativa: true,
            dataCriacao: DateTime.now(),
            idUsuarioCriador: 'user1',
          ),
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Categoria adicionada'),
            backgroundColor: TemaConfiguracao.corSucesso),
      );
    }
  }

  Future<void> _editarCategoria(Categoria categoria) async {
    final nomeController = TextEditingController(text: categoria.nome);
    final descricaoController =
        TextEditingController(text: categoria.descricao ?? '');
    Color corSelecionada = categoria.cor;
    IconData iconeSelecionado = categoria.icone;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Categoria'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _coresDisponiveis.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cor = _coresDisponiveis[index];
                    final selecionada = corSelecionada == cor;
                    return GestureDetector(
                      onTap: () => setState(() => corSelecionada = cor),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: cor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                selecionada ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 84,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: _iconesDisponiveis.length,
                  itemBuilder: (context, index) {
                    final icone = _iconesDisponiveis[index];
                    final selecionado = iconeSelecionado == icone;
                    return InkWell(
                      onTap: () => setState(() => iconeSelecionado = icone),
                      child: Container(
                        decoration: BoxDecoration(
                          color: selecionado
                              ? corSelecionada.withOpacity(0.2)
                              : TemaConfiguracao.corSuperficie,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selecionado
                                ? corSelecionada
                                : Colors.transparent,
                          ),
                        ),
                        child: Icon(icone,
                            color: selecionado
                                ? corSelecionada
                                : TemaConfiguracao.corTexto),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Salvar')),
        ],
      ),
    );
    if (ok == true) {
      setState(() {
        final idx = _categorias.indexWhere((c) => c.id == categoria.id);
        if (idx >= 0) {
          _categorias[idx] = categoria.copiarCom(
            nome: nomeController.text.trim(),
            descricao: descricaoController.text.trim(),
            cor: corSelecionada,
            icone: iconeSelecionado,
          );
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Categoria atualizada'),
            backgroundColor: TemaConfiguracao.corSucesso),
      );
    }
  }

  Future<void> _excluirCategoria(Categoria categoria) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Categoria'),
        content: Text('Deseja excluir "${categoria.nome}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: TemaConfiguracao.corErro),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      setState(() {
        _categorias.removeWhere((c) => c.id == categoria.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Categoria excluída'),
            backgroundColor: TemaConfiguracao.corSucesso),
      );
    }
  }
}
