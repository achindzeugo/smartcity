// lib/src/core/services/storage_service.dart

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class StorageService {
  static final SupabaseClient _client = SupabaseService.client;

  static Future<String> uploadProblemImage({
    required File file,
    required String userId,
    required String problemId,
    required int index,
  }) async {
    final path = '$userId/$problemId/image_${index + 1}.jpg';

    await _client.storage.from('problems').upload(
      path,
      file,
      fileOptions: const FileOptions(
        upsert: true,
        contentType: 'image/jpeg',
      ),
    );

    return _client.storage.from('problems').getPublicUrl(path);
  }
}
