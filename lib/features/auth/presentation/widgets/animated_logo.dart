import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Widget che anima il logo SVG con le 3 foglie separate.
/// Ogni foglia appare in sequenza e poi pulsa con effetto battito cardiaco.
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

  // Controller per il battito cardiaco (3 battiti)
  late final AnimationController _heartbeatController;
  late final Animation<double> _heartbeatAnimation;

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

    // Controller battito cardiaco: 3 battiti in ~4.5 secondi
    // Ogni battito: lub-dub + pausa = 1.5s per battito
    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );

    // Animazione da 0 a 3 (3 battiti)
    _heartbeatAnimation = Tween<double>(begin: 0.0, end: 3.0).animate(
      CurvedAnimation(
        parent: _heartbeatController,
        curve: Curves.linear,
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
    // 0. Delay iniziale per permettere il rendering completo
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    // 1. Avvia apparizione foglie (3 secondi)
    _appearController.forward();

    // 2. Dopo 3 secondi, notifica che le foglie sono apparse e avvia battito cardiaco
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    widget.onLeavesAppeared?.call();
    _heartbeatController.forward();

    // 3. Dopo 4.5 secondi di battito (3 battiti), notifica completamento
    await Future.delayed(const Duration(milliseconds: 4500));
    if (!mounted) return;
    widget.onAnimationComplete?.call();
  }

  /// Calcola la scala per l'effetto battito cardiaco realistico.
  /// Ogni battito ha 2 pulsazioni (lub-dub):
  /// - LUB: pulsazione forte (1.0 → 1.15 → 1.0)
  /// - DUB: pulsazione più debole (1.0 → 1.08 → 1.0)
  /// - Pausa prima del prossimo battito
  double _getHeartbeatScale(double animationValue) {
    if (animationValue >= 3.0) return 1.0;

    // Ogni battito completo occupa 1 unità di animationValue
    // Struttura di un battito:
    // 0.00-0.20: LUB (pulsazione forte)
    // 0.20-0.40: DUB (pulsazione debole)
    // 0.40-1.00: Pausa
    final beatProgress = animationValue % 1.0;

    if (beatProgress < 0.20) {
      // LUB - Prima pulsazione (forte): 1.0 → 1.15 → 1.0
      final lubProgress = beatProgress / 0.20;
      if (lubProgress < 0.5) {
        // Zoom in
        final zoomIn = lubProgress / 0.5;
        return 1.0 + (0.15 * Curves.easeOut.transform(zoomIn));
      } else {
        // Zoom out
        final zoomOut = (lubProgress - 0.5) / 0.5;
        return 1.15 - (0.15 * Curves.easeIn.transform(zoomOut));
      }
    } else if (beatProgress < 0.40) {
      // DUB - Seconda pulsazione (debole): 1.0 → 1.08 → 1.0
      final dubProgress = (beatProgress - 0.20) / 0.20;
      if (dubProgress < 0.5) {
        // Zoom in
        final zoomIn = dubProgress / 0.5;
        return 1.0 + (0.08 * Curves.easeOut.transform(zoomIn));
      } else {
        // Zoom out
        final zoomOut = (dubProgress - 0.5) / 0.5;
        return 1.08 - (0.08 * Curves.easeIn.transform(zoomOut));
      }
    } else {
      // Pausa tra i battiti
      return 1.0;
    }
  }

  @override
  void dispose() {
    _appearController.dispose();
    _heartbeatController.dispose();
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
          _heartbeatController,
        ]),
        builder: (context, child) {
          final heartbeatScale = _getHeartbeatScale(_heartbeatAnimation.value);

          return Transform.scale(
            scale: heartbeatScale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Foglia basso (appare per prima)
                if (_svgFogliaBasso != null)
                  _buildAnimatedLeaf(
                    _svgFogliaBasso!,
                    _fogliaBasso.value,
                  ),
                // Foglia destra (appare seconda)
                if (_svgFogliaDestra != null)
                  _buildAnimatedLeaf(
                    _svgFogliaDestra!,
                    _fogliaDestra.value,
                  ),
                // Foglia sinistra (appare terza)
                if (_svgFogliaSinistra != null)
                  _buildAnimatedLeaf(
                    _svgFogliaSinistra!,
                    _fogliaSinistra.value,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedLeaf(
    String svgString,
    double appearValue,
  ) {
    if (appearValue == 0) return const SizedBox.shrink();

    return Positioned.fill(
      child: Transform.scale(
        scale: appearValue,
        alignment: Alignment.bottomCenter,
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
