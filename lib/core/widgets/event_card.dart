import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../domain/entities/event.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd MMM');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color:
                AppColors.getEmotionColor(event.feelingLevel).withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.getEmotionColor(event.feelingLevel),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'S:${event.feelingLevel}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.getEmotionColor(event.reactionLevel),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'R:${event.reactionLevel}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${dateFormat.format(event.timestamp)} ${timeFormat.format(event.timestamp)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              event.description,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (event.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: event.tags
                    .map<Widget>((tag) => Chip(
                          label: Text(tag),
                          labelStyle: const TextStyle(fontSize: 10),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: AppColors.surfaceLight,
                        ))
                    .toList(),
              ),
            ],
            if (event.aiReflection != null) ...[
              const Divider(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.aiReflection!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: AppColors.secondary,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
