import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/responsive.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_list.dart';
import '../widgets/session_list.dart';
import '../widgets/suggested_prompts.dart';

/// Main chat screen: app bar with bot identity, a responsive centered chat
/// column, and a bottom-fixed input field. Chat history is always
/// functional — shown as a fixed sidebar on desktop, or behind a drawer on
/// mobile/tablet.
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final showSidebar = context.isDesktop;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, showDrawerButton: !showSidebar),
      drawer: showSidebar
          ? null
          : Drawer(
              backgroundColor: AppColors.surface,
              child: SafeArea(child: _SessionListView()),
            ),
      body: Row(
        children: [
          if (showSidebar) const _Sidebar(),
          const Expanded(child: _ChatColumn()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context, {
    required bool showDrawerButton,
  }) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleSpacing: showDrawerButton ? 0 : 8,
      leading: showDrawerButton
          ? Builder(
              builder: (context) => IconButton(
                icon: const Icon(
                  Icons.menu_rounded,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            )
          : null,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.accent.withValues(alpha: 0.15),
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.accent,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('AI Assistant', style: AppTextStyles.heading),
              Consumer<ChatProvider>(
                builder: (context, chat, _) => Text(
                  chat.isTyping ? 'Typing...' : 'Online',
                  style: AppTextStyles.caption.copyWith(
                    color: chat.isTyping
                        ? AppColors.accent
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'New chat',
          icon: const Icon(
            Icons.add_comment_outlined,
            color: AppColors.textSecondary,
          ),
          onPressed: () => context.read<ChatProvider>().newChat(),
        ),
        IconButton(
          tooltip: 'Clear chat',
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: AppColors.textSecondary,
          ),
          onPressed: () => _confirmClearChat(context),
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  void _confirmClearChat(BuildContext context) {
    final chat = context.read<ChatProvider>();
    if (!chat.hasMessages) return;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text('Clear chat?', style: AppTextStyles.heading),
        content: Text(
          'This will permanently delete the current conversation.',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              chat.clearChat();
              Navigator.of(dialogContext).pop();
            },
            child: Text(
              'Clear',
              style: AppTextStyles.body.copyWith(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fixed desktop sidebar wrapping the shared [SessionList].
class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: _SessionListView(),
    );
  }
}

/// Binds [SessionList] to [ChatProvider]. Shared by the sidebar and drawer.
class _SessionListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chat, _) => SessionList(
        sessions: chat.sessions,
        activeSessionId: chat.activeSessionId,
        onNewChat: () {
          chat.newChat();
          if (Scaffold.of(context).isDrawerOpen) {
            Navigator.of(context).pop();
          }
        },
        onSelect: (id) {
          chat.switchSession(id);
          if (Scaffold.of(context).isDrawerOpen) {
            Navigator.of(context).pop();
          }
        },
        onDelete: (id) => chat.deleteSession(id),
      ),
    );
  }
}

/// Centered chat column: message list (or welcome state) plus the input
/// field, constrained to a max width on tablet/desktop.
class _ChatColumn extends StatelessWidget {
  const _ChatColumn();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.chatContainerMaxWidth),
        child: Consumer<ChatProvider>(
          builder: (context, chat, _) {
            return Column(
              children: [
                Expanded(
                  child: chat.hasMessages
                      ? MessageList(
                          messages: chat.messages,
                          isTyping: chat.isTyping,
                          onRetry: (message) => chat.retryMessage(message),
                        )
                      : _WelcomeState(
                          onPromptSelected: (prompt) =>
                              chat.sendMessage(prompt),
                        ),
                ),
                ChatInput(
                  isGenerating: chat.isTyping,
                  onSend: (text) => chat.sendMessage(text),
                  onStop: () => chat.stopGenerating(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Empty-state view shown before the first message is sent: a greeting
/// plus a row of suggested prompt chips.
class _WelcomeState extends StatelessWidget {
  const _WelcomeState({required this.onPromptSelected});

  final ValueChanged<String> onPromptSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.accent,
              size: 30,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'How can I help you today?',
            style: AppTextStyles.heading.copyWith(fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me anything, or try one of the prompts below.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SuggestedPrompts(onSelected: onPromptSelected),
        ],
      ),
    );
  }
}
