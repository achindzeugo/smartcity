// lib/src/shared/widgets/problem_list.dart

import 'dart:io';
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
    final list = (limit != null && limit! < items.length) ? items.sublist(0, limit!) : items;

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

        final createdAt = '${p.createdAt.day.toString().padLeft(2, '0')}/${p.createdAt.month.toString().padLeft(2, '0')}/${p.createdAt.year}';

        final categoryLabel = p.category.replaceAll('_', ' ');

        Widget imageWidget;
        if (p.images.isNotEmpty) {
          final imagePath = p.images.first;
          if (imagePath.startsWith('assets/')) {
            imageWidget = Image.asset(
              imagePath,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 64,
                  height: 64,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                );
              },
            );
          } else {
            imageWidget = Image.file(
              File(imagePath),
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 64,
                  height: 64,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                );
              },
            );
          }
        } else {
          imageWidget = Container(
            width: 64,
            height: 64,
            color: Colors.grey.shade200,
            child: const Icon(Icons.image, color: Colors.grey),
          );
        }

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 1.5,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: imageWidget,
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
              '${categoryLabel.toUpperCase()} • $createdAt',
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
