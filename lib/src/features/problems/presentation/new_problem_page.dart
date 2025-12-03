// lib/src/features/problems/presentation/new_problem_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../problems/data/problem_repository.dart';
import '../../problems/data/problem_model.dart';

class NewProblemPage extends StatefulWidget {
  const NewProblemPage({super.key});

  @override
  State<NewProblemPage> createState() => _NewProblemPageState();
}

class _NewProblemPageState extends State<NewProblemPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _category;
  double? _latitude;
  double? _longitude;
  final List<XFile> _images = [];

  bool _submitting = false;
  bool _isFetchingLocation = false;

  final ProblemRepository _repo = ProblemRepository();
  final ImagePicker _picker = ImagePicker();

  final List<DropdownMenuItem<String>> _categoryItems = const [
    DropdownMenuItem(value: 'insalubrite', child: Text('Insalubrité')),
    DropdownMenuItem(value: 'nid_de_poule', child: Text('Nid de poule')),
    DropdownMenuItem(value: 'lampadaire', child: Text('Lampadaire')),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceDialog() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Source de l'image"),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.camera_alt, size: 40),
              label: const Text("Caméra"),
              onPressed: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            TextButton.icon(
              icon: const Icon(Icons.photo_library, size: 40),
              label: const Text("Galerie"),
              onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      _pickImage(source);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _images.add(pickedFile);
      });
    }
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le service de localisation est désactivé.')));
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La permission de localisation a été refusée.')));
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La permission de localisation a été refusée de manière permanente.')),
        );
      }
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la récupération de la position: $e")),
        );
      }
      return null;
    }
  }

  Future<void> _fetchAndSetLocation() async {
    setState(() => _isFetchingLocation = true);
    final position = await _determinePosition();
    if (position != null) {
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    }
    setState(() => _isFetchingLocation = false);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_latitude == null || _longitude == null) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Position manquante'),
          content: const Text('Aucune position sélectionnée. Continuer sans position ?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Annuler')),
            TextButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Continuer')),
          ],
        ),
      ) ??
          false;
      if (!ok) return;
    }

    setState(() => _submitting = true);

    final newProblem = Problem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _category ?? 'insalubrite',
      latitude: _latitude ?? 0.0,
      longitude: _longitude ?? 0.0,
      createdAt: DateTime.now(),
      reporterId: 'user1',
      status: 'pending',
      images: _images.map((f) => f.path).toList(),
    );

    try {
      _repo.add(newProblem);

      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signalement envoyé.')));

      context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text('Formulaire de signalement', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _submitting
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Soumettre', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: DottedImagePickerBox(images: _images.map((f) => f.path).toList()),
            ),
            const SizedBox(height: 18),

            Text('Titre', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleCtrl,
              validator: (v) => (v == null || v.trim().length < 3) ? 'Entrez un titre valide' : null,
              decoration: InputDecoration(
                hintText: 'Ex: Nid de poule avenue X',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 14),

            Text('Description', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descCtrl,
              validator: (v) => (v == null || v.trim().length < 6) ? 'Entrez une description' : null,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Décrivez le problème, impact, etc.',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 14),

            Text('Catégorie', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
              child: DropdownButtonFormField<String>(
                items: _categoryItems,
                value: _category,
                onChanged: (v) => setState(() => _category = v),
                decoration: const InputDecoration(border: InputBorder.none),
                validator: (v) => v == null ? 'Choisir une catégorie' : null,
              ),
            ),
            const SizedBox(height: 14),

            Text('Emplacement', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _latitude == null ? 'Sélectionner la position du problème' : 'Lat: ${_latitude!.toStringAsFixed(4)}, Lng: ${_longitude!.toStringAsFixed(4)}',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                  _isFetchingLocation
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : IconButton(
                          onPressed: _fetchAndSetLocation,
                          icon: const Icon(Icons.my_location_outlined),
                        ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }
}

class DottedImagePickerBox extends StatelessWidget {
  final List<String> images;
  const DottedImagePickerBox({required this.images, super.key});

  @override
  Widget build(BuildContext context) {
    final has = images.isNotEmpty;
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200, width: 2, style: BorderStyle.solid),
        color: Colors.white,
      ),
      child: has
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(images.first), width: 120, height: 120, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text('${images.length} image(s) sélectionnée(s)', style: TextStyle(color: Colors.grey.shade800))),
              ]),
            )
          : Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.cloud_upload_outlined, size: 28, color: Colors.grey),
                const SizedBox(height: 6),
                Text('Ajouter une photo', style: GoogleFonts.poppins(color: Colors.grey)),
              ]),
            ),
    );
  }
}
