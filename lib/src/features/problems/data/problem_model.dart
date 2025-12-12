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

  factory Problem.fromMap(Map<String, dynamic> map) {
    return Problem(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
      reporterId: map['user_id'] as String,
      status: map['status'] as String? ?? 'pending',
      images: List<String>.from(map['images'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
      'user_id': reporterId,
      'status': status,
      'images': images,
    };
  }
}
