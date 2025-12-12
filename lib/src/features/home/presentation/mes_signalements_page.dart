// lib/src/features/home/presentation/mes_signalements_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:smartcity/src/core/services/session_service.dart';
import 'package:smartcity/src/core/services/supabase_service.dart';
import '../../problems/data/problem_model.dart';

class MesSignalementsPage extends StatefulWidget {
  // MODIF: On retire currentUserId, on le récupère depuis le SessionService
  const MesSignalementsPage({super.key});

  @override
  State<MesSignalementsPage> createState() => _MesSignalementsPageState();
}

class _MesSignalementsPageState extends State<MesSignalementsPage>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  // MODIF: La liste est initialisée à vide, elle sera remplie par Supabase
  List<Problem> _allForUser = [];
  bool _loading = true;

  // MODIF: On récupère l'ID utilisateur depuis la session
  late final String _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // MODIF: On s'assure que l'utilisateur est connecté avant de charger
    if (SessionService.currentUser == null) {
      // Gérer le cas où l'utilisateur n'est pas connecté
      // Par exemple, rediriger vers la page de connexion
      context.go('/login');
      return;
    }
    _currentUserId = SessionService.currentUser!['id'];

    _load();
  }

  // MODIF: La fonction est maintenant asynchrone pour charger depuis Supabase
  Future<void> _load() async {
    setState(() => _loading = true);

    try {
      final data = await SupabaseService.client
          .from('problem')
          .select()
          .eq('user_id', _currentUserId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _allForUser = data.map((item) => Problem.fromMap(item)).toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement: $e")),
        );
      }
    }
  }

  List<Problem> _filterForTab(int index) {
    if (index == 0) return _allForUser;
    if (index == 1) {
      return _allForUser.where((p) => p.status.toLowerCase() == 'pending').toList();
    }
    return _allForUser.where((p) {
      final s = p.status.toLowerCase();
      return s == 'treated' || s == 'resolved' || s == 'done' || s == 'in_progress';
    }).toList();
  }

  // MODIF: La suppression se fait maintenant aussi sur Supabase
  void _confirmDelete(BuildContext ctx, Problem p) {
    showDialog(
      context: ctx,
      builder: (c) => AlertDialog(
        title: const Text('Supprimer ce signalement ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              try {
                // On supprime dans la base de données
                await SupabaseService.client.from('problem').delete().eq('id', p.id);

                // On met à jour l'état local
                setState(() {
                  _allForUser.removeWhere((x) => x.id == p.id);
                });
                if (mounted) Navigator.of(c).pop();
              } catch (e) {
                 if (mounted) {
                   Navigator.of(c).pop();
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text("Erreur lors de la suppression: $e")),
                   );
                 }
              }
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
          Text('Vous n avez encore aucun signalement ici.', style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

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
      onTap: () => context.push('/problem/${p.id}'),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              // MODIF: Utilisation de l'URL de l'image si disponible
              child: (p.images.isNotEmpty)
                  ? Image.network(p.images.first, width: 74, height: 74, fit: BoxFit.cover,
                    // Placeholder pour le chargement de l'image réseau
                    loadingBuilder: (context, child, progress) {
                      return progress == null ? child : const SizedBox(width: 74, height: 74, child: Center(child: CircularProgressIndicator()));
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(width: 74, height: 74, color: Colors.grey.shade100, child: const Icon(Icons.broken_image, color: Colors.grey));
                    },
                  )
                  : Container(width: 74, height: 74, color: Colors.grey.shade100, child: const Icon(Icons.image, color: Colors.grey)),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

                  Text(p.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                  const SizedBox(height: 10),

                  Row(
                    children: [
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

    return WillPopScope(
      onWillPop: () async {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/home');
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F9),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          title: Text("Mes signalements", style: titleStyle),
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 6,
                    )
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: BorderRadius.circular(22),
                  ),
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
      ),
    );
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}


