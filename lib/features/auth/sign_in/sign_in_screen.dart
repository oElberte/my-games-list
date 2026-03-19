import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_games_list/core/utils/app_router.dart';
import 'package:my_games_list/core/utils/l10n_extensions.dart';
import 'package:my_games_list/core/utils/messages_extensions.dart';
import 'package:my_games_list/features/auth/bloc/auth_bloc.dart';
import 'package:my_games_list/features/auth/bloc/auth_event.dart';
import 'package:my_games_list/features/auth/sign_in/bloc/sign_in_bloc.dart';
import 'package:my_games_list/features/auth/sign_in/bloc/sign_in_event.dart';
import 'package:my_games_list/features/auth/sign_in/bloc/sign_in_state.dart';
import 'package:validatorless/validatorless.dart';

/// SignIn screen with email/password authentication.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<SignInBloc>().add(
        SignInSubmitted(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignInBloc, SignInState>(
      listener: (context, state) {
        if (state is SignInSuccess) {
          // Update global auth state with authenticated user
          context.read<AuthBloc>().add(
            AuthUserAuthenticated(state.authResponse.user),
          );
          // Navigate to home on success
          context.go('/');
        } else if (state is SignInError) {
          // Show error message
          context.showErrorMessage(state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.signInTitle),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App Title/Logo
                    const Icon(Icons.games, size: 80, color: Colors.blue),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.appTitle,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.signInSubtitle,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: context.l10n.emailLabel,
                        hintText: context.l10n.emailHint,
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: const OutlineInputBorder(),
                      ),
                      validator: Validatorless.multiple([
                        Validatorless.required(context.l10n.emailRequired),
                        Validatorless.email(context.l10n.emailInvalid),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleSignIn(),
                      decoration: InputDecoration(
                        labelText: context.l10n.passwordLabel,
                        hintText: context.l10n.passwordHint,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: Validatorless.multiple([
                        Validatorless.required(context.l10n.passwordRequired),
                        Validatorless.min(6, context.l10n.passwordMinLength),
                      ]),
                    ),
                    const SizedBox(height: 24),

                    // Sign In Button
                    BlocBuilder<SignInBloc, SignInState>(
                      builder: (context, state) {
                        final isLoading = state is SignInLoading;

                        return ElevatedButton(
                          onPressed: isLoading ? null : _handleSignIn,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  context.l10n.signInButton,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(context.l10n.noAccount),
                        TextButton(
                          onPressed: () => context.go(AppRouter.signUpPath),
                          child: Text(
                            context.l10n.signUpLink,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Social Sign-In Divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            context.l10n.orContinueWith,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Google Sign-In Button
                    BlocBuilder<SignInBloc, SignInState>(
                      builder: (context, state) {
                        final isLoading = state is SignInLoading;
                        return OutlinedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () => context.read<SignInBloc>().add(
                                    const GoogleSignInRequested(),
                                  ),
                          icon: const Icon(Icons.g_mobiledata, size: 24),
                          label: Text(context.l10n.signInWithGoogle),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
