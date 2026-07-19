import 'package:flutter/material.dart';
import '../providers/feed_provider.dart';

class AddFeedPage extends StatefulWidget {
  final FeedProvider provider;

  const AddFeedPage({
    super.key,
    required this.provider,
  });

  @override
  _AddFeedPageState createState() => _AddFeedPageState();
}

class _AddFeedPageState extends State<AddFeedPage> {
  List<String> _categorias = ['Categoria'];
  String? _categoriaSelecionada;
  bool _categoriasLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategorias();
  }

  Future<void> _fetchCategorias() async {
    setState(() {
      _categoriasLoading = true;
    });
    try {
      final categories = await widget.provider.getCategories();
      setState(() {
        _categorias = ['Categoria', ...categories.map((c) => c.name)];
        _categoriasLoading = false;
      });
    } catch (e) {
      setState(() { _categoriasLoading = false; });
    }
  }

  final TextEditingController _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  bool isValidURL(String url) {
    final Uri? uri = Uri.tryParse(url);
    return uri != null && uri.isAbsolute;
  }

  Future<void> _submitFeed() async {
    final String feedUrl = _urlController.text.trim();

    if (!isValidURL(feedUrl)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL inválida. Verifique e tente novamente.')),
      );
      return;
    }

    final String? selectedCategory = _categoriaSelecionada;
    if (selectedCategory == null || selectedCategory == 'Categoria') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma categoria.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await widget.provider.addFeed(feedUrl, category: selectedCategory);

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feed adicionado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        _urlController.clear();

        if (Navigator.canPop(context)) {
          Navigator.pop(context, true);
        }
      } else {
        final String errorMessage = result.error ?? 'Erro desconhecido ao adicionar feed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao conectar com a API. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text('Adicionar Feed', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'URL do Feed',
                  hintText: 'Ex: https://blog.theoldreader.com/rss',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  prefixIcon: const Icon(Icons.rss_feed),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira a URL do Feed';
                  } else if (!isValidURL(value.trim())) {
                    return 'URL inválida. Verifique e tente novamente';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _categoriasLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : DropdownButtonFormField<String>(
                        value: _categoriaSelecionada ?? _categorias[0],
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF756a81)),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        style: const TextStyle(
                          color: Color(0xFF141216),
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                        dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.95),
                        items: _categorias.map((String categoria) {
                          return DropdownMenuItem<String>(
                            value: categoria,
                            child: Text(categoria, style: const TextStyle(color: Color(0xFF141216))),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _categoriaSelecionada = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value == _categorias[0]) {
                            return 'Selecione uma categoria';
                          }
                          return null;
                        },
                      ),
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () {
                    if (_formKey.currentState!.validate()) {
                      _submitFeed();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Adicionar',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24.0),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: const Text(
                        'Adicione a URL do feed RSS que deseja acompanhar. A URL deve começar com http:// ou https://',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
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

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
