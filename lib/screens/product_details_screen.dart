import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hive/hive.dart';
import 'product_form.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> product;
  final int index;

  const ProductDetailsScreen({
    Key? key,
    required this.product,
    required this.index,
  }) : super(key: key);

  Future<void> _shareProduct() async {
    try {
      // Criar um widget para capturar
      final RenderRepaintBoundary boundary = RenderRepaintBoundary();
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Salvar a imagem temporariamente
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/produto_${product['name']}.png');
      await file.writeAsBytes(pngBytes);

      // Compartilhar a imagem
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Confira este produto: ${product['name']}\nPreço: R\$ ${product['price']}',
      );
    } catch (e) {
      print('Erro ao compartilhar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalhes do Produto'),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareProduct,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagem do produto
              if (product['imagePath'] != null && product['imagePath'].toString().isNotEmpty)
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                  ),
                  child: Image.file(
                    File(product['imagePath']),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: theme.primaryColor,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Imagem não disponível',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  height: 300,
                  color: theme.primaryColor.withOpacity(0.1),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sem imagem',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Informações do produto
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome
                    Text(
                      product['name'] ?? 'Nome não especificado',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Preço
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.attach_money),
                          const SizedBox(width: 8),
                          Text(
                            'R\$ ${product['price'] ?? '0.00'}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Categoria
                    if (product['category'] != null && product['category'].toString().isNotEmpty) ...[
                      const Text(
                        'Categoria',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product['category'],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Informações adicionais
                    if (product['info'] != null && product['info'].toString().isNotEmpty) ...[
                      const Text(
                        'Informações',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product['info'],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductForm(
                  index: index,
                  existing: product,
                ),
              ),
            );
          },
          child: const Icon(Icons.edit),
        ),
      ),
    );
  }
} 