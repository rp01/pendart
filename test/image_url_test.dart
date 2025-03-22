import '../lib/parser.dart';

void main() {
  final parser = PendartParser();

  print('\n----- Testing image URL parsing -----\n');

  // Test valid HTTPS URL
  testUrl(parser, 'https://picsum.photos/200');

  // Test invalid (non-HTTPS) URLs
  testUrl(parser, 'http://example.com/image.jpg');
  testUrl(parser, 'image.jpg');
}

void testUrl(PendartParser parser, String url) {
  print('Testing URL: "$url"');

  final tokens = parser.getTokenArray('[[$url]]');
  final imageToken = tokens.where((t) => t.type == TokenType.image).firstOrNull;

  if (imageToken == null) {
    print('  ERROR: No image token found');
    return;
  }

  print('  Token type: ${imageToken.type}');

  if (imageToken.attributes['src'] != null) {
    print('  Source: "${imageToken.attributes['src']}"');
  } else if (imageToken.attributes['error'] != null) {
    print('  Error: "${imageToken.attributes['error']}"');
  } else {
    print('  ISSUE: No src or error attribute found');
  }

  print('');
}
