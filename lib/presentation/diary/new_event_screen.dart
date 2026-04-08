import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/emotion_slider.dart';
import '../../core/constants/app_constants.dart';
import '../providers.dart';

class NewEventScreen extends ConsumerStatefulWidget {
  const NewEventScreen({super.key});

  @override
  ConsumerState<NewEventScreen> createState() => _NewEventScreenState();
}

class _NewEventScreenState extends ConsumerState<NewEventScreen> {
  final _descriptionController = TextEditingController();
  int _feelingLevel = 3;
  int _reactionLevel = 3;
  List<String> _selectedTags = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('NUOVO EVENTO'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveEvent,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('SALVA'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cosa ti è successo?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Descrivi l\'avvenimento nel modo più oggettivo possibile',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Es: Il mio capo mi ha criticato davanti al team...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 32),
            EmotionSlider(
              value: _feelingLevel,
              label: 'Come ti sei SENTITO?',
              onChanged: (value) => setState(() => _feelingLevel = value),
            ),
            const SizedBox(height: 32),
            EmotionSlider(
              value: _reactionLevel,
              label: 'Come hai REAGITO?',
              onChanged: (value) => setState(() => _reactionLevel = value),
            ),
            if (_reactionLevel > _feelingLevel) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.warning),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.warning, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'La tua reazione è stata più intensa della sensazione. C\'è spazio per migliorare il controllo.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            Text(
              'TAG',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    letterSpacing: 1.5,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Seleziona le categorie rilevanti',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.eventTags.map<Widget>((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                  selectedColor: AppColors.primary,
                  checkmarkColor: AppColors.textPrimary,
                  backgroundColor: AppColors.surface,
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.accent
                        : AppColors.primary.withOpacity(0.5),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Future<void> _saveEvent() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci una descrizione')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(eventsProvider.notifier).addEvent(
            description: _descriptionController.text.trim(),
            feelingLevel: _feelingLevel,
            reactionLevel: _reactionLevel,
            tags: _selectedTags,
          );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
