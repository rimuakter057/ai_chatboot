import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants/app_colors.dart';
import 'providers/chat_provider.dart';
import 'screens/chat_screen.dart';
import 'services/chat_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final chatProvider = ChatProvider(ChatStorageService(prefs));
  await chatProvider.loadSessions();

  runApp(AiChatbotApp(chatProvider: chatProvider));
}

class AiChatbotApp extends StatelessWidget {
  const AiChatbotApp({super.key, required this.chatProvider});

  final ChatProvider chatProvider;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: chatProvider,
      child: MaterialApp(
        title: 'AI Chatbot',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.accent,
            brightness: Brightness.dark,
            primary: AppColors.accent,
            surface: AppColors.surface,
          ),
          useMaterial3: true,
        ),
        home: const ChatScreen(),
      ),
    );
  }
}
