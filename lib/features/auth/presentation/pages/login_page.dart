import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../config/theme/theme_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';

/// Pagina di login con design "Biohacking Tech".
/// Stile futuristico con gradienti e forme squadrate.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
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
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    await ref.read(authProvider.notifier).login(_emailController.text.trim());

    if (!mounted) return;
    setState(() => _isLoading = false);
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient tech
          _buildBackgroundGradient(isDark),
          // Content
          SafeArea(
            child: Column(
              children: [
                // AppBar custom con theme toggle
                _buildAppBar(currentTheme),
                // Form scrollabile
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppConstants.largePadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        _buildHeader(isDark),
                        const SizedBox(height: 40),
                        _buildForm(isDark),
                        const SizedBox(height: 24),
                        _buildLoginButton(),
                        const SizedBox(height: 16),
                        _buildForgotPassword(),
                        const SizedBox(height: 32),
                        _buildDivider(isDark),
                        const SizedBox(height: 32),
                        _buildSocialLogin(isDark),
                        const SizedBox(height: 24),
                        _buildRegisterLink(isDark),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Gradient background tech
  Widget _buildBackgroundGradient(bool isDark) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppColors.backgroundDark,
                    AppColors.surfaceDark,
                    AppColors.backgroundDark,
                  ]
                : [
                    AppColors.background,
                    AppColors.surface,
                    AppColors.background,
                  ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  /// AppBar con theme toggle
  Widget _buildAppBar(ThemeModeOption currentTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Theme Toggle Button
          PopupMenuButton<ThemeModeOption>(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                currentTheme.icon,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            tooltip: 'Tema: ${currentTheme.label}',
            onSelected: (mode) => ref.read(themeProvider.notifier).setTheme(mode),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            ),
            itemBuilder: (context) => ThemeModeOption.values.map((mode) {
              final isSelected = mode == currentTheme;
              return PopupMenuItem<ThemeModeOption>(
                value: mode,
                child: Row(
                  children: [
                    Icon(
                      mode.icon,
                      color: isSelected ? AppColors.primary : null,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      mode.label,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? AppColors.primary : null,
                      ),
                    ),
                    if (isSelected) ...[
                      const Spacer(),
                      const Icon(Icons.check, color: AppColors.primary, size: 18),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        // Logo con glow effect
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: isDark ? 0.4 : 0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Image.asset(
            'assets/icons/app_icon_foreground.png',
            width: 140,
            height: 140,
          ),
        ),
        const SizedBox(height: 32),
        // Title con gradient (visivo)
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.primary, AppColors.accent],
          ).createShader(bounds),
          child: Text(
            'Bentornato!',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Accedi per continuare il tuo percorso',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildForm(bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.none,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'inserisci la tua email',
              prefixIcon: const Icon(Icons.email_outlined),
              // Tech border style on focus
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
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
          // Password Field
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
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Accedi',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
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

  Widget _buildDivider(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  isDark ? AppColors.borderDark : AppColors.border,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'oppure',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isDark ? AppColors.borderDark : AppColors.border,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogin(bool isDark) {
    return Column(
      children: [
        // Google button
        _SocialButton(
          icon: Icons.g_mobiledata,
          label: 'Continua con Google',
          isDark: isDark,
          onPressed: () {
            // TODO: Implementare login con Google
          },
        ),
        const SizedBox(height: 12),
        // Apple button
        _SocialButton(
          icon: Icons.apple,
          label: 'Continua con Apple',
          isDark: isDark,
          onPressed: () {
            // TODO: Implementare login con Apple
          },
        ),
      ],
    );
  }

  Widget _buildRegisterLink(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Non hai un account? ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
        ),
        TextButton(
          onPressed: () {
            // TODO: Navigare alla pagina di registrazione
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Registrati'),
        ),
      ],
    );
  }
}

/// Social login button con stile tech
class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isDark
              ? AppColors.surfaceVariantDark.withValues(alpha: 0.5)
              : AppColors.surfaceVariant,
          side: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: icon == Icons.g_mobiledata ? 28 : 24,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
