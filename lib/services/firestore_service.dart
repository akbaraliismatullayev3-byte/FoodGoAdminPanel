
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../models/category_model.dart';
import '../models/coupon_model.dart';
import '../models/review_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<ProductModel>> getProducts() {
    return _db
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      await _db.collection('products').add(product.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    await _db.collection('products').doc(id).delete();
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await _db.collection('products').doc(product.id).update(product.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<OrderModel>> getOrders() {
    return _db.collectionGroup('orders').snapshots().map((snapshot) {
      final orders = snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList();
      orders.sort((a, b) => b.date.compareTo(a.date));
      return orders;
    });
  }

  Stream<List<UserModel>> getUsers() {
    return _db.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Stream<List<CategoryModel>> getCategories() {
    return _db.collection('categories').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CategoryModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> addCategory(CategoryModel category) async {
    await _db.collection('categories').doc(category.id).set(category.toMap());
  }

  Future<void> deleteCategory(String id) async {
    await _db.collection('categories').doc(id).delete();
  }

  Stream<List<CouponModel>> getCoupons() {
    return _db.collection('coupons').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CouponModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> addCoupon(CouponModel coupon) async {
    await _db.collection('coupons').doc(coupon.id).set(coupon.toMap());
  }

  Future<void> deleteCoupon(String id) async {
    await _db.collection('coupons').doc(id).delete();
  }

  Stream<List<ReviewModel>> getReviews() {
    return _db.collectionGroup('reviews').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        String productId = doc.reference.parent.parent?.id ?? 'unknown';
        return ReviewModel.fromMap(doc.data(), doc.id, productId);
      }).toList();
    });
  }

  Future<String> uploadImage(dynamic imageFile) async {
    try {
      String fileName = 'products/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child(fileName);
      
      UploadTask uploadTask;
      if (kIsWeb) {
        uploadTask = ref.putData(imageFile as Uint8List);
      } else {
        uploadTask = ref.putFile(imageFile as File);
      }
      
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }
}
