import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Widget che anima il logo SVG con le 3 foglie separate.
/// Ogni foglia appare in sequenza e poi ondeggia con effetto vento.
class AnimatedLogo extends StatefulWidget {
  final double size;
  final VoidCallback? onLeavesAppeared;
  final VoidCallback? onAnimationComplete;

  const AnimatedLogo({
    super.key,
    this.size = 250,
    this.onLeavesAppeared,
    this.onAnimationComplete,
  });

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with TickerProviderStateMixin {
  // SVG strings per ogni foglia
  String? _svgFogliaBasso;
  String? _svgFogliaDestra;
  String? _svgFogliaSinistra;

  // Controller per l'apparizione delle foglie
  late final AnimationController _appearController;
  late final Animation<double> _fogliaBasso;
  late final Animation<double> _fogliaDestra;
  late final Animation<double> _fogliaSinistra;

  // Controller per l'ondeggiamento (vento)
  late final AnimationController _windController;
  late final Animation<double> _windAnimation;

  // Sequenza rotazioni: 0° → 5° → -4° → 3° → -2° → 0°
  final List<double> _rotationSequence = [0, 5, -4, 3, -2, 0];

  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadAndParseSvg();
  }

  void _setupAnimations() {
    // Controller apparizione: 3 secondi totali (1s per foglia)
    _appearController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Foglia basso: 0-1s
    _fogliaBasso = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _appearController,
        curve: const Interval(0.0, 0.333, curve: Curves.elasticOut),
      ),
    );

    // Foglia destra: 1-2s
    _fogliaDestra = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _appearController,
        curve: const Interval(0.333, 0.666, curve: Curves.elasticOut),
      ),
    );

    // Foglia sinistra: 2-3s
    _fogliaSinistra = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _appearController,
        curve: const Interval(0.666, 1.0, curve: Curves.elasticOut),
      ),
    );

    // Controller vento: 4 secondi (5 rotazioni × 0.5s = 2.5s + pausa)
    _windController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    _windAnimation = Tween<double>(begin: 0.0, end: 5.0).animate(
      CurvedAnimation(
        parent: _windController,
        curve: const Interval(0.0, 0.625, curve: Curves.linear),
      ),
    );
  }

  Future<void> _loadAndParseSvg() async {
    final svgString = await rootBundle.loadString('assets/icons/logo.svg');

    // Estrai i path dal SVG
    final fogliaBasso = _extractPathSvg(svgString, 'object-1');
    final fogliaDestra = _extractPathSvg(svgString, 'object-0');
    final fogliaSinistra = _extractPathSvg(svgString, 'object-2');

    if (mounted) {
      setState(() {
        _svgFogliaBasso = fogliaBasso;
        _svgFogliaDestra = fogliaDestra;
        _svgFogliaSinistra = fogliaSinistra;
        _isLoaded = true;
      });

      // Avvia l'animazione
      _startAnimationSequence();
    }
  }

  /// Estrae un singolo path dall'SVG creando un nuovo SVG con solo quel path
  String _extractPathSvg(String fullSvg, String pathId) {
    // Trova il viewBox e le dimensioni originali
    final viewBoxMatch = RegExp(r'viewBox="([^"]*)"').firstMatch(fullSvg);
    final viewBox = viewBoxMatch?.group(1) ?? '0 0 480 378';

    // Trova il path specifico
    final pathRegex = RegExp(
      r'<path[^>]*id="' + pathId + r'"[^>]*>.*?</path>',
      dotAll: true,
    );
    final pathMatch = pathRegex.firstMatch(fullSvg);

    if (pathMatch == null) {
      // Prova con path auto-chiuso
      final pathRegex2 = RegExp(
        r'<path[^>]*id="' + pathId + r'"[^/]*/?>',
        dotAll: true,
      );
      final pathMatch2 = pathRegex2.firstMatch(fullSvg);
      if (pathMatch2 == null) return '';

      final pathElement = pathMatch2.group(0) ?? '';
      return _buildSvgWithPath(viewBox, pathElement);
    }

    final pathElement = pathMatch.group(0) ?? '';
    return _buildSvgWithPath(viewBox, pathElement);
  }

  String _buildSvgWithPath(String viewBox, String pathElement) {
    // Estrai il transform dal gruppo originale se presente
    return '''<?xml version="1.0" encoding="utf-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="$viewBox" preserveAspectRatio="xMidYMid meet">
  <g transform="matrix(2.7356860637664795, 0, 0, 2.7356860637664795, -332.73370361328125, -403.46136474609375)">
    $pathElement
  </g>
</svg>''';
  }

  Future<void> _startAnimationSequence() async {
    // 1. Avvia apparizione foglie (3 secondi)
    _appearController.forward();

    // 2. Dopo 3 secondi, notifica che le foglie sono apparse e avvia ondeggiamento
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    widget.onLeavesAppeared?.call();
    _windController.forward();

    // 3. Dopo 4 secondi di vento, notifica completamento
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    widget.onAnimationComplete?.call();
  }

  double _getRotationAngle(double animationValue) {
    if (animationValue >= 5.0) return 0.0;

    final index = animationValue.floor();
    final progress = animationValue - index;

    if (index >= _rotationSequence.length - 1) {
      return _rotationSequence.last;
    }

    final startAngle = _rotationSequence[index];
    final endAngle = _rotationSequence[index + 1];

    // Interpolazione smooth
    final easedProgress = Curves.easeInOut.transform(progress);
    return startAngle + (endAngle - startAngle) * easedProgress;
  }

  @override
  void dispose() {
    _appearController.dispose();
    _windController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
      );
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _appearController,
          _windController,
        ]),
        builder: (context, child) {
          final rotation = _getRotationAngle(_windAnimation.value);
          final rotationRadians = rotation * math.pi / 180;

          return Stack(
            alignment: Alignment.center,
            children: [
              // Foglia basso (appare per prima)
              if (_svgFogliaBasso != null)
                _buildAnimatedLeaf(
                  _svgFogliaBasso!,
                  _fogliaBasso.value,
                  rotationRadians,
                ),
              // Foglia destra (appare seconda)
              if (_svgFogliaDestra != null)
                _buildAnimatedLeaf(
                  _svgFogliaDestra!,
                  _fogliaDestra.value,
                  rotationRadians,
                ),
              // Foglia sinistra (appare terza)
              if (_svgFogliaSinistra != null)
                _buildAnimatedLeaf(
                  _svgFogliaSinistra!,
                  _fogliaSinistra.value,
                  rotationRadians,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimatedLeaf(
    String svgString,
    double appearValue,
    double rotation,
  ) {
    if (appearValue == 0) return const SizedBox.shrink();

    return Positioned.fill(
      child: Transform(
        alignment: Alignment.bottomCenter,
        transform: Matrix4.identity()
          ..scale(appearValue)
          ..rotateZ(rotation),
        child: Opacity(
          opacity: appearValue.clamp(0.0, 1.0),
          child: SvgPicture.string(
            svgString,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
