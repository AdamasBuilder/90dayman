import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EmotionSlider extends StatefulWidget {
  final int value;
  final String label;
  final ValueChanged<int> onChanged;
  final bool enabled;

  const EmotionSlider({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  State<EmotionSlider> createState() => _EmotionSliderState();
}

class _EmotionSliderState extends State<EmotionSlider> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            final level = index + 1;
            final isSelected = widget.value == level;
            
            return GestureDetector(
              onTap: widget.enabled ? () => widget.onChanged(level) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSelected ? 48 : 40,
                height: isSelected ? 48 : 40,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.getEmotionColor(level)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.getEmotionColor(level),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$level',
                    style: TextStyle(
                      color: isSelected 
                          ? AppColors.textPrimary 
                          : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: isSelected ? 18 : 14,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sereno',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              AppColors.emotionLevels[widget.value] ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.getEmotionColor(widget.value),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Crisi',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}
