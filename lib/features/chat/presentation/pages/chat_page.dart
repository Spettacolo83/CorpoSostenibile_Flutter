import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
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

/// Pagina Chat - Lista dei contatti e conversazioni.
class ChatPage extends StatefulWidget {
  /// Nome del contatto da aprire automaticamente (opzionale)
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
      roleColor: AppColors.info,
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
    // Se il contatto iniziale è cambiato, apri la nuova chat
    if (widget.initialContactName != oldWidget.initialContactName &&
        widget.initialContactName != null) {
      _hasOpenedInitialChat = false;
      _openInitialChatIfNeeded();
    }
  }

  void _openInitialChatIfNeeded() {
    if (_hasOpenedInitialChat || widget.initialContactName == null) return;
    _hasOpenedInitialChat = true;

    // Cerca il contatto corrispondente
    final contact = ChatPage.contacts.where(
      (c) => c.name == widget.initialContactName,
    ).firstOrNull;

    if (contact != null) {
      // Apri la chat dopo il frame corrente
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
    return Column(
      children: [
        _buildSearchBar(context),
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
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cerca conversazione...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

/// Tile per un singolo contatto
class _ChatContactTile extends StatelessWidget {
  final ChatContact contact;

  const _ChatContactTile({required this.contact});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => _openChat(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: 12,
        ),
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
                                color: isDark ? AppColors.textPrimaryDark : null,
                              ),
                        ),
                      ),
                      Text(
                        contact.time,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: contact.unreadCount > 0
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: contact.roleColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      contact.role,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: contact.roleColor,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          contact.lastMessage,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: contact.unreadCount > 0
                                    ? Theme.of(context).textTheme.bodyMedium?.color
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
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
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
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          CircleAvatar(
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.contact.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : null,
                      ),
                ),
                Text(
                  widget.contact.isOnline ? 'Online' : 'Offline',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: widget.contact.isOnline
                            ? AppColors.success
                            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.videocam_outlined),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
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
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.attach_file),
          ),
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
          CircleAvatar(
            backgroundColor: widget.contact.roleColor,
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
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

    // Simula risposta automatica
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

/// Bolla di messaggio
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
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message.isMe
              ? myMessageColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: message.isMe ? const Radius.circular(4) : null,
            bottomLeft: !message.isMe ? const Radius.circular(4) : null,
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: message.isMe ? Colors.white : null,
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
    );
  }
}
