import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/chat_session.dart';

/// Chat history list shared between the desktop sidebar and the
/// mobile/tablet drawer: a "New chat" action plus one row per session,
/// highlighting the active one and allowing deletion.
class SessionList extends StatelessWidget {
  const SessionList({
    super.key,
    required this.sessions,
    required this.activeSessionId,
    required this.onNewChat,
    required this.onSelect,
    required this.onDelete,
  });

  final List<ChatSession> sessions;
  final String? activeSessionId;
  final VoidCallback onNewChat;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
          child: Material(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onNewChat,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      color: AppColors.accent,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'New chat',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              final isActive = session.id == activeSessionId;

              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.accent.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  dense: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  leading: Icon(
                    Icons.chat_bubble_outline,
                    color: isActive
                        ? AppColors.accent
                        : AppColors.textSecondary,
                    size: 16,
                  ),
                  title: Text(
                    session.title,
                    style: AppTextStyles.caption.copyWith(
                      color: isActive
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: sessions.length > 1
                      ? InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () => onDelete(session.id),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.close_rounded,
                              size: 15,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : null,
                  onTap: () => onSelect(session.id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
