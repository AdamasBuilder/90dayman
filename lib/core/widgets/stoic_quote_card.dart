import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class StoicQuoteCard extends StatelessWidget {
  final String text;
  final String? source;
  final bool isSaved;
  final VoidCallback? onSave;
  final VoidCallback? onTap;

  const StoicQuoteCard({
    super.key,
    required this.text,
    this.source,
    this.isSaved = false,
    this.onSave,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: AppColors.accent.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.format_quote,
              color: AppColors.accent,
              size: 32,
            ),
            const SizedBox(height: 16),
            Text(
              text,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 20,
                height: 1.5,
              ),
            ),
            if (source != null) ...[
              const SizedBox(height: 16),
              Text(
                '— $source',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (onSave != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: onSave,
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? AppColors.accent : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
    );
  }
}
