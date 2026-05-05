import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../providers/product_provider.dart';
import 'common_components.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersStreamProvider);

    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Orders Management", style: inter.copyWith(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 20),
          
          // Filters
          Container(
            padding: const EdgeInsets.all(20),
            decoration: cardDecoration(),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search order ID or Customer...",
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
                      DropdownMenuItem(value: "All", child: Text("All Status")),
                      DropdownMenuItem(value: "Pending", child: Text("Pending")),
                      DropdownMenuItem(value: "Cooking", child: Text("Cooking")),
                      DropdownMenuItem(value: "Delivered", child: Text("Delivered")),
                    ],
                    onChanged: (v) {},
                    hint: const Text("Status"),
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
              child: ordersAsync.when(
                data: (orders) {
                  if (orders.isEmpty) return const Center(child: Text("No orders found"));
                  return SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 40,
                        headingRowColor: MaterialStateProperty.all(AppColors.background),
                        columns: [
                          DataColumn(label: Text("Order ID", style: inter.copyWith(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Customer", style: inter.copyWith(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Date", style: inter.copyWith(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Items", style: inter.copyWith(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Total", style: inter.copyWith(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Status", style: inter.copyWith(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Actions", style: inter.copyWith(fontWeight: FontWeight.bold))),
                        ],
                        rows: orders.map((o) {
                          Color statusColor = AppColors.warning;
                          if (o.status.toLowerCase() == 'delivered') statusColor = AppColors.success;
                          else if (o.status.toLowerCase() == 'cooking') statusColor = AppColors.info;

                          return DataRow(
                            cells: [
                              DataCell(Text(o.id.length > 8 ? "#${o.id.substring(0,8)}" : "#${o.id}", style: inter.copyWith(fontWeight: FontWeight.bold))),
                              DataCell(Text(o.userName, style: inter.copyWith(fontWeight: FontWeight.w600))),
                              DataCell(Text(o.date.split('T').first, style: inter.copyWith(color: AppColors.textLight))),
                              DataCell(Text("${o.itemsCount} items", style: inter.copyWith(color: AppColors.textLight))),
                              DataCell(Text("\$${o.totalAmount.toStringAsFixed(2)}", style: inter.copyWith(fontWeight: FontWeight.bold))),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                  child: Text(o.status, style: inter.copyWith(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                                )
                              ),
                              DataCell(
                                IconButton(icon: const Icon(Icons.visibility_outlined, color: AppColors.primary, size: 20), onPressed: () {})
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
