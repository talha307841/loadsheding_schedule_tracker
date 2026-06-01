import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'presentation/providers/app_state_provider.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/shell_screen.dart';

class PowerAlertApp extends StatelessWidget {
  const PowerAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, state, _) {
        final themeMode = state.darkModeEnabled ? ThemeMode.dark : ThemeMode.light;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'PowerAlert Pakistan',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          home: state.loading
              ? const _SplashScreen()
              : (state.hasSelection ? const ShellScreen() : const OnboardingScreen()),
        );
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bolt_rounded, color: Theme.of(context).colorScheme.primary, size: 64),
            const SizedBox(height: 16),
            Text('PowerAlert Pakistan', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
