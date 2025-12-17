import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/problems/data/problem_model.dart';

class ProblemCard extends StatelessWidget {
  final Problem problem;

  const ProblemCard({super.key, required this.problem});

  // ================== STATUS ==================

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

  // ================== IMAGE ==================

  Widget _leadingVisual() {
    if (problem.images.isNotEmpty &&
        problem.images.first.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          problem.images.first,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
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

  // ================== BUILD ==================

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(problem.status);

    return InkWell(
      onTap: () => context.push('/problem/${problem.id}'),
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
            _leadingVisual(),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    problem.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    problem.description,
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
                      value: _statusProgress(problem.status),
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
                    _uiStatus(problem.status),
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${problem.createdAt.day}/${problem.createdAt.month}/${problem.createdAt.year}',
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
}
