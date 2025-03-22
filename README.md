# Pendart

A lightweight markup language and editor for Flutter applications. Pendart provides a simple syntax for formatting text, headings, code blocks, and interactive checkboxes.

Inspired by [PENDOWN](https://github.com/SenseLogic/PENDOWN), but built natively for Flutter. Unlike other markdown libraries that use an HTML intermediate layer, Pendart directly converts markup to Flutter widgets for better performance and native look and feel.

## Features

- **Native Flutter Rendering**: Text is converted directly to Flutter widgets without any HTML intermediate layer
- **Rich Text Formatting**: Bold, italic, strikethrough, underline
- **Headings**: Multiple levels of headings (H1-H6)
- **Interactive Checkboxes**: Fully functional checkboxes that maintain state
- **Code Blocks**: Support for inline code and code blocks with syntax highlighting
- **Live Preview**: Real-time rendering of formatted text
- **Fully Customizable**: Adjust the editor to fit your application's needs

## Installation

Add Pendart to your `pubspec.yaml`:

```yaml
dependencies:
  pendart: ^0.1.0
```

Then run:

```
flutter pub get
```

## Usage

### Basic Example

```dart
import 'package:flutter/material.dart';
import 'package:pendart/editor.dart';

class MyEditorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pendart Editor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PendartEditor(
          initialText: '! Welcome to Pendart\n\nThis is a **rich text** editor for Flutter.',
          onTextChanged: (text) {
            print('Text changed: $text');
          },
        ),
      ),
    );
  }
}
```

### Interactive Checkboxes

One of Pendart's standout features is its support for interactive checkboxes:

```dart
PendartEditor(
  initialText: '[] Task to do\n[x] Completed task',
  onCheckboxChanged: (index, checked) {
    // Called when a checkbox is toggled
    print('Checkbox $index changed to $checked');
  },
)
```

### Customization

You can customize the size of the editor:

```dart
PendartEditor(
  height: 300, // Default is 400
  width: double.infinity, // Optional, defaults to container width
  enableCheckboxes: true, // Enable or disable checkbox functionality
)
```

## Syntax Reference

Pendart uses a simple and intuitive markup syntax:

| Element | Syntax | Example |
|---------|--------|---------|
| Heading 1 | `! Heading` | ! Main Title |
| Heading 2 | `!! Heading` | !! Subtitle |
| Bold | `**text**` | **bold text** |
| Italic | `%%text%%` | %%italic text%% |
| Strikethrough | `~~text~~` | ~~strikethrough text~% |
| Underline | `__text__` | __underlined text__ |
| Code | `` `code` `` | `code` |
| Link | `@@url@@` or `@@url text@@` | @@https://flutter.dev Flutter@@ |
| Image | `[[image.jpg]]` | [[logo.png]] |
| Checkbox | `[] Task` or `[x] Task` | [] Unchecked task<br>[x] Checked task |
| Horizontal Rule | `---` | --- |
| Line Break | `§` | Text§More text |

## Code Blocks

Pendart supports code blocks with syntax highlighting:

For syntax highlighting, specify the language:

:::¨c¨
#include <stdio.h>
int main() {
printf("Hello, World!\n");
return 0;
}
:::

## Why Pendart?

### Native Flutter Widgets

Unlike other markup solutions that convert text to HTML and then render it in a WebView, Pendart directly converts markup to Flutter widgets. This approach offers:

- **Better Performance**: No HTML/CSS rendering overhead
- **Native Look and Feel**: Widgets respect your app's theme and styling
- **Smaller Size**: No need for HTML rendering dependencies
- **Interactive Elements**: Native support for interactive elements like checkboxes

### Inspired by PENDOWN

Pendart takes inspiration from [PENDOWN](https://github.com/SenseLogic/PENDOWN), a text-to-HTML conversion tool, but adapts its concepts specifically for Flutter's widget-based UI paradigm.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.