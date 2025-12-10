// lib/src/features/home/presentation/all_problems_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/widgets/problem_list.dart';
import '../../problems/data/problem_model.dart';
import '../../problems/data/problem_repository.dart';

class AllProblemsPage extends StatefulWidget {
  const AllProblemsPage({Key? key}) : super(key: key);

  @override
  State<AllProblemsPage> createState() => _AllProblemsPageState();
}

class _AllProblemsPageState extends State<AllProblemsPage> {
  final ProblemRepository _repo = ProblemRepository();

  late final List<Problem> _allProblems;
  int _visibleCount = 20; // on commence avec 20

  @override
  void initState() {
    super.initState();
    _allProblems = _repo.filterByCategory(null);
    if (_allProblems.length < _visibleCount) {
      _visibleCount = _allProblems.length;
    }
  }

  void _loadMore() {
    setState(() {
      _visibleCount = (_visibleCount + 20).clamp(0, _allProblems.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool canLoadMore = _visibleCount < _allProblems.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Tous les problèmes',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
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
      ),
      body: Column(
        children: [
          // Liste paginée
          Expanded(
            child: ProblemList(
              items: _allProblems,
              limit: _visibleCount,                //  20, 40, 60...
              showTrailingIcon: true,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
            ),
          ),

          // Bouton "Load more"
          if (canLoadMore)
            SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _loadMore,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Load more',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
