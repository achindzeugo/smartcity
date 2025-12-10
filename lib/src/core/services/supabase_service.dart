// lib/src/core/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  //  l'URL et la clé anonyme du projet Supabase
  // (dashboard Supabase: Project Settings > API)
  static const String _supabaseUrl = 'https://bihfuxxhybrbgghqpexe.supabase.co';
  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJpaGZ1eHhoeWJyYmdnaHFwZXhlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMxMjM0NDYsImV4cCI6MjA3ODY5OTQ0Nn0.OTQVqzpvxL3goXe0a8P6W8NgvxQoWP2X1TMBFppA3O4';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> init() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }
}
