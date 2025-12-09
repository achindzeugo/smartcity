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

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadProblem();
  }

  void _loadProblem() {
    try {
      final p = _repo.findById(widget.problemId);
      setState(() {
        _problem = p;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _problem = null;
        _loading = false;
      });
    }
  }

  Future<void> _openInGoogleMaps(double lat, double lng, {String? label}) async {
    final labelEncoded = (label ?? 'Problem').replaceAll(' ', '+');
    final Uri googleUri = Uri.parse('google.navigation:q=$lat,$lng');
    final Uri mapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng($labelEncoded)');

    try {
      if (await canLaunchUrl(googleUri)) {
        await launchUrl(googleUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}
    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible d\'ouvrir la carte.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_problem == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Text('Problème non trouvé')),
      );
    }

    final problem = _problem!;

    final List<String> images = problem.images.isNotEmpty ? problem.images : ['assets/images/onboarding1.jpg'];

    final double lat = problem.latitude;
    final double lng = problem.longitude;
    final bool hasLocation = true;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 260,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (i) => setState(() => _imageIndex = i),
                    itemBuilder: (context, index) {
                      final src = images[index];
                      final bool isNetwork = src.startsWith('http') || src.startsWith('https');
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: isNetwork
                              ? Image.network(src, width: double.infinity, height: double.infinity, fit: BoxFit.cover)
                              : Image.asset(src, width: double.infinity, height: double.infinity, fit: BoxFit.cover),
                        ),
                      );
                    },
                  ),

                  Positioned(
                    left: 18,
                    top: 18,
                    child: Material(
                      color: Colors.white.withOpacity(0.9),
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 18,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        images.length,
                            (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _imageIndex == i ? 18 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _imageIndex == i ? Colors.white : Colors.white54,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 1))],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
                child: SingleChildScrollView(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            problem.description,
                            style: theme.textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Text(problem.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    Text(problem.description, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]), maxLines: 5),
                    const SizedBox(height: 12),

                    Row(children: [
                      _buildTinyChip('New', Icons.fiber_new, Colors.blue.shade50, Colors.blue.shade700),
                      const SizedBox(width: 8),
                      _buildTinyChip(_formatDate(problem.createdAt), Icons.calendar_today_outlined, Colors.grey.shade100, Colors.black87),
                      const SizedBox(width: 8),
                      _buildTinyChip('N/A', Icons.info_outline, Colors.grey.shade100, Colors.black87),
                    ]),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        const Text('Services liées', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        const Spacer(),
                        TextButton(onPressed: () {}, child: const Text('Voir tout')),
                      ],
                    ),
                    const SizedBox(height: 8),

                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: 2,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, idx) {
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            leading: Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.image, color: Colors.grey)),
                            title: Text('Service Example ${idx + 1}'),
                            subtitle: Row(children: const [Icon(Icons.location_on, size: 12, color: Colors.grey), SizedBox(width: 4), Flexible(child: Text('Localisation exemple', style: TextStyle(fontSize: 12)))]),
                            trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('\$40'), const SizedBox(height: 4), Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.chevron_right, color: Colors.white))]),
                            onTap: () {},
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    Text('Emplacement', style: GoogleFonts.poppins(textStyle: const TextStyle(fontWeight: FontWeight.w700))),
                    const SizedBox(height: 8),

                    if (!hasLocation)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                        child: const Center(child: Text('Position non disponible')),
                      )
                    else
                      SizedBox(
                        height: 220,
                        child: Stack(
                          children: [
                            FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: LatLng(lat, lng),
                                initialZoom: 16.0,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.smartcity',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(lat, lng),
                                      width: 40,
                                      height: 40,
                                      child: const Icon(Icons.location_on, color: Colors.red, size: 36),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Positioned(
                              right: 12,
                              bottom: 12,
                              child: Material(
                                color: Colors.white,
                                shape: const CircleBorder(),
                                elevation: 4,
                                child: IconButton(
                                  icon: const Icon(Icons.navigation_outlined, color: Colors.blue),
                                  onPressed: () => _openInGoogleMaps(lat, lng, label: problem.title),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    const SizedBox(height: 30),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double? _safeDouble(Problem p, String key) {
    try {
      final value = (p as dynamic).toJson()[key];
      return value is double ? value : (value is int ? value.toDouble() : null);
    } catch (e) {
      return null;
    }
  }

  Widget _buildTinyChip(String text, IconData icon, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Icon(icon, size: 14, color: fg),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: fg, fontSize: 12)),
      ]),
    );
  }

  String _formatDate(DateTime d) {
    final months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month]} ${d.year}';
  }
}
