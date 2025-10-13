import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_games_list/blocs/auth_bloc.dart';
import 'package:my_games_list/blocs/auth_event.dart';
import 'package:my_games_list/blocs/auth_state.dart';
import 'package:my_games_list/blocs/settings_bloc.dart';
import 'package:my_games_list/blocs/settings_event.dart';
import 'package:my_games_list/blocs/settings_state.dart';
import 'package:my_games_list/utils/app_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthBloc and SettingsBloc are already provided at the app level
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.homePath),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Section
            const Text(
              'User Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final user = state is AuthAuthenticated ? state.user : null;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: ${user?.name ?? 'Unknown'}'),
                        const SizedBox(height: 4),
                        Text('Email: ${user?.email ?? 'Unknown'}'),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Theme Settings Section
            const Text(
              'Appearance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                return SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle between light and dark theme'),
                  value: state.isDarkMode,
                  onChanged: (value) => context.read<SettingsBloc>().add(
                    SettingsDarkModeSet(value),
                  ),
                );
              },
            ),
            const Spacer(),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                  context.go(AppRouter.signInPath);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
