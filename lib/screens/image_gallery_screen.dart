import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import 'package:hive/hive.dart';
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart';

class ImageGalleryScreen extends StatefulWidget {
  final bool isSelectionMode;
  final Function(String)? onImageSelected;

  const ImageGalleryScreen({
    Key? key,
    this.isSelectionMode = false,
    this.onImageSelected,
  }) : super(key: key);

  @override
  _ImageGalleryScreenState createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  late Box _imageBox;
  List<Map<String, dynamic>> _images = [];
  bool _isLoading = true;
  String _sortBy = 'data';
  bool _ascending = false;
  String _searchQuery = '';
  String? _appImagesPath;

  @override
  void initState() {
    super.initState();
    _initGallery();
  }

  Future<void> _initGallery() async {
    setState(() => _isLoading = true);
    try {
      if (!Hive.isBoxOpen('images')) {
        await Hive.openBox('images');
      }
      _imageBox = Hive.box('images');

      // Obter o diretório de imagens do app
      final dir = await getExternalStorageDirectory();
      _appImagesPath = '${dir!.path}/images';
      
      // Criar diretório se não existir
      final imagesDir = Directory(_appImagesPath!);
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Limpar o box antes de recarregar as imagens
      await _imageBox.clear();

      // Carregar imagens do diretório
      final files = await imagesDir.list().toList();
      for (var file in files) {
        if (file is File && (file.path.endsWith('.jpg') || file.path.endsWith('.png'))) {
          // Verificar se a imagem já existe no box
          final existingImage = _imageBox.values.firstWhere(
            (img) => img['path'] == file.path,
            orElse: () => null,
          );

          if (existingImage == null) {
            await _imageBox.add({
              'path': file.path,
              'name': file.path.split('/').last,
              'size': file.lengthSync(),
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            });
          }
        }
      }

      _images = _imageBox.values.toList().cast<Map<String, dynamic>>();
      _sortImages();
    } catch (e) {
      debugPrint('Erro ao carregar imagens: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _sortImages() {
    _images.sort((a, b) {
      int compare;
      switch (_sortBy) {
        case 'data':
          compare = (b['timestamp'] as int).compareTo(a['timestamp'] as int);
          break;
        case 'nome':
          compare = (a['name'] as String).compareTo(b['name'] as String);
          break;
        case 'tamanho':
          compare = (b['size'] as int).compareTo(a['size'] as int);
          break;
        default:
          compare = 0;
      }
      return _ascending ? compare : -compare;
    });
  }

  Future<void> _addImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    
    if (file != null && _appImagesPath != null) {
      setState(() => _isLoading = true);
      try {
        // Copiar imagem para o diretório do app
        final fileName = '${DateTime.now().millisecondsSinceEpoch}${file.path.substring(file.path.lastIndexOf('.'))}';
        final newPath = '$_appImagesPath/$fileName';
        await File(file.path).copy(newPath);

        await _imageBox.add({
          'path': newPath,
          'name': fileName.split('.').first,
          'size': File(newPath).lengthSync(),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      } catch (e) {
        debugPrint('Erro ao adicionar imagem: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteImage(int index) async {
    final image = _images[index];
    final file = File(image['path']);
    
    if (await file.exists()) {
      await file.delete();
    }
    
    await _imageBox.deleteAt(index);
    await _initGallery();
    setState(() {});
  }

  Future<void> _shareImage(String imagePath) async {
    try {
      await Share.shareXFiles([XFile(imagePath)], text: 'Compartilhar imagem');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao compartilhar imagem')),
        );
      }
    }
  }

  void _showImageDialog(String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Stack(
          children: [
            PhotoView(
              imageProvider: FileImage(File(imagePath)),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectImage(String imagePath) {
    if (widget.isSelectionMode) {
      if (widget.onImageSelected != null) {
        widget.onImageSelected!(imagePath);
      }
      Navigator.pop(context, imagePath);
    }
  }

  Future<void> _renameImage(int index) async {
    final image = _images[index];
    final controller = TextEditingController(text: image['name']);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renomear Imagem'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Novo nome',
            hintText: 'Digite o novo nome',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                final oldFile = File(image['path']);
                final newPath = '${oldFile.parent.path}/$newName';
                await oldFile.rename(newPath);
                await _imageBox.putAt(index, {
                  ...image,
                  'path': newPath,
                  'name': newName,
                });
                await _initGallery();
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showImageDetails(int index) async {
    final image = _images[index];
    final file = File(image['path']);
    final size = file.lengthSync();
    final date = DateTime.fromMillisecondsSinceEpoch(image['timestamp']);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalhes da Imagem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nome: ${image['name']}'),
            Text('Tamanho: ${(size / 1024).toStringAsFixed(2)} KB'),
            Text('Data: ${DateFormat('dd/MM/yyyy HH:mm').format(date)}'),
            Text('Caminho: ${image['path']}'),
          ],
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

  void _showImageMenu(int index) {
    final image = _images[index];
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Adicionar ao Produto'),
            onTap: () {
              Navigator.pop(context);
              // Implementar lógica para adicionar ao produto
            },
          ),
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text('Visualizar'),
            onTap: () {
              Navigator.pop(context);
              _showImageDialog(image['path']);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Renomear'),
            onTap: () {
              Navigator.pop(context);
              _renameImage(index);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Detalhes'),
            onTap: () {
              Navigator.pop(context);
              _showImageDetails(index);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Compartilhar'),
            onTap: () {
              Navigator.pop(context);
              _shareImage(image['path']);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Excluir', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _deleteImage(index);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final filteredImages = _searchQuery.isEmpty
        ? _images
        : _images.where((image) {
            final name = image['name'].toString().toLowerCase();
            return name.contains(_searchQuery.toLowerCase());
          }).toList();

    if (_images.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.image_not_supported,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma imagem encontrada',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Adicionar Imagem'),
            ),
          ],
        ),
      );
    }

    if (filteredImages.isEmpty) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma imagem encontrada para "$_searchQuery"',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _searchQuery = '');
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Limpar busca'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Buscar',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.sort),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Ordenar por'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RadioListTile(
                            title: const Text('Data'),
                            value: 'data',
                            groupValue: _sortBy,
                            onChanged: (value) {
                              setState(() => _sortBy = value.toString());
                              _sortImages();
                              Navigator.pop(context);
                            },
                          ),
                          RadioListTile(
                            title: const Text('Nome'),
                            value: 'nome',
                            groupValue: _sortBy,
                            onChanged: (value) {
                              setState(() => _sortBy = value.toString());
                              _sortImages();
                              Navigator.pop(context);
                            },
                          ),
                          RadioListTile(
                            title: const Text('Tamanho'),
                            value: 'tamanho',
                            groupValue: _sortBy,
                            onChanged: (value) {
                              setState(() => _sortBy = value.toString());
                              _sortImages();
                              Navigator.pop(context);
                            },
                          ),
                          SwitchListTile(
                            title: const Text('Ordem Crescente'),
                            value: _ascending,
                            onChanged: (value) {
                              setState(() => _ascending = value);
                              _sortImages();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _initGallery,
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
              itemCount: filteredImages.length,
        itemBuilder: (context, index) {
                final image = filteredImages[index];
          return GestureDetector(
                  onTap: () => _showImageMenu(index),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(image['path']),
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${(image['size'] / 1024).toStringAsFixed(1)} KB',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
            ),
          );
        },
      ),
          ),
        ),
      ],
    );
  }
}
