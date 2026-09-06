import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/responsive.dart';
import '../models/chat_message.dart';

/// A single chat bubble, styled differently depending on whether the
/// message belongs to the user or the bot.
///
/// User bubbles are right-aligned with an accent background; bot bubbles
/// are left-aligned with a dark surface background. Both have one "sharp"
/// corner pointing toward the edge of the screen they're aligned to, which
/// gives the classic messaging-app chat-tail look without an actual tail
/// asset. Bot messages get a copy-to-clipboard action; a failed reply is
/// shown with an error tint and a "Retry" button instead.
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message, this.onRetry});

  final ChatMessage message;

  /// Called when the user taps "Retry" on a failed bot reply. Only
  /// relevant when `message.status == MessageStatus.error`.
  final VoidCallback? onRetry;

  bool get _isError => message.status == MessageStatus.error;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final maxWidth = context.chatContainerMaxWidth.isFinite
        ? context.chatContainerMaxWidth
        : context.screenWidth;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth * context.bubbleMaxWidthFraction,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUser
                ? AppColors.accent
                : (_isError
                      ? AppColors.error.withValues(alpha: 0.12)
                      : AppColors.surface),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
            border: isUser
                ? null
                : Border.all(
                    color: _isError ? AppColors.error : AppColors.border,
                  ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isError) ...[
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.error,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      message.text,
                      style: AppTextStyles.chatMessage.copyWith(
                        color: isUser
                            ? AppColors.onAccent
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              if (_isError && onRetry != null) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: onRetry,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.refresh_rounded,
                          color: AppColors.accent,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Retry',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.timestamp),
                    style: AppTextStyles.caption.copyWith(
                      color: isUser
                          ? AppColors.onAccent.withValues(alpha: 0.7)
                          : AppColors.textSecondary,
                      fontSize: 10.5,
                    ),
                  ),
                  if (!isUser && !_isError) ...[
                    const SizedBox(width: 8),
                    _CopyButton(text: message.text),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// Small icon button that copies the bot's message text to the clipboard
/// and briefly confirms with a checkmark.
class _CopyButton extends StatefulWidget {
  const _CopyButton({required this.text});

  final String text;

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  Future<void> _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleCopy,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Icon(
          _copied ? Icons.check_rounded : Icons.copy_rounded,
          size: 13,
          color: _copied ? AppColors.accent : AppColors.textSecondary,
        ),
      ),
    );
  }
}
