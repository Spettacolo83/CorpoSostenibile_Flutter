import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/routes/app_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/animated_logo.dart';

/// Pagina di splash/avvio dell'applicazione.
/// Mostra il logo animato con SVG e verifica lo stato di autenticazione.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  // Controller per il testo
  late final AnimationController _textController;
  late final Animation<double> _textFade;
  bool _animationComplete = false;

  @override
  void initState() {
    super.initState();
    _setupTextAnimation();
  }

  void _setupTextAnimation() {
    // Controller testo: 2 secondi fade-in
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeIn,
      ),
    );
  }

  void _onLeavesAppeared() {
    // Avvia fade-in del testo quando le foglie sono apparse
    _textController.forward();
  }

  void _onLogoAnimationComplete() {
    setState(() => _animationComplete = true);
    _navigateBasedOnAuthState();
  }

  void _navigateBasedOnAuthState() {
    final authState = ref.read(authProvider);

    // Attende che l'auth sia inizializzato
    if (!authState.isInitialized) {
      // Riprova tra poco
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _navigateBasedOnAuthState();
      });
      return;
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      if (authState.isLoggedIn) {
        context.go(AppRoutes.home);
      } else {
        context.go(AppRoutes.login);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ascolta i cambiamenti dell'auth state
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (_animationComplete && next.isInitialized) {
        _navigateBasedOnAuthState();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animato
            AnimatedLogo(
              size: 250,
              onLeavesAppeared: _onLeavesAppeared,
              onAnimationComplete: _onLogoAnimationComplete,
            ),
            const SizedBox(height: 8),
            // Testo con fade-in
            FadeTransition(
              opacity: _textFade,
              child: Text(
                'corposostenibile',
                style: GoogleFonts.quicksand(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
