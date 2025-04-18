import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'image_gallery_screen.dart';
import 'product_list.dart';
import 'template_editor_screen.dart';
import 'product_form.dart';
import 'navegador_google.dart';
import '../utils/calculator.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/pdf_generator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../screens/settings_screen.dart';
import 'dart:io';
import 'dart:math';
import 'product_details_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import '../utils/calculator.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isLoading = true;
  late AnimationController _loadingController;
  late Animation<double> _loadingAnimation;
  String _filterType = '';
  String _filterText = '';
  double _minPrice = 0;
  double _maxPrice = double.infinity;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _loadingAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _loadingController,
        curve: Curves.easeInOut,
      ),
    );
    _loadingController.repeat();
    _initHive();
  }

  Future<void> _initHive() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      Hive.init(appDir.path);
      
      if (!Hive.isBoxOpen('products')) {
        await Hive.openBox('products');
      }
      if (!Hive.isBoxOpen('template_settings')) {
        await Hive.openBox('template_settings');
      }
      if (!Hive.isBoxOpen('app_settings')) {
        await Hive.openBox('app_settings');
      }
      
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Erro ao inicializar Hive: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  Future<void> _gerarPdf() async {
    final box = Hive.box('products');
    final products = box.values.toList();
    
    if (products.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Adicione produtos antes de gerar o PDF')),
        );
      }
      return;
    }

    await gerarPdfComLoading(context, products);
  }

  @override

  Widget build(BuildContext context) {
    if (_isLoading) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _loadingAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _loadingAnimation.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shopping_bag,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Carregando...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Produtos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _gerarPdf,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => _applyFilter(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'name',
                child: Text('Filtrar por Nome'),
              ),
              const PopupMenuItem(
                value: 'price',
                child: Text('Filtrar por Preço'),
              ),
              const PopupMenuItem(
                value: 'category',
                child: Text('Filtrar por Categoria'),
              ),
              const PopupMenuItem(
                value: 'date',
                child: Text('Filtrar por Data'),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Text('Limpar Filtros'),
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.shopping_bag, size: 30),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Catálogo de Produtos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Gerencie seus produtos',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Início'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() => _selectedIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Template'),
              selected: _selectedIndex == 2,
              onTap: () {
                setState(() => _selectedIndex = 2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              selected: _selectedIndex == 3,
              onTap: () {
                setState(() => _selectedIndex = 3);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Gerar PDF'),
              onTap: () {
                Navigator.pop(context);
                _gerarPdf();
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_photo_alternate),
              title: const Text('Adicionar Imagem'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ImageGalleryScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Baixar Imagens'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NavegadorGoogle(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Novo Produto'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductForm(),
                  ),
                );
              },
            ),

            ListTile(
              title: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: () {
                    // Navegar para a Calculadora
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Calculator()),
                    );
                  },
                  child: Text(
                    'Calculator',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          RefreshIndicator(
            onRefresh: () async {
              setState(() => _isLoading = true);
              await _initHive();
              setState(() => _isLoading = false);
            },
            child: _buildProductList(),
          ),
          const ImageGalleryScreen(),
          const TemplateEditorScreen(),
          const SettingsScreen(),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductForm(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Produtos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Galeria',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Template',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }

  void _applyFilter(String filterType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filtrar por ${filterType == 'name' ? 'Nome' : filterType == 'price' ? 'Preço' : filterType == 'category' ? 'Categoria' : 'Data'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (filterType == 'name')
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nome do produto',
                  hintText: 'Digite o nome para filtrar',
                ),
                onChanged: (value) {
                  setState(() {
                    _filterText = value;
                    _filterType = filterType;
                  });
                },
              )
            else if (filterType == 'price')
              Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Preço mínimo',
                      hintText: 'Digite o preço mínimo',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _minPrice = double.tryParse(value) ?? 0;
                        _filterType = filterType;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Preço máximo',
                      hintText: 'Digite o preço máximo',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _maxPrice = double.tryParse(value) ?? double.infinity;
                        _filterType = filterType;
                      });
                    },
                  ),
                ],
              )
            else if (filterType == 'category')
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  hintText: 'Digite a categoria para filtrar',
                ),
                onChanged: (value) {
                  setState(() {
                    _filterText = value;
                    _filterType = filterType;
                  });
                },
              )
            else if (filterType == 'date')
              Column(
                children: [
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                          _filterType = filterType;
                        });
                      }
                    },
                    child: Text(_startDate == null
                        ? 'Selecione a data inicial'
                        : 'Data inicial: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _endDate = date;
                          _filterType = filterType;
                        });
                      }
                    },
                    child: Text(_endDate == null
                        ? 'Selecione a data final'
                        : 'Data final: ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _filterText = '';
                _filterType = '';
                _minPrice = 0;
                _maxPrice = double.infinity;
                _startDate = null;
                _endDate = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Limpar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final products = productProvider.getProducts();
        final filteredProducts = products.where((product) {
          if (_filterType.isEmpty) return true;
          
          switch (_filterType) {
            case 'name':
              return product['name']?.toString().toLowerCase().contains(_filterText.toLowerCase()) ?? false;
            case 'price':
              final price = double.tryParse(product['price']?.toString() ?? '0') ?? 0;
              return price >= _minPrice && price <= _maxPrice;
            case 'category':
              return product['category']?.toString().toLowerCase().contains(_filterText.toLowerCase()) ?? false;
            case 'date':
              if (_startDate == null || _endDate == null) return true;
              final productDate = DateTime.parse(product['date'] ?? DateTime.now().toString());
              return productDate.isAfter(_startDate!) && productDate.isBefore(_endDate!);
            default:
              return true;
          }
        }).toList();

        return ListView.builder(
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: InkWell(
                onTap: () => _showProductDetails(context, product, index),
                child: ListTile(
                  leading: product['imagePath'] != null && product['imagePath'].toString().isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(product['imagePath']),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.image_not_supported),
                              );
                            },
                          ),
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.image_not_supported),
                        ),
                  title: Text(product['name'] ?? ''),
                  subtitle: Text(
                    'R\$ ${product['price'] ?? '0.00'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editProduct(context, index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteProduct(context, index),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showProductDetails(BuildContext context, Map<String, dynamic> product, int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  if (product['imagePath'] != null && product['imagePath'].toString().isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.file(
                        File(product['imagePath']),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported, size: 50),
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 50),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.white),
                            onPressed: () => _shareProduct(context, product),
                          ),
                          IconButton(
                            icon: const Icon(Icons.download, color: Colors.white),
                            onPressed: () => _exportProduct(context, product),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'R\$ ${product['price'] ?? '0.00'}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    if (product['code'] != null && product['code'].toString().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Código: ${product['code']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                    if (product['category'] != null && product['category'].toString().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Categoria: ${product['category']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                    if (product['additionalInfo'] != null && product['additionalInfo'].toString().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Informações: ${product['additionalInfo']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Fechar'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _editProduct(context, index),
                          child: const Text('Editar'),
                        ),
                      ],
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

  Future<void> _shareProduct(BuildContext context, Map<String, dynamic> product) async {
    try {
      final imagePath = product['imagePath'];
      if (imagePath != null && imagePath.toString().isNotEmpty) {
        final imageFile = File(imagePath);
        if (await imageFile.exists()) {
          await Share.shareXFiles(
            [XFile(imagePath)],
            text: '${product['name']}\nPreço: R\$ ${product['price']}',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao compartilhar: $e')),
        );
      }
    }
  }

  Future<void> _exportProduct(BuildContext context, Map<String, dynamic> product) async {
    try {
      final imagePath = product['imagePath'];
      if (imagePath != null && imagePath.toString().isNotEmpty) {
        final imageFile = File(imagePath);
        if (await imageFile.exists()) {
          final dir = await getExternalStorageDirectory();
          final fileName = '${product['name']}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final newPath = '${dir!.path}/$fileName';
          await imageFile.copy(newPath);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Imagem exportada para: $newPath')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar: $e')),
        );
      }
    }
  }

  void _editProduct(BuildContext context, int index) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final product = productProvider.getProduct(index);
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

  void _deleteProduct(BuildContext context, int index) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir este produto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              productProvider.deleteProduct(index);
              Navigator.pop(context);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class _HomeAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final Function(BuildContext) onTap;

  const _HomeAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
        onTap: () => onTap(context),
          borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkTextColor
                      : AppTheme.textColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Calculator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator'),
      ),
      body: Center(
        child: Text('Calculator Screen'),
      ),
    );
  }
}
