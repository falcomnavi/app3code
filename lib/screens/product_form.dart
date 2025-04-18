import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'image_gallery_screen.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';

class ProductForm extends StatefulWidget {
  final int? index;
  final Map? existing;

  const ProductForm({Key? key, this.index, this.existing}) : super(key: key);

  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _categories = [
    'Atacado',
    'Varejo',
    'Eletrônicos',
    'Alimentos',
    'Bebidas',
    'Limpeza',
    'Higiene',
    'Outros'
  ];

  String _name = '';
  String _price = '';
  String _code = '';
  String _imagePath = '';
  String _category = 'Outros';
  String _additionalInfo = '';

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _name = widget.existing!['name'] ?? '';
      _price = widget.existing!['price'] ?? '';
      _code = widget.existing!['code'] ?? '';
      _imagePath = widget.existing!['imagePath'] ?? '';
      _category = widget.existing!['category'] ?? 'Outros';
      _additionalInfo = widget.existing!['additionalInfo'] ?? '';
    }
  }

  Future<void> _pickImage() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecionar Imagem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Galeria do Dispositivo'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Imagens do App'),
              onTap: () => Navigator.pop(context, 'app'),
            ),
          ],
        ),
      ),
    );

    if (result == 'gallery') {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        // Copiar imagem para o diretório do app
        final dir = await getExternalStorageDirectory();
        final appImagesPath = '${dir!.path}/images';
        final imagesDir = Directory(appImagesPath);
        if (!await imagesDir.exists()) {
          await imagesDir.create(recursive: true);
        }
        
        final fileName = '${DateTime.now().millisecondsSinceEpoch}${file.path.substring(file.path.lastIndexOf('.'))}';
        final newPath = '$appImagesPath/$fileName';
        await File(file.path).copy(newPath);
        
        setState(() => _imagePath = newPath);
      }
    } else if (result == 'app') {
      final image = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => const ImageGalleryScreen(
            isSelectionMode: true,
          ),
        ),
      );

      if (image != null) {
        setState(() => _imagePath = image);
      }
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final product = {
        'name': _name,
        'price': _price,
        'code': _code,
        'imagePath': _imagePath,
        'category': _category,
        'additionalInfo': _additionalInfo,
      };

      try {
        if (widget.index != null) {
          await Provider.of<ProductProvider>(context, listen: false)
              .updateProduct(widget.index!, product);
        } else {
          await Provider.of<ProductProvider>(context, listen: false)
              .addProduct(product);
        }
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar produto: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.index == null ? 'Cadastrar Produto' : 'Editar Produto'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        if (_imagePath.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_imagePath),
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.image_not_supported),
                                );
                              },
                            ),
                          )
                        else
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.image, size: 50),
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text('Selecionar Imagem'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: _name,
                          decoration: const InputDecoration(
                            labelText: 'Nome do Produto',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Informe o nome' : null,
                          onChanged: (value) => _name = value,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _code,
                          decoration: const InputDecoration(
                            labelText: 'Código',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => _code = value,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _price,
                          decoration: const InputDecoration(
                            labelText: 'Preço',
                            border: OutlineInputBorder(),
                            prefixText: 'R\$ ',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Informe o preço' : null,
                          onChanged: (value) => _price = value,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _category,
                          decoration: const InputDecoration(
                            labelText: 'Categoria',
                            border: OutlineInputBorder(),
                          ),
                          items: _categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _category = newValue;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _additionalInfo,
                          decoration: const InputDecoration(
                            labelText: 'Informações Adicionais',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          onChanged: (value) => _additionalInfo = value,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveProduct,
                  child: const Text('Salvar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
