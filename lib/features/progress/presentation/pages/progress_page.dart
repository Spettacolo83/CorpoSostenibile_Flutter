import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/circular_progress_ring.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../../../core/widgets/stat_card.dart';

/// Tipo di grafico disponibile
enum ChartType {
  weight('Peso', 'kg', Icons.monitor_weight, AppColors.primary),
  sleep('Sonno', 'ore', Icons.nightlight_round, AppColors.ringSleep),
  bodyMass('Massa', '%', Icons.accessibility_new, AppColors.chartOrange),
  hydration('Idratazione', 'L', Icons.water_drop, AppColors.ringWater),
  calories('Calorie', 'kcal', Icons.local_fire_department, AppColors.ringCalories);

  final String label;
  final String unit;
  final IconData icon;
  final Color color;

  const ChartType(this.label, this.unit, this.icon, this.color);
}

/// Pagina Progresso - Design "Modern Fitness" con circular rings.
class ProgressPage extends StatefulWidget {
  final String? scrollTarget;
  final VoidCallback? onScrollComplete;

  const ProgressPage({
    super.key,
    this.scrollTarget,
    this.onScrollComplete,
  });

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage>
    with SingleTickerProviderStateMixin {
  ChartType _selectedChart = ChartType.weight;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _wellnessKey = GlobalKey();

  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _scrollToTargetIfNeeded();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void didUpdateWidget(ProgressPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollTarget != null &&
        widget.scrollTarget != oldWidget.scrollTarget) {
      _scrollToTargetIfNeeded();
    }
  }

  void _scrollToTargetIfNeeded() {
    if (widget.scrollTarget == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (widget.scrollTarget == 'wellness') {
        final context = _wellnessKey.currentContext;
        if (context != null) {
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
          );
        }
      }

      widget.onScrollComplete?.call();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top + 12;

    return Stack(
      children: [
        // Gradient background per header
        _buildHeaderGradient(context),
        // Content
        SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.only(
            top: topInset,
            left: AppConstants.defaultPadding,
            right: AppConstants.defaultPadding,
            bottom: AppConstants.defaultPadding + 80,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildMainRings(context),
              const SizedBox(height: 24),
              _buildChartSection(context),
              const SizedBox(height: 24),
              _buildQuickStats(context),
              const SizedBox(height: 24),
              _buildWellnessSection(context),
              const SizedBox(height: 24),
              _buildWeeklyInsights(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderGradient(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.secondary.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I Tuoi Progressi',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Traccia il tuo percorso verso il benessere',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildMainRings(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        final progress = _progressAnimation.value;
        return GlassmorphicCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // 3 Anelli principali in fila
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAnimatedRing(
                    progress: 0.64 * progress,
                    value: '${(320 * progress).toInt()}',
                    label: 'Calorie',
                    unit: 'kcal',
                    color: AppColors.ringCalories,
                    size: 90,
                  ),
                  _buildAnimatedRing(
                    progress: 0.75 * progress,
                    value: '${(1.5 * progress).toStringAsFixed(1)}',
                    label: 'Acqua',
                    unit: 'L',
                    color: AppColors.ringWater,
                    size: 90,
                  ),
                  _buildAnimatedRing(
                    progress: 0.83 * progress,
                    value: '${(25 * progress).toInt()}',
                    label: 'Attività',
                    unit: 'min',
                    color: AppColors.ringActivity,
                    size: 90,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Summary row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMiniStat(
                    Icons.local_fire_department,
                    '500',
                    'Obiettivo',
                    AppColors.ringCalories,
                  ),
                  _buildMiniStat(
                    Icons.water_drop,
                    '2.0L',
                    'Obiettivo',
                    AppColors.ringWater,
                  ),
                  _buildMiniStat(
                    Icons.directions_run,
                    '30',
                    'Obiettivo',
                    AppColors.ringActivity,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedRing({
    required double progress,
    required String value,
    required String label,
    required String unit,
    required Color color,
    required double size,
  }) {
    return Column(
      children: [
        CircularProgressRing(
          progress: progress,
          size: size,
          color: color,
          strokeWidth: 10,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildChartSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Andamento',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        _buildChartSelector(context),
        const SizedBox(height: 16),
        _buildSelectedChart(context),
      ],
    );
  }

  Widget _buildChartSelector(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ChartType.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chartType = ChartType.values[index];
          final isSelected = chartType == _selectedChart;

          return GestureDetector(
            onTap: () => setState(() => _selectedChart = chartType),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          chartType.color,
                          chartType.color.withValues(alpha: 0.8),
                        ],
                      )
                    : null,
                color: isSelected ? null : AppColors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                border: isSelected
                    ? null
                    : Border.all(color: AppColors.border),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: chartType.color.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    chartType.icon,
                    size: 18,
                    color: isSelected ? Colors.white : chartType.color,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    chartType.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : chartType.color,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedChart(BuildContext context) {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ultimi 7 giorni',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Andamento ${_selectedChart.label}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              _buildChartBadge(context),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: CustomPaint(
              size: const Size(double.infinity, 180),
              painter: _ModernChartPainter(chartType: _selectedChart),
            ),
          ),
          const SizedBox(height: 16),
          _buildChartStats(context),
        ],
      ),
    );
  }

  Widget _buildChartBadge(BuildContext context) {
    final badges = {
      ChartType.weight: ('-4.2 kg', Icons.trending_down, true),
      ChartType.sleep: ('+0.5h', Icons.trending_up, false),
      ChartType.bodyMass: ('-2.3%', Icons.trending_down, true),
      ChartType.hydration: ('+0.3L', Icons.trending_up, false),
      ChartType.calories: ('-150', Icons.trending_down, true),
    };

    final (value, icon, isPositive) = badges[_selectedChart]!;
    final color = _selectedChart.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartStats(BuildContext context) {
    final stats = {
      ChartType.weight: [
        ('Inizio', '82.5 kg'),
        ('Attuale', '78.3 kg'),
        ('Obiettivo', '75.0 kg'),
      ],
      ChartType.sleep: [
        ('Media', '7.5 ore'),
        ('Min', '6.0 ore'),
        ('Max', '9.0 ore'),
      ],
      ChartType.bodyMass: [
        ('Inizio', '28.5%'),
        ('Attuale', '26.2%'),
        ('Obiettivo', '22.0%'),
      ],
      ChartType.hydration: [
        ('Media', '2.1 L'),
        ('Ieri', '2.3 L'),
        ('Obiettivo', '2.5 L'),
      ],
      ChartType.calories: [
        ('Media', '1,850'),
        ('Oggi', '1,720'),
        ('Target', '1,800'),
      ],
    };

    final currentStats = stats[_selectedChart]!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: currentStats.asMap().entries.map((entry) {
        final (label, value) = entry.value;
        final isHighlight = entry.key == 1;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: isHighlight
              ? BoxDecoration(
                  color: _selectedChart.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          child: Column(
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isHighlight
                          ? _selectedChart.color
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quick Stats',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Vedi tutto',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              StatCard(
                icon: Icons.monitor_weight,
                value: '78.3',
                label: 'Peso (kg)',
                trend: -2.5,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              StatCard(
                icon: Icons.favorite,
                value: '68',
                label: 'BPM Riposo',
                trend: -3.0,
                color: AppColors.ringCalories,
              ),
              const SizedBox(width: 12),
              StatCard(
                icon: Icons.directions_walk,
                value: '8,432',
                label: 'Passi oggi',
                trend: 12.0,
                color: AppColors.ringActivity,
              ),
              const SizedBox(width: 12),
              StatCard(
                icon: Icons.accessibility_new,
                value: '26.2',
                label: 'BMI',
                trend: -1.5,
                color: AppColors.chartOrange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWellnessSection(BuildContext context) {
    return Column(
      key: _wellnessKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Il Tuo Benessere',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _WellnessCard(
                icon: Icons.restaurant,
                title: 'Fame',
                value: '3.2',
                subtitle: 'su 10 • Controllata',
                color: AppColors.primary,
                progress: 0.32,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _WellnessCard(
                icon: Icons.nightlight_round,
                title: 'Sonno',
                value: '7.5h',
                subtitle: 'Media settimanale',
                color: AppColors.ringSleep,
                progress: 0.75,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _WellnessCard(
                icon: Icons.emoji_emotions,
                title: 'Stress',
                value: '4.2',
                subtitle: 'su 10 • Moderato',
                color: AppColors.chartOrange,
                progress: 0.42,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _WellnessCard(
                icon: Icons.battery_charging_full,
                title: 'Energia',
                value: '7.8',
                subtitle: 'su 10 • Ottima',
                color: AppColors.ringActivity,
                progress: 0.78,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyInsights(BuildContext context) {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.insights,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Insights Settimanali',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInsightRow(
            context,
            Icons.trending_up,
            'Ottimo progresso!',
            'Hai perso 0.5 kg questa settimana',
            AppColors.success,
          ),
          const SizedBox(height: 12),
          _buildInsightRow(
            context,
            Icons.water_drop,
            'Idratazione migliorata',
            'Media aumentata del 15% rispetto alla scorsa settimana',
            AppColors.ringWater,
          ),
          const SizedBox(height: 12),
          _buildInsightRow(
            context,
            Icons.nightlight_round,
            'Qualità sonno',
            'Cerca di dormire almeno 30 min in più',
            AppColors.ringSleep,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Card Wellness con circular progress
class _WellnessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final double progress;

  const _WellnessCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              CircularProgressRing(
                progress: progress,
                size: 48,
                color: color,
                strokeWidth: 5,
                showGlow: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Painter per i grafici moderni con curve smooth
class _ModernChartPainter extends CustomPainter {
  final ChartType chartType;

  _ModernChartPainter({required this.chartType});

  @override
  void paint(Canvas canvas, Size size) {
    final chartColor = chartType.color;

    // Dati dummy per ogni tipo di grafico
    final dataMap = {
      ChartType.weight: [82.5, 82.0, 81.2, 80.5, 79.8, 79.2, 78.8, 78.3],
      ChartType.sleep: [7.0, 6.5, 8.0, 7.5, 6.0, 7.0, 8.5, 7.5],
      ChartType.bodyMass: [28.5, 28.2, 27.8, 27.5, 27.0, 26.8, 26.5, 26.2],
      ChartType.hydration: [1.8, 2.0, 2.2, 1.9, 2.3, 2.1, 2.4, 2.1],
      ChartType.calories: [2000, 1900, 1850, 1920, 1800, 1780, 1850, 1720],
    };

    final rangeMap = {
      ChartType.weight: (75.0, 85.0),
      ChartType.sleep: (5.0, 10.0),
      ChartType.bodyMass: (20.0, 32.0),
      ChartType.hydration: (1.0, 3.0),
      ChartType.calories: (1500.0, 2200.0),
    };

    final data = dataMap[chartType]!;
    final (minVal, maxVal) = rangeMap[chartType]!;
    final range = maxVal - minVal;

    // Calcola i punti
    final points = <Offset>[];
    for (var i = 0; i < data.length; i++) {
      final x = (size.width / (data.length - 1)) * i;
      final y = size.height - ((data[i] - minVal) / range * size.height);
      points.add(Offset(x, y));
    }

    // Disegna griglia orizzontale sfumata
    final gridPaint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    for (var i = 0; i <= 4; i++) {
      final y = (size.height / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Crea path curvo usando Bezier
    final path = Path();
    final fillPath = Path();

    path.moveTo(points[0].dx, points[0].dy);
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(points[0].dx, points[0].dy);

    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];

      final controlPoint1 = Offset(
        p0.dx + (p1.dx - p0.dx) / 2,
        p0.dy,
      );
      final controlPoint2 = Offset(
        p0.dx + (p1.dx - p0.dx) / 2,
        p1.dy,
      );

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );
      fillPath.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Gradient fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          chartColor.withValues(alpha: 0.3),
          chartColor.withValues(alpha: 0.05),
          chartColor.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Linea principale con glow
    final glowPaint = Paint()
      ..color = chartColor.withValues(alpha: 0.3)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(path, glowPaint);

    final linePaint = Paint()
      ..color = chartColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // Disegna punti
    for (var i = 0; i < points.length; i++) {
      final isLast = i == points.length - 1;

      // Outer glow for last point
      if (isLast) {
        final glowPaint = Paint()
          ..color = chartColor.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(points[i], 12, glowPaint);
      }

      // White border
      canvas.drawCircle(
        points[i],
        isLast ? 8 : 5,
        Paint()..color = Colors.white,
      );

      // Colored center
      canvas.drawCircle(
        points[i],
        isLast ? 6 : 3.5,
        Paint()..color = chartColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ModernChartPainter oldDelegate) =>
      oldDelegate.chartType != chartType;
}
