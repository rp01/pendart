import 'package:flutter/material.dart';
import '../lib/parser.dart';

void main() {
  // Test the image parsing functionality directly
  final parser = PendartParser();

  // Test different URL formats
  const testUrl1 = "https://picsum.photos/200";
  const testUrl2 = "http://example.com/image.jpg";
  const testUrl3 = "image.jpg";

  // Get tokens for the test URLs
  final tokens1 = parser.getTokenArray("[[${testUrl1}]]");
  final tokens2 = parser.getTokenArray("[[${testUrl2}]]");
  final tokens3 = parser.getTokenArray("[[${testUrl3}]]");

  // Print the token attributes to see what's being set
  print("Token 1 (https URL):");
  printTokenAttributes(findImageToken(tokens1));

  print("\nToken 2 (http URL):");
  printTokenAttributes(findImageToken(tokens2));

  print("\nToken 3 (local path):");
  printTokenAttributes(findImageToken(tokens3));

  // Launch a Flutter app to visualize the result
  runApp(const MyApp());
}

Token? findImageToken(List<Token> tokens) {
  for (var token in tokens) {
    if (token.type == TokenType.image) {
      return token;
    }
  }
  return null;
}

void printTokenAttributes(Token? token) {
  if (token == null) {
    print("  No image token found");
    return;
  }

  print("  Type: ${token.type}");
  print("  Text: '${token.text}'");
  print("  Attributes:");
  token.attributes.forEach((key, value) {
    print("    $key: $value");
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Image URL Test'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Image URL Tests',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              buildImageTest(
                  'HTTPS URL (should work)', 'https://picsum.photos/200'),
              const SizedBox(height: 16),
              buildImageTest('HTTP URL (should show error)',
                  'http://example.com/image.jpg'),
              const SizedBox(height: 16),
              buildImageTest('Local path (should show error)', 'image.jpg'),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildImageTest(String label, String imageUrl) {
    final parser = PendartParser();
    final tokens = parser.getTokenArray("[[${imageUrl}]]");
    final imageToken = findImageToken(tokens);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('URL: $imageUrl'),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Token attributes:'),
              if (imageToken != null) ...[
                for (var entry in imageToken.attributes.entries)
                  Text('  ${entry.key}: ${entry.value}'),
              ] else
                Text('  No image token found'),
            ],
          ),
        ),
      ],
    );
  }
}
