import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double price;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final String? imagePath;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'imagePath': imagePath,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      description: json['description'],
      imagePath: json['imagePath'],
    );
  }
} 