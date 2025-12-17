import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:smartcity/src/core/services/session_service.dart';
import 'package:smartcity/src/core/services/supabase_service.dart';

class NewProblemPage extends StatefulWidget {
  const NewProblemPage({super.key});

  @override
  State<NewProblemPage> createState() => _NewProblemPageState();
}

class _NewProblemPageState extends State<NewProblemPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String? _categoryCode;
  double? _latitude;
  double? _longitude;

  bool _submitting = false;
  bool _fetchingLocation = false;

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];

  final SupabaseClient _client = SupabaseService.client;

  /// 🔹 Mapping CATEGORIE (code UI → UUID DB)
  static const Map<String, String> _categoryMap = {
    'insalubrite': '3b865f4c-b9ad-463d-a80e-8f229ece1667',
    'nid_de_poule': '7a2ac70d-7b94-43f1-be68-b820a743830d',
    'lampadaire': '9025d473-2aaf-4ba9-8894-1ee2da295883',
  };

  /// 🔹 Statut "soumis"
  static const String _statutSoumisId =
      'c44a270d-69c1-494c-925d-f9db778664dd';

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // 📍 LOCALISATION
  // ─────────────────────────────────────────────

  Future<void> _fetchLocation() async {
    setState(() => _fetchingLocation = true);

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw 'Localisation désactivée';
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw 'Permission refusée';
      }

      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      setState(() => _fetchingLocation = false);
    }
  }

  // ─────────────────────────────────────────────
  // 🖼 IMAGES
  // ─────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(source: source);
    if (file != null) {
      setState(() => _images.add(file));
    }
  }

  Future<void> _selectImageSource() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ajouter une image'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text('Caméra'),
            onPressed: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          TextButton.icon(
            icon: const Icon(Icons.photo),
            label: const Text('Galerie'),
            onPressed: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
        ],
      ),
    );

    if (source != null) _pickImage(source);
  }

  // ─────────────────────────────────────────────
  // 🚀 SUBMIT + UPLOAD IMAGES
  // ─────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = SessionService.currentUser;
    if (user == null) return;

    setState(() => _submitting = true);

    try {
      // 1️⃣ CREATE PROBLEM
      final problem = await _client.from('problemes').insert({
        'titre': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'latitude': _latitude,
        'longitude': _longitude,
        'id_statut': _statutSoumisId,
        'id_categorie': _categoryMap[_categoryCode],
        'id_utilisateur_affecte': user['id'],
      }).select().single();

      final String problemId = problem['id'];

      // 2️⃣ UPLOAD IMAGES
      String? imageUrl;

      if (_images.isNotEmpty) {
        final file = File(_images.first.path);
        final path =
            '${user['id']}/$problemId/image_1.jpg';

        await _client.storage.from('problems').upload(
          path,
          file,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );

        imageUrl =
            _client.storage.from('problems').getPublicUrl(path);

        // 3️⃣ CREATE MEDIA_URL
        final media = await _client.from('media_url').insert({
          'url': imageUrl,
          'type': 'image',
        }).select().single();

        // 4️⃣ LINK TO PROBLEM
        await _client
            .from('problemes')
            .update({'id_media_url': media['id']})
            .eq('id', problemId);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signalement envoyé')),
      );

      context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      setState(() => _submitting = false);
    }
  }

  // ─────────────────────────────────────────────
  // 🧱 UI
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nouveau signalement',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: _submitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: _submitting
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Soumettre',
              style: TextStyle(color: Colors.white)),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            GestureDetector(
              onTap: _selectImageSource,
              child: DottedImagePickerBox(images: _images),
            ),

            _label('Titre'),
            _input(_titleCtrl, 'Ex: Égout bouché'),

            _label('Description'),
            _input(_descCtrl, 'Décrivez le problème', maxLines: 4),

            _label('Catégorie'),
            DropdownButtonFormField<String>(
              value: _categoryCode,
              items: const [
                DropdownMenuItem(
                    value: 'insalubrite', child: Text('Insalubrité')),
                DropdownMenuItem(
                    value: 'nid_de_poule', child: Text('Nid de poule')),
                DropdownMenuItem(
                    value: 'lampadaire', child: Text('Lampadaire')),
              ],
              onChanged: (v) => setState(() => _categoryCode = v),
              validator: (v) => v == null ? 'Choisir une catégorie' : null,
            ),

            _label('Localisation'),
            ListTile(
              tileColor: Colors.grey.shade100,
              title: Text(
                _latitude == null
                    ? 'Aucune position sélectionnée'
                    : 'Lat ${_latitude!.toStringAsFixed(4)} , Lng ${_longitude!.toStringAsFixed(4)}',
              ),
              trailing: _fetchingLocation
                  ? const CircularProgressIndicator()
                  : IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: _fetchLocation,
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6),
    child: Text(text,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
  );

  Widget _input(TextEditingController c, String hint,
      {int maxLines = 1}) =>
      TextFormField(
        controller: c,
        maxLines: maxLines,
        validator: (v) =>
        v == null || v.trim().length < 3 ? 'Champ invalide' : null,
        decoration: InputDecoration(hintText: hint),
      );
}

// ─────────────────────────────────────────────
// IMAGE BOX
// ─────────────────────────────────────────────

class DottedImagePickerBox extends StatelessWidget {
  final List<XFile> images;
  const DottedImagePickerBox({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green.shade200, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: images.isEmpty
          ? const Center(child: Text('Ajouter une image'))
          : Row(
        children: [
          Image.file(File(images.first.path),
              width: 120, height: 120, fit: BoxFit.cover),
          const SizedBox(width: 12),
          Text('${images.length} image(s) sélectionnée(s)'),
        ],
      ),
    );
  }
}
