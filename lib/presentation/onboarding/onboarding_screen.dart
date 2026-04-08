import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/onboarding_question.dart';
import '../../services/storage/database_service.dart';
import '../providers.dart';
import 'onboarding_profile_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<OnboardingQuestion> _questions = [];
  bool _loading = true;
  final Map<String, int> _responses = {};

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final db = await ref.read(databaseServiceProvider.future);
    final phrases = await db.getPhrases();

    setState(() {
      _questions = phrases
          .where((e) => e['text'] != null && e['category'] != null)
          .map((e) {
        return OnboardingQuestion(
          id: e['id'] as String? ?? '',
          question: e['text'] as String? ?? '',
          category: _parseCategory(e['category'] as String? ?? 'stoicAttitude'),
          source: e['source'] as String? ?? 'Unknown',
        );
      }).toList();
      _loading = false;
    });
  }

  QuestionCategory _parseCategory(String cat) {
    switch (cat) {
      case 'stoicAttitude':
        return QuestionCategory.stoicAttitude;
      case 'grit':
        return QuestionCategory.grit;
      case 'emotionRegulation':
        return QuestionCategory.emotionRegulation;
      case 'personality':
        return QuestionCategory.personality;
      case 'stress':
        return QuestionCategory.stress;
      default:
        return QuestionCategory.stoicAttitude;
    }
  }

  void _saveResponse(String questionId, int level) async {
    setState(() {
      _responses[questionId] = level;
    });

    final db = await ref.read(databaseServiceProvider.future);
    await db.saveOnboardingResponse(questionId, level);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.accent))
            : Column(
                children: [
                  _buildProgressBar(),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (page) {
                        setState(() => _currentPage = page);
                      },
                      itemCount: _questions.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildWelcomePage(context);
                        }
                        return _buildQuestionPage(
                            context, _questions[index - 1], index);
                      },
                    ),
                  ),
                  _buildNavigationButtons(),
                ],
              ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentPage + 1) / (_questions.length + 1);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Domanda ${_currentPage == 0 ? 0 : _currentPage} di ${_questions.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              Text(
                '${(_responses.length * 100 / _questions.length).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.accent,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.spa,
            size: 80,
            color: AppColors.accent,
          ).animate().scale(duration: 600.ms),
          const SizedBox(height: 32),
          Text(
            'Analisi Iniziale',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
          const SizedBox(height: 24),
          Text(
            'Per costruire il tuo percorso personalizzato, '
            'ho bisogno di conoscerti meglio.\n\n'
            'Rispondi a ${_questions.length} domande basate su '
            'test scientifici validati:\n\n'
            '• Atitudine Stoica (Modern Stoicism)\n'
            '• Grit & Determazione (Angela Duckworth)\n'
            '• Regolazione Emotiva (DERS)\n'
            '• Personalità (Big Five)\n'
            '• Stress Percepito (PSS-10)',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.touch_app, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                'Tocca per iniziare',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.accent,
                    ),
              ),
            ],
          ).animate().fadeIn(delay: 700.ms, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(
      BuildContext context, OnboardingQuestion question, int index) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              question.categoryLabel.toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.secondary,
                    letterSpacing: 2,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            question.question,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildResponseOptions(question),
        ],
      ),
    );
  }

  Widget _buildResponseOptions(OnboardingQuestion question) {
    return Column(
      children: [
        Text(
          'Quanto ti riconosci in questa affermazione?',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            final level = index + 1;
            final isSelected = _responses[question.id] == level;

            return GestureDetector(
              onTap: () => _saveResponse(question.id, level),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isSelected ? AppColors.accent : AppColors.surfaceLight,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$level',
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Per nulla',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            Text(
              'Estremamente',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    final currentQuestionIndex = _currentPage - 1;
    final questionId =
        currentQuestionIndex >= 0 && currentQuestionIndex < _questions.length
            ? _questions[currentQuestionIndex].id
            : null;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text('INDIETRO'),
            )
          else
            const SizedBox(width: 80),
          const SizedBox(width: 8),
          if (_currentPage == 0)
            Expanded(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const OnboardingProfileScreen(),
                    ),
                  );
                },
                child: const Text('SALTA (testing)'),
              ),
            ),
          const Spacer(),
          if (_currentPage < _questions.length)
            ElevatedButton(
              onPressed:
                  questionId != null && _responses.containsKey(questionId)
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
              child: const Text('AVANTI'),
            )
          else
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const OnboardingProfileScreen(),
                  ),
                );
              },
              child: const Text('COMPLETA'),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
