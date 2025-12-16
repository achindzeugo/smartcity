// lib/src/features/problems/data/problem_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import 'problem_model.dart';

class ProblemRepository {
  final SupabaseClient supabase;

  ProblemRepository({SupabaseClient? client})
      : supabase = client ?? SupabaseService.client;

  // ================== PAGINATION ==================

  Future<List<Problem>> fetchPage({
    required int pageIndex,
    required int pageSize,
  }) async {
    final from = pageIndex * pageSize;
    final to = from + pageSize - 1;

    final res = await supabase
        .from('problemes')
        .select('*, statut:statut_pb(*), media_url(*)')
        .order('create_at', ascending: false)
        .range(from, to);

    return _mapList(res);
  }

  // ================== BY ID ==================

  Future<Problem> fetchById(String id) async {
    final res = await supabase
        .from('problemes')
        .select('*, statut:statut_pb(*), media_url(*)')
        .eq('id', id)
        .maybeSingle();

    if (res == null) {
      throw Exception('Problème introuvable');
    }

    return _mapOne(res);
  }

  // ================== MES SIGNALEMENTS (FIX FINAL) ==================

  Future<List<Problem>> fetchByReporter(String userId) async {
    final res = await supabase
        .from('problemes')
        .select('*, statut:statut_pb(*), media_url(*)')
        .eq('id_utilisateur_affecte', userId) // ✅ SEULE COLONNE EXISTANTE
        .order('create_at', ascending: false);

    return _mapList(res);
  }

  // ================== INSERT ==================

  Future<Problem> add(Problem p) async {
    final res = await supabase
        .from('problemes')
        .insert(p.toMap())
        .select('*, statut:statut_pb(*), media_url(*)')
        .maybeSingle();

    if (res == null) {
      throw Exception('Insertion échouée');
    }

    return _mapOne(res);
  }

  // ================== MAPPERS ==================

  List<Problem> _mapList(dynamic res) {
    if (res is! List) return [];

    return res.map<Problem>((e) {
      final row = Map<String, dynamic>.from(e);

      // image
      if (row['media_url'] != null && row['media_url']['url'] != null) {
        row['images'] = [row['media_url']['url']];
      }

      // statut
      if (row['statut'] != null && row['statut']['code'] != null) {
        row['status'] = row['statut']['code'];
      }

      return Problem.fromMap(row);
    }).toList();
  }

  Problem _mapOne(Map<String, dynamic> row) {
    if (row['media_url'] != null && row['media_url']['url'] != null) {
      row['images'] = [row['media_url']['url']];
    }

    if (row['statut'] != null && row['statut']['code'] != null) {
      row['status'] = row['statut']['code'];
    }

    return Problem.fromMap(row);
  }
}
