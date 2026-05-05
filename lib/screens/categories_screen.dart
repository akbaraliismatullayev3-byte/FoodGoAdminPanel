import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../providers/product_provider.dart';
import '../models/category_model.dart';
import 'common_components.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Categories Management", style: inter.copyWith(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              ElevatedButton.icon(
                onPressed: () => _showAddCategoryDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text("Add Category"),
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
            child: categoriesAsync.when(
              data: (categories) => GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return Container(
                    decoration: cardDecoration(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            cat.icon.isNotEmpty ? cat.icon : "🍔",
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(cat.name, style: inter.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 10),
                        IconButton(
                          onPressed: () => ref.read(firestoreServiceProvider).deleteCategory(cat.id),
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

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final iconController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: Text("Add New Category", style: inter.copyWith(color: AppColors.textDark)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: AppColors.textDark),
              decoration: const InputDecoration(
                labelText: "Category Name",
                labelStyle: TextStyle(color: AppColors.textLight),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textLight)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: iconController,
              style: const TextStyle(color: AppColors.textDark),
              decoration: const InputDecoration(
                labelText: "Emoji Icon (e.g. 🍕)",
                labelStyle: TextStyle(color: AppColors.textLight),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textLight)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final cat = CategoryModel(
                id: nameController.text.toLowerCase().replaceAll(' ', '_'),
                name: nameController.text,
                icon: iconController.text,
              );
              ref.read(firestoreServiceProvider).addCategory(cat);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
