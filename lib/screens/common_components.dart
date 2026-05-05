import 'package:flutter/material.dart';
import '../constants.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderScreen({Key? key, required this.title, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppColors.textLight.withOpacity(0.3)),
          const SizedBox(height: 20),
          Text(title, style: inter.copyWith(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textLight)),
          const SizedBox(height: 10),
          Text("Tez orada ishga tushadi (Coming Soon)", style: inter.copyWith(color: AppColors.textLight)),
        ],
      ),
    );
  }
}

BoxDecoration cardDecoration() {
  return BoxDecoration(
    color: AppColors.cardBg,
    borderRadius: BorderRadius.circular(15),
    border: Border.all(color: Colors.grey.withOpacity(0.05)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.03),
        blurRadius: 15,
        offset: const Offset(0, 5),
      ),
    ],
  );
}
