// lib/src/features/problems/data/problem_model.dart

class Problem {
  final String id;
  final String title;
  final String description;
  final String category;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final String reporterId;
  final String status;
  final List<String> images;

  Problem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.reporterId,
    this.status = 'pending',
    this.images = const [],
  });

  Problem copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    String? reporterId,
    String? status,
    List<String>? images,
  }) {
    return Problem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      reporterId: reporterId ?? this.reporterId,
      status: status ?? this.status,
      images: images ?? this.images,
    );
  }
}
