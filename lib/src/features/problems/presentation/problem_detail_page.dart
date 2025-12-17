// lib/src/features/problems/presentation/problem_detail_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../problems/data/problem_repository.dart';
import '../../problems/data/problem_model.dart';

class ProblemDetailPage extends StatefulWidget {
  final String problemId;
  const ProblemDetailPage({super.key, required this.problemId});

  @override
  State<ProblemDetailPage> createState() => _ProblemDetailPageState();
}

class _ProblemDetailPageState extends State<ProblemDetailPage> {
  final ProblemRepository _repo = ProblemRepository();
  Problem? _problem;
  bool _loading = true;
  int _imageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProblem();
  }

  Future<void> _loadProblem() async {
    setState(() => _loading = true);
    try {
      final p = await _repo.fetchById(widget.problemId);
      if (!mounted) return;
      setState(() => _problem = p);
    } catch (_) {
      setState(() => _problem = null);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ================== STATUS LOGIC ==================

  String _uiStatus(String code) {
    switch (code) {
      case 'soumis':
        return 'Soumis';
      case 'en cours':
        return 'En attente';
      case 'résolu':
        return 'Résolu';
      default:
        return 'Soumis';
    }
  }

  Color _statusColor(String code) {
    switch (code) {
      case 'soumis':
        return Colors.blue;
      case 'en cours':
        return Colors.orange;
      case 'résolu':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  double _statusProgress(String code) {
    switch (code) {
      case 'soumis':
        return 0.25;
      case 'en cours':
        return 0.6;
      case 'résolu':
        return 1.0;
      default:
        return 0.0;
    }
  }

  // ================== MAP ==================

  Future<void> _openInGoogleMaps(double lat, double lng) async {
    final Uri googleNavUri = Uri.parse(
      'google.navigation:q=$lat,$lng',
    );

    final Uri fallbackWebUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );

    try {
      if (await canLaunchUrl(googleNavUri)) {
        await launchUrl(
          googleNavUri,
          mode: LaunchMode.externalApplication,
        );
        return;
      }
    } catch (_) {}

    if (await canLaunchUrl(fallbackWebUri)) {
      await launchUrl(
        fallbackWebUri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  // ================== BUILD ==================

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_problem == null) {
      return Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: const Center(child: Text('Problème non trouvé')),
      );
    }

    final p = _problem!;
    final images = p.images;
    final hasImages = images.isNotEmpty;
    final lat = p.latitude;
    final lng = p.longitude;
    final hasLocation = lat != 0.0 || lng != 0.0;

    final statusColor = _statusColor(p.status);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ================== IMAGES ==================
            SizedBox(
              height: 260,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: hasImages ? images.length : 1,
                    onPageChanged: (i) => setState(() => _imageIndex = i),
                    itemBuilder: (_, i) {
                      if (!hasImages) {
                        return _imagePlaceholder();
                      }
                      return Padding(
                        padding: const EdgeInsets.all(14),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.network(
                            images[i],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _imagePlaceholder(),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    left: 18,
                    top: 18,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ================== CONTENT ==================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // STATUS
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _uiStatus(p.status),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            p.category,
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: _statusProgress(p.status),
                            minHeight: 6,
                            valueColor:
                            AlwaysStoppedAnimation(statusColor),
                            backgroundColor: Colors.grey.shade200,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Text(
                      p.title,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(p.description,
                        style: TextStyle(color: Colors.grey.shade700)),

                    const SizedBox(height: 20),

                    // ================== SERVICES ==================
                    Row(
                      children: [
                        const Text(
                          'Services responsables',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        const Spacer(),
                        TextButton(onPressed: () {}, child: const Text('Voir tout')),
                      ],
                    ),

                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 2,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.apartment),
                            ),
                            title: Text('Service municipal ${i + 1}'),
                            subtitle: const Text('Responsable du traitement'),
                            trailing: const Icon(Icons.chevron_right),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ================== MAP ==================
                    Text(
                      'Emplacement',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),

                    hasLocation
                        ? SizedBox(
                      height: 220,
                      child: Stack(
                        children: [
                          FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(lat, lng),
                              initialZoom: 16,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(lat, lng),
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 36,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: FloatingActionButton(
                              mini: true,
                              onPressed: () =>
                                  _openInGoogleMaps(lat, lng),
                              child: const Icon(Icons.navigation),
                            ),
                          ),
                        ],
                      ),
                    )
                        : _noLocation(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================== HELPERS ==================

  Widget _imagePlaceholder() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 64,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _noLocation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text('Position non disponible'),
      ),
    );
  }
}
