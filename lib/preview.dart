import 'package:flutter/material.dart';
import 'parser.dart';

/// Widget to render Pendart content
class PendartView extends StatelessWidget {
  final String text;
  final TextStyle? defaultTextStyle;
  final bool isDarkMode;

  const PendartView({
    super.key,
    required this.text,
    this.defaultTextStyle,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final parser = PendartParser();
    final widgets = parser.processText(text, context, isDarkMode: isDarkMode);

    return Container(
      color: isDarkMode ? Colors.black87 : Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }
}
