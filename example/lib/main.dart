import 'package:flutter/material.dart';
import 'package:pendart/parser.dart';
import 'package:pendart/editor.dart';
import 'package:pendart/preview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  // Toggle theme
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pendart Example',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue,
        canvasColor: Colors.grey[850],
        cardColor: Colors.grey[800],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: PendartDemoPage(
        toggleTheme: _toggleTheme,
        isDarkMode: _isDarkMode,
      ),
    );
  }
}

class PendartDemoPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const PendartDemoPage({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  _PendartDemoPageState createState() => _PendartDemoPageState();
}

class _PendartDemoPageState extends State<PendartDemoPage> {
  final PendartParser parser = PendartParser();

  final String demoText = '''
! Pendart Demo

This is a demo of the Pendart markup language.

!! Formatting

You can use **bold**, %%italic%%, ~~strikethrough~~, and __underline__.

!! Links

Links can be created in two ways:

1. Self-contained link: @@https://flutter.dev@@
2. Custom text link: @@https://dart.dev Dart Language@@

You can tap on these links to open them in your browser.

!! Secure URLs

Only secure (HTTPS) URLs are supported:

- Secure link: @@https://pub.dev@@
- Insecure link: @@http://example.com@@
- Invalid link: @@file:///etc/passwd@@

!! Images

Images also require secure URLs:

[[https://picsum.photos/200/200]]

Invalid image URLs will show error messages:

[[http://example.com/image.jpg]]
[[image.jpg]]

!! Theme Support

This demo shows how Pendart respects your app's theme. Try toggling between light and dark mode using the button in the app bar.
''';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pendart Example'),
          actions: [
            IconButton(
              icon:
                  Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: widget.toggleTheme,
              tooltip: widget.isDarkMode
                  ? 'Switch to Light Mode'
                  : 'Switch to Dark Mode',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Parser Demo'),
              Tab(text: 'Editor Demo'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Parser demo tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: parser.processText(demoText, context),
              ),
            ),

            // Editor demo tab
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: PendartEditor(
                initialText: demoText,
                height: double.infinity,
                width: double.infinity,
                // No need to manually pass theme - it will use the app's theme automatically
              ),
            ),
          ],
        ),
      ),
    );
  }
}
