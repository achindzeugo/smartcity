import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/problems/data/problem_model.dart';
import 'problem_card.dart';

class ProblemList extends StatelessWidget {
  final List<Problem> items;
  final int? limit;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const ProblemList({
    super.key,
    required this.items,
    this.limit,
    this.physics,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final list = (limit != null && limit! < items.length)
        ? items.sublist(0, limit!)
        : items;

    if (list.isEmpty) {
      return Center(
        child: Text(
          'Aucun signalement',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    return ListView.separated(
      physics: physics,
      padding: padding ?? const EdgeInsets.all(14),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        return ProblemCard(problem: list[index]);
      },
    );
  }
}
