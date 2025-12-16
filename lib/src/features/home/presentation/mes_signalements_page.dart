// lib/src/features/home/presentation/mes_signalements_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../problems/data/problem_repository.dart';
import '../../problems/data/problem_model.dart';

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
  List<Problem> _allForUser = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _load();
  }

  // ================== DATA ==================

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _allForUser = [];
    });

    try {
      final list = await _repo.fetchByReporter(widget.currentUserId);
      if (!mounted) return;
      setState(() => _allForUser = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onRefresh() async => _load();

  // ================== STATUS ==================

  String _uiStatus(String s) {
    switch (s) {
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

  Color _statusColor(String s) {
    switch (s) {
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

  double _statusProgress(String s) {
    switch (s) {
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

  List<Problem> _filterForTab(int index) {
    switch (index) {
      case 0:
        return _allForUser;
      case 1:
        return _allForUser.where((p) => p.status == 'soumis').toList();
      case 2:
        return _allForUser.where((p) => p.status == 'en cours').toList();
      case 3:
        return _allForUser.where((p) => p.status == 'résolu').toList();
      default:
        return _allForUser;
    }
  }

  // ================== IMAGE ==================

  Widget _leadingVisual(Problem p) {
    if (p.images.isNotEmpty && p.images.first.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          p.images.first,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _iconFallback(),
        ),
      );
    }
    return _iconFallback();
  }

  Widget _iconFallback() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.report_problem_outlined,
        color: Colors.green,
        size: 32,
      ),
    );
  }

  // ================== CARD ==================

  Widget _buildCard(Problem p) {
    final color = _statusColor(p.status);

    return InkWell(
      onTap: () => context.push('/problem/${p.id}'),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            _leadingVisual(p),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _statusProgress(p.status),
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _uiStatus(p.status),
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${p.createdAt.day}/${p.createdAt.month}/${p.createdAt.year}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.report_problem_outlined,
              size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Aucun signalement',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Text(
            'Vous n’avez encore rien signalé ici.',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // ================== BUILD ==================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Mes signalements",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                controller: _tabController,
                onTap: (_) => setState(() {}),
                indicator: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(30),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black54,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Soumis'),
                  Tab(text: 'En attente'),
                  Tab(text: 'Résolu'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Erreur: $_error'))
          : RefreshIndicator(
        onRefresh: _onRefresh,
        child: TabBarView(
          controller: _tabController,
          children: List.generate(4, (i) {
            final items = _filterForTab(i);
            if (items.isEmpty) return _buildEmpty();
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 12),
              itemBuilder: (_, index) =>
                  _buildCard(items[index]),
            );
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
