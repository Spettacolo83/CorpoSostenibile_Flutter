import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

/// Modello per un contatto chat
class ChatContact {
  final String name;
  final String role;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final Color roleColor;
  final String? avatarPath;

  const ChatContact({
    required this.name,
    required this.role,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isOnline = false,
    this.roleColor = AppColors.primary,
    this.avatarPath,
  });
}

/// Pagina Chat - Design "Modern Fitness" con glassmorphism.
class ChatPage extends StatefulWidget {
  final String? initialContactName;

  const ChatPage({super.key, this.initialContactName});

  static const List<ChatContact> contacts = [
    ChatContact(
      name: 'Alice P.',
      role: 'Nutrizionista',
      lastMessage: 'Perfetto! Ci vediamo lunedì per il check-up settimanale.',
      time: '10:30',
      unreadCount: 2,
      isOnline: true,
      roleColor: AppColors.primary,
      avatarPath: 'assets/images/alice_avatar.png',
    ),
    ChatContact(
      name: 'Lorenzo S.',
      role: 'Coach',
      lastMessage: 'Ottimo allenamento oggi! Continua così 💪',
      time: 'Ieri',
      isOnline: true,
      roleColor: AppColors.warning,
      avatarPath: 'assets/images/lorenzo_avatar.png',
    ),
    ChatContact(
      name: 'Delia D.S.',
      role: 'Psicologa Alimentare',
      lastMessage: 'Come ti sei sentito questa settimana con il nuovo approccio?',
      time: 'Ieri',
      unreadCount: 1,
      roleColor: AppColors.chartPurple,
      avatarPath: 'assets/images/delia_avatar.png',
    ),
    ChatContact(
      name: 'Mario Rossi',
      role: 'Compagno di percorso',
      lastMessage: 'Anche io ho iniziato da poco, ci supportiamo!',
      time: 'Lun',
      roleColor: AppColors.textSecondary,
    ),
  ];

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _hasOpenedInitialChat = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _openInitialChatIfNeeded();
  }

  @override
  void didUpdateWidget(ChatPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialContactName != oldWidget.initialContactName &&
        widget.initialContactName != null) {
      _hasOpenedInitialChat = false;
      _openInitialChatIfNeeded();
    }
  }

  void _openInitialChatIfNeeded() {
    if (_hasOpenedInitialChat || widget.initialContactName == null) return;
    _hasOpenedInitialChat = true;

    final contact = ChatPage.contacts.where(
      (c) => c.name == widget.initialContactName,
    ).firstOrNull;

    if (contact != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => _ChatDetailSheet(contact: contact),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top + 12;

    return Stack(
      children: [
        // Header gradient
        Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.1),
                AppColors.secondary.withValues(alpha: 0.05),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Column(
          children: [
            SizedBox(height: topInset),
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildSearchBar(context),
            const SizedBox(height: 8),
            _buildOnlineNow(context),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: ChatPage.contacts.length,
                itemBuilder: (context, index) {
                  return _ChatContactTile(contact: ChatPage.contacts[index]);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Messaggi',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              Text(
                '${ChatPage.contacts.where((c) => c.unreadCount > 0).length} non letti',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
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
              icon: const Icon(Icons.edit_outlined, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cerca conversazione...',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                filled: false,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineNow(BuildContext context) {
    final onlineContacts = ChatPage.contacts.where((c) => c.isOnline).toList();
    if (onlineContacts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
          child: Text(
            'Online ora',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
            itemCount: onlineContacts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final contact = onlineContacts[index];
              return _OnlineAvatar(contact: contact);
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Avatar online con animazione
class _OnlineAvatar extends StatelessWidget {
  final ChatContact contact;

  const _OnlineAvatar({required this.contact});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openChat(context),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      contact.roleColor,
                      contact.roleColor.withValues(alpha: 0.6),
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
                    radius: 28,
                    backgroundColor: contact.roleColor.withValues(alpha: 0.2),
                    backgroundImage: contact.avatarPath != null
                        ? AssetImage(contact.avatarPath!)
                        : null,
                    child: contact.avatarPath == null
                        ? Text(
                            contact.name.split(' ').map((e) => e[0]).take(2).join(),
                            style: TextStyle(
                              color: contact.roleColor,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              Positioned(
                right: 4,
                bottom: 4,
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
          const SizedBox(height: 6),
          Text(
            contact.name.split(' ').first,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  void _openChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ChatDetailSheet(contact: contact),
    );
  }
}

/// Tile per un singolo contatto
class _ChatContactTile extends StatelessWidget {
  final ChatContact contact;

  const _ChatContactTile({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: contact.unreadCount > 0
            ? AppColors.primary.withValues(alpha: 0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: InkWell(
        onTap: () => _openChat(context),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            contact.name,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: contact.unreadCount > 0
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                          ),
                        ),
                        Text(
                          contact.time,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: contact.unreadCount > 0
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontWeight: contact.unreadCount > 0
                                    ? FontWeight.w600
                                    : null,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildRoleBadge(context),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            contact.lastMessage,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: contact.unreadCount > 0
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                  fontWeight: contact.unreadCount > 0
                                      ? FontWeight.w500
                                      : null,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (contact.unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${contact.unreadCount}',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            contact.roleColor.withValues(alpha: 0.15),
            contact.roleColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: contact.roleColor.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        contact.role,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: contact.roleColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: contact.roleColor.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: contact.roleColor.withValues(alpha: 0.2),
            backgroundImage: contact.avatarPath != null
                ? AssetImage(contact.avatarPath!)
                : null,
            child: contact.avatarPath == null
                ? Text(
                    contact.name.split(' ').map((e) => e[0]).take(2).join(),
                    style: TextStyle(
                      color: contact.roleColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : null,
          ),
        ),
        if (contact.isOnline)
          Positioned(
            right: 0,
            bottom: 0,
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
    );
  }

  void _openChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ChatDetailSheet(contact: contact),
    );
  }
}

/// Bottom sheet per la chat dettagliata
class _ChatDetailSheet extends StatefulWidget {
  final ChatContact contact;

  const _ChatDetailSheet({required this.contact});

  @override
  State<_ChatDetailSheet> createState() => _ChatDetailSheetState();
}

class _ChatDetailSheetState extends State<_ChatDetailSheet> {
  final _messageController = TextEditingController();
  final List<_ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadDummyMessages();
  }

  void _loadDummyMessages() {
    _messages.addAll([
      _ChatMessage(
        text: 'Ciao! Come procede il tuo percorso?',
        isMe: false,
        time: '10:00',
      ),
      _ChatMessage(
        text: 'Ciao! Molto bene, grazie! Ho seguito i tuoi consigli questa settimana.',
        isMe: true,
        time: '10:15',
      ),
      _ChatMessage(
        text: widget.contact.lastMessage,
        isMe: false,
        time: widget.contact.time,
      ),
    ]);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildHeader(context),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _MessageBubble(
                    message: _messages[index],
                    myMessageColor: widget.contact.roleColor,
                  );
                },
              ),
            ),
            _buildMessageInput(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surface,
            ),
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.contact.roleColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: widget.contact.roleColor.withValues(alpha: 0.2),
              backgroundImage: widget.contact.avatarPath != null
                  ? AssetImage(widget.contact.avatarPath!)
                  : null,
              child: widget.contact.avatarPath == null
                  ? Text(
                      widget.contact.name.split(' ').map((e) => e[0]).take(2).join(),
                      style: TextStyle(
                        color: widget.contact.roleColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.contact.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: widget.contact.isOnline
                            ? AppColors.success
                            : AppColors.textSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.contact.isOnline ? 'Online' : 'Offline',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: widget.contact.isOnline
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.videocam_outlined, color: widget.contact.roleColor),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.call_outlined, color: widget.contact.roleColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom + 12,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.9),
            border: Border(
              top: BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.attach_file, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 120),
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    minLines: 1,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'Scrivi un messaggio...',
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
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
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.contact.roleColor,
                      widget.contact.roleColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: widget.contact.roleColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(
        text: _messageController.text,
        isMe: true,
        time: 'Ora',
      ));
    });
    _messageController.clear();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: 'Grazie per il messaggio! Ti risponderò al più presto.',
            isMe: false,
            time: 'Ora',
          ));
        });
      }
    });
  }
}

/// Modello per un messaggio
class _ChatMessage {
  final String text;
  final bool isMe;
  final String time;

  const _ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
  });
}

/// Bolla di messaggio moderna
class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  final Color myMessageColor;

  const _MessageBubble({
    required this.message,
    required this.myMessageColor,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: message.isMe
              ? LinearGradient(
                  colors: [
                    myMessageColor,
                    myMessageColor.withValues(alpha: 0.85),
                  ],
                )
              : null,
          color: message.isMe ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: message.isMe ? const Radius.circular(4) : null,
            bottomLeft: !message.isMe ? const Radius.circular(4) : null,
          ),
          boxShadow: [
            BoxShadow(
              color: (message.isMe ? myMessageColor : Colors.black)
                  .withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message.text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: message.isMe ? Colors.white : AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                message.time,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: message.isMe
                          ? Colors.white.withValues(alpha: 0.7)
                          : AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
