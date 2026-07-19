import 'package:flutter/material.dart';
import '../providers/feed_provider.dart';
import '../models/feed.dart';
import '../models/category.dart';
import 'add_feed_page.dart';

class SubscriptionsPage extends StatefulWidget {
  final FeedProvider provider;
  const SubscriptionsPage({super.key, required this.provider});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  List<Feed> subscriptions = [];
  List<Category> categories = [];
  bool loading = true;
  bool loadingCategories = true;
  String? error;
  final TextEditingController _addController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() { loadingCategories = true; });
    try {
      final categoryList = await widget.provider.getCategories();
      setState(() {
        categories = categoryList;
        loadingCategories = false;
      });
    } catch (e) {
      setState(() { loadingCategories = false; });
    }
  }

  Future<void> _loadSubscriptions() async {
    setState(() { loading = true; error = null; });
    try {
      final feedList = await widget.provider.getFeeds();
      setState(() {
        subscriptions = feedList;
        loading = false;
      });
    } catch (e) {
      setState(() { error = 'Erro: $e'; loading = false; });
    }
  }

  Future<void> _addSubscription() async {
    final url = _addController.text.trim();
    if (url.isEmpty) return;
    setState(() { loading = true; });
    try {
      final result = await widget.provider.addFeed(url);
      if (result.success) {
        _addController.clear();
        await _loadSubscriptions();
      } else {
        setState(() { error = result.error ?? 'Erro ao adicionar'; });
      }
    } catch (e) {
      setState(() { error = 'Erro: $e'; });
    }
  }

  Future<void> _editSubscription(Feed sub) async {
    final controller = TextEditingController(text: sub.title);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar titulo'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Salvar')),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      setState(() { loading = true; });
      await widget.provider.renameFeed(sub.id, result.trim());
      await _loadSubscriptions();
    }
  }

  Future<void> _removeSubscription(Feed sub) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover assinatura'),
        content: Text('Remover o feed "${sub.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remover')),
        ],
      ),
    );
    if (confirm == true) {
      setState(() { loading = true; });
      await widget.provider.removeFeed(sub.id);
      await _loadSubscriptions();
    }
  }

  Future<void> _assignCategory(Feed sub) async {
    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma categoria disponivel')),
      );
      return;
    }

    String? selectedCategory = sub.categories.isNotEmpty ? sub.categories.first : categories.first.name;

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Atribuir a categoria'),
        content: DropdownButtonFormField<String>(
          initialValue: selectedCategory,
          decoration: const InputDecoration(
            labelText: 'Categoria',
            border: OutlineInputBorder(),
          ),
          items: categories.map((cat) => DropdownMenuItem(
            value: cat.name,
            child: Text(cat.name),
          )).toList(),
          onChanged: (value) => selectedCategory = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, selectedCategory),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() { loading = true; });
      try {
        await widget.provider.moveFeed(sub.id, result);
        await _loadSubscriptions();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar categoria: $e')),
        );
        setState(() { loading = false; });
      }
    }
  }

  Future<void> _createCategory() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova categoria'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nome da categoria',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Criar'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() { loading = true; });
      try {
        await widget.provider.createCategory(result);
        await _loadCategories();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Categoria "$result" criada com sucesso')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar categoria: $e')),
        );
      } finally {
        setState(() { loading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assinaturas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            tooltip: 'Nova categoria',
            onPressed: _createCategory,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: _loadSubscriptions,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _addController,
                              decoration: const InputDecoration(
                                labelText: 'URL do feed',
                                border: OutlineInputBorder(),
                                hintText: 'https://exemplo.com/feed',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _addSubscription,
                            child: const Text('Adicionar'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadSubscriptions,
                        child: ListView.builder(
                          itemCount: subscriptions.length,
                          itemBuilder: (context, idx) {
                            final sub = subscriptions[idx];
                            final categoryName = sub.categories.isNotEmpty
                                ? sub.categories.first
                                : 'Sem categoria';

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              child: ListTile(
                                title: Text(
                                  sub.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(sub.url ?? ''),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        categoryName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.category_outlined),
                                      tooltip: 'Atribuir categoria',
                                      onPressed: () => _assignCategory(sub),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      tooltip: 'Editar titulo',
                                      onPressed: () => _editSubscription(sub),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      tooltip: 'Remover feed',
                                      onPressed: () => _removeSubscription(sub),
                                    ),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddFeedPage(provider: widget.provider),
            ),
          ).then((result) {
            if (result == true) {
              _loadSubscriptions();
            }
          });
        },
        tooltip: 'Adicionar Feed',
        child: const Icon(Icons.add),
      ),
    );
  }
}
