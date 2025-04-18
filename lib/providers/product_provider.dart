import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class ProductProvider with ChangeNotifier {
  final Box _box = Hive.box('products');

  List<Map<String, dynamic>> getProducts() {
    return _box.values.map((product) => Map<String, dynamic>.from(product)).toList();
  }

  Map<String, dynamic> getProduct(int index) {
    return Map<String, dynamic>.from(_box.getAt(index));
  }

  Future<void> addProduct(Map<String, dynamic> product) async {
    // Garante que o caminho da imagem está correto
    if (product['image'] != null && product['image'].toString().isNotEmpty) {
      final imagePath = product['image'].toString();
      if (File(imagePath).existsSync()) {
        product['image'] = imagePath;
      } else {
        product['image'] = null;
      }
    }
    await _box.add(product);
    notifyListeners();
  }

  Future<void> updateProduct(int index, Map<String, dynamic> product) async {
    final existingProduct = _box.getAt(index) as Map<String, dynamic>;
    
    // Verifica se a imagem foi alterada
    if (product['imagePath'] != existingProduct['imagePath']) {
      // Se a imagem antiga existe e é diferente da nova, exclui a antiga
      if (existingProduct['imagePath'] != null && 
          existingProduct['imagePath'].toString().isNotEmpty &&
          existingProduct['imagePath'] != product['imagePath']) {
        final oldImage = File(existingProduct['imagePath']);
        if (await oldImage.exists()) {
          await oldImage.delete();
        }
      }
    }
    
    await _box.putAt(index, product);
    notifyListeners();
  }

  Future<void> deleteProduct(int index) async {
    await _box.deleteAt(index);
    notifyListeners();
  }
} 