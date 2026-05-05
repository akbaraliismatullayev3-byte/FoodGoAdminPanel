import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants.dart';
import '../providers/product_provider.dart';
import 'add_product_dialog.dart';
import 'edit_product_dialog.dart';
import 'common_components.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider);

    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Products Management", style: inter.copyWith(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              ElevatedButton.icon(
                onPressed: () => showDialog(context: context, builder: (_) => const AddProductDialog()),
                icon: const Icon(Icons.add),
                label: Text("Add Product", style: inter.copyWith(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Filters and Search
          Container(
            padding: const EdgeInsets.all(20),
            decoration: cardDecoration(),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search products...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    items: const [
                      DropdownMenuItem(value: "All", child: Text("All Categories")),
                      DropdownMenuItem(value: "Burgers", child: Text("Burgers")),
                      DropdownMenuItem(value: "Pizza", child: Text("Pizza")),
                    ],
                    onChanged: (v) {},
                    hint: const Text("Category"),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Table
          Expanded(
            child: Container(
              decoration: cardDecoration(),
              child: productsAsync.when(
                data: (products) {
                  if (products.isEmpty) return const Center(child: Text("No products found"));
                  return SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 40,
                        headingRowColor: MaterialStateProperty.all(AppColors.background),
                        columns: [
                          DataColumn(label: Text("Image", style: inter.copyWith(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Name", style: inter.copyWith(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Tag", style: inter.copyWith(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Price", style: inter.copyWith(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Status", style: inter.copyWith(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Actions", style: inter.copyWith(fontWeight: FontWeight.bold))),
                        ],
                        rows: products.map((p) {
                          return DataRow(
                            cells: [
                              DataCell(
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: p.imageUrl.isNotEmpty ? p.imageUrl : 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=100',
                                    width: 40, height: 40, fit: BoxFit.cover,
                                    errorWidget: (c, u, e) => Container(width: 40, height: 40, color: Colors.grey[200]),
                                  ),
                                ),
                              ),
                              DataCell(Text(p.name, style: inter.copyWith(fontWeight: FontWeight.w600))),
                              DataCell(Text(p.tag.isNotEmpty ? p.tag : "None", style: inter.copyWith(color: AppColors.textLight))),
                              DataCell(Text("\$${p.price.toStringAsFixed(2)}", style: inter.copyWith(fontWeight: FontWeight.bold))),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                  child: Text("Active", style: inter.copyWith(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold)),
                                )
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20), 
                                      onPressed: () => showDialog(context: context, builder: (_) => EditProductDialog(product: p)),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20), 
                                      onPressed: () => ref.read(firestoreServiceProvider).deleteProduct(p.id)
                                    ),
                                  ],
                                )
                              ),
                            ]
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text("Xatolik: $e")),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
