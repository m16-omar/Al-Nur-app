class ProductReview {
  final String id;
  final String productId;
  final String userName;
  final String userInitial;
  final double rating;
  final String title;
  final String comment;
  final String date;
  final List<String> tags;
  final bool isVerifiedBuyer;

  const ProductReview({
    required this.id,
    required this.productId,
    required this.userName,
    required this.userInitial,
    required this.rating,
    required this.title,
    required this.comment,
    required this.date,
    this.tags = const [],
    this.isVerifiedBuyer = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'userName': userName,
        'userInitial': userInitial,
        'rating': rating,
        'title': title,
        'comment': comment,
        'date': date,
        'tags': tags,
        'isVerifiedBuyer': isVerifiedBuyer,
      };

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? 'Anonymous Buyer',
      userInitial: json['userInitial']?.toString() ??
          ((json['userName']?.toString().isNotEmpty == true)
              ? json['userName'].toString()[0].toUpperCase()
              : 'A'),
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      title: json['title']?.toString() ?? '',
      comment: json['comment']?.toString() ?? '',
      date: json['date']?.toString() ?? 'Recent',
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      isVerifiedBuyer: json['isVerifiedBuyer'] as bool? ?? true,
    );
  }
}
