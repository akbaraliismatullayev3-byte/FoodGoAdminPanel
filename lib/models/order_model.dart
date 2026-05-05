
class OrderModel {
  final String id;
  final String userId;
  final String userName;
  final double totalAmount;
  final String status;
  final String date;
  final int itemsCount;

  OrderModel({
    required this.id, required this.userId, required this.userName, 
    required this.totalAmount, required this.status, required this.date, required this.itemsCount
  });

  factory OrderModel.fromMap(Map<String, dynamic> data, String id) {
    List items = data['items'] ?? [];
    return OrderModel(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['deliveryAddress']?['fullName'] ?? 'Unknown',
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'Pending',
      date: data['date'] ?? '',
      itemsCount: items.length,
    );
  }
}
