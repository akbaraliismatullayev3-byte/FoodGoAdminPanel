import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../providers/product_provider.dart';
import '../models/coupon_model.dart';
import 'common_components.dart';

class CouponsScreen extends ConsumerWidget {
  const CouponsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couponsAsync = ref.watch(couponsStreamProvider);

    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Coupons & Discounts", style: inter.copyWith(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              ElevatedButton.icon(
                onPressed: () => _showAddCouponDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text("New Coupon"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: couponsAsync.when(
              data: (coupons) => ListView.builder(
                itemCount: coupons.length,
                itemBuilder: (context, index) {
                  final coupon = coupons[index];
                  final isExpired = coupon.expiryDate.isBefore(DateTime.now());

                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(20),
                    decoration: cardDecoration(),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.local_offer, color: AppColors.success),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(coupon.code, style: inter.copyWith(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.5, color: AppColors.textDark)),
                              Text(
                                "Discount: ${coupon.discountPercent}% off (Max \$${coupon.maxDiscount})",
                                style: inter.copyWith(color: AppColors.textLight),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Expires: ${DateFormat('yyyy-MM-dd').format(coupon.expiryDate)}",
                              style: inter.copyWith(
                                color: isExpired ? AppColors.danger : AppColors.textLight,
                                fontWeight: isExpired ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isExpired ? AppColors.danger.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isExpired ? "Expired" : "Active",
                                style: inter.copyWith(
                                  color: isExpired ? AppColors.danger : AppColors.success,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          onPressed: () => ref.read(firestoreServiceProvider).deleteCoupon(coupon.id),
                          icon: const Icon(Icons.delete_outline, color: AppColors.danger),
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

  void _showAddCouponDialog(BuildContext context, WidgetRef ref) {
    final codeController = TextEditingController();
    final discountController = TextEditingController();
    final maxController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: Text("Create New Coupon", style: inter.copyWith(color: AppColors.textDark)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              style: const TextStyle(color: AppColors.textDark),
              decoration: const InputDecoration(
                labelText: "Coupon Code (e.g. FOODGO50)",
                labelStyle: TextStyle(color: AppColors.textLight),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: discountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textDark),
              decoration: const InputDecoration(
                labelText: "Discount Percentage (%)",
                labelStyle: TextStyle(color: AppColors.textLight),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: maxController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textDark),
              decoration: const InputDecoration(
                labelText: "Max Discount Amount (\$)",
                labelStyle: TextStyle(color: AppColors.textLight),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final coupon = CouponModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                code: codeController.text.toUpperCase(),
                discountPercent: double.parse(discountController.text),
                maxDiscount: double.parse(maxController.text),
                expiryDate: DateTime.now().add(const Duration(days: 30)),
              );
              ref.read(firestoreServiceProvider).addCoupon(coupon);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }
}
