import 'package:flutter/material.dart';
import '../lib/preview.dart';
import '../lib/parser.dart';

void main() {
  // Test directly
  final parser = PendartParser();

  testImageToken(parser, 'https://picsum.photos/200');
  testImageToken(parser, 'http://example.com/image.jpg');
  testImageToken(parser, 'image.jpg');

  runApp(const MyImageTest());
}

void testImageToken(PendartParser parser, String url) {
  final tokens = parser.getTokenArray('[[$url]]');
  final imageToken = tokens.firstWhere((t) => t.type == TokenType.image,
      orElse: () => Token());

  print('\nTesting URL: $url');
  print('Token type: ${imageToken.type}');
  print('Token attributes:');
  imageToken.attributes.forEach((key, value) {
    print('  $key: "$value"');
  });
}

class MyImageTest extends StatelessWidget {
  const MyImageTest({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Image URL Test'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Secure URL (should work):'),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                width: double.infinity,
                child: const PendartView(
                  text: '[[https://picsum.photos/200]]',
                ),
              ),
              const Text('Non-secure URL (should show error):'),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                width: double.infinity,
                child: const PendartView(
                  text: '[[http://example.com/image.jpg]]',
                ),
              ),
              const Text('Local path (should show error):'),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(8),
                width: double.infinity,
                child: const PendartView(
                  text: '[[image.jpg]]',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
