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
  late List<Problem> _items;

  // UI constants
  static const double _fabSize = 72.0;
  static const double _bottomBarHeight = 82.0;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _items = _repo.filterByCategory(_selectedCategory);
  }

  void _selectCategory(String? code) {
    setState(() {
      _selectedCategory = code;
      _items = _repo.filterByCategory(code);
    });
    // update route so url can reflect selection (dynamic routing)
    if (code == null) {
      GoRouter.of(context).go('/home');
    } else {
      GoRouter.of(context).go('/category/$code');
    }
  }

  @override
  Widget build(BuildContext context) {
    final latest = _repo.getLatest();
    final center = latest != null
        ? LatLng(latest.latitude, latest.longitude)
        : LatLng(4.0483, 9.7066); // fallback

    const userAgentPackageName = 'com.example.smartcity'; // replace if needed

    // compute bottom inset (system gesture bar or keyboard)
    final double viewPaddingBottom = MediaQuery.of(context).viewPadding.bottom;
    final double viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    final double bottomInset = viewPaddingBottom > viewInsetsBottom ? viewPaddingBottom : viewInsetsBottom;

    // totalBarHeight includes base bar + system inset + small margin
    final double totalBarHeight = _bottomBarHeight + bottomInset + 8.0;

    // bottomSpace used by the ListView padding (same base as totalBarHeight + extra margin)
    final double bottomSpace = totalBarHeight + 8.0;

    return Scaffold(
      extendBody: true, // allow FAB notch to overlap body without affecting layout
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

      // Floating action button bigger and centered
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: _fabSize,
        height: _fabSize,
        child: FloatingActionButton(
          onPressed: () => GoRouter.of(context).go('/problem/new'),
          backgroundColor: Colors.green.shade700,
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: const Icon(Icons.add, size: 36),
        ),
      ),

      // Use SafeArea but let bottom be handled by padding (we add bottom padding ourselves)
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // MAP (flutter_map v8.x)
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

                  RichAttributionWidget(
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

            // Card over map: show latest problem summary (styled)
            if (latest != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: InkWell(
                    onTap: () => GoRouter.of(context).go('/problem/${latest.id}'),
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
                                    textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
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
                            onPressed: () => GoRouter.of(context).go('/problem/${latest.id}'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Categories horizontal (chips)
            SizedBox(
              height: 64,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length + 1, // +1 for "All"
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

            // Header Recent problems
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Row(
                children: [
                  Text('Problèmes récents', style: GoogleFonts.poppins(textStyle: const TextStyle(fontWeight: FontWeight.w700))),
                  const Spacer(),
                  TextButton(
                    onPressed: () => GoRouter.of(context).go('/problems'),
                    child: Text('Voir tout', style: GoogleFonts.poppins()),
                  ),
                ],
              ),
            ),

            // List of recent problems from the selected category
            Expanded(
              child: ProblemList(
                items: _items,
                limit: null, // No limit
                showTrailingIcon: true,
                physics: const AlwaysScrollableScrollPhysics(), // Always allow scrolling
                padding: EdgeInsets.fromLTRB(14, 8, 14, bottomSpace), // Add padding for bottom bar
              ),
            ),

          ],
        ),
      ),

      // Bottom navigation with notch for centered FAB — pass computed height
      bottomNavigationBar: _buildBottomBar(context, totalBarHeight),
    );
  }

  Widget _buildBottomBar(BuildContext context, double totalBarHeight) {
    return SizedBox(
      height: totalBarHeight,
      child: SafeArea(
        top: false,
        bottom: true,
        child: BottomAppBar(
          elevation: 10,
          color: Colors.white,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left items
                Row(
                  children: [
                    _NavItem(
                      icon: Icons.home_filled,
                      label: 'Home',
                      isActive: true,
                      onPressed: () => GoRouter.of(context).go('/home'),
                    ),
                    const SizedBox(width: 24),
                    _NavItem(
                      icon: Icons.group_outlined,
                      label: 'Community',
                      onPressed: () {},
                    ),
                  ],
                ),
                // Right items
                Row(
                  children: [
                    _NavItem(
                      icon: Icons.report_gmailerrorred_outlined,
                      label: 'Reports',
                      onPressed: () => GoRouter.of(context).go('/my-reports'),
                    ),
                    const SizedBox(width: 24),
                    _NavItem(
                      icon: Icons.person_outline,
                      label: 'Profile',
                      onPressed: () {},
                    ),
                  ],
                )
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
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.green.shade700 : Colors.grey.shade600,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 12,
                  color: isActive ? Colors.green.shade700 : Colors.grey.shade600,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
