// lib/src/features/notifications/presentation/notifications_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

enum NotificationType { statusUpdate, newComment, system }

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  final bool unread;
  final NotificationType type;
  final String? problemId; // pour ouvrir le détail d’un problème

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    this.unread = true,
    this.type = NotificationType.system,
    this.problemId,
  });
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late List<AppNotification> _items;

  @override
  void initState() {
    super.initState();
    // 🔥 Mock – tu remplaceras ça par tes vraies données plus tard
    _items = [
      AppNotification(
        id: 'n1',
        title: 'Signalement traité',
        message: 'Votre problème "Lampadaire cassé" est maintenant marqué comme traité.',
        date: DateTime.now().subtract(const Duration(minutes: 15)),
        type: NotificationType.statusUpdate,
        problemId: 'p3',
      ),
      AppNotification(
        id: 'n2',
        title: 'Nouveau commentaire',
        message: 'La mairie a répondu à votre signalement "Inondation et flaque d’eau".',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        type: NotificationType.newComment,
        problemId: 'p1',
      ),
      AppNotification(
        id: 'n3',
        title: 'Bienvenue sur SmartCity',
        message: 'Merci d’avoir rejoint la communauté SmartCity !',
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: NotificationType.system,
        unread: false,
      ),
    ];
  }

  void _markAllRead() {
    setState(() {
      _items = _items.map((n) => AppNotification(
        id: n.id,
        title: n.title,
        message: n.message,
        date: n.date,
        type: n.type,
        problemId: n.problemId,
        unread: false,
      )).toList();
    });
  }

  void _openNotification(AppNotification n) {
    // Marquer comme lu
    setState(() {
      _items = _items.map((e) {
        if (e.id == n.id) {
          return AppNotification(
            id: e.id,
            title: e.title,
            message: e.message,
            date: e.date,
            type: e.type,
            problemId: e.problemId,
            unread: false,
          );
        }
        return e;
      }).toList();
    });

    // Si liée à un problème → ouvrir la page détail
    if (n.problemId != null) {
      context.go('/problem/${n.problemId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFFF5F5F7);
    final green = Colors.green.shade800;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        leading: const SizedBox.shrink(), // pas de flèche, on est dans le tab bottom
        actions: [
          TextButton(
            onPressed: _items.any((n) => n.unread) ? _markAllRead : null,
            child: Text(
              'Tout lire',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: _items.any((n) => n.unread)
                    ? green
                    : Colors.grey.shade400,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _items.isEmpty
          ? _buildEmpty()
          : ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final n = _items[index];
          return _buildNotificationCard(n, green);
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            'Aucune notification',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification n, Color green) {
    final iconData = () {
      switch (n.type) {
        case NotificationType.statusUpdate:
          return Icons.check_circle_outline;
        case NotificationType.newComment:
          return Icons.chat_bubble_outline;
        case NotificationType.system:
        default:
          return Icons.info_outline;
      }
    }();

    final accentColor = () {
      switch (n.type) {
        case NotificationType.statusUpdate:
          return Colors.green.shade600;
        case NotificationType.newComment:
          return Colors.blue.shade600;
        case NotificationType.system:
        default:
          return Colors.orange.shade700;
      }
    }();

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openNotification(n),
      child: Card(
        elevation: n.unread ? 3 : 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icône + point vert
              Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(iconData, color: accentColor, size: 22),
                  ),
                  if (n.unread)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),

              // Texte
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight:
                        n.unread ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      n.message,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatDateTime(n.date),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);

    if (diff.inMinutes < 1) return 'À l’instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    return '${d.day}/${d.month}/${d.year}';
  }
}
