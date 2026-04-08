import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/stoic_quotes.dart';
import '../../core/widgets/stoic_quote_card.dart';
import '../providers.dart';
import '../diary/new_event_screen.dart';
import '../challenge/daily_challenge_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final todayEventsAsync = ref.watch(todayEventsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: [
          _buildDashboard(context, userAsync, todayEventsAsync),
          _buildDiaryPage(context, todayEventsAsync),
          _buildChallengePage(context),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => _navigateToNewEvent(context),
              backgroundColor: AppColors.accent,
              icon: const Icon(Icons.add),
              label: const Text('Nuovo Evento'),
            )
          : null,
    );
  }

  Widget _buildDashboard(
      BuildContext context, AsyncValue userAsync, AsyncValue todayEventsAsync) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            userAsync.when(
              data: (user) {
                if (user == null) return const SizedBox();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      StoicQuotes.getGreeting(user),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 8),
                    Text(
                      StoicQuotes.getMorningMotivation(user.currentDay),
                      style: Theme.of(context).textTheme.bodySmall,
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const SizedBox(),
            ),
            const SizedBox(height: 32),
            _buildProgressCard(context, userAsync),
            const SizedBox(height: 24),
            _buildTodaySummary(context, todayEventsAsync),
            const SizedBox(height: 24),
            _buildQuoteCard(context),
            const SizedBox(height: 24),
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, AsyncValue userAsync) {
    return userAsync.when(
      data: (user) {
        if (user == null) return const SizedBox();
        final progress = user.currentDay / 90;
        final daysLeft = 90 - user.currentDay;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.3),
                AppColors.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.accent.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_fire_department,
                      color: AppColors.accent),
                  const SizedBox(width: 8),
                  Text(
                    'GIORNO ${user.currentDay}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: AppColors.surface,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).toInt()}% completato',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '$daysLeft giorni rimanenti',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatItem(
                      context, '${user.streakDays}', 'Giorni\nconsecutivi'),
                  const SizedBox(width: 24),
                  _buildStatItem(context, '${(progress * 90).toInt()}',
                      'Azioni\ncompiute'),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildTodaySummary(BuildContext context, AsyncValue todayEventsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.today, color: AppColors.secondary, size: 20),
            const SizedBox(width: 8),
            Text(
              'I TUOI EVENTI DI OGGI',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    letterSpacing: 1.5,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        todayEventsAsync.when(
          data: (events) {
            if (events.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.note_add_outlined,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nessun evento registrato oggi',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cosa ti è successo? Come hai reagito?',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: events
                  .take(3)
                  .map<Widget>((event) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.getEmotionColor(
                                    event.reactionLevel),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  '${event.reactionLevel}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                event.description,
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox(),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildQuoteCard(BuildContext context) {
    final quote = StoicQuotes.getDailyQuote();
    return StoicQuoteCard(
      text: quote['text']!,
      source: quote['source'],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AZIONI RAPIDE',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                letterSpacing: 1.5,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.add_circle_outline,
                label: 'Nuovo Evento',
                onTap: () => _navigateToNewEvent(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.psychology,
                label: 'Sfida AI',
                onTap: () => _openChallenge(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.wb_sunny_outlined,
                label: 'Riflessione\nMattutina',
                onTap: () => _startMorningReflection(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.nights_stay_outlined,
                label: 'Riflessione\nSera',
                onTap: () => _startEveningReflection(context),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.primary.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.accent, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiaryPage(BuildContext context, AsyncValue todayEventsAsync) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'DIARIO',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Expanded(
            child: todayEventsAsync.when(
              data: (events) {
                if (events.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.book_outlined,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Il tuo diario è vuoto',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Aggiungi il tuo primo evento',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppColors.getEmotionColor(event.feelingLevel)
                              .withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.getEmotionColor(
                                  event.reactionLevel),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                '${event.reactionLevel}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.description,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${event.timestamp.hour}:${event.timestamp.minute.toString().padLeft(2, '0')}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Errore')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengePage(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'S.fida GIORNALIERA',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Domande scomode generate dall\'AI',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(60),
                      border: Border.all(color: AppColors.accent, width: 2),
                    ),
                    child: const Icon(
                      Icons.psychology,
                      size: 60,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'La tua sfida ti aspetta',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Affronta una domanda scomoda per\ncontinuare il tuo percorso',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => _openChallenge(context),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('INIZIA LA SFIDA'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'CRONOLOGIA',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    letterSpacing: 1.5,
                  ),
            ),
            const SizedBox(height: 16),
            _buildChallengeHistory(context),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeHistory(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final questionsAsync = ref.watch(questionsProvider);

        return questionsAsync.when(
          data: (questions) {
            if (questions.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Nessuna sfida completata ancora',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              );
            }
            return Column(
              children: questions
                  .take(5)
                  .map<Widget>((q) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              q.isAnswered
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: q.isAnswered
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    q.typeLabel,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                  Text(
                                    q.question,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox(),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.surface, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Diario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_outlined),
            activeIcon: Icon(Icons.psychology),
            label: 'Sfida',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profilo',
          ),
        ],
      ),
    );
  }

  void _navigateToNewEvent(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewEventScreen()),
    );
  }

  void _openChallenge(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DailyChallengeScreen()),
    );
  }

  void _startMorningReflection(BuildContext context) {
    _openChallenge(context);
  }

  void _startEveningReflection(BuildContext context) {
    _openChallenge(context);
  }
}
