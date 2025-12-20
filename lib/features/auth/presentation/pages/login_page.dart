import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

/// Pagina di login dell'applicazione.
/// Gestisce l'autenticazione con email/password e OAuth.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // TODO: Implementare autenticazione reale
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => _isLoading = false);
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              _buildHeader(),
              const SizedBox(height: 48),
              _buildForm(),
              const SizedBox(height: 24),
              _buildLoginButton(),
              const SizedBox(height: 16),
              _buildForgotPassword(),
              const SizedBox(height: 32),
              _buildDivider(),
              const SizedBox(height: 32),
              _buildSocialLogin(),
              const SizedBox(height: 24),
              _buildRegisterLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.eco,
            size: 40,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Bentornato!',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Accedi per continuare il tuo percorso',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'inserisci la tua email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Inserisci la tua email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Inserisci un\'email valida';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'inserisci la tua password',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Inserisci la tua password';
              }
              if (value.length < 6) {
                return 'La password deve avere almeno 6 caratteri';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Accedi'),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return TextButton(
      onPressed: () {
        // TODO: Navigare alla pagina di recupero password
      },
      child: const Text('Password dimenticata?'),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'oppure',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        SizedBox(
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implementare login con Google
            },
            icon: const Icon(Icons.g_mobiledata, size: 28),
            label: const Text('Continua con Google'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implementare login con Apple
            },
            icon: const Icon(Icons.apple, size: 24),
            label: const Text('Continua con Apple'),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Non hai un account? ',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () {
            // TODO: Navigare alla pagina di registrazione
          },
          child: const Text('Registrati'),
        ),
      ],
    );
  }
}
