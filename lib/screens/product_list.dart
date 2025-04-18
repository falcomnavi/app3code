import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'product_form.dart';

class ProductList extends StatefulWidget {
  const ProductList({Key? key}) : super(key: key);

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredProducts = [];
  late Box _productBox;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProducts);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (!Hive.isBoxOpen('products')) {
        await Hive.openBox('products');
      }
      
      _productBox = Hive.box('products');
      final products = _productBox.values.map((item) {
        if (item is Map) {
          return Map<String, dynamic>.from(item);
        }
        return <String, dynamic>{};
      }).toList();
      
      setState(() {
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Erro ao carregar produtos: $e';
      });
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _productBox.values.where((product) {
        final name = product['name']?.toString().toLowerCase() ?? '';
        final code = product['code']?.toString().toLowerCase() ?? '';
        final category = product['category']?.toString().toLowerCase() ?? '';
        return name.contains(query) || 
               code.contains(query) || 
               category.contains(query);
      }).toList();
    });
  }

  void _editProduct(Map<String, dynamic> product, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductForm(
          index: index,
          existing: product,
        ),
      ),
    );
  }

  Future<void> _deleteProduct(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir este produto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _productBox.deleteAt(index);
      _filterProducts();
    }
  }

  void _showProductDetails(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          product['name']?.toString() ?? 'Sem nome',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product['imagePath'] != null && product['imagePath'].toString().isNotEmpty)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(product['imagePath']),
                      height: 200,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.image_not_supported, size: 64),
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              if (product['code'] != null && product['code'].toString().isNotEmpty)
                _buildDetailRow('Código:', product['code']),
              if (product['price'] != null && product['price'].toString().isNotEmpty)
                _buildDetailRow(
                  'Preço:',
                  'R\$ ${double.tryParse(product['price'].toString())?.toStringAsFixed(2) ?? '0.00'}',
                ),
              if (product['category'] != null && product['category'].toString().isNotEmpty)
                _buildDetailRow('Categoria:', product['category']),
              if (product['additionalInfo'] != null && product['additionalInfo'].toString().isNotEmpty)
                _buildDetailRow('Informações adicionais:', product['additionalInfo']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Produtos'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por nome, código ou categoria',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            Expanded(
              child: Center(
                child: Text(
                  _error!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            )
          else
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _productBox.listenable(),
                builder: (context, Box box, _) {
                  final products = _searchController.text.isEmpty
                      ? box.values.toList()
                      : _filteredProducts;

                  if (products.isEmpty) {
                    return const Center(
                      child: Text('Nenhum produto encontrado.'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: product['imagePath'] != null && product['imagePath'].toString().isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(product['imagePath']),
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.image_not_supported),
                                      );
                                    },
                                  ),
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.image_not_supported),
                                ),
                          title: Text(
                            product['name']?.toString() ?? 'Sem nome',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (product['code'] != null && product['code'].toString().isNotEmpty)
                                Text(
                                  'Código: ${product['code']}',
                                  style: TextStyle(
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                  ),
                                ),
                              if (product['category'] != null && product['category'].toString().isNotEmpty)
                                Text(
                                  'Categoria: ${product['category']}',
                                  style: TextStyle(
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                  ),
                                ),
                              Text(
                                'Preço: R\$ ${double.tryParse(product['price'].toString())?.toStringAsFixed(2) ?? '0.00'}',
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editProduct(product, index),
                                tooltip: 'Editar',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteProduct(index),
                                tooltip: 'Excluir',
                              ),
                            ],
                          ),
                          onTap: () => _showProductDetails(product),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductForm()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
