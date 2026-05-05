
class CouponModel {
  final String id;
  final String code;
  final double discountPercent;
  final double maxDiscount;
  final DateTime expiryDate;

  CouponModel({
    required this.id, 
    required this.code, 
    required this.discountPercent, 
    required this.maxDiscount, 
    required this.expiryDate
  });

  factory CouponModel.fromMap(Map<String, dynamic> data, String id) {
    return CouponModel(
      id: id,
      code: data['code'] ?? '',
      discountPercent: (data['discountPercent'] ?? 0.0).toDouble(),
      maxDiscount: (data['maxDiscount'] ?? 0.0).toDouble(),
      expiryDate: data['expiryDate'] != null ? DateTime.parse(data['expiryDate']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'discountPercent': discountPercent,
      'maxDiscount': maxDiscount,
      'expiryDate': expiryDate.toIso8601String(),
    };
  }
}
