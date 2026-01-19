import 'achievement.dart';

/// Modello per il progresso utente con gamification.
class UserProgress {
  final int currentStreak;
  final int longestStreak;
  final int totalXP;
  final int currentLevel;
  final int workoutsCompleted;
  final List<Achievement> achievements;
  final DailyGoals dailyGoals;
  final WeeklyStats weeklyStats;

  const UserProgress({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalXP = 0,
    this.currentLevel = 1,
    this.workoutsCompleted = 0,
    this.achievements = const [],
    this.dailyGoals = const DailyGoals(),
    this.weeklyStats = const WeeklyStats(),
  });

  /// XP necessari per il prossimo livello.
  int get xpToNextLevel => currentLevel * 500;

  /// Progresso verso il prossimo livello (0.0 - 1.0).
  double get levelProgress {
    final xpInCurrentLevel = totalXP - ((currentLevel - 1) * 500);
    return xpInCurrentLevel / xpToNextLevel;
  }

  /// Numero di achievements sbloccati.
  int get unlockedAchievementsCount =>
      achievements.where((a) => a.isUnlocked).length;

  UserProgress copyWith({
    int? currentStreak,
    int? longestStreak,
    int? totalXP,
    int? currentLevel,
    int? workoutsCompleted,
    List<Achievement>? achievements,
    DailyGoals? dailyGoals,
    WeeklyStats? weeklyStats,
  }) {
    return UserProgress(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalXP: totalXP ?? this.totalXP,
      currentLevel: currentLevel ?? this.currentLevel,
      workoutsCompleted: workoutsCompleted ?? this.workoutsCompleted,
      achievements: achievements ?? this.achievements,
      dailyGoals: dailyGoals ?? this.dailyGoals,
      weeklyStats: weeklyStats ?? this.weeklyStats,
    );
  }
}

/// Obiettivi giornalieri dell'utente.
class DailyGoals {
  final double caloriesBurned;
  final double caloriesTarget;
  final double waterConsumed; // in litri
  final double waterTarget;
  final int activityMinutes;
  final int activityTarget;
  final double sleepHours;
  final double sleepTarget;

  const DailyGoals({
    this.caloriesBurned = 0,
    this.caloriesTarget = 500,
    this.waterConsumed = 0,
    this.waterTarget = 2.0,
    this.activityMinutes = 0,
    this.activityTarget = 30,
    this.sleepHours = 0,
    this.sleepTarget = 7,
  });

  /// Progress calorie (0.0 - 1.0)
  double get caloriesProgress =>
      caloriesTarget > 0 ? (caloriesBurned / caloriesTarget).clamp(0.0, 1.0) : 0;

  /// Progress acqua (0.0 - 1.0)
  double get waterProgress =>
      waterTarget > 0 ? (waterConsumed / waterTarget).clamp(0.0, 1.0) : 0;

  /// Progress attività (0.0 - 1.0)
  double get activityProgress =>
      activityTarget > 0 ? (activityMinutes / activityTarget).clamp(0.0, 1.0) : 0;

  /// Progress sonno (0.0 - 1.0)
  double get sleepProgress =>
      sleepTarget > 0 ? (sleepHours / sleepTarget).clamp(0.0, 1.0) : 0;

  DailyGoals copyWith({
    double? caloriesBurned,
    double? caloriesTarget,
    double? waterConsumed,
    double? waterTarget,
    int? activityMinutes,
    int? activityTarget,
    double? sleepHours,
    double? sleepTarget,
  }) {
    return DailyGoals(
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      caloriesTarget: caloriesTarget ?? this.caloriesTarget,
      waterConsumed: waterConsumed ?? this.waterConsumed,
      waterTarget: waterTarget ?? this.waterTarget,
      activityMinutes: activityMinutes ?? this.activityMinutes,
      activityTarget: activityTarget ?? this.activityTarget,
      sleepHours: sleepHours ?? this.sleepHours,
      sleepTarget: sleepTarget ?? this.sleepTarget,
    );
  }
}

/// Statistiche settimanali.
class WeeklyStats {
  final int workoutsThisWeek;
  final int workoutsGoal;
  final double weightChange; // +/- kg
  final List<double> caloriesHistory; // ultimi 7 giorni
  final List<double> waterHistory;
  final List<int> activityHistory;

  const WeeklyStats({
    this.workoutsThisWeek = 0,
    this.workoutsGoal = 4,
    this.weightChange = 0,
    this.caloriesHistory = const [],
    this.waterHistory = const [],
    this.activityHistory = const [],
  });

  double get workoutsProgress =>
      workoutsGoal > 0 ? (workoutsThisWeek / workoutsGoal).clamp(0.0, 1.0) : 0;

  WeeklyStats copyWith({
    int? workoutsThisWeek,
    int? workoutsGoal,
    double? weightChange,
    List<double>? caloriesHistory,
    List<double>? waterHistory,
    List<int>? activityHistory,
  }) {
    return WeeklyStats(
      workoutsThisWeek: workoutsThisWeek ?? this.workoutsThisWeek,
      workoutsGoal: workoutsGoal ?? this.workoutsGoal,
      weightChange: weightChange ?? this.weightChange,
      caloriesHistory: caloriesHistory ?? this.caloriesHistory,
      waterHistory: waterHistory ?? this.waterHistory,
      activityHistory: activityHistory ?? this.activityHistory,
    );
  }
}

/// Dati demo per testing.
class DemoUserProgress {
  static UserProgress get sample => UserProgress(
        currentStreak: 12,
        longestStreak: 28,
        totalXP: 2450,
        currentLevel: 5,
        workoutsCompleted: 47,
        dailyGoals: const DailyGoals(
          caloriesBurned: 320,
          caloriesTarget: 500,
          waterConsumed: 1.5,
          waterTarget: 2.0,
          activityMinutes: 25,
          activityTarget: 30,
          sleepHours: 7.5,
          sleepTarget: 8,
        ),
        weeklyStats: const WeeklyStats(
          workoutsThisWeek: 3,
          workoutsGoal: 4,
          weightChange: -0.5,
          caloriesHistory: [280, 350, 420, 310, 380, 290, 320],
          waterHistory: [1.8, 2.0, 1.5, 2.2, 1.9, 2.0, 1.5],
          activityHistory: [30, 45, 20, 35, 25, 40, 25],
        ),
        achievements: DefaultAchievements.all.map((a) {
          // Simula alcuni achievement sbloccati
          if (['streak_3', 'streak_7', 'first_workout', 'workouts_10', 'early_bird']
              .contains(a.id)) {
            return a.copyWith(
              isUnlocked: true,
              unlockedAt: DateTime.now().subtract(
                Duration(days: DefaultAchievements.all.indexOf(a) * 5),
              ),
            );
          }
          return a;
        }).toList(),
      );
}
