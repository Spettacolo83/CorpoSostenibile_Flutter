import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_theme.dart';

/// Tier degli achievement.
enum AchievementTier {
  bronze(Color(0xFFCD7F32), 'Bronzo'),
  silver(Color(0xFFC0C0C0), 'Argento'),
  gold(Color(0xFFFFD700), 'Oro'),
  platinum(Color(0xFFE5E4E2), 'Platino');

  final Color color;
  final String label;

  const AchievementTier(this.color, this.label);
}

/// Badge achievement con animazione unlock.
class AchievementBadge extends StatefulWidget {
  final IconData icon;
  final String title;
  final AchievementTier tier;
  final bool isUnlocked;
  final bool showAnimation;
  final VoidCallback? onTap;
  final double size;

  const AchievementBadge({
    super.key,
    required this.icon,
    required this.title,
    required this.tier,
    this.isUnlocked = false,
    this.showAnimation = false,
    this.onTap,
    this.size = 80,
  });

  @override
  State<AchievementBadge> createState() => _AchievementBadgeState();
}

class _AchievementBadgeState extends State<AchievementBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _glowAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    if (widget.showAnimation) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.showAnimation ? _scaleAnimation.value : 1.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Badge circle
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: widget.isUnlocked
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.tier.color,
                              widget.tier.color.withValues(alpha: 0.7),
                            ],
                          )
                        : null,
                    color: widget.isUnlocked ? null : AppColors.surfaceVariant,
                    boxShadow: widget.isUnlocked
                        ? [
                            BoxShadow(
                              color: widget.tier.color.withValues(
                                alpha: 0.4 * _glowAnimation.value,
                              ),
                              blurRadius: 20 * _glowAnimation.value,
                              spreadRadius: 2 * _glowAnimation.value,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      size: widget.size * 0.45,
                      color: widget.isUnlocked
                          ? Colors.white
                          : AppColors.textHint,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Title
                SizedBox(
                  width: widget.size + 20,
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: widget.isUnlocked
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Card per singolo achievement con dettagli.
class AchievementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final AchievementTier tier;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final VoidCallback? onTap;

  const AchievementCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.tier,
    this.isUnlocked = false,
    this.unlockedAt,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(
            color: isUnlocked
                ? tier.color.withValues(alpha: 0.3)
                : AppColors.divider,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: tier.color.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Badge icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isUnlocked
                    ? LinearGradient(
                        colors: [
                          tier.color,
                          tier.color.withValues(alpha: 0.7),
                        ],
                      )
                    : null,
                color: isUnlocked ? null : AppColors.surfaceVariant,
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 28,
                  color: isUnlocked ? Colors.white : AppColors.textHint,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isUnlocked
                                        ? AppColors.textPrimary
                                        : AppColors.textHint,
                                  ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? tier.color.withValues(alpha: 0.15)
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tier.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isUnlocked ? tier.color : AppColors.textHint,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isUnlocked && unlockedAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Sbloccato il ${_formatDate(unlockedAt!)}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textHint,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Streak badge con counter animato.
class StreakBadge extends StatelessWidget {
  final int streakDays;
  final bool showFlame;

  const StreakBadge({
    super.key,
    required this.streakDays,
    this.showFlame = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFF97316)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showFlame)
            const Icon(
              Icons.local_fire_department,
              color: Colors.white,
              size: 20,
            ),
          if (showFlame) const SizedBox(width: 6),
          Text(
            '$streakDays giorni',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Level badge con progress al prossimo livello.
class LevelBadge extends StatelessWidget {
  final int level;
  final double progressToNext; // 0.0 - 1.0
  final int currentXP;
  final int xpToNextLevel;

  const LevelBadge({
    super.key,
    required this.level,
    required this.progressToNext,
    required this.currentXP,
    required this.xpToNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$level',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Livello $level',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      '$currentXP / $xpToNextLevel XP',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressToNext,
              minHeight: 8,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
