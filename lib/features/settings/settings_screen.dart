import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_games_list/core/utils/l10n_extensions.dart';
import 'package:my_games_list/core/utils/messages_extensions.dart';
import 'package:my_games_list/features/auth/bloc/auth_bloc.dart';
import 'package:my_games_list/features/auth/bloc/auth_event.dart';
import 'package:my_games_list/features/auth/bloc/auth_state.dart';
import 'package:my_games_list/features/settings/bloc/account_management_bloc.dart';
import 'package:my_games_list/features/settings/bloc/account_management_event.dart';
import 'package:my_games_list/features/settings/bloc/account_management_state.dart';
import 'package:my_games_list/features/settings/bloc/settings_bloc.dart';
import 'package:my_games_list/features/settings/bloc/settings_event.dart';
import 'package:my_games_list/features/settings/bloc/settings_state.dart';
import 'package:my_games_list/features/settings/widgets/delete_account_dialog.dart';

// Language autonyms — shown in their own language, intentionally not localized.
const List<({String code, String name})> _languageOptions = [
  (code: 'en', name: 'English'),
  (code: 'pt', name: 'Português'),
];

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthBloc and SettingsBloc are already provided at the app level;
    // AccountManagementBloc is provided by the settings route.
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Section
            Text(
              context.l10n.userInformationTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        Text(
                          context.l10n.nameFormat(
                            user?.name ?? context.l10n.unknown,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10n.emailFormat(
                            user?.email ?? context.l10n.unknown,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Theme Settings Section
            Text(
              context.l10n.appearanceTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                return SwitchListTile(
                  title: Text(context.l10n.darkModeTitle),
                  subtitle: Text(context.l10n.darkModeSubtitle),
                  value: state.isDarkMode,
                  onChanged: (value) => context.read<SettingsBloc>().add(
                    SettingsDarkModeSet(value),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Language Settings Section
            Text(
              context.l10n.languageTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(context.l10n.languageTitle),
                    trailing: DropdownButton<String?>(
                      value: state.localeCode,
                      onChanged: (value) => context.read<SettingsBloc>().add(
                        SettingsLocaleSet(value),
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(context.l10n.languageSystem),
                        ),
                        for (final option in _languageOptions)
                          DropdownMenuItem<String?>(
                            value: option.code,
                            child: Text(option.name),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Privacy & data Section (LGPD: export + delete)
            const _PrivacyDataSection(),
            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Logout teardown (token + per-user in-memory state) is
                  // handled centrally by AuthBloc via SessionResetService.
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(context.l10n.logoutButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyDataSection extends StatelessWidget {
  const _PrivacyDataSection();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountManagementBloc, AccountManagementState>(
      listenWhen: (previous, current) =>
          previous.exportStatus != current.exportStatus ||
          previous.deleteStatus != current.deleteStatus,
      listener: _onStateChanged,
      child: BlocBuilder<AccountManagementBloc, AccountManagementState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.privacyDataTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.download_outlined),
                      title: Text(context.l10n.exportDataTitle),
                      subtitle: Text(context.l10n.exportDataSubtitle),
                      trailing:
                          state.exportStatus == AccountActionStatus.loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.chevron_right),
                      onTap: state.isBusy
                          ? null
                          : () => context.read<AccountManagementBloc>().add(
                              const AccountManagementExportRequested(),
                            ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.delete_forever_outlined,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      title: Text(
                        context.l10n.deleteAccountTitle,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      subtitle: Text(context.l10n.deleteAccountSubtitle),
                      trailing:
                          state.deleteStatus == AccountActionStatus.loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                      onTap: state.isBusy
                          ? null
                          : () => _confirmDelete(context),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onStateChanged(BuildContext context, AccountManagementState state) {
    if (state.exportStatus == AccountActionStatus.success) {
      context.showSuccessMessage(context.l10n.exportDataSuccess);
    } else if (state.exportStatus == AccountActionStatus.failure) {
      context.showErrorMessage(context.l10n.exportDataError);
    }

    if (state.deleteStatus == AccountActionStatus.success) {
      // Tear down the session the same way logout does, then the router
      // redirects to sign-in once AuthUnauthenticated is emitted.
      context.read<AuthBloc>().add(const AuthLogoutRequested());
    } else if (state.deleteStatus == AccountActionStatus.failure) {
      context.showErrorMessage(context.l10n.deleteAccountError);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final bloc = context.read<AccountManagementBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const DeleteAccountDialog(),
    );

    if (confirmed ?? false) {
      bloc.add(const AccountManagementDeleteRequested());
    }
  }
}
