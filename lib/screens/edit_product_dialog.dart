import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_go_admin_panel/providers/product_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../constants.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';

class EditProductDialog extends ConsumerStatefulWidget {
  final ProductModel product;
  const EditProductDialog({Key? key, required this.product}) : super(key: key);

  @override
  ConsumerState<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends ConsumerState<EditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _caloriesCtrl;
  late TextEditingController _proteinCtrl;
  late TextEditingController _imageUrlCtrl;
  late TextEditingController _ratingCtrl;
  late TextEditingController _reviewsCtrl;
  
  XFile? _pickedImage;
  Uint8List? _webImage;
  bool _isUsingLink = true;
  late String _selectedTag;
  final List<String> _tags = ['Burgers', 'Pizza', 'Sushi', 'Dessert', 'Drinks', 'Salad', 'SIGNATURE'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product.name);
    _descCtrl = TextEditingController(text: widget.product.description);
    _priceCtrl = TextEditingController(text: widget.product.price.toString());
    _caloriesCtrl = TextEditingController(text: widget.product.calories.toString());
    _proteinCtrl = TextEditingController(text: widget.product.protein);
    _imageUrlCtrl = TextEditingController(text: widget.product.imageUrl);
    _ratingCtrl = TextEditingController(text: widget.product.rating.toString());
    _reviewsCtrl = TextEditingController(text: widget.product.reviews.toString());
    _selectedTag = _tags.contains(widget.product.tag) ? widget.product.tag : _tags.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _caloriesCtrl.dispose();
    _proteinCtrl.dispose();
    _imageUrlCtrl.dispose();
    _ratingCtrl.dispose();
    _reviewsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _webImage = bytes;
          _pickedImage = image;
          _isUsingLink = false;
        });
      } else {
        setState(() {
          _pickedImage = image;
          _isUsingLink = false;
        });
      }
    }
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      String imageUrl = _imageUrlCtrl.text.trim();
      
      // If a new image was picked, upload it
      if (!_isUsingLink && _pickedImage != null) {
        if (kIsWeb) {
          imageUrl = await ref.read(firestoreServiceProvider).uploadImage(_webImage);
        } else {
          imageUrl = await ref.read(firestoreServiceProvider).uploadImage(File(_pickedImage!.path));
        }
      }

      final updatedProduct = ProductModel(
        id: widget.product.id,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: double.tryParse(_priceCtrl.text) ?? 0.0,
        imageUrl: imageUrl,
        tag: _selectedTag,
        calories: int.tryParse(_caloriesCtrl.text) ?? 0,
        protein: _proteinCtrl.text.trim(),
        rating: double.tryParse(_ratingCtrl.text) ?? 0.0,
        reviews: int.tryParse(_reviewsCtrl.text) ?? 0,
        createdAt: widget.product.createdAt,
      );
      
      await ref.read(firestoreServiceProvider).updateProduct(updatedProduct);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mahsulot muvaffaqiyatli yangilandi!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xatolik: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.cardBg,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Mahsulotni tahrirlash", style: inter.copyWith(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Toggle between Upload and Link
                Row(
                  children: [
                    Expanded(
                      child: _buildToggleButton(
                        title: "Yangi rasm yuklash",
                        isSelected: !_isUsingLink,
                        onTap: () => setState(() => _isUsingLink = false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildToggleButton(
                        title: "Link orqali / Joriy",
                        isSelected: _isUsingLink,
                        onTap: () => setState(() => _isUsingLink = true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (!_isUsingLink)
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: AppColors.textLight.withOpacity(0.3)),
                          image: _pickedImage != null
                            ? DecorationImage(
                                image: kIsWeb 
                                  ? MemoryImage(_webImage!) 
                                  : FileImage(File(_pickedImage!.path)) as ImageProvider,
                                fit: BoxFit.cover,
                              )
                            : null,
                        ),
                        child: _pickedImage == null 
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, color: AppColors.textLight, size: 30),
                                SizedBox(height: 8),
                                Text("Yangi rasm", style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                              ],
                            )
                          : null,
                      ),
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Rasm URL manzili"),
                      _buildField(controller: _imageUrlCtrl, hint: "https://example.com/image.jpg"),
                    ],
                  ),
                
                const SizedBox(height: 10),

                _buildLabel("Taom nomi"),
                _buildField(controller: _nameCtrl, hint: "Masalan: Qarsildoq Burger"),
                
                _buildLabel("Ta'rifi"),
                _buildField(controller: _descCtrl, hint: "Tarkibi...", maxLines: 3),
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Narxi (\$)"),
                          _buildField(controller: _priceCtrl, hint: "12.50", isNumber: true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Tag"),
                          Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedTag,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textLight),
                                items: _tags.map((t) => DropdownMenuItem(value: t, child: Text(t, style: inter.copyWith(color: AppColors.textDark)))).toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() => _selectedTag = v);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Kaloriya"),
                          _buildField(controller: _caloriesCtrl, hint: "450", isNumber: true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Protein"),
                          _buildField(controller: _proteinCtrl, hint: "25g"),
                        ],
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Rating"),
                          _buildField(controller: _ratingCtrl, hint: "4.8", isNumber: true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Reviews"),
                          _buildField(controller: _reviewsCtrl, hint: "100", isNumber: true),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text("Yangilash", style: inter.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton({required String title, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? null : Border.all(color: AppColors.textLight.withOpacity(0.2)),
        ),
        child: Text(
          title,
          style: inter.copyWith(
            color: isSelected ? Colors.white : AppColors.textLight,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(text, style: inter.copyWith(fontWeight: FontWeight.w600, color: AppColors.textDark, fontSize: 13)),
    );
  }

  Widget _buildField({required TextEditingController controller, required String hint, int maxLines = 1, bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      validator: (v) => (v == null || v.isEmpty) ? 'Majburiy maydon' : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: inter.copyWith(color: AppColors.textLight, fontSize: 13),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }
}
