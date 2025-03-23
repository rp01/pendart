import 'package:flutter/material.dart';
import 'parser.dart';

/// Widget to render Pendart content
class PendartView extends StatelessWidget {
  final String text;
  final TextStyle? defaultTextStyle;
  final ThemeData? theme;

  const PendartView({
    super.key,
    required this.text,
    this.defaultTextStyle,
    this.theme,
  });

  /// Get the current theme to use (either provided or from context)
  ThemeData _getCurrentTheme(BuildContext context) {
    return theme ?? Theme.of(context);
  }

  /// Check if the current theme is dark mode
  bool _isDarkMode(BuildContext context) {
    final currentTheme = _getCurrentTheme(context);
    return currentTheme.brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    final parser = PendartParser();
    final isDark = _isDarkMode(context);
    final currentTheme = _getCurrentTheme(context);
    final backgroundColor = isDark
        ? currentTheme.canvasColor
        : currentTheme.scaffoldBackgroundColor;

    final widgets = parser.processText(text, context, isDarkMode: isDark);

    return Container(
      color: backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }
}
