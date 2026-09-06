import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_session.dart';

/// Persists chat sessions to on-device storage so conversations survive
/// app restarts.
class ChatStorageService {
  ChatStorageService(this._prefs);

  final SharedPreferences _prefs;

  static const _sessionsKey = 'chat_sessions_v1';
  static const _activeSessionKey = 'active_session_id_v1';

  Future<void> saveSessions(
    List<ChatSession> sessions,
    String? activeSessionId,
  ) async {
    final encoded = jsonEncode(sessions.map((s) => s.toJson()).toList());
    await _prefs.setString(_sessionsKey, encoded);
    if (activeSessionId != null) {
      await _prefs.setString(_activeSessionKey, activeSessionId);
    }
  }

  /// Returns the saved sessions and the previously active session id, or
  /// empty/null if nothing has been saved yet.
  (List<ChatSession>, String?) loadSessions() {
    final raw = _prefs.getString(_sessionsKey);
    final activeId = _prefs.getString(_activeSessionKey);
    if (raw == null) return (<ChatSession>[], null);

    final decoded = jsonDecode(raw) as List;
    final sessions = decoded
        .map((e) => ChatSession.fromJson(e as Map<String, dynamic>))
        .toList();
    return (sessions, activeId);
  }
}
