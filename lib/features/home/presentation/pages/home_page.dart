import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/user_progress.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/ai_chat_provider.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../../professionals/presentation/pages/professionals_page.dart'
    show ProfessionalsPage, TeamScrollTarget;
import '../../../progress/presentation/pages/progress_page.dart';

/// Pagina principale dell'applicazione.
/// Design "Modern Fitness" - futuristico con glassmorphism e gamification.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;
  String? _chatContactName;
  TeamScrollTarget _teamScrollTarget = TeamScrollTarget.none;
  String? _progressScrollTarget;

  void _navigateToChat({String? contactName}) {
    setState(() {
      _chatContactName = contactName;
      _currentIndex = _TabIndex.chat;
    });
  }

  void _navigateToTeamWithScroll(TeamScrollTarget target) {
    setState(() {
      _teamScrollTarget = target;
      _currentIndex = _TabIndex.team;
    });
  }

  void _navigateToProgress({String? scrollTarget}) {
    setState(() {
      _progressScrollTarget = scrollTarget;
      _currentIndex = _TabIndex.progress;
    });
  }

  void _showAIAssistant(BuildContext context, String firstName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AIAssistantSheet(userName: firstName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    final pages = [
      _DashboardView(
        firstName: authState.firstName,
        onNavigateToTab: (index) => setState(() => _currentIndex = index),
        onNavigateToAppointments: () =>
            _navigateToTeamWithScroll(TeamScrollTarget.appointment),
        onNavigateToResources: () =>
            _navigateToTeamWithScroll(TeamScrollTarget.tips),
        onNavigateToChat: () => _navigateToChat(),
        onNavigateToPlan: () => _navigateToProgress(scrollTarget: 'wellness'),
      ),
      ProgressPage(
        scrollTarget: _progressScrollTarget,
        onScrollComplete: () {
          if (_progressScrollTarget != null) {
            setState(() => _progressScrollTarget = null);
          }
        },
      ),
      ChatPage(initialContactName: _chatContactName),
      ProfessionalsPage(
        onOpenChat: (professionalName) =>
            _navigateToChat(contactName: professionalName),
        scrollTarget: _teamScrollTarget,
        onScrollComplete: () {
          // Reset del flag dopo lo scroll
          if (_teamScrollTarget != TeamScrollTarget.none) {
            setState(() => _teamScrollTarget = TeamScrollTarget.none);
          }
        },
      ),
      _ProfileView(
        displayName: authState.displayName,
        email: authState.email ?? '',
      ),
    ];

    final titles = [
      AppConstants.appName,
      'Progresso',
      'Chat',
      'Il Tuo Team',
      'Profilo',
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: AppColors.background.withValues(alpha: 0.8),
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.auto_awesome),
          tooltip: 'Assistente AI',
          onPressed: () => _showAIAssistant(context, authState.firstName),
        ),
        title: Text(titles[_currentIndex]),
      ),
      body: AnimatedSwitcher(
        duration: AppConstants.defaultAnimationDuration,
        child: pages[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
            // Reset contatto chat se si naviga via bottom nav
            if (index == _TabIndex.chat) {
              _chatContactName = null;
            }
            // Reset scroll target se si naviga via bottom nav
            if (index == _TabIndex.progress) {
              _progressScrollTarget = null;
            }
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.insert_chart_outlined),
            selectedIcon: Icon(Icons.insert_chart),
            label: 'Progresso',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Team',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profilo',
          ),
        ],
      ),
    );
  }
}

/// Indici delle tab per navigazione
abstract class _TabIndex {
  static const int progress = 1;
  static const int chat = 2;
  static const int team = 3;
}

/// Vista Dashboard NUOVA - Modern Fitness con glassmorphism e gamification
class _DashboardView extends StatelessWidget {
  final String firstName;
  final void Function(int tabIndex) onNavigateToTab;
  final VoidCallback onNavigateToAppointments;
  final VoidCallback onNavigateToResources;
  final VoidCallback onNavigateToChat;
  final VoidCallback onNavigateToPlan;

  const _DashboardView({
    required this.firstName,
    required this.onNavigateToTab,
    required this.onNavigateToAppointments,
    required this.onNavigateToResources,
    required this.onNavigateToChat,
    required this.onNavigateToPlan,
  });

  // Demo data - in produzione verrebbe dal provider
  UserProgress get _demoProgress => DemoUserProgress.sample;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top + kToolbarHeight - 30;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: topInset,
        bottom: AppConstants.defaultPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HERO CARD con streak
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildHeroSection(context),
          ),
          const SizedBox(height: 28),

          // 2. CIRCULAR PROGRESS RINGS
          _buildProgressRings(context),
          const SizedBox(height: 28),

          // 3. TODAY'S WORKOUT CARD
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildTodayWorkout(context),
          ),
          const SizedBox(height: 28),

          // 4. QUICK STATS (horizontal scroll)
          _buildQuickStats(context),
          const SizedBox(height: 28),

          // 5. ACHIEVEMENTS (horizontal scroll)
          _buildAchievements(context),
          const SizedBox(height: 28),

          // 6. RECENT ACTIVITIES
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildRecentActivities(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final greeting = _getGreeting();
    final name = firstName.isNotEmpty ? firstName : 'Utente';

    return HeroStreakCard(
      greeting: greeting,
      userName: name,
      streakDays: _demoProgress.currentStreak,
      motivationalText: _getMotivationalText(),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buongiorno';
    if (hour < 18) return 'Buon pomeriggio';
    return 'Buonasera';
  }

  String _getMotivationalText() {
    final streak = _demoProgress.currentStreak;
    if (streak >= 30) return 'Incredibile! Un mese di costanza!';
    if (streak >= 14) return 'Due settimane di fuoco! Continua cosi!';
    if (streak >= 7) return 'Una settimana perfetta!';
    if (streak >= 3) return 'Ottimo inizio! Mantieni il ritmo!';
    return 'Continua il tuo percorso di benessere';
  }

  Widget _buildProgressRings(BuildContext context) {
    final goals = _demoProgress.dailyGoals;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Obiettivi di Oggi',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              TextButton(
                onPressed: () => onNavigateToTab(1),
                child: const Text('Dettagli'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildRingCard(
                context,
                progress: goals.caloriesProgress,
                color: AppColors.ringCalories,
                icon: Icons.local_fire_department,
                value: '${goals.caloriesBurned.toInt()}',
                label: 'Calorie',
                target: '/${goals.caloriesTarget.toInt()} kcal',
              ),
              const SizedBox(width: 16),
              _buildRingCard(
                context,
                progress: goals.waterProgress,
                color: AppColors.ringWater,
                icon: Icons.water_drop,
                value: goals.waterConsumed.toStringAsFixed(1),
                label: 'Acqua',
                target: '/${goals.waterTarget.toStringAsFixed(1)} L',
              ),
              const SizedBox(width: 16),
              _buildRingCard(
                context,
                progress: goals.activityProgress,
                color: AppColors.ringActivity,
                icon: Icons.directions_run,
                value: '${goals.activityMinutes}',
                label: 'Attività',
                target: '/${goals.activityTarget} min',
              ),
              const SizedBox(width: 16),
              _buildRingCard(
                context,
                progress: goals.sleepProgress,
                color: AppColors.ringSleep,
                icon: Icons.nightlight_round,
                value: goals.sleepHours.toStringAsFixed(1),
                label: 'Sonno',
                target: '/${goals.sleepTarget.toStringAsFixed(0)} ore',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRingCard(
    BuildContext context, {
    required double progress,
    required Color color,
    required IconData icon,
    required String value,
    required String label,
    required String target,
  }) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressRing(
            progress: progress,
            size: 70,
            color: color,
            strokeWidth: 8,
            centerIcon: icon,
          ),
          const SizedBox(height: 12),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: Theme.of(context).textTheme.bodySmall,
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: target,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textHint,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayWorkout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Il tuo Workout di Oggi',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 16),
        HeroWorkoutCard(
          workoutName: 'Full Body Energizzante',
          duration: '25 minuti',
          difficulty: 'Intermedio',
          difficultyColor: AppColors.warning,
          icon: Icons.fitness_center,
          onStart: onNavigateToPlan,
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final weekly = _demoProgress.weeklyStats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Statistiche Rapide',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              StatCard(
                icon: Icons.fitness_center,
                value: '${weekly.workoutsThisWeek}/${weekly.workoutsGoal}',
                label: 'Workout settimana',
                trend: 12.5,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              StatCard(
                icon: Icons.monitor_weight,
                value: '${weekly.weightChange > 0 ? '+' : ''}${weekly.weightChange.toStringAsFixed(1)} kg',
                label: 'Peso settimana',
                trend: weekly.weightChange * -10,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 12),
              StatCard(
                icon: Icons.star,
                value: '${_demoProgress.totalXP}',
                label: 'XP Totali',
                trend: 8.3,
                color: AppColors.gold,
              ),
              const SizedBox(width: 12),
              StatCard(
                icon: Icons.emoji_events,
                value: '${_demoProgress.unlockedAchievementsCount}',
                label: 'Achievements',
                color: AppColors.chartPurple,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievements(BuildContext context) {
    final unlockedAchievements =
        _demoProgress.achievements.where((a) => a.isUnlocked).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'I tuoi Achievements',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              TextButton(
                onPressed: () => onNavigateToTab(4), // Profile
                child: const Text('Vedi tutti'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: unlockedAchievements.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final achievement = unlockedAchievements[index];
              return AchievementBadge(
                icon: achievement.icon,
                title: achievement.title,
                tier: achievement.tier,
                isUnlocked: true,
                size: 70,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Attività Recenti',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Vedi tutto'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _ActivityItem(
                icon: Icons.check_circle,
                title: 'Workout completato',
                subtitle: 'Oggi, 07:30 - Full Body',
                color: AppColors.success,
              ),
              const Divider(height: 1, color: AppColors.divider),
              _ActivityItem(
                icon: Icons.local_fire_department,
                title: 'Streak mantenuta!',
                subtitle: 'Oggi - ${_demoProgress.currentStreak} giorni',
                color: AppColors.primary,
              ),
              const Divider(height: 1, color: AppColors.divider),
              _ActivityItem(
                icon: Icons.emoji_events,
                title: 'Achievement sbloccato',
                subtitle: 'Ieri - "Una Settimana"',
                color: AppColors.gold,
              ),
              const Divider(height: 1, color: AppColors.divider),
              _ActivityItem(
                icon: Icons.water_drop,
                title: 'Obiettivo acqua raggiunto',
                subtitle: 'Ieri, 18:00',
                color: AppColors.info,
              ),
            ],
          ),
        ),
      ],
    );
  }
}


/// Item attività recente
class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
    );
  }
}

/// Vista Profilo
class _ProfileView extends ConsumerWidget {
  final String displayName;
  final String email;

  const _ProfileView({
    required this.displayName,
    required this.email,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topInset = MediaQuery.of(context).padding.top + 12;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: topInset,
        left: AppConstants.defaultPadding,
        right: AppConstants.defaultPadding,
        bottom: AppConstants.defaultPadding,
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Avatar utente
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: const Icon(
                Icons.person,
                size: 48,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            displayName.isNotEmpty ? displayName : 'Utente',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 32),
          // Sezioni profilo
          _ProfileMenuItem(
            icon: Icons.person_outline,
            title: 'Dati personali',
            onTap: () {},
          ),
          _ProfileMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifiche',
            onTap: () {},
          ),
          _ProfileMenuItem(
            icon: Icons.lock_outline,
            title: 'Privacy e sicurezza',
            onTap: () {},
          ),
          _ProfileMenuItem(
            icon: Icons.help_outline,
            title: 'Assistenza',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          // Pulsante Logout
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context, ref),
              icon: const Icon(Icons.logout, color: AppColors.error, size: 20),
              label: const Text('Esci'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Conferma uscita'),
        content: const Text('Sei sicuro di voler uscire dal tuo account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppRoutes.splash);
              }
            },
            child: const Text(
              'Esci',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// Elemento menu profilo
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
    );
  }
}

/// Sheet per l'assistente AI con persistenza chat
class _AIAssistantSheet extends ConsumerStatefulWidget {
  final String userName;

  const _AIAssistantSheet({required this.userName});

  @override
  ConsumerState<_AIAssistantSheet> createState() => _AIAssistantSheetState();
}

class _AIAssistantSheetState extends ConsumerState<_AIAssistantSheet> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  static const _suggestions = [
    'Cosa posso mangiare a colazione?',
    'Come posso gestire la fame nervosa?',
    'Qual è il mio obiettivo settimanale?',
    'Consigliami uno spuntino sano',
  ];

  @override
  void initState() {
    super.initState();
    // Imposta il nome utente nel provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiChatProvider.notifier).setUserName(widget.userName);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    _controller.clear();
    FocusScope.of(context).unfocus();
    ref.read(aiChatProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  void _resetChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuova conversazione'),
        content: const Text('Vuoi iniziare una nuova conversazione?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(aiChatProvider.notifier).resetChat();
            },
            child: const Text('Conferma'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiChatProvider);

    // Scroll automatico quando arrivano nuovi messaggi
    ref.listen(aiChatProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXL)),
        ),
        child: Column(
          children: [
            _buildHeader(context, chatState.messages.isNotEmpty),
            Expanded(
              child: chatState.messages.isEmpty
                  ? _buildSuggestions(context)
                  : _buildMessages(context, chatState),
            ),
            _buildInput(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool hasMessages) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXL)),
        border: const Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Tasto reset (solo se ci sono messaggi)
          if (hasMessages)
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: IconButton(
                onPressed: _resetChat,
                icon: const Icon(Icons.refresh, size: 20),
                tooltip: 'Nuova conversazione',
              ),
            )
          else
            const SizedBox(width: 48),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo con glow
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/logo.svg',
                    height: 28,
                    width: 28,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Assistente AI',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    final displayName = widget.userName.isNotEmpty ? widget.userName : 'Utente';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          // Icona AI con glow
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ShaderMask(
                shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 44,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: Text(
              'Ciao $displayName, come posso aiutarti?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Chiedimi qualsiasi cosa sul tuo percorso!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Suggerimenti',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions.map((suggestion) {
              return ActionChip(
                label: Text(
                  suggestion,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
                onPressed: () => _sendMessage(suggestion),
                backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages(BuildContext context, AIChatState chatState) {
    final itemCount = chatState.messages.length + (chatState.isTyping ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (chatState.isTyping && index == chatState.messages.length) {
          return _buildTypingIndicator(context);
        }
        final msg = chatState.messages[index];
        return _AIMessageBubble(
          message: _AIMessage(text: msg.text, isUser: msg.isUser),
        );
      },
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium).copyWith(
            bottomLeft: const Radius.circular(4),
          ),
          border: Border.all(
            color: AppColors.divider,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.3 + (value * 0.7)),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }

  Widget _buildInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 120),
              child: TextField(
                controller: _controller,
                maxLines: null,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Scrivi un messaggio...',
                  hintStyle: const TextStyle(
                    color: AppColors.textHint,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Send button con gradient
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _sendMessage(_controller.text),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.send, color: Colors.white, size: 22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modello per messaggio AI
class _AIMessage {
  final String text;
  final bool isUser;

  const _AIMessage({required this.text, required this.isUser});
}

/// Bolla di messaggio AI con supporto markdown
class _AIMessageBubble extends StatelessWidget {
  final _AIMessage message;

  const _AIMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final textColor = message.isUser ? Colors.white : AppColors.textPrimary;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: message.isUser ? AppColors.primaryGradient : null,
          color: message.isUser ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium).copyWith(
            bottomRight: message.isUser ? const Radius.circular(4) : null,
            bottomLeft: !message.isUser ? const Radius.circular(4) : null,
          ),
          border: message.isUser
              ? null
              : Border.all(
                  color: AppColors.divider,
                  width: 1,
                ),
          boxShadow: message.isUser
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor,
                ),
            children: _parseMarkdown(message.text, textColor),
          ),
        ),
      ),
    );
  }

  /// Converte testo markdown in TextSpan formattati
  /// Supporta: **bold**, *italic*, `code`, ## headers, * liste, > citazioni
  List<TextSpan> _parseMarkdown(String text, Color? baseColor) {
    // Pre-processa il testo per gestire markdown a livello di riga
    var processed = text;

    // Rimuovi blocchi ```markdown e ``` (code blocks)
    processed = processed.replaceAll(RegExp(r'```\w*\n?'), '');
    processed = processed.replaceAll('```', '');

    // Rimuovi --- (linea orizzontale)
    processed = processed.replaceAll(RegExp(r'^-{3,}$', multiLine: true), '');

    // Rimuovi ### ## # dai titoli (in ordine da più lungo a più corto)
    processed = processed.replaceAll(RegExp(r'^###\s+', multiLine: true), '');
    processed = processed.replaceAll(RegExp(r'^##\s+', multiLine: true), '');
    processed = processed.replaceAll(RegExp(r'^#\s+', multiLine: true), '');

    // Converti liste puntate "* testo" a inizio riga in "• testo"
    processed = processed.replaceAllMapped(
      RegExp(r'^(\*)\s+', multiLine: true),
      (m) => '• ',
    );

    // Converti citazioni "> testo" rimuovendo il >
    processed = processed.replaceAll(RegExp(r'^>\s*', multiLine: true), '');

    // Rimuovi asterischi orfani (** senza chiusura, o * isolati)
    // Prima gestisci **text** (bold) sostituendo con placeholder
    final boldMatches = <String, String>{};
    var boldIndex = 0;
    processed = processed.replaceAllMapped(
      RegExp(r'\*\*([^*]+)\*\*'),
      (m) {
        final key = '\u0001BOLD$boldIndex\u0001';
        boldMatches[key] = m.group(1)!;
        boldIndex++;
        return key;
      },
    );

    // Poi gestisci *text* (italic)
    final italicMatches = <String, String>{};
    var italicIndex = 0;
    processed = processed.replaceAllMapped(
      RegExp(r'\*([^*]+)\*'),
      (m) {
        final key = '\u0002ITALIC$italicIndex\u0002';
        italicMatches[key] = m.group(1)!;
        italicIndex++;
        return key;
      },
    );

    // Gestisci `code`
    final codeMatches = <String, String>{};
    var codeIndex = 0;
    processed = processed.replaceAllMapped(
      RegExp(r'`([^`]+)`'),
      (m) {
        final key = '\u0003CODE$codeIndex\u0003';
        codeMatches[key] = m.group(1)!;
        codeIndex++;
        return key;
      },
    );

    // Rimuovi asterischi rimasti (pattern rotti)
    processed = processed.replaceAll(RegExp(r'\*+'), '');

    // Ora costruisci gli spans
    final List<TextSpan> spans = [];
    final allPlaceholders = RegExp(r'\u0001BOLD\d+\u0001|\u0002ITALIC\d+\u0002|\u0003CODE\d+\u0003');

    int lastEnd = 0;
    for (final match in allPlaceholders.allMatches(processed)) {
      // Testo normale prima del placeholder
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: processed.substring(lastEnd, match.start)));
      }

      final placeholder = match.group(0)!;
      if (placeholder.startsWith('\u0001')) {
        // Bold
        spans.add(TextSpan(
          text: boldMatches[placeholder],
          style: TextStyle(fontWeight: FontWeight.bold, color: baseColor),
        ));
      } else if (placeholder.startsWith('\u0002')) {
        // Italic
        spans.add(TextSpan(
          text: italicMatches[placeholder],
          style: TextStyle(fontStyle: FontStyle.italic, color: baseColor),
        ));
      } else if (placeholder.startsWith('\u0003')) {
        // Code
        spans.add(TextSpan(
          text: codeMatches[placeholder],
          style: TextStyle(
            fontFamily: 'monospace',
            backgroundColor: baseColor?.withValues(alpha: 0.1),
            color: baseColor,
          ),
        ));
      }

      lastEnd = match.end;
    }

    // Testo rimanente
    if (lastEnd < processed.length) {
      spans.add(TextSpan(text: processed.substring(lastEnd)));
    }

    // Se non c'erano match, restituisci il testo
    if (spans.isEmpty) {
      spans.add(TextSpan(text: processed));
    }

    return spans;
  }
}
