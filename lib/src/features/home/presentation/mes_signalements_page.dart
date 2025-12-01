// lib/src/features/home/presentation/mes_signalements_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../problems/data/problem_repository.dart';
import '../../problems/data/problem_model.dart';

/// Page "Mes signalements" (liste des problèmes signalés par l'utilisateur)
/// Usage de test: MesSignalementsPage(currentUserId: 'user1')
class MesSignalementsPage extends StatefulWidget {
  final String currentUserId;

  const MesSignalementsPage({super.key, required this.currentUserId});

  @override
  State<MesSignalementsPage> createState() => _MesSignalementsPageState();
}

class _MesSignalementsPageState extends State<MesSignalementsPage>
    with SingleTickerProviderStateMixin {
  final ProblemRepository _repo = ProblemRepository();

  late TabController _tabController;
  late List<Problem> _allForUser;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  void _load() {
    // synchronous repo (mock). Si async, adapte en Future/await.
    setState(() {
      _allForUser = _repo.getByReporter(widget.currentUserId);
      _loading = false;
    });
  }

  /// 0 = All, 1 = Pending, 2 = Treated
  List<Problem> _filterForTab(int index) {
    if (index == 0) return _allForUser;
    if (index == 1) {
      return _allForUser.where((p) => p.status.toLowerCase() == 'pending').toList();
    }
    return _allForUser.where((p) {
      final s = p.status.toLowerCase();
      return s == 'treated' || s == 'resolved' || s == 'done';
    }).toList();
  }

  void _confirmDelete(BuildContext ctx, Problem p) {
    showDialog(
      context: ctx,
      builder: (c) => AlertDialog(
        title: const Text('Supprimer ce signalement ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              setState(() {
                _allForUser.removeWhere((x) => x.id == p.id);
              });
              Navigator.of(c).pop();
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(String label) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.report_problem_outlined, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(label, style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 6),
          Text('Vous n\'avez encore aucun signalement ici.', style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  /// Convertit le statut en valeur 0..1 pour la barre de progression
  double _statusProgress(String status) {
    final s = status.toLowerCase();
    if (s == 'pending') return 0.25;
    if (s == 'in_progress' || s == 'progress') return 0.6;
    if (s == 'treated' || s == 'resolved' || s == 'done') return 1.0;
    return 0.0;
  }

  Widget _buildTile(Problem p) {
    final date = '${p.createdAt.day}/${p.createdAt.month}/${p.createdAt.year}';
    final statusLower = p.status.toLowerCase();
    final statusColor = statusLower == 'pending' ? Colors.orange.shade700 : Colors.green.shade700;
    final progress = _statusProgress(p.status);

    return InkWell(
      onTap: () => context.go('/problem/${p.id}'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            // IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: (p.images.isNotEmpty)
                  ? Image.asset(p.images.first, width: 74, height: 74, fit: BoxFit.cover)
                  : Container(width: 74, height: 74, color: Colors.grey.shade100, child: const Icon(Icons.image, color: Colors.grey)),
            ),

            const SizedBox(width: 12),

            // DETAILS column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title + more icon row
                  Row(
                    children: [
                      Expanded(
                        child: Text(p.title,
                            maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 6),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // description small
                  Text(p.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                  const SizedBox(height: 10),

                  // progress + meta row
                  Row(
                    children: [
                      // rounded progress bar
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // date small
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 6),
                          Text(date, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // right column: status label + delete
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
                  child: Text(p.status, style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
                const SizedBox(height: 8),
                Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: InkWell(
                    onTap: () => _confirmDelete(context, p),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 22),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<Problem> items) {
    if (items.isEmpty) return _buildEmpty('Aucun signalement');

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildTile(items[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        leading: BackButton(color: Colors.black87, onPressed: () => context.pop()),
        title: Text("Statut d'incidents", style: titleStyle),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(78),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6)],
              ),
              padding: const EdgeInsets.all(4),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(color: Colors.green.shade700, borderRadius: BorderRadius.circular(22)),
                labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black54,
                tabs: [
                  Tab(child: Text('All', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                  Tab(child: Text('Pending', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                  Tab(child: Text('Treated', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: List.generate(3, (i) {
            final list = _filterForTab(i);
            return _buildList(list);
          }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
