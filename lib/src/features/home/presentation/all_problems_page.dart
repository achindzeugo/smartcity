import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../problems/data/problem_repository.dart';
import '../../problems/data/problem_model.dart';

class AllProblemsPage extends StatefulWidget {
  const AllProblemsPage({Key? key}) : super(key: key);

  @override
  State<AllProblemsPage> createState() => _AllProblemsPageState();
}

class _AllProblemsPageState extends State<AllProblemsPage>
    with SingleTickerProviderStateMixin {
  final ProblemRepository _repo = ProblemRepository();

  static const int _pageSize = 10;

  final List<Problem> _visible = [];
  bool _loadingInitial = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _page = 0;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initLoad();
  }

  // ================== DATA ==================

  Future<void> _initLoad() async {
    setState(() {
      _loadingInitial = true;
      _visible.clear();
      _page = 0;
      _hasMore = true;
    });

    final data = await _repo.fetchPage(
      pageIndex: _page,
      pageSize: _pageSize,
    );

    if (!mounted) return;
    setState(() {
      _visible.addAll(data);
      _page = 1;
      _hasMore = data.length == _pageSize;
      _loadingInitial = false;
    });
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;

    setState(() => _loadingMore = true);

    final data = await _repo.fetchPage(
      pageIndex: _page,
      pageSize: _pageSize,
    );

    if (!mounted) return;
    setState(() {
      _visible.addAll(data);
      _page++;
      _hasMore = data.length == _pageSize;
      _loadingMore = false;
    });
  }

  Future<void> _onRefresh() async {
    await _initLoad();
  }

  // ================== STATUS HELPERS ==================

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

  List<Problem> _filtered() {
    switch (_tabController.index) {
      case 0:
        return _visible;
      case 1:
        return _visible.where((p) => p.status == 'soumis').toList();
      case 2:
        return _visible.where((p) => p.status == 'en cours').toList();
      case 3:
        return _visible.where((p) => p.status == 'résolu').toList();
      default:
        return _visible;
    }
  }

  // ================== IMAGE / ICON ==================

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
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================== BUILD ==================

  @override
  Widget build(BuildContext context) {
    final items = _filtered();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Tous les signalements',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
      body: _loadingInitial
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length + (_hasMore ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == items.length) {
              return ElevatedButton(
                onPressed: _loadingMore ? null : _loadMore,
                child: _loadingMore
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : const Text('Load more'),
              );
            }
            return _buildCard(items[index]);
          },
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
