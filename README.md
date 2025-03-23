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

## Theme Support

As of version 0.3.0, Pendart has improved theme support that integrates with your app's theme:

### Using System Theme

Both `PendartView` and `PendartEditor` can automatically use your app's theme:

```dart
import 'package:pendart/preview.dart';
import 'package:pendart/editor.dart';

// The widgets will automatically use your app's ThemeData
PendartView(
  text: "This text respects your app's theme",
)

PendartEditor(
  initialText: "# Start typing here",
  height: 400,
)
```

### Custom Theme

You can also provide a custom theme:

```dart
// For light theme
final lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
  // other properties...
);

// For dark theme
final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.blueAccent,
  // other properties...
);

// Pass the theme directly to the widgets
PendartEditor(
  initialText: "# Custom themed editor",
  theme: isDarkMode ? darkTheme : lightTheme,
)
```

### Deprecated Properties

The `isDarkMode` property is deprecated in favor of using ThemeData:

```dart
// Old way (still supported but deprecated)
PendartEditor(
  initialText: "Text",
  isDarkMode: true, // Deprecated
)

// New way
PendartEditor(
  initialText: "Text",
  // No need to set isDarkMode, it will use your app's theme
)
```

## Example

Check out the `example` folder for a complete example of how to use Pendart with theme switching.

## License

MIT