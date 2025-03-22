// A simple command-line debugging tool for the parser
import 'parser.dart';

void main() {
  final parser = PendartParser();

  // Test URLs
  testImageToken(parser, 'https://picsum.photos/200');
  testImageToken(parser, 'http://example.com/image.jpg');
  testImageToken(parser, 'image.jpg');
}

void testImageToken(PendartParser parser, String url) {
  final text = '[[$url]]';
  final tokens = parser.getTokenArray(text);

  print('\nTesting image URL: "$url"');
  print('Input text: "$text"');

  final imageTokens = tokens.where((t) => t.type == TokenType.image).toList();

  if (imageTokens.isEmpty) {
    print('No image tokens found!');
    print('All tokens:');
    for (final t in tokens) {
      print('  ${t.type}: "${t.text}"');
    }
    return;
  }

  for (int i = 0; i < imageTokens.length; i++) {
    final token = imageTokens[i];
    print('Image token #${i + 1}:');
    print('  Text: "${token.text}"');
    print('  Attributes:');
    token.attributes.forEach((key, value) {
      print('    $key: "$value"');
    });
  }
}
