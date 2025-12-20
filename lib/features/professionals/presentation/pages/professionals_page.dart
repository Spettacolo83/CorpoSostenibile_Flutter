import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

/// Tipo di scroll per la pagina Team
enum TeamScrollTarget { none, tips, appointment }

/// Modello per un professionista
class Professional {
  final String name;
  final String role;
  final String specialty;
  final String description;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final Color color;
  final String? avatarPath;

  const Professional({
    required this.name,
    required this.role,
    required this.specialty,
    required this.description,
    required this.rating,
    required this.reviewCount,
    this.isAvailable = true,
    required this.color,
    this.avatarPath,
  });
}

/// Modello per un consiglio del giorno
class DailyTip {
  final String title;
  final String content;
  final String author;
  final IconData icon;
  final Color color;

  const DailyTip({
    required this.title,
    required this.content,
    required this.author,
    required this.icon,
    required this.color,
  });
}

/// Pagina Professionisti - Il tuo team di supporto.
class ProfessionalsPage extends StatefulWidget {
  final void Function(String professionalName)? onOpenChat;
  final TeamScrollTarget scrollTarget;
  final VoidCallback? onScrollComplete;

  const ProfessionalsPage({
    super.key,
    this.onOpenChat,
    this.scrollTarget = TeamScrollTarget.none,
    this.onScrollComplete,
  });

  @override
  State<ProfessionalsPage> createState() => _ProfessionalsPageState();
}

class _ProfessionalsPageState extends State<ProfessionalsPage> {
  final ScrollController _scrollController = ScrollController();

  static const List<Professional> _professionals = [
    Professional(
      name: 'Alice P.',
      role: 'Nutrizionista',
      specialty: 'Nutrizione Integrativa',
      description:
          'Specializzata in piani alimentari personalizzati e sostenibili. '
          'Ti aiuterò a trovare il tuo equilibrio senza rinunce.',
      rating: 4.9,
      reviewCount: 127,
      color: AppColors.primary,
      avatarPath: 'assets/images/alice_avatar.png',
    ),
    Professional(
      name: 'Lorenzo S.',
      role: 'Coach',
      specialty: 'Fitness & Lifestyle',
      description:
          'Il movimento è medicina. Ti guiderò in un percorso di attività fisica '
          'adatto al tuo stile di vita, senza eccessi.',
      rating: 4.8,
      reviewCount: 98,
      color: AppColors.warning,
      avatarPath: 'assets/images/lorenzo_avatar.png',
    ),
    Professional(
      name: 'Delia D.S.',
      role: 'Psicologa Alimentare',
      specialty: 'Psicologia del Comportamento',
      description:
          'Insieme lavoreremo sulle cause profonde del tuo rapporto con il cibo. '
          'Niente giudizi, solo comprensione e crescita.',
      rating: 4.9,
      reviewCount: 156,
      color: AppColors.info,
      avatarPath: 'assets/images/delia_avatar.png',
    ),
  ];

  static const List<DailyTip> _dailyTips = [
    DailyTip(
      title: 'Consiglio Nutrizionale',
      content:
          'Oggi prova ad aggiungere una porzione extra di verdure al pranzo. '
          'Non come sacrificio, ma come regalo al tuo corpo!',
      author: 'Alice P.',
      icon: Icons.restaurant,
      color: AppColors.primary,
    ),
    DailyTip(
      title: 'Movimento del Giorno',
      content:
          'Una camminata di 15 minuti dopo pranzo può fare miracoli per la digestione '
          'e il tuo umore. Provaci!',
      author: 'Lorenzo S.',
      icon: Icons.directions_walk,
      color: AppColors.warning,
    ),
    DailyTip(
      title: 'Mindfulness',
      content:
          'Prima di mangiare, fermati un attimo. Respira. Chiediti: "Ho davvero fame '
          'o sto cercando altro?" La consapevolezza è il primo passo.',
      author: 'Delia D.S.',
      icon: Icons.self_improvement,
      color: AppColors.info,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollToTargetIfNeeded();
  }

  @override
  void didUpdateWidget(ProfessionalsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollTarget != TeamScrollTarget.none &&
        widget.scrollTarget != oldWidget.scrollTarget) {
      _scrollToTargetIfNeeded();
    }
  }

  void _scrollToTargetIfNeeded() {
    if (widget.scrollTarget == TeamScrollTarget.none) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      double targetOffset;
      if (widget.scrollTarget == TeamScrollTarget.appointment) {
        // Scroll to the bottom where the appointment section is
        targetOffset = _scrollController.position.maxScrollExtent;
      } else {
        // Scroll to tips section (just past the header, ~200px)
        targetOffset = 200;
      }

      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );

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
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildDailyTips(context),
          const SizedBox(height: 24),
          _buildTeamSection(context),
          const SizedBox(height: 24),
          _buildNextAppointment(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.8),
            AppColors.primaryLight.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.groups,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Il Tuo Team',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Un approccio integrato con Nutrizionista, Coach e Psicologa '
            'per accompagnarti verso il tuo benessere sostenibile.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTips(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Consigli del Giorno',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Archivio'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _dailyTips.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _DailyTipCard(tip: _dailyTips[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTeamSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I Tuoi Professionisti',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ..._professionals.map((pro) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ProfessionalCard(
                professional: pro,
                onMessageTap: widget.onOpenChat != null
                    ? () => widget.onOpenChat!(pro.name)
                    : null,
              ),
            )),
      ],
    );
  }

  Widget _buildNextAppointment(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.event,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prossimo Appuntamento',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : null,
                            ),
                      ),
                      Text(
                        'Lunedì 23 Dicembre, 10:00',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0x33000000),
                    backgroundImage: AssetImage('assets/images/alice_avatar.png'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alice P.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textPrimaryDark : null,
                              ),
                        ),
                        Text(
                          'Check-up settimanale',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.videocam, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Modifica'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Prepara'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Card per un consiglio del giorno
class _DailyTipCard extends StatelessWidget {
  final DailyTip tip;

  const _DailyTipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tip.color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tip.color.withValues(alpha: isDark ? 0.4 : 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(tip.icon, color: tip.color, size: 20),
              const SizedBox(width: 8),
              Text(
                tip.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: tip.color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              tip.content,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : null,
                  ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '— ${tip.author}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }
}

/// Card per un professionista
class _ProfessionalCard extends StatelessWidget {
  final Professional professional;
  final VoidCallback? onMessageTap;

  const _ProfessionalCard({
    required this.professional,
    this.onMessageTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor:
                          professional.color.withValues(alpha: 0.2),
                      backgroundImage: professional.avatarPath != null
                          ? AssetImage(professional.avatarPath!)
                          : null,
                      child: professional.avatarPath == null
                          ? Text(
                              professional.name
                                  .split(' ')
                                  .map((e) => e[0])
                                  .take(2)
                                  .join(),
                              style: TextStyle(
                                color: professional.color,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            )
                          : null,
                    ),
                    if (professional.isAvailable)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        professional.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : null,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: professional.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          professional.role,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: professional.color,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        professional.specialty,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${professional.rating}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.textPrimaryDark : null,
                                ),
                          ),
                          Text(
                            ' (${professional.reviewCount} recensioni)',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              professional.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : null,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: OutlinedButton.icon(
                    onPressed: onMessageTap,
                    icon: const Icon(Icons.chat_outlined, size: 16),
                    label: const Text('Chat'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Prenota'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
