import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../providers/product_provider.dart';
import 'common_components.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersStreamProvider);

    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Users Management", style: inter.copyWith(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
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
                      hintText: "Search by name or email...",
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
                      DropdownMenuItem(value: "All", child: Text("All Users")),
                      DropdownMenuItem(value: "Active", child: Text("Active")),
                      DropdownMenuItem(value: "Blocked", child: Text("Blocked")),
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
              child: usersAsync.when(
                data: (users) {
                  if (users.isEmpty) return const Center(child: Text("No users found"));
                  return SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 40,
                        headingRowColor: MaterialStateProperty.all(AppColors.background),
                        columns: [
                          DataColumn(label: Text("Profile", style: inter.copyWith(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Name", style: inter.copyWith(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Email", style: inter.copyWith(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Role", style: inter.copyWith(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Status", style: inter.copyWith(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Actions", style: inter.copyWith(fontWeight: FontWeight.bold))),
                        ],
                        rows: users.asMap().entries.map((e) {
                          final idx = e.key;
                          final u = e.value;
                          final isBlocked = idx % 5 == 4; // Mocking block status for UI variety

                          return DataRow(
                            cells: [
                              DataCell(
                                CircleAvatar(
                                  radius: 18,
                                  backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=${idx + 10}"),
                                )
                              ),
                              DataCell(Text(u.name.isNotEmpty ? u.name : "Unknown", style: inter.copyWith(fontWeight: FontWeight.w600))),
                              DataCell(Text(u.email, style: inter.copyWith(color: AppColors.textLight))),
                              DataCell(Text(u.role.toUpperCase(), style: inter.copyWith(color: AppColors.textLight, fontSize: 12))),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: isBlocked ? AppColors.danger.withOpacity(0.1) : AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                  child: Text(isBlocked ? "Blocked" : "Active", style: inter.copyWith(color: isBlocked ? AppColors.danger : AppColors.success, fontSize: 12, fontWeight: FontWeight.bold)),
                                )
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20), onPressed: () {}),
                                    IconButton(icon: Icon(isBlocked ? Icons.lock_open : Icons.block, color: isBlocked ? AppColors.success : AppColors.danger, size: 20), onPressed: () {}),
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
