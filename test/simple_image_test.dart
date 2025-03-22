// A simple command-line tool to test image URL parsing
// without Flutter dependencies

import 'dart:io';

void main() {
  print('Testing image URL parsing');
  print('------------------------');

  testMarkupParsing("[[https://picsum.photos/200]]", "Valid HTTPS URL");
  testMarkupParsing("[[http://example.com/image.jpg]]", "Invalid HTTP URL");
  testMarkupParsing("[[image.jpg]]", "Invalid local path");
}

void testMarkupParsing(String markup, String description) {
  print('\nTesting: $description');
  print('Input: $markup');

  // Simple regex to extract URL from [[url]] format
  final RegExp imageRegex = RegExp(r'\[\[(.*?)\]\]');
  final match = imageRegex.firstMatch(markup);

  if (match != null) {
    final String url = match.group(1) ?? '';
    print('Extracted URL: $url');

    // Check if it's a secure URL
    if (url.startsWith('https://')) {
      print('✓ URL is secure (HTTPS)');
    } else if (url.startsWith('http://')) {
      print('✗ URL is not secure (HTTP) - Only HTTPS URLs are supported');
    } else {
      print('✗ Not a web URL - Only HTTPS URLs are supported');
    }
  } else {
    print('No URL found in the markup');
  }
}
