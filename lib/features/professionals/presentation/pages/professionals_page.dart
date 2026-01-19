import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glassmorphic_card.dart';

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

/// Pagina Professionisti - Design "Modern Fitness".
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
      color: AppColors.chartPurple,
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
      color: AppColors.chartOrange,
    ),
    DailyTip(
      title: 'Mindfulness',
      content:
          'Prima di mangiare, fermati un attimo. Respira. Chiediti: "Ho davvero fame '
          'o sto cercando altro?" La consapevolezza è il primo passo.',
      author: 'Delia D.S.',
      icon: Icons.self_improvement,
      color: AppColors.chartBlue,
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
        targetOffset = _scrollController.position.maxScrollExtent;
      } else {
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
    final topInset = MediaQuery.of(context).padding.top + 12;

    return SingleChildScrollView(
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
    return GlassmorphicCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.groups,
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
                  'Il Tuo Team',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nutrizionista, Coach e Psicologa per il tuo benessere sostenibile',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.history, size: 18),
              label: const Text('Archivio'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
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
    return GlassmorphicCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent,
                      AppColors.accent.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.event,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prossimo Appuntamento',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Lunedì 23 Dicembre, 10:00',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0x33000000),
                    backgroundImage: AssetImage('assets/images/alice_avatar.png'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alice P.',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Check-up settimanale',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.videocam, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Modifica'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.checklist, size: 18),
                    label: const Text('Prepara'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Card per un consiglio del giorno - Design moderno
class _DailyTipCard extends StatelessWidget {
  final DailyTip tip;

  const _DailyTipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tip.color.withValues(alpha: 0.15),
            tip.color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: tip.color.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: tip.color.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            tip.color,
                            tip.color.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: tip.color.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(tip.icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tip.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Text(
                    tip.content,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: tip.color.withValues(alpha: 0.2),
                      child: Text(
                        tip.author.split(' ').map((e) => e[0]).take(2).join(),
                        style: TextStyle(
                          fontSize: 10,
                          color: tip.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tip.author,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: tip.color,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Card per un professionista - Design moderno
class _ProfessionalCard extends StatelessWidget {
  final Professional professional;
  final VoidCallback? onMessageTap;

  const _ProfessionalCard({
    required this.professional,
    this.onMessageTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar con glow
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: professional.color.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            professional.color,
                            professional.color.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: professional.color.withValues(alpha: 0.2),
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
                      ),
                    ),
                    if (professional.isAvailable)
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.success.withValues(alpha: 0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      professional.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            professional.color.withValues(alpha: 0.15),
                            professional.color.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: professional.color.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        professional.role,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: professional.color,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      professional.specialty,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    // Rating con stelle
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          final filled = index < professional.rating.floor();
                          final partial = index == professional.rating.floor() &&
                              professional.rating % 1 > 0;
                          return Padding(
                            padding: const EdgeInsets.only(right: 2),
                            child: Icon(
                              filled
                                  ? Icons.star
                                  : partial
                                      ? Icons.star_half
                                      : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            ),
                          );
                        }),
                        const SizedBox(width: 6),
                        Text(
                          '${professional.rating}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          ' (${professional.reviewCount})',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            professional.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: OutlinedButton.icon(
                  onPressed: onMessageTap,
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Messaggia'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        professional.color,
                        professional.color.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    boxShadow: [
                      BoxShadow(
                        color: professional.color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Prenota'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
