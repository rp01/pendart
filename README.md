# Pendart

A Flutter package for editing and rendering rich text markup with support for light and dark modes.

## Features

* Simple, intuitive markup syntax
* Editor with formatting toolbar
* Live preview
* Checkbox support
* Code syntax highlighting
* Light and dark mode support

## Usage

### PendartView Widget

`PendartView` is a simple widget for displaying Pendart markup as formatted text:

```dart
import 'package:pendart/preview.dart';

// ...

PendartView(
  text: "This is **bold** and this is %%italic%%",
  isDarkMode: false, // Set to true for dark mode
)
```

### PendartEditor Widget

`PendartEditor` provides a full editor experience with a formatting toolbar:

```dart
import 'package:pendart/editor.dart';

// ...

PendartEditor(
  initialText: "# Start typing here",
  height: 400,
  isDarkMode: false, // Set to true for dark mode
  onTextChanged: (text) {
    // Do something with the updated text
    print('Text updated: $text');
  },
)
```

## Markup Syntax

Pendart uses a simple markup language:

| Markup | Result |
|--------|--------|
| `**text**` | **Bold text** |
| `%%text%%` | *Italic text* |
| `__text__` | <u>Underlined text</u> |
| `~~text~~` | ~~Strikethrough text~~ |
| `! Text` | # Heading 1 |
| `!! Text` | ## Heading 2 |
| `[]` | ☐ Unchecked checkbox |
| `[x]` | ☑ Checked checkbox |
| `@@url text@@` | [text](url) |
| `[[image.jpg]]` | Image |
| `---` | Horizontal rule |
| ````code```` | `Inline code` |
| `:::` and `:::` | Code block |

## Dark Mode Support

Both `PendartView` and `PendartEditor` support dark mode through the `isDarkMode` property. When enabled, the widgets will use a dark color scheme for better visibility in dark environments.

Example with theme switching:

```dart
bool isDarkMode = false;

// ... in your build method:
PendartEditor(
  initialText: "Dark mode example", 
  isDarkMode: isDarkMode,
  onTextChanged: (text) {
    // Handle text changes
  },
),

// Toggle dark mode
FloatingActionButton(
  onPressed: () {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  },
  child: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
)
```

## Example

Check out the `example.dart` file for a complete example of how to use Pendart with dark mode support.

## License

MIT