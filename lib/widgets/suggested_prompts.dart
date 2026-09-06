import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// Horizontal, scrollable row of suggested prompt chips shown below the
/// welcome message on an empty chat screen.
class SuggestedPrompts extends StatelessWidget {
  const SuggestedPrompts({super.key, required this.onSelected});

  final ValueChanged<String> onSelected;

  static const List<String> _prompts = [
    'Explain quantum computing simply',
    'Write a short poem about the sea',
    'Give me healthy dinner ideas',
    'Help me debug my Flutter code',
    'Summarize this article for me',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _prompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final prompt = _prompts[index];
          return ActionChip(
            label: Text(prompt, style: AppTextStyles.chip),
            backgroundColor: AppColors.surface,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            onPressed: () => onSelected(prompt),
          );
        },
      ),
    );
  }
}
