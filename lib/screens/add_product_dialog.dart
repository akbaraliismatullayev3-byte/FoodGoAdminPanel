import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../constants.dart';
import '../models/product_model.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';

class AddProductDialog extends ConsumerStatefulWidget {
  const AddProductDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends ConsumerState<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  final _ratingCtrl = TextEditingController(text: "4.5");
  final _reviewsCtrl = TextEditingController(text: "10");
  
  XFile? _pickedImage;
  Uint8List? _webImage;
  bool _isUsingLink = false;
  String _selectedTag = 'Burgers';
  final List<String> _tags = ['Burgers', 'Pizza', 'Sushi', 'Dessert', 'Drinks', 'Salad', 'SIGNATURE'];
  bool _isLoading = false;

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

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_isUsingLink && _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Iltimos, rasm yuklang yoki link kiriting!'), backgroundColor: AppColors.danger),
      );
      return;
    }

    if (_isUsingLink && _imageUrlCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Iltimos, rasm linkini kiriting!'), backgroundColor: AppColors.danger),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // 1. Check Admin Role (Temporarily disabled for development)
      /*
      final userModel = await ref.read(userModelProvider.future);
      if (userModel == null || userModel.role != 'admin') {
        throw 'Ruxsat berilmagan: Faqat adminlar mahsulot qo\'sha oladi.';
      }
      */

      // 2. Determine Image URL
      String imageUrl = '';
      if (_isUsingLink) {
        imageUrl = _imageUrlCtrl.text.trim();
      } else {
        if (kIsWeb) {
          imageUrl = await ref.read(firestoreServiceProvider).uploadImage(_webImage);
        } else {
          imageUrl = await ref.read(firestoreServiceProvider).uploadImage(File(_pickedImage!.path));
        }
      }

      // 3. Prepare Product Data
      final product = ProductModel(
        id: '', // Firestore will generate an ID
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: double.tryParse(_priceCtrl.text) ?? 0.0,
        imageUrl: imageUrl,
        tag: _selectedTag,
        calories: int.tryParse(_caloriesCtrl.text) ?? 0,
        protein: _proteinCtrl.text.trim(),
        rating: double.tryParse(_ratingCtrl.text) ?? 0.0,
        reviews: int.tryParse(_reviewsCtrl.text) ?? 0,
        createdAt: DateTime.now(),
      );
      
      // 4. Save to Firestore
      await ref.read(firestoreServiceProvider).addProduct(product);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mahsulot muvaffaqiyatli qo\'shildi!'), backgroundColor: AppColors.success),
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
                    Text("Yangi mahsulot", style: inter.copyWith(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 10),
                
                // Toggle between Upload and Link
                Row(
                  children: [
                    Expanded(
                      child: _buildToggleButton(
                        title: "Rasm yuklash",
                        isSelected: !_isUsingLink,
                        onTap: () => setState(() => _isUsingLink = false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildToggleButton(
                        title: "Link orqali",
                        isSelected: _isUsingLink,
                        onTap: () => setState(() => _isUsingLink = true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (!_isUsingLink)
                  // Image Picker
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
                                Text("Rasm tanlang", style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                              ],
                            )
                          : null,
                      ),
                    ),
                  )
                else
                  // URL Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Rasm URL manzili"),
                      _buildField(controller: _imageUrlCtrl, hint: "https://example.com/image.jpg"),
                    ],
                  ),
                
                const SizedBox(height: 10),

                // Name
                _buildLabel("Taom nomi"),
                _buildField(controller: _nameCtrl, hint: "Masalan: Qarsildoq Burger"),
                
                // Description
                _buildLabel("Ta'rifi"),
                _buildField(controller: _descCtrl, hint: "Tarkibi, mazasi haqida...", maxLines: 3),
                
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
                          _buildLabel("Kaloriya (kkal)"),
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
                          _buildLabel("Reviews soni"),
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
                    onPressed: _isLoading ? null : _saveProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text("Saqlash", style: inter.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildField({
    required TextEditingController controller, 
    required String hint, 
    int maxLines = 1,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      validator: (v) {
        if (v == null || v.isEmpty) {
          // Special case for image URL: if we are using link mode, it's mandatory
          if (controller == _imageUrlCtrl && _isUsingLink) return 'Rasm linki majburiy';
          if (controller != _imageUrlCtrl) return 'Majburiy maydon';
        }
        return null;
      },
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
