import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../config/theme/theme_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/ai_chat_provider.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../../professionals/presentation/pages/professionals_page.dart'
    show ProfessionalsPage, TeamScrollTarget;
import '../../../progress/presentation/pages/progress_page.dart';

/// Pagina principale dell'applicazione.
/// Mostra la dashboard con le funzionalità principali.
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

    final currentTheme = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: isDark
                  ? AppColors.backgroundDark.withValues(alpha: 0.7)
                  : AppColors.background.withValues(alpha: 0.8),
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.auto_awesome),
          tooltip: 'Assistente AI',
          onPressed: () => _showAIAssistant(context, authState.firstName),
        ),
        title: Text(titles[_currentIndex]),
        actions: [
          PopupMenuButton<ThemeModeOption>(
            icon: Icon(currentTheme.icon),
            tooltip: 'Tema: ${currentTheme.label}',
            onSelected: (mode) => ref.read(themeProvider.notifier).setTheme(mode),
            itemBuilder: (context) => ThemeModeOption.values.map((mode) {
              return PopupMenuItem<ThemeModeOption>(
                value: mode,
                child: Row(
                  children: [
                    Icon(
                      mode.icon,
                      color: mode == currentTheme ? AppColors.primary : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      mode.label,
                      style: TextStyle(
                        fontWeight:
                            mode == currentTheme ? FontWeight.bold : null,
                        color: mode == currentTheme ? AppColors.primary : null,
                      ),
                    ),
                    if (mode == currentTheme) ...[
                      const Spacer(),
                      const Icon(Icons.check, color: AppColors.primary),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
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

/// Vista Dashboard con panoramica del percorso utente
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

  @override
  Widget build(BuildContext context) {
    // Top padding ridotto: solo safe area + piccolo gap
    final topInset = MediaQuery.of(context).padding.top + 12;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: topInset,
        left: AppConstants.defaultPadding,
        right: AppConstants.defaultPadding,
        bottom: AppConstants.defaultPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreetingCard(context, firstName),
          const SizedBox(height: 24),
          _buildQuickActions(context),
          const SizedBox(height: 24),
          _buildProgressSection(context),
          const SizedBox(height: 24),
          _buildRecentActivities(context),
        ],
      ),
    );
  }

  Widget _buildGreetingCard(BuildContext context, String name) {
    final greeting = name.isNotEmpty ? 'Ciao, $name!' : 'Ciao!';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge), // ARROTONDATO
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.4 : 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar con bordo tech
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Continua il tuo percorso di benessere',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Azioni Rapide',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.calendar_today,
                title: 'Appuntamenti',
                color: AppColors.secondary, // Viola tech
                onTap: onNavigateToAppointments,
                isSquared: true, // SQUADRATO
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.menu_book,
                title: 'Piano Alimentare',
                color: AppColors.primary, // Verde primary leggibile
                onTap: onNavigateToPlan,
                isSquared: false, // ARROTONDATO
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.chat_bubble_outline,
                title: 'Messaggi',
                color: AppColors.info,
                onTap: onNavigateToChat,
                isSquared: false, // ARROTONDATO
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.article_outlined,
                title: 'Risorse',
                color: AppColors.neonOrange, // NEON!
                onTap: onNavigateToResources,
                isSquared: true, // SQUADRATO
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I tuoi Progressi',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        // Card SQUADRATA per coerenza con greeting
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusNone), // SQUADRATO
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.divider,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _ProgressIndicator(
                label: 'Obiettivo settimanale',
                progress: 0.7,
                color: AppColors.neonOrange, // NEON!
              ),
              const SizedBox(height: 16),
              _ProgressIndicator(
                label: 'Piano alimentare',
                progress: 0.85,
                color: AppColors.primary, // Verde primary leggibile
              ),
              const SizedBox(height: 16),
              _ProgressIndicator(
                label: 'Idratazione',
                progress: 0.6,
                color: AppColors.info,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Attività Recenti',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Vedi tutto'),
            ),
          ],
        ),
        // Card ARROTONDATA (alternata con quella squadrata sopra)
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.divider,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _ActivityItem(
                icon: Icons.check_circle,
                title: 'Colazione completata',
                subtitle: 'Oggi, 08:30',
                color: AppColors.neonOrange, // NEON!
              ),
              Divider(
                height: 1,
                color: isDark ? AppColors.borderDark : AppColors.divider,
              ),
              _ActivityItem(
                icon: Icons.local_drink,
                title: 'Obiettivo acqua raggiunto',
                subtitle: 'Ieri, 18:00',
                color: AppColors.info,
              ),
              Divider(
                height: 1,
                color: isDark ? AppColors.borderDark : AppColors.divider,
              ),
              _ActivityItem(
                icon: Icons.event_available,
                title: 'Appuntamento confermato',
                subtitle: 'Ieri, 10:00',
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Card per azioni rapide - Stile Tech con alternanza
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final bool isSquared;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    this.isSquared = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // In dark mode, use appropriate colors
    Color displayColor = color;
    if (isDark) {
      if (color == AppColors.textSecondary) {
        displayColor = AppColors.textSecondaryDark;
      }
    }

    final borderRadius = isSquared ? AppTheme.radiusNone : AppTheme.radiusMedium;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceVariantDark
                : displayColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isDark
                  ? AppColors.borderDark
                  : displayColor.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Icona con sfondo tech - SQUADRATA per coerenza
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: displayColor.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(icon, color: displayColor, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Indicatore di progresso - Stile Tech
class _ProgressIndicator extends StatelessWidget {
  final String label;
  final double progress;
  final Color color;

  const _ProgressIndicator({
    required this.label,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark
                ? color.withValues(alpha: 0.15)
                : color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

/// Item attività recente - Stile Tech
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
      ),
    );
  }
}

/// Vista Profilo - Stile Tech
class _ProfileView extends ConsumerWidget {
  final String displayName;
  final String email;

  const _ProfileView({
    required this.displayName,
    required this.email,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Top padding ridotto: solo safe area + piccolo gap
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
          // Avatar utente con glow tech
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
                  color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.primary.withValues(alpha: 0.1),
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
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
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
          // Pulsante Logout - Stile Tech
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

/// Elemento menu profilo - Stile Tech
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.divider,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          color: isDark ? AppColors.backgroundDark : AppColors.background,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXL)),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.divider,
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
                color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
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
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          // Icona AI con glow tech
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: isDark ? 0.4 : 0.25),
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
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Chiedimi qualsiasi cosa sul tuo percorso!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Suggerimenti',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
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
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
                onPressed: () => _sendMessage(suggestion),
                backgroundColor: isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.primary.withValues(alpha: 0.08),
                side: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.primary.withValues(alpha: 0.2),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium).copyWith(
            bottomLeft: const Radius.circular(4),
          ),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.divider,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.divider,
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
                style: TextStyle(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Scrivi un messaggio...',
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.textHintDark : AppColors.textHint,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
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

/// Bolla di messaggio AI con supporto markdown - Stile Tech
class _AIMessageBubble extends StatelessWidget {
  final _AIMessage message;

  const _AIMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = message.isUser
        ? Colors.white
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary);

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: message.isUser ? AppColors.primaryGradient : null,
          color: message.isUser
              ? null
              : (isDark ? AppColors.surfaceDark : AppColors.surface),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium).copyWith(
            bottomRight: message.isUser ? const Radius.circular(4) : null,
            bottomLeft: !message.isUser ? const Radius.circular(4) : null,
          ),
          border: message.isUser
              ? null
              : Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.divider,
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
