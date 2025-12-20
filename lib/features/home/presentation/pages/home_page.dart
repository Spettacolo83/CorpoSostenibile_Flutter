import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../../../config/theme/app_colors.dart';
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

    return Scaffold(
      appBar: AppBar(
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 32,
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
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Continua il tuo percorso di benessere',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
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
                color: AppColors.textSecondary,
                onTap: onNavigateToAppointments,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.menu_book,
                title: 'Piano Alimentare',
                color: AppColors.accent,
                onTap: onNavigateToPlan,
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
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.article_outlined,
                title: 'Risorse',
                color: AppColors.warning,
                onTap: onNavigateToResources,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I tuoi Progressi',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _ProgressIndicator(
                  label: 'Obiettivo settimanale',
                  progress: 0.7,
                  color: AppColors.warning,
                ),
                const SizedBox(height: 16),
                _ProgressIndicator(
                  label: 'Piano alimentare',
                  progress: 0.85,
                  color: AppColors.accent,
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
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Vedi tutto'),
            ),
          ],
        ),
        Card(
          child: Column(
            children: const [
              _ActivityItem(
                icon: Icons.check_circle,
                title: 'Colazione completata',
                subtitle: 'Oggi, 08:30',
                color: AppColors.warning,
              ),
              Divider(height: 1),
              _ActivityItem(
                icon: Icons.local_drink,
                title: 'Obiettivo acqua raggiunto',
                subtitle: 'Ieri, 18:00',
                color: AppColors.info,
              ),
              Divider(height: 1),
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

/// Card per azioni rapide
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // In dark mode, use a lighter version for gray/dark colors
    Color displayColor = color;
    if (isDark) {
      if (color == AppColors.textSecondary) {
        displayColor = const Color(0xFF9CA3AF); // Grigio chiaro visibile
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: displayColor.withValues(alpha: isDark ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: displayColor.withValues(alpha: isDark ? 0.4 : 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: displayColor, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: displayColor,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Indicatore di progresso
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
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
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          const SizedBox(height: 32),
          // Avatar utente
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: const Icon(
              Icons.person,
              size: 50,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            displayName.isNotEmpty ? displayName : 'Utente',
            style: Theme.of(context).textTheme.headlineSmall,
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
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context, ref),
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text('Esci'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
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
                context.go(AppRoutes.login);
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
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
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
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          // Tasto reset (solo se ci sono messaggi)
          if (hasMessages)
            IconButton(
              onPressed: _resetChat,
              icon: const Icon(Icons.refresh),
              tooltip: 'Nuova conversazione',
            )
          else
            const SizedBox(width: 48),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/logo.svg',
                  height: 32,
                  width: 32,
                ),
                const SizedBox(width: 10),
                Text(
                  'Assistente AI',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
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
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 48,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Ciao $displayName, come posso aiutarti?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
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
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions.map((suggestion) {
              return ActionChip(
                label: Text(suggestion),
                onPressed: () => _sendMessage(suggestion),
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                side: BorderSide.none,
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
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomLeft: const Radius.circular(4),
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
            shape: BoxShape.circle,
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
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
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
                decoration: InputDecoration(
                  hintText: 'Scrivi un messaggio...',
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => _sendMessage(_controller.text),
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
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
    final textColor = message.isUser ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: message.isUser
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                )
              : null,
          color: message.isUser ? null : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: message.isUser ? const Radius.circular(4) : null,
            bottomLeft: !message.isUser ? const Radius.circular(4) : null,
          ),
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
