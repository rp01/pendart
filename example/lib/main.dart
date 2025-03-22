import 'package:flutter/material.dart';
import 'package:pendart/parser.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pendart Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PendartDemoPage(),
    );
  }
}

class PendartDemoPage extends StatefulWidget {
  const PendartDemoPage({super.key});

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
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pendart Example'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: parser.processText(demoText, context),
        ),
      ),
    );
  }
}
