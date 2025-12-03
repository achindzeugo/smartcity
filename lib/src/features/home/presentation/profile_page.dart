// lib/src/features/home/presentation/profile_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  bool _saving = false;

  // Données utilisateur (mock)
  String _name = 'Zeugo Keng Achind';
  String _email = 'achind.zeugo@gmail.com';
  String _phone = '+237690000000';

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: _name);
    _emailCtrl = TextEditingController(text: _email);
    _phoneCtrl = TextEditingController(text: _phone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Annuler les changements → revenir aux valeurs sauvegardées
        _nameCtrl.text = _name;
        _emailCtrl.text = _email;
        _phoneCtrl.text = _phone;
      }
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    // Ici tu appelleras ton backend / service
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _name = _nameCtrl.text.trim();
      _email = _emailCtrl.text.trim();
      _phone = _phoneCtrl.text.trim();
      _saving = false;
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color green = Colors.green.shade800;
    final Color bg = const Color(0xFFF5F5F7);

    return Scaffold(
      backgroundColor: bg,

      // AppBar collée au haut vert
      appBar: AppBar(
        backgroundColor: green,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.close_rounded : Icons.edit_rounded,
              color: Colors.white,
            ),
            onPressed: _toggleEditing,
          ),
        ],
      ),

      // Bouton Enregistrer seulement en mode édition
      bottomNavigationBar: _isEditing
          ? SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _saving
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : Text(
              'Enregistrer',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      )
          : null,

      body: Stack(
        children: [
          // Bande verte en haut (comme sur le design)
          Container(
            height: 220,
            color: green,
          ),

          // Contenu scrollable par-dessus
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Column(
              children: [
                // Avatar + nom centré dans la partie verte
                SizedBox(
                  height: 130,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 42,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 38,
                              backgroundColor: Colors.grey.shade300,
                              child: const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 2,
                            bottom: 4,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: green,
                                child: const Icon(
                                  Icons.edit,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _name,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ✅ Grosse Card blanche au milieu (comme sur ton UI)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Nom complet'),
                        _buildField(
                          controller: _nameCtrl,
                          enabled: _isEditing,
                          hint: 'Votre nom',
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Adresse e-mail'),
                        _buildField(
                          controller: _emailCtrl,
                          enabled: _isEditing,
                          keyboardType: TextInputType.emailAddress,
                          hint: 'email@example.com',
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Numéro de téléphone'),
                        _buildField(
                          controller: _phoneCtrl,
                          enabled: _isEditing,
                          keyboardType: TextInputType.phone,
                          hint: '+237 …',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Petit label au-dessus des champs
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// TextField stylé à l’intérieur de la carte
  Widget _buildField({
    required TextEditingController controller,
    required bool enabled,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFF7F7F9),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }
}
