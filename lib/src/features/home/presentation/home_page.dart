import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/problem_list.dart';

import '../../problems/data/problem_repository.dart';
import '../../problems/data/problem_model.dart';

class HomePage extends StatefulWidget {
  final String? initialCategory;
  const HomePage({super.key, this.initialCategory});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProblemRepository _repo = ProblemRepository();

  final List<String> categories = ['insalubrite', 'nid_de_poule', 'lampadaire'];
  String? _selectedCategory;

  // état list recent
  List<Problem> _items = [];
  bool _loading = true;
  String? _error;

  // 🔽 FAB plus petit
  static const double _fabSize = 56.0;
  // 🔽 Bottom bar moins haute
  static const double _bottomBarHeight = 64.0;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _loadInitialItems();
  }

  Future<void> _loadInitialItems() async {
    setState(() {
      _loading = true;
      _error = null;
      _items = [];
    });

    try {
      // On récupère directement la première page (5 derniers)
      final recent = await _repo.fetchPage(pageIndex: 0, pageSize: 5);

      // Si une catégorie est demandée au démarrage, on filtre côté client
      final filtered = (_selectedCategory == null)
          ? recent
          : recent.where((p) => p.category == _selectedCategory || p.category.contains(_selectedCategory!)).toList();

      setState(() {
        _items = filtered;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if(mounted) setState(() => _loading = false);
    }
  }

  /// Si tu veux filtrer par catégorie depuis le serveur, remplace
  /// cette implémentation par une requête server-side (ex: .eq('id_categorie', ...))
  /// Ici on fait client-side: on récupère une page (5) puis on filtre.
  Future<void> _selectCategory(String? code) async {
    setState(() {
      _selectedCategory = code;
      _loading = true;
      _error = null;
      _items = [];
    });

    try {
      // Exemple simple : récupère la première page (5) et filtre côté client
      final recent = await _repo.fetchPage(pageIndex: 0, pageSize: 20);
      final byCat = code == null
          ? recent
          : recent.where((p) => (p.category == code) || (p.category.contains(code))).toList();

      // on limite à 5
      setState(() {
        _items = byCat.take(5).toList();
      });

      // navigation route
      if (code == null) {
        context.go('/home');
      } else {
        context.go('/category/$code');
      }
    } catch (e) {
      if(mounted) setState(() => _error = e.toString());
    } finally {
      if(mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // latest = premier élément de la liste (les items proviennent de supabase)
    final Problem? latest = _items.isNotEmpty ? _items.first : null;

    final center = latest != null
        ? LatLng(latest.latitude, latest.longitude)
        : LatLng(4.0483, 9.7066);

    const userAgentPackageName = 'com.example.smartcity';

    final double viewPaddingBottom = MediaQuery.of(context).viewPadding.bottom;
    final double viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    final double bottomInset =
    viewPaddingBottom > viewInsetsBottom ? viewPaddingBottom : viewInsetsBottom;
    final double totalBarHeight = _bottomBarHeight + bottomInset + 6.0;
    final double bottomSpace = totalBarHeight + 8.0;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Accueil',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
        ],
      ),

      /// 🔽 FAB DÉTACHÉ, À DROITE, AU-DESSUS DE LA BARRE
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        // petit décalage visuel par rapport au bord
        padding: const EdgeInsets.only(right: 8.0, bottom: 4.0),
        child: SizedBox(
          width: _fabSize,
          height: _fabSize,
          child: FloatingActionButton(
            onPressed: () => context.push('/problem/new'),
            backgroundColor: Colors.green.shade700,
            elevation: 6,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, size: 28),
          ),
        ),
      ),

      bottomNavigationBar: _buildBottomBar(context, totalBarHeight),

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              height: 180,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: userAgentPackageName,
                  ),
                  MarkerLayer(
                    markers: latest != null
                        ? [
                      Marker(
                        point: center,
                        width: 44,
                        height: 44,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 36,
                          ),
                        ),
                      ),
                    ]
                        : [],
                  ),
                  const RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        'OpenStreetMap contributors',
                        onTap: null,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: CircularProgressIndicator(),
              ),

            if (!_loading && latest != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: InkWell(
                    onTap: () => context.push('/problem/${latest.id}'),
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.warning_rounded, color: Colors.red),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  latest.title,
                                  style: GoogleFonts.poppins(
                                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${latest.createdAt.day}/${latest.createdAt.month}/${latest.createdAt.year} • ${latest.description}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.chevron_right, color: Colors.grey.shade700),
                            onPressed: () => context.push('/problem/${latest.id}'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            SizedBox(
              height: 64,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isAll = index == 0;
                  final code = isAll ? null : categories[index - 1];
                  final label = isAll ? 'Tous' : (code!.replaceAll('_', ' '));
                  final selected = _selectedCategory == code || (isAll && _selectedCategory == null);
                  return ChoiceChip(
                    label: Text(
                      label,
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(fontSize: 13, color: selected ? Colors.white : Colors.black87),
                      ),
                    ),
                    selected: selected,
                    onSelected: (_) => _selectCategory(code),
                    selectedColor: Colors.green.shade700,
                    backgroundColor: Colors.grey.shade100,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  );
                },
              ),
            ),

            const SizedBox(height: 0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Row(
                children: [
                  Text('Problèmes récents', style: GoogleFonts.poppins(textStyle: const TextStyle(fontWeight: FontWeight.w700))),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.push('/problems'),
                    child: Text('Voir tout', style: GoogleFonts.poppins()),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _error != null && !_loading
                  ? Center(child: Text('Erreur: $_error'))
                  : ProblemList(
                items: _items,
                limit: null, // la liste est déjà limitée à 5
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(14, 8, 14, bottomSpace),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, double totalBarHeight) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 68,
        child: BottomAppBar(
          elevation: 8,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: _NavItem(icon: Icons.home_filled, label: 'Accueil', isActive: true, onPressed: () => context.go('/home')),
                ),
                Expanded(
                  child: _NavItem(icon: Icons.receipt_long, label: 'Signalements', onPressed: () => context.push('/my-reports')),
                ),

                const SizedBox(width: 52),

                Expanded(
                  child: _NavItem(icon: Icons.notifications_outlined, label: 'Alertes', onPressed: () => context.push('/notifications')),
                ),
                Expanded(
                  child: _NavItem(icon: Icons.person_outline, label: 'Profil', onPressed: () => context.push('/profile')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.green.shade700 : Colors.grey.shade600;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color), // ⬅️ réduit
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 10, // ⬅️ réduit
                color: color,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
