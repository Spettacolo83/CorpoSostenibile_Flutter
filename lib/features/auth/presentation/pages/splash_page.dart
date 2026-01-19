import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/routes/app_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/animated_logo.dart';

/// Pagina di splash/avvio dell'applicazione.
/// Design "Modern Fitness" - futuristico con gradient animato.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  // Controller per il testo
  late final AnimationController _textController;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  // Controller per il gradient background
  late final AnimationController _gradientController;

  // Controller per la progress bar
  late final AnimationController _progressController;

  // Controller per il glow del logo
  late final AnimationController _glowController;

  bool _animationComplete = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Controller gradient: animazione continua del background
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Controller testo: 1.5 secondi fade-in + slide
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Controller progress bar: lineare per tutta la durata
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..forward();

    // Controller glow: pulsazione del glow
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
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
    _gradientController.dispose();
    _progressController.dispose();
    _glowController.dispose();
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
      body: Stack(
        children: [
          // Animated gradient background
          _buildAnimatedGradient(),
          // Particelle decorative
          _buildParticles(),
          // Content
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  // Logo con glow
                  Center(child: _buildLogoWithGlow()),
                  const SizedBox(height: 16),
                  // Testo animato
                  Center(child: _buildAnimatedText()),
                  const Spacer(flex: 3),
                  // Progress bar futuristica
                  Center(child: _buildProgressBar()),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedGradient() {
    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, child) {
        final value = _gradientController.value;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  const Color(0xFFFF6B6B),
                  const Color(0xFFF97316),
                  value,
                )!,
                Color.lerp(
                  const Color(0xFFF97316),
                  const Color(0xFFFF6B6B),
                  value,
                )!,
                Color.lerp(
                  const Color(0xFFFF8A65),
                  const Color(0xFFFF6B6B),
                  value,
                )!,
              ],
              stops: [
                0.0,
                0.5 + (value * 0.2),
                1.0,
              ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(
                  -0.5 + value,
                  -0.5 + (value * 0.5),
                ),
                radius: 1.5,
                colors: [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlesPainter(_gradientController.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildLogoWithGlow() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glowIntensity = 0.2 + (_glowController.value * 0.3);
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: glowIntensity),
                blurRadius: 50 + (_glowController.value * 30),
                spreadRadius: 10 + (_glowController.value * 10),
              ),
            ],
          ),
          child: AnimatedLogo(
            size: 220,
            onLeavesAppeared: _onLeavesAppeared,
            onAnimationComplete: _onLogoAnimationComplete,
          ),
        );
      },
    );
  }

  Widget _buildAnimatedText() {
    return FadeTransition(
      opacity: _textFade,
      child: SlideTransition(
        position: _textSlide,
        child: Column(
          children: [
            Text(
              'corposostenibile',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Il tuo percorso verso il benessere',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.9),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              final percent = (_progressController.value * 100).toInt();
              return Text(
                'Caricamento... $percent%',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          // Progress bar con glassmorphism
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progressController.value,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [
                              Colors.white,
                              Color(0xFFFFE4B5),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.5),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter per le particelle decorative di sfondo.
class _ParticlesPainter extends CustomPainter {
  final double animationValue;

  _ParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Particelle sparse
    final particles = [
      Offset(size.width * 0.1, size.height * 0.2),
      Offset(size.width * 0.85, size.height * 0.15),
      Offset(size.width * 0.2, size.height * 0.7),
      Offset(size.width * 0.9, size.height * 0.6),
      Offset(size.width * 0.5, size.height * 0.85),
      Offset(size.width * 0.15, size.height * 0.45),
      Offset(size.width * 0.75, size.height * 0.35),
      Offset(size.width * 0.6, size.height * 0.1),
    ];

    for (var i = 0; i < particles.length; i++) {
      final particle = particles[i];
      final offset = 10 * (i.isEven ? animationValue : 1 - animationValue);
      final radius = 2.0 + (i % 3) + (animationValue * 2);

      canvas.drawCircle(
        Offset(
          particle.dx + offset * (i.isEven ? 1 : -1),
          particle.dy + offset * (i.isOdd ? 1 : -1),
        ),
        radius,
        paint..color = Colors.white.withValues(alpha: 0.05 + (i * 0.02)),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
