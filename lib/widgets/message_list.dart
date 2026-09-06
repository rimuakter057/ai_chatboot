import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/responsive.dart';
import '../models/chat_message.dart';
import 'chat_bubble.dart';
import 'typing_indicator.dart';

/// Scrollable list of chat messages that animates new messages in with a
/// combined fade + slide transition via [AnimatedList], auto-scrolls to the
/// bottom whenever a message is added or the typing indicator appears, and
/// surfaces a "scroll to bottom" button once the user has scrolled up.
class MessageList extends StatefulWidget {
  const MessageList({
    super.key,
    required this.messages,
    required this.isTyping,
    this.onRetry,
  });

  final List<ChatMessage> messages;
  final bool isTyping;

  /// Called with the failed message when the user taps "Retry" on it.
  final ValueChanged<ChatMessage>? onRetry;

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final ScrollController _scrollController = ScrollController();
  int _previousLength = 0;
  bool _showScrollToBottom = false;

  static const double _scrollToBottomThreshold = 120;

  @override
  void initState() {
    super.initState();
    _previousLength = widget.messages.length;
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final distanceFromBottom =
        _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;
    final shouldShow = distanceFromBottom > _scrollToBottomThreshold;
    if (shouldShow != _showScrollToBottom) {
      setState(() => _showScrollToBottom = shouldShow);
    }
  }

  @override
  void didUpdateWidget(covariant MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Insert newly added messages into the AnimatedList so they animate in.
    if (widget.messages.length > _previousLength) {
      for (var i = _previousLength; i < widget.messages.length; i++) {
        _listKey.currentState?.insertItem(
          i,
          duration: const Duration(milliseconds: 320),
        );
      }
      _previousLength = widget.messages.length;
    } else if (widget.messages.length < _previousLength) {
      // Chat was cleared. AnimatedList can't have items removed out from
      // under it without matching removeItem calls, so force a fresh
      // AnimatedList with a new key instead of animating removals.
      _previousLength = widget.messages.length;
      _listKey = GlobalKey<AnimatedListState>();
    }

    // Auto-scroll to the latest message / typing indicator after the frame
    // has been laid out, but only if the user was already near the bottom
    // (otherwise a message arriving while reading older history would
    // yank the view away from them).
    if (widget.messages.length != oldWidget.messages.length ||
        widget.isTyping != oldWidget.isTyping) {
      final wasNearBottom = !_showScrollToBottom;
      if (wasNearBottom) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToBottom(),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  Widget _buildItem(
    BuildContext context,
    int index,
    Animation<double> animation,
  ) {
    final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(fade);

    final message = widget.messages[index];

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: ChatBubble(
          message: message,
          onRetry: widget.onRetry == null
              ? null
              : () => widget.onRetry!(message),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.pagePadding;

    return Stack(
      children: [
        ListView(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 12,
          ),
          children: [
            AnimatedList(
              key: _listKey,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              initialItemCount: widget.messages.length,
              itemBuilder: _buildItem,
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SizeTransition(sizeFactor: animation, child: child),
              ),
              child: widget.isTyping
                  ? const Padding(
                      key: ValueKey('typing'),
                      padding: EdgeInsets.only(top: 2),
                      child: TypingIndicator(),
                    )
                  : const SizedBox.shrink(key: ValueKey('no-typing')),
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 12,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 200),
            offset: _showScrollToBottom ? Offset.zero : const Offset(0, 2),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _showScrollToBottom ? 1 : 0,
              child: IgnorePointer(
                ignoring: !_showScrollToBottom,
                child: _ScrollToBottomButton(onTap: _scrollToBottom),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScrollToBottomButton extends StatelessWidget {
  const _ScrollToBottomButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(
            Icons.arrow_downward_rounded,
            color: AppColors.accent,
            size: 20,
          ),
        ),
      ),
    );
  }
}
