import 'dart:math';

import 'package:flutter/material.dart';
import 'package:journal_app/Colors/color_theme.dart';
import 'package:journal_app/controllers/db_functions.dart';

class SuggestionWidget extends StatelessWidget {
  const SuggestionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final List<Color> colorForCards = ColorTheme.getColorForCards(brightness);
    return ValueListenableBuilder<String>(
      valueListenable: suggestionNotifier,
      builder: (context, suggestion, _) {
        return Container(
          padding: const EdgeInsets.all(4),
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
          ),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            color: colorForCards[Random().nextInt(colorForCards.length)],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EmoTips💡',
                    style: TextStyle(
                        color: ColorTheme.getTextColor(brightness),
                        fontFamily: 'Nunito',
                        fontSize: 25),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    suggestion,
                    style:
                        TextStyle(color: ColorTheme.getTextColor(brightness)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
