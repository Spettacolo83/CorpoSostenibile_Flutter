import 'package:flutter/material.dart';

import '../widgets/achievement_badge.dart';

/// Modello per un achievement/badge.
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final AchievementTier tier;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.tier,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    AchievementTier? tier,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      tier: tier ?? this.tier,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

/// Achievements predefiniti per l'app.
class DefaultAchievements {
  static List<Achievement> get all => [
        // Streak Achievements
        const Achievement(
          id: 'streak_3',
          title: '3 Giorni',
          description: 'Mantieni una streak di 3 giorni consecutivi',
          icon: Icons.local_fire_department,
          tier: AchievementTier.bronze,
        ),
        const Achievement(
          id: 'streak_7',
          title: 'Una Settimana',
          description: 'Mantieni una streak di 7 giorni consecutivi',
          icon: Icons.local_fire_department,
          tier: AchievementTier.bronze,
        ),
        const Achievement(
          id: 'streak_14',
          title: 'Due Settimane',
          description: 'Mantieni una streak di 14 giorni consecutivi',
          icon: Icons.local_fire_department,
          tier: AchievementTier.silver,
        ),
        const Achievement(
          id: 'streak_30',
          title: 'Un Mese',
          description: 'Mantieni una streak di 30 giorni consecutivi',
          icon: Icons.local_fire_department,
          tier: AchievementTier.gold,
        ),
        const Achievement(
          id: 'streak_90',
          title: 'Tre Mesi',
          description: 'Mantieni una streak di 90 giorni consecutivi',
          icon: Icons.local_fire_department,
          tier: AchievementTier.platinum,
        ),

        // Milestone Achievements
        const Achievement(
          id: 'first_workout',
          title: 'Primo Passo',
          description: 'Completa il tuo primo workout',
          icon: Icons.fitness_center,
          tier: AchievementTier.bronze,
        ),
        const Achievement(
          id: 'workouts_10',
          title: 'In Forma',
          description: 'Completa 10 workout',
          icon: Icons.fitness_center,
          tier: AchievementTier.silver,
        ),
        const Achievement(
          id: 'workouts_50',
          title: 'Atleta',
          description: 'Completa 50 workout',
          icon: Icons.fitness_center,
          tier: AchievementTier.gold,
        ),

        // Category Trophies
        const Achievement(
          id: 'nutrition_master',
          title: 'Nutrizionista',
          description: 'Completa il tuo piano alimentare per una settimana',
          icon: Icons.restaurant,
          tier: AchievementTier.silver,
        ),
        const Achievement(
          id: 'hydration_master',
          title: 'Idratato',
          description: 'Raggiungi l\'obiettivo acqua per 7 giorni',
          icon: Icons.water_drop,
          tier: AchievementTier.silver,
        ),
        const Achievement(
          id: 'sleep_master',
          title: 'Dormiente',
          description: 'Dormi almeno 7 ore per 7 notti',
          icon: Icons.nightlight,
          tier: AchievementTier.silver,
        ),

        // Special Achievements
        const Achievement(
          id: 'early_bird',
          title: 'Mattiniero',
          description: 'Completa un workout prima delle 7:00',
          icon: Icons.wb_sunny,
          tier: AchievementTier.bronze,
        ),
        const Achievement(
          id: 'weekend_warrior',
          title: 'Weekend Warrior',
          description: 'Allènati nel weekend per 4 settimane consecutive',
          icon: Icons.calendar_today,
          tier: AchievementTier.gold,
        ),
      ];
}
