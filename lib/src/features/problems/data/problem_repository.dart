// lib/src/features/problems/data/problem_repository.dart

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../../../core/services/storage_service.dart';
import 'problem_model.dart';

class ProblemRepository {
  final SupabaseClient supabase;

  ProblemRepository({SupabaseClient? client})
      : supabase = client ?? SupabaseService.client;

  // ============================================================
  // 🟢 CREATE PROBLEM + IMAGES (NOUVEAU – N'ÉCRASE RIEN)
  // ============================================================

  Future<void> createProblemWithImages({
    required String title,
    required String description,
    required String categoryId,
    required String statutId,
    required String userId,
    double? latitude,
    double? longitude,
    required List<File> images,
  }) async {
    // 1️⃣ Create problem
    final problem = await supabase
        .from('problemes')
        .insert({
      'titre': title,
      'description': description,
      'id_categorie': categoryId,
      'id_statut': statutId,
      'id_utilisateur_affecte': userId,
      'latitude': latitude,
      'longitude': longitude,
    })
        .select()
        .single();

    final String problemId = problem['id'];

    // 2️⃣ Upload images (Storage)
    if (images.isNotEmpty) {
      final List<String> urls = [];

      for (int i = 0; i < images.length; i++) {
        final url = await StorageService.uploadProblemImage(
          file: images[i],
          userId: userId,
          problemId: problemId,
          index: i,
        );
        urls.add(url);
      }

      // 3️⃣ Create media_url
      final media = await supabase
          .from('media_url')
          .insert({
        'url': urls.first, // image principale
        'type': 'image',
      })
          .select()
          .single();

      // 4️⃣ Link image to problem
      await supabase
          .from('problemes')
          .update({'id_media_url': media['id']})
          .eq('id', problemId);
    }
  }

  // ============================================================
  // 📄 FETCH PAGE (OBLIGATOIRE – utilisé partout)
  // ============================================================

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

  // ============================================================
  // 🔍 FETCH BY ID
  // ============================================================

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

  // ============================================================
  // 👤 MES SIGNALEMENTS
  // ============================================================

  Future<List<Problem>> fetchByReporter(String userId) async {
    final res = await supabase
        .from('problemes')
        .select('*, statut:statut_pb(*), media_url(*)')
        .eq('id_utilisateur_affecte', userId)
        .order('create_at', ascending: false);

    return _mapList(res);
  }

  // ============================================================
  // ➕ INSERT SIMPLE (compatibilité ancien code)
  // ============================================================

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

  // ============================================================
  // 🧠 MAPPERS
  // ============================================================

  List<Problem> _mapList(dynamic res) {
    if (res is! List) return [];

    return res.map<Problem>((row) {
      final map = Map<String, dynamic>.from(row);

      if (map['media_url'] != null && map['media_url']['url'] != null) {
        map['images'] = [map['media_url']['url']];
      }

      if (map['statut'] != null && map['statut']['code'] != null) {
        map['status'] = map['statut']['code'];
      }

      return Problem.fromMap(map);
    }).toList();
  }

  Problem _mapOne(Map<String, dynamic> row) {
    final map = Map<String, dynamic>.from(row);

    if (map['media_url'] != null && map['media_url']['url'] != null) {
      map['images'] = [map['media_url']['url']];
    }

    if (map['statut'] != null && map['statut']['code'] != null) {
      map['status'] = map['statut']['code'];
    }

    return Problem.fromMap(map);
  }
}
