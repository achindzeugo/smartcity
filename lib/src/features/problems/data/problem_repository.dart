// lib/src/features/problems/data/problem_repository.dart

import 'problem_model.dart';

class ProblemRepository {
  // Mock list (initial seed)
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
      reporterId: 'user2',
      status: 'pending',
      images: ['assets/images/onboarding3.jpg'],
    ),
  ];

  // Return immutable copy
  List<Problem> getAll() => List.unmodifiable(_items);

  /// Add a new problem to the repo
  void add(Problem p) {
    _items.add(p);
  }

  /// Remove by id (returns true if removed)
  bool removeById(String id) {
    final initialLength = _items.length;
    _items.removeWhere((p) => p.id == id);
    return _items.length < initialLength;
  }

  /// Find by id (throws if not found) - keep this behaviour if you prefer throw
  Problem findById(String id) =>
      _items.firstWhere((p) => p.id == id, orElse: () => throw Exception('Not found'));

  /// Safe find -> returns null if not found
  Problem? findByIdOrNull(String id) {
    try {
      return findById(id);
    } catch (_) {
      return null;
    }
  }

  /// Get latest (by createdAt) without mutating original list
  Problem? getLatest() {
    if (_items.isEmpty) return null;
    final sorted = List<Problem>.from(_items)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.first;
  }

  /// Filter by category
  List<Problem> filterByCategory(String? category) {
    if (category == null || category.isEmpty) return getAll();
    return _items.where((p) => p.category == category).toList();
  }

  /// Return problems reported by user
  List<Problem> getByReporter(String reporterId) {
    return _items.where((p) => p.reporterId == reporterId).toList();
  }

  /// Return problems by status (case-insensitive)
  List<Problem> getByStatus(String status) {
    return _items.where((p) => p.status.toLowerCase() == status.toLowerCase()).toList();
  }

  /// Update an existing problem by id (full replacement)
  /// Throws if not found
  void update(Problem newProblem) {
    final idx = _items.indexWhere((p) => p.id == newProblem.id);
    if (idx == -1) throw Exception('Not found');
    _items[idx] = newProblem;
  }

  /// Convenience: update only the status
  void updateStatus(String id, String newStatus) {
    final idx = _items.indexWhere((p) => p.id == id);
    if (idx == -1) throw Exception('Not found');
    final p = _items[idx];
    _items[idx] = p.copyWith(status: newStatus);
  }

  /// Simple helper to generate a new id (non-persistent; for demo only)
  String nextId() {
    final existing = _items.map((e) {
      final s = e.id.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(s) ?? 0;
    }).toList();
    final max = existing.isEmpty ? 0 : existing.reduce((a, b) => a > b ? a : b);
    return 'p${max + 1}';
  }
}
