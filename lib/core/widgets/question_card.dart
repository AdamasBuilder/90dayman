import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../domain/entities/daily_question.dart';

class QuestionCard extends StatelessWidget {
  final DailyQuestion question;
  final VoidCallback? onTap;

  const QuestionCard({
    super.key,
    required this.question,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = question.isAnswered
        ? AppColors.success.withOpacity(0.2)
        : AppColors.warning.withOpacity(0.2);
    
    final borderColor = question.isAnswered
        ? AppColors.success
        : AppColors.warning;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                question.isAnswered ? Icons.check : Icons.help_outline,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.typeLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: borderColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    question.question,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (question.isAnswered && question.answer != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      question.answer!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
