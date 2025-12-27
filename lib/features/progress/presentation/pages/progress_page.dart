import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

/// Tipo di grafico disponibile - Colori NEON tech
enum ChartType {
  weight('Peso', 'kg', Icons.monitor_weight, AppColors.primary),
  sleep('Sonno', 'ore', Icons.nightlight_round, AppColors.neonBlue),
  bodyMass('Massa', '%', Icons.accessibility_new, AppColors.neonOrange),
  hydration('Idratazione', 'L', Icons.water_drop, AppColors.neonPurple),
  calories('Calorie', 'kcal', Icons.local_fire_department, AppColors.neonRed);

  final String label;
  final String unit;
  final IconData icon;
  final Color color;

  const ChartType(this.label, this.unit, this.icon, this.color);
}

/// Pagina Progresso - Mostra i grafici di avanzamento dell'utente.
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

class _ProgressPageState extends State<ProgressPage> {
  ChartType _selectedChart = ChartType.weight;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _wellnessKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollToTargetIfNeeded();
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
        // Scorri fino a "Il Tuo Benessere"
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Top padding ridotto: solo safe area + piccolo gap
    final topInset = MediaQuery.of(context).padding.top + 12;

    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.only(
        top: topInset,
        left: AppConstants.defaultPadding,
        right: AppConstants.defaultPadding,
        bottom: AppConstants.defaultPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartSelector(context),
          const SizedBox(height: 16),
          _buildSelectedChart(context),
          const SizedBox(height: 24),
          _buildSyncCard(context),
          const SizedBox(height: 24),
          _buildProgressGrid(context),
          const SizedBox(height: 24),
          _buildWeeklyStats(context),
        ],
      ),
    );
  }

  Widget _buildChartSelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ChartType.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chartType = ChartType.values[index];
          final isSelected = chartType == _selectedChart;
          final chipColor = chartType.color;

          // Chip con bordo neon separato (uniforme visivamente)
          return Container(
            padding: isSelected
                ? const EdgeInsets.symmetric(horizontal: 3, vertical: 1)
                : EdgeInsets.zero,
            decoration: isSelected
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall + 3),
                    border: Border.all(
                      color: chipColor.withValues(alpha: 0.7),
                      width: 1.5,
                    ),
                  )
                : null,
            child: FilterChip(
              selected: isSelected,
              showCheckmark: false,
              avatar: Icon(
                chartType.icon,
                size: 18,
                color: isSelected ? Colors.white : chipColor,
              ),
              label: Text(chartType.label),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : chipColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              backgroundColor: isDark
                  ? AppColors.surfaceVariantDark
                  : Colors.transparent,
              selectedColor: chipColor,
              side: BorderSide(
                color: isSelected ? chipColor : chipColor.withValues(alpha: 0.5),
                width: isSelected ? 0 : 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              onSelected: (_) {
                setState(() => _selectedChart = chartType);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedChart(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // SQUADRATO
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusNone),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Andamento ${_selectedChart.label}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                _buildChartBadge(context),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              child: CustomPaint(
                size: const Size(double.infinity, 180),
                painter: _ChartPainter(chartType: _selectedChart),
              ),
            ),
            const SizedBox(height: 16),
            _buildChartStats(context),
          ],
        ),
      ),
    );
  }

  Widget _buildChartBadge(BuildContext context) {
    // Badge info - usa il colore del chart selezionato
    final badges = {
      ChartType.weight: ('-4.2 kg', Icons.trending_down),
      ChartType.sleep: ('+0.5h', Icons.trending_up),
      ChartType.bodyMass: ('-2.3%', Icons.trending_down),
      ChartType.hydration: ('+0.3L', Icons.trending_up),
      ChartType.calories: ('-150', Icons.trending_down),
    };

    final (value, icon) = badges[_selectedChart]!;
    final color = _selectedChart.color; // Usa il colore del chart!

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
        final color = entry.key == 1 ? AppColors.primary : AppColors.textSecondary;

        return Column(
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
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSyncCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: const Icon(
                Icons.watch,
                color: AppColors.info,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Smartwatch Sincronizzato',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Apple Watch • Ultimo sync: 5 min fa',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sincronizzazione in corso...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.sync, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressGrid(BuildContext context) {
    return Column(
      key: _wellnessKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Il Tuo Benessere',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ProgressCard(
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
              child: _ProgressCard(
                icon: Icons.nightlight_round,
                title: 'Sonno',
                value: '7.5h',
                subtitle: 'Media settimanale',
                color: AppColors.info,
                progress: 0.75,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ProgressCard(
                icon: Icons.local_fire_department,
                title: 'Calorie',
                value: '1,850',
                subtitle: 'kcal oggi',
                color: const Color(0xFFE57373),
                progress: 0.85,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ProgressCard(
                icon: Icons.directions_walk,
                title: 'Passi',
                value: '8,432',
                subtitle: 'Obiettivo: 10,000',
                color: AppColors.neonPurple, // Viola neon
                progress: 0.84,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyStats(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Riepilogo Settimanale',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              context,
              Icons.emoji_emotions,
              'Umore medio',
              'Buono',
              AppColors.success,
            ),
            const Divider(height: 24),
            _buildStatRow(
              context,
              Icons.water_drop,
              'Idratazione',
              '2.1L / giorno',
              AppColors.info,
            ),
            const Divider(height: 24),
            _buildStatRow(
              context,
              Icons.fitness_center,
              'Allenamenti',
              '4 sessioni',
              const Color(0xFFE57373),
            ),
            const Divider(height: 24),
            _buildStatRow(
              context,
              Icons.self_improvement,
              'Mindfulness',
              '35 min totali',
              AppColors.neonPurple, // Viola neon
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
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
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}

/// Card per mostrare un indicatore di progresso - SQUADRATA
class _ProgressCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final double progress;

  const _ProgressCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // SQUADRATA
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusNone),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter per i grafici
class _ChartPainter extends CustomPainter {
  final ChartType chartType;

  _ChartPainter({required this.chartType});

  @override
  void paint(Canvas canvas, Size size) {
    final chartColor = chartType.color;

    final paint = Paint()
      ..color = chartColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          chartColor.withValues(alpha: 0.3),
          chartColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

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

    final path = Path();
    final fillPath = Path();

    for (var i = 0; i < data.length; i++) {
      final x = (size.width / (data.length - 1)) * i;
      final y = size.height - ((data[i] - minVal) / range * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Disegna griglia
    final gridPaint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      final y = size.height / 3 * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Disegna riempimento e linea
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Disegna punti
    final dotPaint = Paint()
      ..color = chartColor
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (var i = 0; i < data.length; i++) {
      final x = (size.width / (data.length - 1)) * i;
      final y = size.height - ((data[i] - minVal) / range * size.height);

      canvas.drawCircle(Offset(x, y), 6, dotBorderPaint);
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) =>
      oldDelegate.chartType != chartType;
}
