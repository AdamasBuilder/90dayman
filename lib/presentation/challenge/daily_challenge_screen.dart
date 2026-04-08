import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/stoic_quotes.dart';
import '../../domain/entities/daily_question.dart';
import '../providers.dart';

class DailyChallengeScreen extends ConsumerStatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  ConsumerState<DailyChallengeScreen> createState() =>
      _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends ConsumerState<DailyChallengeScreen> {
  final _answerController = TextEditingController();
  DailyQuestion? _currentQuestion;
  bool _isLoading = true;
  bool _isAnswering = false;
  bool _showReflection = false;
  String _aiReflection = '';

  @override
  void initState() {
    super.initState();
    _loadOrGenerateQuestion();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _loadOrGenerateQuestion() async {
    setState(() => _isLoading = true);

    try {
      final questionsNotifier = ref.read(questionsProvider.notifier);

      var todaysQuestion =
          await questionsNotifier.getTodaysQuestion(QuestionType.onDemand);

      if (todaysQuestion == null) {
        todaysQuestion = await questionsNotifier.generateOnDemandChallenge();
      }

      setState(() {
        _currentQuestion = todaysQuestion;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('S.FIDA'),
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent))
          : _currentQuestion == null
              ? _buildErrorState()
              : _buildQuestionContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Qualcosa è andato storto',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Non riesco a generare la sfida. Completa prima il tuo profilo.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('INDIETRO'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuoteHeader(),
          const SizedBox(height: 32),
          _buildQuestion(),
          const SizedBox(height: 32),
          if (!_showReflection) ...[
            _buildAnswerInput(),
          ] else ...[
            _buildReflection(),
          ],
        ],
      ),
    );
  }

  Widget _buildQuoteHeader() {
    final quote = StoicQuotes.getQuoteByAuthor('epictetus');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.format_quote, color: AppColors.accent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quote['text']!,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '— ${quote['source']}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withOpacity(0.2),
            AppColors.primary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accent.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.help_outline,
            size: 48,
            color: AppColors.accent,
          ),
          const SizedBox(height: 16),
          Text(
            _currentQuestion!.question,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
            textAlign: TextAlign.center,
          ),
          if (_currentQuestion!.generatedByAI) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome,
                      size: 14, color: AppColors.accent),
                  const SizedBox(width: 6),
                  Text(
                    'Generata da AI',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'La tua risposta',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Rispondi con onestà. Questa è una conversazione solo tra te e te stesso.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _answerController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Scrivi qui la tua risposta...',
            alignLabelWithHint: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isAnswering ? null : _submitAnswer,
            child: _isAnswering
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('CONFERMA RISPOSTA'),
          ),
        ),
      ],
    );
  }

  Widget _buildReflection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success),
              const SizedBox(width: 8),
              Text(
                'Hai risposto',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.success,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _currentQuestion!.answer ?? '',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
          ),
          if (_aiReflection.isNotEmpty) ...[
            const Divider(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline,
                    color: AppColors.accent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Riflessione Stoica',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.accent,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _aiReflection,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CHIUDI'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAnswer() async {
    if (_answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci una risposta')),
      );
      return;
    }

    setState(() => _isAnswering = true);

    try {
      await ref.read(questionsProvider.notifier).answerQuestion(
            _currentQuestion!.id,
            _answerController.text.trim(),
          );

      _aiReflection = _generateSelfReflection();

      setState(() {
        _currentQuestion = _currentQuestion!.copyWith(
          answer: _answerController.text.trim(),
          answeredAt: DateTime.now(),
        );
        _showReflection = true;
        _isAnswering = false;
      });
    } catch (e) {
      setState(() => _isAnswering = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      }
    }
  }

  String _generateSelfReflection() {
    final reflections = [
      'Il coraggio non è l\'assenza di paura, ma la decisione che qualcosa è più importante della paura.',
      'Ogni introspezione è un passo verso la padronanza di te stesso.',
      'La consapevolezza è il primo passo verso il cambiamento.',
      'Non giudicare te stesso per la risposta, ma per l\'onestà con cui l\'hai data.',
      'Marco Aurelio scriveva: "L\'uomo che vince se stesso è il più grande vincitore."',
      'La verità che cerchi è spesso quella che eviti di guardare.',
      'Essere vulnerabili nella riflessione è una forma di forza.',
    ];

    final hour = DateTime.now().hour;
    return reflections[hour % reflections.length];
  }
}
