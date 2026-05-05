
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String tag;
  final int calories;
  final String protein;
  final String imageUrl;
  final double rating;
  final int reviews;
  final DateTime? createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.tag,
    required this.calories,
    required this.protein,
    required this.imageUrl,
    this.rating = 0.0,
    this.reviews = 0,
    this.createdAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> data, String id) {
    return ProductModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      tag: data['tag'] ?? '',
      calories: data['calories'] ?? 0,
      protein: data['protein']?.toString() ?? '',
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviews: data['reviews'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'tag': tag,
      'calories': calories,
      'protein': protein,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviews': reviews,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
