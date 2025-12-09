// lib/src/features/home/presentation/all_problems_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/widgets/problem_list.dart';
import '../../problems/data/problem_repository.dart';

class AllProblemsPage extends StatefulWidget {
  const AllProblemsPage({Key? key}) : super(key: key);

  @override
  State<AllProblemsPage> createState() => _AllProblemsPageState();
}

class _AllProblemsPageState extends State<AllProblemsPage> {
  @override
  Widget build(BuildContext context) {
    final allProblems = ProblemRepository().filterByCategory(null);

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
          onPressed: () => context.pop(),
        ),
      ),
      body: ProblemList(
        items: allProblems,
        limit: null, // show all items
        showTrailingIcon: true,
      ),
    );
  }
}
