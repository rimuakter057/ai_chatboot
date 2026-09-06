import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../services/chat_storage_service.dart';

/// Holds all chat state: the list of sessions (chat history), which one is
/// active, its messages, and the typing/loading indicator — and persists
/// everything to disk via [ChatStorageService].
///
/// A real app would replace [_reply] and the simulated failure in
/// [_generateReply] with a call to an actual AI backend, but the
/// surrounding state management stays the same.
class ChatProvider extends ChangeNotifier {
  ChatProvider(this._storage);

  final ChatStorageService _storage;
  final _random = Random();

  List<ChatSession> _sessions = [];
  String? _activeSessionId;
  bool _isTyping = false;

  /// Bumped on every new bot-reply request and by [stopGenerating]; a
  /// pending reply only applies itself if this hasn't changed since it
  /// started, which is what makes "stop generating" work.
  int _requestId = 0;

  List<ChatSession> get sessions => List.unmodifiable(_sessions);

  ChatSession? get activeSession {
    for (final session in _sessions) {
      if (session.id == _activeSessionId) return session;
    }
    return null;
  }

  String? get activeSessionId => _activeSessionId;

  List<ChatMessage> get messages =>
      List.unmodifiable(activeSession?.messages ?? const []);

  bool get isTyping => _isTyping;
  bool get hasMessages => messages.isNotEmpty;

  /// Loads persisted sessions, or creates a first empty one if this is a
  /// fresh install. Must be awaited once before the UI is shown.
  Future<void> loadSessions() async {
    final (loaded, activeId) = _storage.loadSessions();

    _sessions = loaded.isEmpty ? [_newSession()] : loaded;
    _activeSessionId = _sessions.any((s) => s.id == activeId)
        ? activeId
        : _sessions.first.id;

    notifyListeners();
  }

  ChatSession _newSession() {
    final now = DateTime.now();
    return ChatSession(
      id: _generateId(),
      title: 'New chat',
      messages: [],
      createdAt: now,
      updatedAt: now,
    );
  }

  // Note: uses a plain int literal rather than `1 << 32` — dart2js compiles
  // `<<` using JS's 32-bit bitwise semantics, which silently truncates that
  // shift to 0 and makes Random.nextInt throw a RangeError on web.
  String _generateId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(4294967296)}';

  /// Starts a fresh conversation and makes it the active one.
  void newChat() {
    final session = _newSession();
    _sessions.insert(0, session);
    _activeSessionId = session.id;
    _persist();
    notifyListeners();
  }

  /// Switches the active conversation shown in the message list.
  void switchSession(String sessionId) {
    if (sessionId == _activeSessionId) return;
    _activeSessionId = sessionId;
    _persist();
    notifyListeners();
  }

  /// Deletes a conversation. Always keeps at least one session around.
  void deleteSession(String sessionId) {
    if (_sessions.length <= 1) {
      _sessions[0] = _newSession();
      _activeSessionId = _sessions[0].id;
    } else {
      _sessions.removeWhere((s) => s.id == sessionId);
      if (_activeSessionId == sessionId) {
        _activeSessionId = _sessions.first.id;
      }
    }
    _persist();
    notifyListeners();
  }

  /// Sends a user message and simulates a bot reply after a short delay.
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    final session = activeSession;
    if (trimmed.isEmpty || session == null) return;

    session.messages.add(
      ChatMessage(id: _generateId(), text: trimmed, isUser: true),
    );
    if (session.title == 'New chat') {
      session.title = _deriveTitle(trimmed);
    }
    session.updatedAt = DateTime.now();
    _persist();
    notifyListeners();

    await _generateReply(session, trimmed);
  }

  /// Re-attempts a bot reply for a message that previously failed.
  void retryMessage(ChatMessage failedMessage) {
    final session = activeSession;
    final retryText = failedMessage.retryText;
    if (session == null || retryText == null) return;

    session.messages.removeWhere((m) => m.id == failedMessage.id);
    notifyListeners();

    unawaited(_generateReply(session, retryText));
  }

  /// Cancels the in-flight bot reply, if any.
  void stopGenerating() {
    if (!_isTyping) return;

    _requestId++; // Invalidates the pending _generateReply call below.
    _isTyping = false;

    final session = activeSession;
    if (session != null) {
      session.messages.add(
        ChatMessage(
          id: _generateId(),
          text: 'Stopped generating.',
          isUser: false,
        ),
      );
      session.updatedAt = DateTime.now();
      _persist();
    }
    notifyListeners();
  }

  Future<void> _generateReply(ChatSession session, String userText) async {
    final thisRequestId = ++_requestId;
    _isTyping = true;
    notifyListeners();

    // Simulate network/AI latency before the bot responds.
    await Future.delayed(Duration(milliseconds: 900 + _random.nextInt(700)));

    // Superseded by stopGenerating() or another sendMessage() while waiting.
    if (thisRequestId != _requestId) return;

    _isTyping = false;

    // Simulate an occasional backend failure so the retry flow is real.
    final failed = _random.nextDouble() < 0.18;
    session.messages.add(
      failed
          ? ChatMessage(
              id: _generateId(),
              text: "Something went wrong. Let's try that again.",
              isUser: false,
              status: MessageStatus.error,
              retryText: userText,
            )
          : ChatMessage(
              id: _generateId(),
              text: _reply(userText),
              isUser: false,
            ),
    );
    session.updatedAt = DateTime.now();
    _persist();
    notifyListeners();
  }

  void clearChat() {
    final session = activeSession;
    if (session == null) return;
    session.messages.clear();
    session.title = 'New chat';
    session.updatedAt = DateTime.now();
    _persist();
    notifyListeners();
  }

  void _persist() {
    unawaited(_storage.saveSessions(_sessions, _activeSessionId));
  }

  String _deriveTitle(String firstMessage) {
    final singleLine = firstMessage.replaceAll('\n', ' ').trim();
    return singleLine.length > 40
        ? '${singleLine.substring(0, 40)}...'
        : singleLine;
  }

  String _reply(String userText) {
    return 'This is a simulated response to: "$userText". '
        'Connect this app to your AI backend to generate real replies.';
  }
}
