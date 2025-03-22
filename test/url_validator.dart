import 'dart:io';

void main() {
  print('===== URL Security Validator for Links and Images =====\n');

  final urls = [
    'https://picsum.photos/200',
    'https://picsum.photos/200/200',
    'http://example.com/image.jpg',
    'image.jpg',
    'file:///etc/passwd',
    'javascript:alert("XSS")',
    'data:text/html,<script>alert("XSS")</script>',
    'https://evil.com?redirect=javascript:alert("XSS")',
    'https://legitimatesite.com',
    '//protocol-relative.com',
    'ftp://files.example.com',
  ];

  for (final url in urls) {
    validateUrl(url);
  }
}

void validateUrl(String url) {
  print('Testing URL: $url');

  // Check for HTTPS protocol
  final isSecureHttps = url.startsWith('https://');

  // Check for potentially dangerous URL schemes
  final hasBlockedScheme =
      RegExp(r'^(javascript|data|file|ftp|ws|wss):').hasMatch(url);

  // Check for protocol-relative URLs (could load content over http)
  final isProtocolRelative = url.startsWith('//');

  // Check for script injection attempts in the URL
  final hasScriptInjection = url.toLowerCase().contains('script') ||
      url.contains('javascript:') ||
      url.contains('eval(') ||
      url.contains('onerror=');

  // Check URL structure (simple check)
  final hasValidDomain = isSecureHttps &&
      RegExp(r'^https://[a-zA-Z0-9][\w\-\.]+\.[a-zA-Z]{2,}').hasMatch(url);

  // Validate for image use
  print('📷 Image URL validation:');
  if (isSecureHttps) {
    if (hasScriptInjection || hasBlockedScheme) {
      print('  ❌ REJECTED: Potentially unsafe URL');
    } else {
      print('  ✅ ACCEPTED: URL is secure (https)');
    }
  } else {
    print('  ❌ REJECTED: Not using HTTPS protocol');
  }

  // Validate for link use (same validation as images in this implementation)
  print('🔗 Link URL validation:');
  if (isSecureHttps) {
    if (hasScriptInjection || hasBlockedScheme) {
      print('  ❌ REJECTED: Potentially unsafe URL');
    } else {
      print('  ✅ ACCEPTED: URL is secure (https)');
    }
  } else {
    print('  ❌ REJECTED: Not using HTTPS protocol');
  }

  print('-------------------');
}
