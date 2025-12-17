// lib/src/features/problems/data/problem_repository.dart
import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import 'problem_model.dart';

class ProblemRepository {
  final SupabaseClient _client = SupabaseService.client;

  // Convertit une ligne Supabase en objet Problem
  Problem _fromRow(Map<String, dynamic> row) {
    final categoryData = row['categorie_pb'];
    String categoryLabel = (categoryData is Map && categoryData.containsKey('libelle'))
        ? categoryData['libelle']
        : 'Inconnue';

    return Problem(
      id: row['id'] as String,
      title: row['titre'] as String,
      description: row['description'] as String,
      category: categoryLabel,
      latitude: (row['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (row['longitude'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(row['create_at'] as String),
      reporterId: row['id_utilisateur_affecte'] ?? 'system',
      status: row['statut_pb']?['code'] ?? 'soumis',
      images: (row['media_url']?['url'] != null) ? [row['media_url']['url']] : [],
    );
  }

  // ============ PUBLIC API ==============

  /// Récupère une page de problèmes (ex: 10 derniers)
  Future<List<Problem>> fetchPage({required int pageIndex, required int pageSize}) async {
    try {
      final start = pageIndex * pageSize;
      final end = start + pageSize - 1;

      final response = await _client
          .from('problemes')
          .select('*, categorie_pb(libelle), statut_pb(code), media_url(url)')
          .order('create_at', ascending: false)
          .range(start, end);

      return response.map<Problem>(_fromRow).toList();
    } catch (e) {
      log('Erreur fetchPage: $e');
      throw Exception("Erreur lors de la récupération des problèmes");
    }
  }

  /// Récupère un problème par son ID avec les détails (catégorie, statut)
  Future<Problem> fetchById(String id) async {
    try {
      final response = await _client
          .from('problemes')
          .select('*, categorie_pb(libelle), statut_pb(code), media_url(url)')
          .eq('id', id)
          .single();

      return _fromRow(response);
    } catch (e) {
      log('Erreur fetchById: $e');
      throw Exception("Problème non trouvé");
    }
  }

  /// Récupère les problèmes signalés par un utilisateur spécifique
  Future<List<Problem>> fetchByReporter(String userId) async {
    try {
      final response = await _client
          .from('problemes')
          .select('*, categorie_pb(libelle), statut_pb(code), media_url(url)')
          .eq('id_utilisateur_affecte', userId)
          .order('create_at', ascending: false);

      return response.map<Problem>(_fromRow).toList();
    } catch (e) {
      log('Erreur fetchByReporter: $e');
      throw Exception("Erreur lors de la récupération des signalements");
    }
  }

  /// Ajoute un nouveau problème
  Future<void> add(Problem p) async {
    try {
      await _client.from('problemes').insert({
        'titre': p.title,
        'description': p.description,
        'id_categorie': p.category, // Côté client, on envoie l'ID
        'latitude': p.latitude,
        'longitude': p.longitude,
        'id_utilisateur_affecte': p.reporterId,
      });
    } catch (e) {
      log('Erreur add problem: $e');
      throw Exception("Erreur lors de l'ajout du problème");
    }
  }
}
