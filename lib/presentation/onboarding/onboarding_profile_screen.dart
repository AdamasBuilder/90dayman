import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../providers.dart';
import '../home/home_screen.dart';

class OnboardingProfileScreen extends ConsumerStatefulWidget {
  const OnboardingProfileScreen({super.key});

  @override
  ConsumerState<OnboardingProfileScreen> createState() =>
      _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState
    extends ConsumerState<OnboardingProfileScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  String _name = '';
  String _painPoints = '';
  String _selfDescription = '';
  String _stressResponse = '';
  List<String> _coreValues = [];
  List<String> _avoidedThings = [];
  String _idealSelf90Days = '';

  final List<String> _allValues = [
    'Onestà',
    'Lealtà',
    'Coraggio',
    'Disciplina',
    'Pazienza',
    'Rispetto',
    'Responsabilità',
    'Umiltà',
    'Determinazione',
    'Saggezza',
    'Amicizia',
    'Famiglia',
    'Salute',
    'Libertà',
    'Successo',
    'Felicità',
    'Spiritualità',
    'Conoscenza',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Domanda ${_currentPage + 1} di 7'),
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              )
            : null,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentPage + 1) / 7,
            backgroundColor: AppColors.surface,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                _buildNamePage(),
                _buildPainPointsPage(),
                _buildSelfDescriptionPage(),
                _buildStressResponsePage(),
                _buildCoreValuesPage(),
                _buildAvoidedThingsPage(),
                _buildIdealSelfPage(),
              ],
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Prima di tutto,\ncome ti chiami?',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          TextField(
            autofocus: true,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
            decoration: InputDecoration(
              hintText: 'Il tuo nome',
              hintStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            onChanged: (value) => _name = value,
          ),
        ],
      ),
    );
  }

  Widget _buildPainPointsPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Cosa ti porta qui oggi?\nQual è il tuo punto di sofferenza?',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Descrivi liberamente cosa ti turba o cosa vuoi migliorare',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: TextField(
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: 'Scrivi qui i tuoi pensieri...',
                alignLabelWithHint: true,
              ),
              onChanged: (value) => _painPoints = value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelfDescriptionPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Descrivi te stesso\ncon tre aggettivi',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Scegli tre aggettivi che ti definiscono',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: TextField(
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: 'Ad esempio: determinato, impulsivo, leale...',
                alignLabelWithHint: true,
              ),
              onChanged: (value) => _selfDescription = value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStressResponsePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Come rispondi\nnormalmente allo stress?',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ...[
            'Fuga - evito la situazione',
            'Attacco - reagisco con forza',
            'Paralisi - mi blocco',
            'Riflessione - analizzo e agisco'
          ].map((option) {
            final isSelected = _stressResponse == option;
            return GestureDetector(
              onTap: () => setState(() => _stressResponse = option),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isSelected ? AppColors.accent : AppColors.primary,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 16),
                    Text(option, style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCoreValuesPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Quali sono i tuoi\ntre valori più importanti?',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allValues.map<Widget>((value) {
                final isSelected = _coreValues.contains(value);
                return FilterChip(
                  label: Text(value),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected && _coreValues.length < 3) {
                        _coreValues.add(value);
                      } else if (!selected) {
                        _coreValues.remove(value);
                      }
                    });
                  },
                  selectedColor: AppColors.accent,
                  checkmarkColor: AppColors.background,
                );
              }).toList(),
            ),
          ),
          Text(
            'Selezionati: ${_coreValues.length}/3',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildAvoidedThingsPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Cosa eviti di fare\no affrontare che sai di dover affrontare?',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: TextField(
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: 'Scrivi le cose che eviti...',
                alignLabelWithHint: true,
              ),
              onChanged: (value) {
                _avoidedThings = value
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdealSelfPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Definisci il "te stesso ideale"\ntra 90 giorni',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Come sarai quando avrai completato il percorso?',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: TextField(
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: 'Descrivi la versione migliore di te...',
                alignLabelWithHint: true,
              ),
              onChanged: (value) => _idealSelf90Days = value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TextButton(
            onPressed: () async {
              await _completeProfile();
            },
            child: const Text('SALTA QUESTA DOMANDA'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_currentPage < 6) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  _completeProfile();
                }
              },
              child: Text(_currentPage == 6 ? 'COMPLETA PROFILO' : 'CONTINUA'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeProfile() async {
    await ref
        .read(userProvider.notifier)
        .createUser(_name.trim().isNotEmpty ? _name.trim() : 'Utente Demo');

    await ref.read(userProvider.notifier).updateProfile(
          painPoints: _painPoints
              .split('\n')
              .where((e) => e.trim().isNotEmpty)
              .toList(),
          selfDescription: _selfDescription.isNotEmpty
              ? _selfDescription
              : 'Utente in testing',
          stressResponse: _stressResponse.isNotEmpty ? _stressResponse : 'work',
          coreValues: _coreValues.isNotEmpty
              ? _coreValues
              : ['Disciplina', 'Coraggio', 'Onestà'],
          avoidedThings: _avoidedThings,
          idealSelf90Days: _idealSelf90Days.isNotEmpty
              ? _idealSelf90Days
              : 'Diventare una versione migliore di me stesso',
        );

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }
}
