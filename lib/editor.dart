import 'package:flutter/material.dart';
import 'parser.dart';

/// A widget for editing and previewing Pendart markup
class PendartEditor extends StatefulWidget {
  final String initialText;
  final Function(String)? onTextChanged;
  final Function(int, bool)? onCheckboxChanged;
  final double height;
  final double? width;
  final bool enableCheckboxes;
  final ThemeData? theme;

  const PendartEditor({
    super.key,
    this.initialText = '',
    this.onTextChanged,
    this.onCheckboxChanged,
    this.height = 400,
    this.width,
    this.enableCheckboxes = true,
    this.theme,
  });

  @override
  State<PendartEditor> createState() => _PendartEditorState();
}

class _PendartEditorState extends State<PendartEditor> {
  late TextEditingController _textController;
  late PendartParser _parser;
  bool _isPreviewMode = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _parser = PendartParser();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Get the current theme to use, falling back to the context theme if not provided
  ThemeData _getCurrentTheme(BuildContext context) {
    return widget.theme ?? Theme.of(context);
  }

  /// Check if the current theme is dark
  bool _isDarkMode(BuildContext context) {
    final ThemeData theme = _getCurrentTheme(context);
    return theme.brightness == Brightness.dark;
  }

  void _insertFormatting(String prefix, String suffix,
      {String placeholder = ''}) {
    final TextEditingValue value = _textController.value;
    final int start = value.selection.baseOffset;
    final int end = value.selection.extentOffset;

    if (start < 0 || end < 0) return;

    String newText;
    TextSelection newSelection;

    if (start == end) {
      // No selection, insert placeholder between markers
      newText =
          value.text.replaceRange(start, end, '$prefix$placeholder$suffix');
      newSelection = TextSelection.collapsed(
          offset: start + prefix.length + placeholder.length);
    } else {
      // Text selected, wrap with markers
      final selectedText = value.text.substring(start, end);
      newText =
          value.text.replaceRange(start, end, '$prefix$selectedText$suffix');
      newSelection = TextSelection.collapsed(
          offset: start + prefix.length + selectedText.length + suffix.length);
    }

    _textController.value = value.copyWith(
      text: newText,
      selection: newSelection,
    );

    if (widget.onTextChanged != null) {
      widget.onTextChanged!(_textController.text);
    }
  }

  Widget _buildToolbar() {
    final ThemeData theme = _getCurrentTheme(context);
    final bool isDark = _isDarkMode(context);
    final Color iconColor =
        isDark ? Colors.white : theme.iconTheme.color ?? Colors.black87;
    final Color dividerColor = theme.dividerColor;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : theme.scaffoldBackgroundColor,
        border: Border(
            bottom: BorderSide(
          color: dividerColor,
        )),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                _isPreviewMode ? Icons.edit : Icons.visibility,
                color: iconColor,
              ),
              tooltip: _isPreviewMode ? 'Edit' : 'Preview',
              onPressed: () {
                setState(() {
                  _isPreviewMode = !_isPreviewMode;
                });
              },
            ),
            VerticalDivider(
              width: 16,
              thickness: 1,
              color: dividerColor,
            ),
            IconButton(
              icon: Icon(
                Icons.format_bold,
                color: iconColor,
              ),
              tooltip: 'Bold',
              onPressed: () =>
                  _insertFormatting('**', '**', placeholder: 'bold text'),
            ),
            IconButton(
              icon: Icon(
                Icons.format_italic,
                color: iconColor,
              ),
              tooltip: 'Italic',
              onPressed: () =>
                  _insertFormatting('%%', '%%', placeholder: 'italic text'),
            ),
            IconButton(
              icon: Icon(
                Icons.format_strikethrough,
                color: iconColor,
              ),
              tooltip: 'Strikethrough',
              onPressed: () => _insertFormatting('~~', '~~',
                  placeholder: 'strikethrough text'),
            ),
            IconButton(
              icon: Icon(
                Icons.format_underlined,
                color: iconColor,
              ),
              tooltip: 'Underline',
              onPressed: () =>
                  _insertFormatting('__', '__', placeholder: 'underlined text'),
            ),
            IconButton(
              icon: Text('H1',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  )),
              tooltip: 'Heading 1',
              onPressed: () {
                final value = _textController.value;
                final int start = value.selection.baseOffset;
                final int end = value.selection.extentOffset;

                if (start < 0) return;

                // If text is selected, apply heading to that text
                if (start != end) {
                  final selectedText = value.text.substring(start, end);
                  final newText =
                      value.text.replaceRange(start, end, '! $selectedText');
                  _textController.value = value.copyWith(
                    text: newText,
                    selection: TextSelection.collapsed(
                        offset: start + selectedText.length + 2),
                  );
                } else {
                  // Otherwise, insert at the beginning of the line
                  final int lineStart =
                      value.text.lastIndexOf('\n', start > 0 ? start - 1 : 0) +
                          1;
                  final TextSelection newSelection =
                      TextSelection.collapsed(offset: lineStart);
                  _textController.selection = newSelection;
                  _insertFormatting('! ', '', placeholder: 'Heading 1');
                }

                if (widget.onTextChanged != null) {
                  widget.onTextChanged!(_textController.text);
                }
              },
            ),
            IconButton(
              icon: Text('H2',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  )),
              tooltip: 'Heading 2',
              onPressed: () {
                final value = _textController.value;
                final int start = value.selection.baseOffset;
                final int end = value.selection.extentOffset;

                if (start < 0) return;

                // If text is selected, apply heading to that text
                if (start != end) {
                  final selectedText = value.text.substring(start, end);
                  final newText =
                      value.text.replaceRange(start, end, '!! $selectedText');
                  _textController.value = value.copyWith(
                    text: newText,
                    selection: TextSelection.collapsed(
                        offset: start + selectedText.length + 3),
                  );
                } else {
                  // Otherwise, insert at the beginning of the line
                  final int lineStart =
                      value.text.lastIndexOf('\n', start > 0 ? start - 1 : 0) +
                          1;
                  final TextSelection newSelection =
                      TextSelection.collapsed(offset: lineStart);
                  _textController.selection = newSelection;
                  _insertFormatting('!! ', '', placeholder: 'Heading 2');
                }

                if (widget.onTextChanged != null) {
                  widget.onTextChanged!(_textController.text);
                }
              },
            ),
            IconButton(
              icon: Icon(
                Icons.code,
                color: iconColor,
              ),
              tooltip: 'Code',
              onPressed: () => _insertFormatting('`', '`', placeholder: 'code'),
            ),
            IconButton(
              icon: Icon(
                Icons.insert_link,
                color: iconColor,
              ),
              tooltip: 'Link',
              onPressed: () => _insertFormatting('@@', '@@',
                  placeholder: 'https://example.com'),
            ),
            IconButton(
              icon: Icon(
                Icons.image,
                color: iconColor,
              ),
              tooltip: 'Image',
              onPressed: () =>
                  _insertFormatting('[[', ']]', placeholder: 'image.jpg'),
            ),
            IconButton(
              icon: Icon(
                Icons.check_box_outline_blank,
                color: iconColor,
              ),
              tooltip: 'Unchecked Checkbox',
              onPressed: () {
                final value = _textController.value;
                final int start = value.selection.baseOffset;
                final int lineStart =
                    value.text.lastIndexOf('\n', start > 0 ? start - 1 : 0) + 1;
                final TextSelection newSelection =
                    TextSelection.collapsed(offset: lineStart);
                _textController.selection = newSelection;
                _insertFormatting('[] ', '\n', placeholder: 'Task item');
              },
            ),
            IconButton(
              icon: Icon(
                Icons.check_box,
                color: iconColor,
              ),
              tooltip: 'Checked Checkbox',
              onPressed: () {
                final value = _textController.value;
                final int start = value.selection.baseOffset;
                final int lineStart =
                    value.text.lastIndexOf('\n', start > 0 ? start - 1 : 0) + 1;
                final TextSelection newSelection =
                    TextSelection.collapsed(offset: lineStart);
                _textController.selection = newSelection;
                _insertFormatting('[x] ', '\n', placeholder: 'Completed task');
              },
            ),
            IconButton(
              icon: Icon(
                Icons.horizontal_rule,
                color: iconColor,
              ),
              tooltip: 'Horizontal Rule',
              onPressed: () => _insertFormatting('---\n', '', placeholder: ''),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = _getCurrentTheme(context);
    final bool isDark = _isDarkMode(context);
    final Color borderColor = theme.dividerColor;
    final Color backgroundColor =
        isDark ? theme.cardColor : theme.scaffoldBackgroundColor;
    final Color textColor = theme.textTheme.bodyMedium?.color ??
        (isDark ? Colors.white : Colors.black);
    final Color hintColor = theme.hintColor;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(4.0),
        color: backgroundColor,
      ),
      child: Column(
        children: [
          _buildToolbar(),
          Expanded(
            child: _isPreviewMode
                ? SingleChildScrollView(
                    key: const Key('pendart_preview'),
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: _parser.processText(
                        _textController.text,
                        context,
                        isDarkMode: isDark,
                        onCheckboxChanged: widget.onCheckboxChanged != null
                            ? _handleCheckboxChange
                            : null,
                        enableCheckboxes: widget.enableCheckboxes,
                      ),
                    ),
                  )
                : TextField(
                    controller: _textController,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(16.0),
                      border: InputBorder.none,
                      hintText: 'Write your Pendart text here...',
                      hintStyle: TextStyle(color: hintColor),
                      fillColor: backgroundColor,
                      filled: true,
                    ),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: textColor,
                    ),
                    onChanged: widget.onTextChanged,
                  ),
          ),
        ],
      ),
    );
  }

  void _handleCheckboxChange(int tokenIndex, bool newValue) {
    if (widget.onCheckboxChanged != null) {
      widget.onCheckboxChanged!(tokenIndex, newValue);

      // Update the text to reflect the new checkbox state
      List<Token> tokens = _parser.getTokenArray(_textController.text);
      if (tokenIndex < tokens.length &&
          tokens[tokenIndex].type == TokenType.checkbox) {
        String checkboxMarker = newValue ? "[x]" : "[]";
        String checkboxText = tokens[tokenIndex].text;

        // Find the checkbox in the text
        final String text = _textController.text;
        final List<String> lines = text.split('\n');

        for (int i = 0; i < lines.length; i++) {
          String line = lines[i];
          bool isUnchecked =
              line.startsWith("[]") && line.substring(2).trim() == checkboxText;
          bool isChecked = line.startsWith("[x]") &&
              line.substring(3).trim() == checkboxText;

          if (isUnchecked || isChecked) {
            // Replace the line with updated checkbox
            lines[i] = "$checkboxMarker $checkboxText";

            // Update text controller
            final newText = lines.join('\n');
            _textController.value = TextEditingValue(
              text: newText,
              selection: TextSelection.collapsed(
                  offset: _textController.selection.baseOffset),
            );

            if (widget.onTextChanged != null) {
              widget.onTextChanged!(_textController.text);
            }

            break;
          }
        }
      }
    }
  }
}
