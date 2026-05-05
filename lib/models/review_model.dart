
class ReviewModel {
  final String id;
  final String productId;
  final String userName;
  final String comment;
  final double rating;
  final String date;

  ReviewModel({
    required this.id, 
    required this.productId, 
    required this.userName, 
    required this.comment, 
    required this.rating, 
    required this.date
  });

  factory ReviewModel.fromMap(Map<String, dynamic> data, String id, String productId) {
    return ReviewModel(
      id: id,
      productId: productId,
      userName: data['userName'] ?? 'Anonymous',
      comment: data['comment'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      date: data['date'] ?? '',
    );
  }
}
