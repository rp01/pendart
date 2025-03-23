import 'package:flutter/material.dart';
import '../lib/preview.dart';
import '../lib/editor.dart';

/// Example app that demonstrates the Pendart widgets with dark mode support
class PendartExample extends StatefulWidget {
  const PendartExample({super.key});

  @override
  State<PendartExample> createState() => _PendartExampleState();
}

class _PendartExampleState extends State<PendartExample> {
  bool isDarkMode = false;
  String pendartText = '''! Pendart Markup Example

This is a simple example of **Pendart markup** with %%italic%% and __underlined__ text.

!! Code Examples

Here's some inline code: `print("Hello World")`.

And a code block:

:::
// A simple function in JavaScript
function greet(name) {
  return "Hello, " + name + "!";
}
:::

!! Lists and Checkboxes

[] A task to complete
[x] A completed task
[] Another pending task

!! Formatting

You can also use ~~strikethrough~~, ^^superscript^^ and ,,subscript,, text.

!! Links and Images

Check out this link: @@https://flutter.dev Flutter Website@@

Here's an image: [[https://picsum.photos/200]]

---

That's all for now!
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pendart Example'),
        actions: [
          // Dark mode toggle
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
          ),
        ],
      ),
      body: Theme(
        // Apply theme based on dark mode setting
        data: isDarkMode
            ? ThemeData.dark().copyWith(
                checkboxTheme: CheckboxThemeData(
                  fillColor: WidgetStateProperty.all(Colors.lightBlue),
                ),
              )
            : ThemeData.light(),
        child: Container(
          color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pendart Editor',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Editor with dark mode
                  PendartEditor(
                    initialText: pendartText,
                    height: 400,
                    onTextChanged: (text) {
                      setState(() {
                        pendartText = text;
                      });
                    },
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    'Pendart View (Read-only)',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Preview with dark mode
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      color: isDarkMode ? Colors.grey[850] : Colors.white,
                    ),
                    child: PendartView(
                      text: pendartText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Main entry point for the example app
void main() {
  runApp(const MaterialApp(
    title: 'Pendart Example',
    home: PendartExample(),
  ));
}
