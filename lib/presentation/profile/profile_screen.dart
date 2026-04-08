import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/stoic_quotes.dart';
import '../../core/widgets/stoic_quote_card.dart';
import '../providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final eventsAsync = ref.watch(eventsProvider);

    return SafeArea(
      child: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('No user'));
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, user.name),
                const SizedBox(height: 24),
                _buildProgressOverview(context, user.currentDay, user.streakDays),
                const SizedBox(height: 24),
                _buildEmotionChart(context, eventsAsync),
                const SizedBox(height: 24),
                _buildProfileDetails(context, user),
                const SizedBox(height: 24),
                _buildSavedQuote(context),
                const SizedBox(height: 24),
                _buildSettings(context),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error')),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: AppColors.accent, width: 2),
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Viaggio iniziato',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressOverview(BuildContext context, int currentDay, int streak) {
    final progress = currentDay / 90;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(context, '$currentDay', 'Giorno'),
              Container(
                width: 1,
                height: 40,
                color: AppColors.primary.withOpacity(0.3),
              ),
              _buildStatColumn(context, '${(progress * 100).toInt()}%', 'Progresso'),
              Container(
                width: 1,
                height: 40,
                color: AppColors.primary.withOpacity(0.3),
              ),
              _buildStatColumn(context, '$streak', 'Streak'),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.background,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Giorno 1', style: Theme.of(context).textTheme.bodySmall),
              Text('Giorno 90', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.accent,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildEmotionChart(BuildContext context, AsyncValue eventsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PATTERN EMOTIVI',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: eventsAsync.when(
            data: (events) {
              if (events.isEmpty) {
                return Center(
                  child: Text(
                    'Registra eventi per vedere i tuoi pattern',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }
              
              final recentEvents = events.take(7).toList().reversed.toList();
              
              return BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 6,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            'G${value.toInt() + 1}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.primary.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: recentEvents.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.reactionLevel.toDouble(),
                          color: AppColors.getEmotionColor(entry.value.reactionLevel),
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Error')),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetails(BuildContext context, user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'IL TUO PROFILO',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          if (user.selfDescription.isNotEmpty) ...[
            _buildDetailRow(context, 'Come ti descrivi', user.selfDescription),
            const SizedBox(height: 12),
          ],
          if (user.stressResponse.isNotEmpty) ...[
            _buildDetailRow(context, 'Risposta allo stress', user.stressResponse),
            const SizedBox(height: 12),
          ],
          if (user.coreValues.isNotEmpty) ...[
            _buildDetailRow(context, 'Valori', user.coreValues.join(', ')),
            const SizedBox(height: 12),
          ],
          if (user.idealSelf90Days.isNotEmpty) ...[
            _buildDetailRow(context, 'Obiettivo 90 giorni', user.idealSelf90Days),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSavedQuote(BuildContext context) {
    final quote = StoicQuotes.getDailyQuote();
    return StoicQuoteCard(
      text: quote['text']!,
      source: quote['source'],
    );
  }

  Widget _buildSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'IMPOSTAZIONI',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildSettingTile(
          context,
          icon: Icons.notifications_outlined,
          title: 'Notifiche giornaliere',
          subtitle: '7:00 e 21:00',
          trailing: Switch(
            value: true,
            onChanged: (value) {},
            activeColor: AppColors.accent,
          ),
        ),
        _buildSettingTile(
          context,
          icon: Icons.timer_outlined,
          title: 'Modalità Focus',
          subtitle: 'Blocca il telefono finché non rispondi',
          trailing: Switch(
            value: true,
            onChanged: (value) {},
            activeColor: AppColors.accent,
          ),
        ),
        _buildSettingTile(
          context,
          icon: Icons.key_outlined,
          title: 'API Key Gemini',
          subtitle: 'Configura la tua chiave AI',
          trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          onTap: () => _showApiKeyDialog(context),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.accent),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showApiKeyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Configura Gemini API'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Inserisci la tua API key di Google Gemini per abilitare le domande AI personalizzate.',
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'Inserisci la tua key',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ANNULLA'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('SALVA'),
          ),
        ],
      ),
    );
  }
}
