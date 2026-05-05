import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../models/category_model.dart';
import '../models/coupon_model.dart';
import '../models/review_model.dart';

final firestoreServiceProvider = Provider((ref) => FirestoreService());

final productsStreamProvider = StreamProvider<List<ProductModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getProducts();
});

final ordersStreamProvider = StreamProvider<List<OrderModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getOrders();
});

final usersStreamProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getUsers();
});

final categoriesStreamProvider = StreamProvider<List<CategoryModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getCategories();
});

final couponsStreamProvider = StreamProvider<List<CouponModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getCoupons();
});

final reviewsStreamProvider = StreamProvider<List<ReviewModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getReviews();
});
