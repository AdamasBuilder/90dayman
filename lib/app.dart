import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/onboarding/onboarding_screen.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/providers.dart';

class Uomo90App extends ConsumerWidget {
  const Uomo90App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Uomo in 90 Giorni',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppStartup(),
    );
  }
}

class AppStartup extends ConsumerWidget {
  const AppStartup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const OnboardingScreen();
        }
        if (!user.profileComplete) {
          return const OnboardingScreen();
        }
        return const HomeScreen();
      },
      loading: () => const SplashScreen(),
      error: (error, stack) {
        debugPrint('User provider error: $error');
        return const OnboardingScreen();
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accent, width: 2),
              ),
              child: const Icon(
                Icons.spa,
                size: 60,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'UOMO IN 90 GIORNI',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    letterSpacing: 4,
                  ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String error;

  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
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
                'Errore',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Retry logic
                },
                child: const Text('RIPROVA'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
