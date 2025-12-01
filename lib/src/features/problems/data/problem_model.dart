class Problem {
  final String id;
  final String title;
  final String description;
  final String category;

  final double latitude;
  final double longitude;

  final DateTime createdAt;

  // 🔥 NEW fields
  final String reporterId;   // l’utilisateur qui a signalé
  final String status;       // pending | treated
  final List<String> images; // liste d’images (paths ou URLs)

  Problem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.createdAt,

    // NEW
    required this.reporterId,
    required this.status,
    required this.images,
  });

  // OPTIONAL : toJson si tu veux sauvegarder plus tard
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'latitude': latitude,
    'longitude': longitude,
    'createdAt': createdAt.toIso8601String(),
    'reporterId': reporterId,
    'status': status,
    'images': images,
  };
}
