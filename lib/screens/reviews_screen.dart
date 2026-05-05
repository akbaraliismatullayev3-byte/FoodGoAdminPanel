import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../providers/product_provider.dart';
import 'common_components.dart';

class ReviewsScreen extends ConsumerWidget {
  const ReviewsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(reviewsStreamProvider);

    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Customer Reviews", style: inter.copyWith(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 30),
          Expanded(
            child: reviewsAsync.when(
              data: (reviews) => ListView.builder(
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(20),
                    decoration: cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              child: Text(review.userName[0].toUpperCase(), style: const TextStyle(color: AppColors.primary)),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(review.userName, style: inter.copyWith(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                                  Text("Product ID: ${review.productId}", style: inter.copyWith(color: AppColors.textLight, fontSize: 12)),
                                ],
                              ),
                            ),
                            Row(
                              children: List.generate(5, (i) => Icon(
                                Icons.star, 
                                size: 18, 
                                color: i < review.rating ? AppColors.warning : AppColors.textLight.withOpacity(0.3)
                              )),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          review.comment,
                          style: inter.copyWith(color: AppColors.textDark, fontSize: 14),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          review.date,
                          style: inter.copyWith(color: AppColors.textLight, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text("Xatolik: $e")),
            ),
          ),
        ],
      ),
    );
  }
}
