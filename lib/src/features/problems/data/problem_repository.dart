import 'problem_model.dart';

class ProblemRepository {
  // Mock list
  final List<Problem> _items = [
    Problem(
      id: 'p1',
      title: 'Inondation et flaque d\'eau',
      description: 'Rue Ndjo-Ndjo, Douala — forte inondation après pluie',
      category: 'insalubrite',
      latitude: 4.0483,
      longitude: 9.7066,
      createdAt: DateTime(2025, 5, 24),

      reporterId: 'user1',
      status: 'pending',
      images: ['assets/images/onboarding1.png'],
    ),

    Problem(
      id: 'p2',
      title: 'Nid de poule avenue principale',
      description: 'Grosse gêne pour les véhicules',
      category: 'nid_de_poule',
      latitude: 4.0500,
      longitude: 9.7080,
      createdAt: DateTime(2025, 6, 1),

      // 🔥 NEW
      reporterId: 'user1',
      status: 'treated',
      images: ['assets/images/onboarding2.jpg'],
    ),

    Problem(
      id: 'p3',
      title: 'Lampadaire cassé',
      description: 'Quartier sombre la nuit',
      category: 'lampadaire',
      latitude: 4.0475,
      longitude: 9.7030,
      createdAt: DateTime(2025, 4, 12),

      // 🔥 NEW
      reporterId: 'user2',
      status: 'pending',
      images: ['assets/images/onboarding3.jpg'],
    ),
  ];

  // ===============================
  // BASIC CRUD
  // ===============================

  List<Problem> getAll() => List.unmodifiable(_items);

  Problem findById(String id) =>
      _items.firstWhere((p) => p.id == id, orElse: () => throw Exception('Not found'));

  Problem? getLatest() {
    if (_items.isEmpty) return null;
    _items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return _items.first;
  }

  List<Problem> filterByCategory(String? category) {
    if (category == null || category.isEmpty) return getAll();
    return _items.where((p) => p.category == category).toList();
  }

  // ===============================
  // 🔥 NEW FOR "MES SIGNALEMENTS"
  // ===============================

  /// Retourne les problèmes rapportés par un utilisateur
  List<Problem> getByReporter(String reporterId) {
    return _items.where((p) => p.reporterId == reporterId).toList();
  }

  /// Retourne les problèmes avec un statut donné
  List<Problem> getByStatus(String status) {
    return _items.where((p) => p.status.toLowerCase() == status.toLowerCase()).toList();
  }
}
