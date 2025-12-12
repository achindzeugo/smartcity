class UserProfile {
  final String id;
  final String email;
  final String nom;
  final String role;
  final String? avatarUrl;
  final DateTime? lastLogin;
  final DateTime dateCreation;
  final String? departementId;
  final Map<String, dynamic>? departement;
  final String? problemeId;

  UserProfile({
    required this.id,
    required this.email,
    required this.nom,
    required this.role,
    this.avatarUrl,
    this.lastLogin,
    required this.dateCreation,
    this.departementId,
    this.departement,
    this.problemeId,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      nom: json['nom'] as String,
      role: json['role'] as String,
      avatarUrl: json['avatar_url'] as String?,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
      dateCreation: DateTime.parse(json['date_creation'] as String),
      departementId: json['id_departement'] as String?,
      departement: json['departement'] as Map<String, dynamic>?,
      problemeId: json['id_probleme'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nom': nom,
      'role': role,
      'avatar_url': avatarUrl,
      'last_login': lastLogin?.toIso8601String(),
      'date_creation': dateCreation.toIso8601String(),
      'id_departement': departementId,
      'departement': departement,
      'id_probleme': problemeId,
    };
  }

  String get displayName => nom.isNotEmpty ? nom : email.split('@')[0];
  bool get isAdmin => role == 'admin';
  bool get isAgentMunicipal => role == 'agent_municipal';
  bool get isClient => role == 'client';
  String? get departementName => departement?['nom'] as String?;
}