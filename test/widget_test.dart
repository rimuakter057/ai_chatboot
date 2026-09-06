// Basic smoke test for the AI Chatbot UI.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_chatboot/main.dart';
import 'package:ai_chatboot/providers/chat_provider.dart';
import 'package:ai_chatboot/services/chat_storage_service.dart';

void main() {
  testWidgets('Chat screen shows welcome state and sends a message', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final chatProvider = ChatProvider(ChatStorageService(prefs));
    await chatProvider.loadSessions();

    await tester.pumpWidget(AiChatbotApp(chatProvider: chatProvider));

    // Welcome state is shown before any messages are sent.
    expect(find.text('How can I help you today?'), findsOneWidget);

    // Type a message and send it via the input field.
    await tester.enterText(find.byType(TextField), 'Hello there');
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pump();

    // The user's message should now appear in the chat.
    expect(find.text('Hello there'), findsOneWidget);
  });
}
