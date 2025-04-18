import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../services/recent_products_service.dart';
import '../models/recent_product.dart';
import 'product_form_screen.dart';
import 'pdf_generator_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final RecentProductsService _recentProductsService = RecentProductsService();
  List<RecentProduct> _recentProducts = [];

  @override
  void initState() {
    super.initState();
    _loadRecentProducts();
    _addToRecentProducts();
  }

  Future<void> _loadRecentProducts() async {
    await _recentProductsService.init();
    final products = await _recentProductsService.getRecentProducts();
    setState(() {
      _recentProducts = products;
    });
  }

  Future<void> _addToRecentProducts() async {
    final recentProduct = RecentProduct(
      id: widget.product.id,
      name: widget.product.name,
      price: widget.product.price,
      lastAccessed: DateTime.now(),
    );
    await _recentProductsService.addRecentProduct(recentProduct);
    await _loadRecentProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Produto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductFormScreen(product: widget.product),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmar Exclusão'),
                  content: const Text('Tem certeza que deseja excluir este produto?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<ProductProvider>().deleteProduct(widget.product.id);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Excluir'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Preço: R\$ ${widget.product.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Código: ${widget.product.code}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Descrição: ${widget.product.description}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PDFGeneratorScreen(products: [widget.product]),
                          ),
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Gerar PDF'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_recentProducts.isNotEmpty) ...[
              Text(
                'Produtos Recentes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentProducts.length,
                itemBuilder: (context, index) {
                  final product = _recentProducts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(product.name),
                      subtitle: Text('R\$ ${product.price.toStringAsFixed(2)}'),
                      trailing: Text(
                        'Acessado: ${_formatDate(product.lastAccessed)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(
                              product: Product(
                                id: product.id,
                                name: product.name,
                                price: product.price,
                                code: '',
                                description: '',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} dias atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} horas atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutos atrás';
    } else {
      return 'Agora mesmo';
    }
  }
} 