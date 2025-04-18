import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../theme/app_theme.dart';
import '../utils/calculator.dart';
import '../utils/pdf_generator.dart';
import '../providers/product_provider.dart';
import 'image_gallery_screen.dart';
import 'navegador_google.dart';
import 'product_details_screen.dart';
import 'product_form.dart';
import 'product_list.dart';
import 'settings_screen.dart';
import 'template_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
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
      if (!Hive.isBoxOpen('products')) await Hive.openBox('products');
      if (!Hive.isBoxOpen('template_settings')) await Hive.openBox('template_settings');
      if (!Hive.isBoxOpen('app_settings')) await Hive.openBox('app_settings');
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Erro ao inicializar Hive: \$e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  void _chamarCalculadora() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CalculatorScreen()),
    );
  }

  Future<void> _gerarPdf() async {
    final box = Hive.box('products');
    final products = box.values.toList();
    if (products.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione produtos antes de gerar o PDF')),
      );
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
                builder: (context, child) => Transform.rotate(
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
                    child: const Icon(Icons.shopping_bag, color: Colors.white, size: 40),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Carregando...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
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
          IconButton(icon: const Icon(Icons.picture_as_pdf), onPressed: _gerarPdf),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: _applyFilter,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'name', child: Text('Filtrar por Nome')),
              PopupMenuItem(value: 'price', child: Text('Filtrar por Preço')),
              PopupMenuItem(value: 'category', child: Text('Filtrar por Categoria')),
              PopupMenuItem(value: 'date', child: Text('Filtrar por Data')),
              PopupMenuItem(value: 'clear', child: Text('Limpar Filtros')),
            ],
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          RefreshIndicator(onRefresh: () async { setState(() => _isLoading = true); await _initHive(); setState(() => _isLoading = false); }, child: _buildProductList()),
          const ImageGalleryScreen(),
          const TemplateEditorScreen(),
          const SettingsScreen(),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductForm())), child: const Icon(Icons.add))
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Produtos'),
          BottomNavigationBarItem(icon: Icon(Icons.photo_library), label: 'Galeria'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Template'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configurações'),
        ],
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(padding: EdgeInsets.zero, children: [
        DrawerHeader(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.7)]),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            CircleAvatar(radius: 30, child: Icon(Icons.shopping_bag, size: 30)),
            SizedBox(height: 10),
            Text('Catálogo de Produtos', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('Gerencie seus produtos', style: TextStyle(color: Colors.white70, fontSize: 14)),
          ]),
        ),
        _buildDrawerItem(Icons.home, 'Início', 0),
        _buildDrawerItem(Icons.photo_library, 'Galeria', 1),
        _buildDrawerItem(Icons.dashboard, 'Template', 2),
        _buildDrawerItem(Icons.settings, 'Configurações', 3),
        const Divider(),
        ListTile(leading: const Icon(Icons.picture_as_pdf), title: const Text('Gerar PDF'), onTap: () { Navigator.pop(context); _gerarPdf(); }),
        ListTile(leading: const Icon(Icons.add_photo_alternate), title: const Text('Adicionar Imagem'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ImageGalleryScreen())); }),
        ListTile(leading: const Icon(Icons.download), title: const Text('Baixar Imagens'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const NavegadorGoogle())); }),
        ListTile(leading: const Icon(Icons.calculate), title: const Text('Calculadora'), onTap: () { Navigator.pop(context); _chamarCalculadora(); }),
        ListTile(leading: const Icon(Icons.add), title: const Text('Novo Produto'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductForm())); }),
      ]),
    );
  }

  ListTile _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: _selectedIndex == index,
      onTap: () { setState(() => _selectedIndex = index); Navigator.pop(context); },
    );
  }

  void _applyFilter(String filterType) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filtrar por ' + (filterType == 'name' ? 'Nome' : filterType == 'price' ? 'Preço' : filterType == 'category' ? 'Categoria' : 'Data')),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            if (filterType == 'name') ...[
              TextField(decoration: const InputDecoration(labelText: 'Nome do produto'), onChanged: (v) => setState(() => _filterText = v)),
            ] else if (filterType == 'price') ...[
              TextField(decoration: const InputDecoration(labelText: 'Preço mínimo'), keyboardType: TextInputType.number, onChanged: (v) => setState(() => _minPrice = double.tryParse(v) ?? 0)),
              const SizedBox(height: 8),
              TextField(decoration: const InputDecoration(labelText: 'Preço máximo'), keyboardType: TextInputType.number, onChanged: (v) => setState(() => _maxPrice = double.tryParse(v) ?? double.infinity)),
            ] else if (filterType == 'category') ...[
              TextField(decoration: const InputDecoration(labelText: 'Categoria'), onChanged: (v) => setState(() => _filterText = v)),
            ] else if (filterType == 'date') ...[
              TextButton(onPressed: () async { final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now()); if (d != null) setState(() => _startDate = d); }, child: Text(_startDate == null ? 'Data inicial' : 'Início: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}')),
              TextButton(onPressed: () async { final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now()); if (d != null) setState(() => _endDate = d); }, child: Text(_endDate == null ? 'Data final' : 'Fim: ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}')),
            ],
          ]),
          actions: [
            TextButton(onPressed: () => setState(() { _filterType = ''; _filterText = ''; _minPrice = 0; _maxPrice = double.infinity; _startDate = null; _endDate = null; Navigator.pop(context); }), child: const Text('Limpar')),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
          ],
        );
      },
    );
    setState(() => _filterType = filterType);
  }

  Widget _buildProductList() {
    return Consumer<ProductProvider>(builder: (context, pp, _) {
      final items = pp.getProducts().where((p) {
        if (_filterType == 'name') return p['name'].toString().toLowerCase().contains(_filterText.toLowerCase());
        if (_filterType == 'price') {
          final price = double.tryParse(p['price'].toString()) ?? 0;
          return price >= _minPrice && price <= _maxPrice;
        }
        if (_filterType == 'category') return p['category'].toString().toLowerCase().contains(_filterText.toLowerCase());
        if (_filterType == 'date' && _startDate != null && _endDate != null) {
          final pd = DateTime.parse(p['date']);
          return pd.isAfter(_startDate!) && pd.isBefore(_endDate!);
        }
        return true;
      }).toList();
      return ListView.builder(
        itemCount: items.length,
        itemBuilder: (ctx, i) {
          final prod = items[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: prod['imagePath'] != null && prod['imagePath'].toString().isNotEmpty
                  ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(prod['imagePath']), width: 50, height: 50, fit: BoxFit.cover))
                  : Container(width: 50, height: 50, color: Colors.grey[200], child: const Icon(Icons.image_not_supported)),
              title: Text(prod['name']),
              subtitle: Text('R\$ ${prod['price']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit), onPressed: () => _editProduct(i)),
                IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteProduct(i)),
              ]),
              onTap: () => _showProductDetails(prod, i),
            ),
          );
        },
      );
    });
  }

  void _showProductDetails(Map<String, dynamic> product, int index) {
    showDialog(context: context, builder: (_) => AlertDialog(
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        product['imagePath'] != null && product['imagePath'].toString().isNotEmpty
            ? Image.file(File(product['imagePath']), height: 200, width: double.infinity, fit: BoxFit.cover)
            : Container(height: 200, color: Colors.grey[200], child: const Icon(Icons.image_not_supported, size: 50)),
        const SizedBox(height: 16),
        Text(product['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('R\$ ${product['price']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
        if (product['code'] != null) Text('Código: ${product['code']}'),
        if (product['category'] != null) Text('Categoria: ${product['category']}'),
        if (product['additionalInfo'] != null) Text('Info: ${product['additionalInfo']}'),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
        ElevatedButton(onPressed: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => ProductForm(index: index, existing: product))); }, child: const Text('Editar')),
      ],
    ));
  }

  Future<void> _shareProduct(int index) async {
    final prod = Provider.of<ProductProvider>(context, listen: false).getProduct(index);
    final path = prod['imagePath'];
    if (path != null && await File(path).exists()) {
      await Share.shareXFiles([XFile(path)], text: '${prod['name']}\nR\$ ${prod['price']}');
    }
  }

  Future<void> _exportProduct(int index) async {
    final prod = Provider.of<ProductProvider>(context, listen: false).getProduct(index);
    final path = prod['imagePath'];
    if (path != null && await File(path).exists()) {
      final dir = await getExternalStorageDirectory();
      final name = '${prod['name']}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final dest = File('${dir!.path}/\$name');
      await File(path).copy(dest.path);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exportado: \${dest.path}')));
    }
  }

  void _editProduct(int index) {
    final prod = Provider.of<ProductProvider>(context, listen: false).getProduct(index);
    Navigator.push(context, MaterialPageRoute(builder: (_) => ProductForm(index: index, existing: prod)));
  }

  void _deleteProduct(int index) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Excluir produto'),
      content: const Text('Deseja realmente excluir?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        TextButton(onPressed: () { Provider.of<ProductProvider>(context, listen: false).deleteProduct(index); Navigator.pop(context); }, child: const Text('Excluir')),
      ],
    ));
  }
}
