import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/theme_provider.dart';
import '../../../core/constants/colors.dart';

/// Profile screen with a simple dark mode toggle hook.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primaryYellow,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'Test User',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 32),
          Text(
            'App Settings',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.primaryYellow,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Toggle between Light and Dark interface'),
              value: isDark,
              activeColor: AppColors.primaryYellow,
              onChanged: (val) {
                ref.read(themeProvider.notifier).setThemeMode(
                      val ? ThemeMode.dark : ThemeMode.light,
                    );
              },
              secondary: const Icon(Icons.dark_mode_outlined),
            ),
          ),
        ],
      ),
    );
  }
}
