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

  /// Create a Problem from a Supabase / Postgres row (Map)
  /// This is defensive: it checks multiple field names because your DB
  /// schema had small variations (create_at / date_creation, titre / title, etc.)
  factory Problem.fromMap(Map<String, dynamic> m) {
    // helpers to get field values with fallback keys
    String getString(List<String> keys, [String fallback = '']) {
      for (final k in keys) {
        if (m.containsKey(k) && m[k] != null) return m[k].toString();
      }
      return fallback;
    }

    double getDouble(List<String> keys, [double fallback = 0.0]) {
      for (final k in keys) {
        if (m.containsKey(k) && m[k] != null) {
          final v = m[k];
          if (v is num) return v.toDouble();
          final parsed = double.tryParse(v.toString());
          if (parsed != null) return parsed;
        }
      }
      return fallback;
    }

    DateTime getDate(List<String> keys) {
      for (final k in keys) {
        if (m.containsKey(k) && m[k] != null) {
          final v = m[k];
          if (v is DateTime) return v;
          try {
            return DateTime.parse(v.toString());
          } catch (_) {}
        }
      }
      return DateTime.now();
    }

    // images may be stored elsewhere — here we try to read a JSON/text field,
    // fallback to empty list.
    List<String> getImages() {
      if (m.containsKey('images') && m['images'] != null) {
        final im = m['images'];
        if (im is List) return im.map((e) => e.toString()).toList();
        if (im is String) {
          // maybe comma separated or json array
          try {
            // try json decode
            final decoded = im;
          } catch (_) {}
          return im.split(',').map((e) => e.trim()).where((s) => s.isNotEmpty).toList();
        }
      }
      // Some schemas use id_media_url; ignore for now
      return <String>[];
    }

    final id = getString(['id', 'uuid'], '');
    final title = getString(['titre', 'title'], 'No title');
    final description = getString(['description', 'desc'], '');
    final category = getString(['id_categorie', 'category', 'categorie', 'cat'], 'uncategorized');
    final latitude = getDouble(['latitude', 'lat'], 0.0);
    final longitude = getDouble(['longitude', 'lng', 'lon'], 0.0);
    final createdAt = getDate(['create_at', 'created_at', 'date_creation', 'createdAt']);
    final reporterId = getString(['id_utilisateur_signale', 'reporter_id', 'id_utilisateur', 'reported_by'], '');
    final status = (() {
      if (m['statut'] is Map && m['statut']['code'] != null) {
        return m['statut']['code'].toString();
      }
      return 'soumis'; // fallback
    })();

    return Problem(
      id: id,
      title: title,
      description: description,
      category: category,
      latitude: latitude,
      longitude: longitude,
      createdAt: createdAt,
      reporterId: reporterId,
      status: status,
      images: getImages(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': title,
      'description': description,
      'id_categorie': category,
      'latitude': latitude,
      'longitude': longitude,
      'create_at': createdAt.toIso8601String(),
      'id_utilisateur_signale': reporterId,
      'id_statut': status,
    };
  }
}
