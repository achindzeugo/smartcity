// lib/src/shared/widgets/problem_list.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../features/problems/data/problem_model.dart';

class ProblemList extends StatelessWidget {
  final List<Problem> items;
  final int? limit;
  final bool showTrailingIcon;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const ProblemList({
    Key? key,
    required this.items,
    this.limit,
    this.showTrailingIcon = true,
    this.physics,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // si limit est défini et < items.length → on tronque
    final List<Problem> list;
    if (limit != null && limit! < items.length) {
      list = items.sublist(0, limit!);
    } else {
      list = items;
    }

    final List<String> incidentImages = [
      'assets/images/onboarding1.png',
      'assets/images/onboarding2.jpg',
      'assets/images/onboarding3.png',
    ];

    if (list.isEmpty) {
      return Center(
        child: Text(
          'Aucun problème pour le moment.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    return ListView.separated(
      physics: physics,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final p = list[i];
        final imagePath = incidentImages[i % incidentImages.length];

        final createdAt =
            '${p.createdAt.day.toString().padLeft(2, '0')}/'
            '${p.createdAt.month.toString().padLeft(2, '0')}/'
            '${p.createdAt.year}';

        final categoryLabel =
        p.category.replaceAll('_', ' '); // ex: nid_de_poule → nid de poule

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 1.5,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.asset(
                imagePath,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              p.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            subtitle: Text(
              '$categoryLabel • $createdAt',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: showTrailingIcon
                ? IconButton(
              icon: const Icon(Icons.arrow_forward_rounded),
              onPressed: () => context.push('/problem/${p.id}'),
            )
                : null,
            onTap: () => context.push('/problem/${p.id}'),
          ),
        );
      },
    );
  }
}
