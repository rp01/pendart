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

  const PendartEditor({
    super.key,
    this.initialText = '',
    this.onTextChanged,
    this.onCheckboxChanged,
    this.height = 400,
    this.width,
    this.enableCheckboxes = true,
  });

  @override
  State<PendartEditor> createState() => _PendartEditorState();
}

class _PendartEditorState extends State<PendartEditor> {
  late TextEditingController _textController;
  late PendartParser _parser;
  bool _isPreviewMode = false;
  ScrollController _scrollController = ScrollController();

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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            IconButton(
              icon: Icon(_isPreviewMode ? Icons.edit : Icons.visibility),
              tooltip: _isPreviewMode ? 'Edit' : 'Preview',
              onPressed: () {
                setState(() {
                  _isPreviewMode = !_isPreviewMode;
                });
              },
            ),
            const VerticalDivider(width: 16, thickness: 1),
            IconButton(
              icon: const Icon(Icons.format_bold),
              tooltip: 'Bold',
              onPressed: () =>
                  _insertFormatting('**', '**', placeholder: 'bold text'),
            ),
            IconButton(
              icon: const Icon(Icons.format_italic),
              tooltip: 'Italic',
              onPressed: () =>
                  _insertFormatting('%%', '%%', placeholder: 'italic text'),
            ),
            IconButton(
              icon: const Icon(Icons.format_strikethrough),
              tooltip: 'Strikethrough',
              onPressed: () => _insertFormatting('~~', '~~',
                  placeholder: 'strikethrough text'),
            ),
            IconButton(
              icon: const Icon(Icons.format_underlined),
              tooltip: 'Underline',
              onPressed: () =>
                  _insertFormatting('__', '__', placeholder: 'underlined text'),
            ),
            IconButton(
              icon: const Text('H1',
                  style: TextStyle(fontWeight: FontWeight.bold)),
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
              icon: const Text('H2',
                  style: TextStyle(fontWeight: FontWeight.bold)),
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
              icon: const Icon(Icons.code),
              tooltip: 'Code',
              onPressed: () => _insertFormatting('`', '`', placeholder: 'code'),
            ),
            IconButton(
              icon: const Icon(Icons.insert_link),
              tooltip: 'Link',
              onPressed: () => _insertFormatting('@@', '@@',
                  placeholder: 'https://example.com'),
            ),
            IconButton(
              icon: const Icon(Icons.image),
              tooltip: 'Image',
              onPressed: () =>
                  _insertFormatting('[[', ']]', placeholder: 'image.jpg'),
            ),
            IconButton(
              icon: const Icon(Icons.check_box_outline_blank),
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
              icon: const Icon(Icons.check_box),
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
              icon: const Icon(Icons.horizontal_rule),
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
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(
        children: [
          _buildToolbar(),
          Expanded(
            child: _isPreviewMode
                ? SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _parser.processText(
                        _textController.text,
                        context,
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
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(16.0),
                      border: InputBorder.none,
                      hintText: 'Write your Pendart text here...',
                    ),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
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
