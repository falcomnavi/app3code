import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';

class ProductService {
  static const String _boxName = 'products';
  late Box<Product> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Product>(_boxName);
  }

  Future<void> addProduct(Product product) async {
    await _box.put(product.id, product);
  }

  Future<void> updateProduct(Product product) async {
    await _box.put(product.id, product);
  }

  Future<void> deleteProduct(String id) async {
    await _box.delete(id);
  }

  Future<List<Product>> getProducts() async {
    return _box.values.toList();
  }

  Future<Product?> getProduct(String id) async {
    return _box.get(id);
  }

  Future<void> clearProducts() async {
    await _box.clear();
  }
} 