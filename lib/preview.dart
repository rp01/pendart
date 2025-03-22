import 'package:flutter/material.dart';
import 'parser.dart';

/// Widget to render Pendart content
class PendartView extends StatelessWidget {
  final String text;
  final TextStyle? defaultTextStyle;

  const PendartView({
    super.key,
    required this.text,
    this.defaultTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final parser = PendartParser();
    final widgets = parser.processText(text, context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
