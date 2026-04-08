import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../providers.dart';

class BlockingOverlay extends ConsumerStatefulWidget {
  final VoidCallback onCompleted;

  const BlockingOverlay({
    super.key,
    required this.onCompleted,
  });

  @override
  ConsumerState<BlockingOverlay> createState() => _BlockingOverlayState();
}

class _BlockingOverlayState extends ConsumerState<BlockingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  int _postponeCount = 0;
  bool _showAnswerInput = false;
  final _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = ref.watch(overlayQuestionProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showExitConfirmation(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeader(),
                const SizedBox(height: 48),
                _buildQuestion(question?.question ?? _getPlaceholderQuestion()),
                const SizedBox(height: 48),
                if (_showAnswerInput) ...[
                  _buildAnswerInput(),
                ] else ...[
                  _buildOptions(),
                ],
                const Spacer(),
                _buildMotivationalText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        ScaleTransition(
          scale: _breathingAnimation,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            child: const Icon(
              Icons.psychology,
              size: 40,
              color: AppColors.accent,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'RIFLESSIONE RICHIESTA',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                letterSpacing: 2,
                color: AppColors.accent,
              ),
        ),
      ],
    );
  }

  Widget _buildQuestion(String questionText) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.format_quote,
            color: AppColors.accent,
            size: 32,
          ),
          const SizedBox(height: 16),
          Text(
            questionText,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerInput() {
    return Column(
      children: [
        TextField(
          controller: _answerController,
          maxLines: 4,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Scrivi la tua risposta...',
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitAnswer,
            child: const Text('CONFERMA'),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => setState(() => _showAnswerInput = false),
          child: const Text('Annulla'),
        ),
      ],
    );
  }

  Widget _buildOptions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => setState(() => _showAnswerInput = true),
            icon: const Icon(Icons.edit),
            label: const Text('RISpondi ora'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_postponeCount < AppConstants.maxPostpones) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _postpone(AppConstants.postpone15Min),
              child: Text('Rimanda ${AppConstants.postpone15Min} min'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _postpone(AppConstants.postpone1Hour),
              child: Text('Rimanda ${AppConstants.postpone1Hour} min'),
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Hai rimandato ${AppConstants.maxPostpones} volte. Rispondi ora.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.warning,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMotivationalText() {
    final hour = DateTime.now().hour;
    String text;

    if (hour < 12) {
      text = '"Il mattino ha l\'oro in bocca" - Fiabe tedesche';
    } else if (hour < 17) {
      text = '"Il sole e\' calato, ma il lavoro continua" - Seneca';
    } else {
      text = '"La sera porta riflessione, non rimpianto" - Marco Aurelio';
    }

    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontStyle: FontStyle.italic,
            color: AppColors.textSecondary,
          ),
      textAlign: TextAlign.center,
    );
  }

  void _postpone(int minutes) {
    setState(() => _postponeCount++);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ricorderò tra $minutes minuti'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _submitAnswer() {
    if (_answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci una risposta')),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    widget.onCompleted();
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Sei sicuro?'),
        content: const Text(
          'Puoi posticipare la riflessione, ma il tuo percorso richiede disciplina.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Rimanda'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showAnswerInput = true;
            },
            child: const Text('Rispondi ora'),
          ),
        ],
      ),
    );
  }

  String _getPlaceholderQuestion() {
    final questions = [
      'Cosa eviti di affrontare in questo momento?',
      'Se fossi onesto con te stesso, cosa diresti?',
      'Cosa faresti se non avessi paura?',
      'Quale decisione hai rimandato troppo a lungo?',
      'Cosa ti impedisce di essere la versione migliore di te stesso?',
      'Di cosa hai bisogno ma non chiedi mai?',
      'Cosa accadrebbe se smettessi di cercare l\'approvazione degli altri?',
    ];
    return questions[DateTime.now().minute % questions.length];
  }
}
