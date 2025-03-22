import 'package:flutter_test/flutter_test.dart';
import 'package:pendart/utils.dart';

void main() {
  group('CodeToken', () {
    test('creates CodeToken with default values', () {
      final token = CodeToken();
      expect(token.text, '');
      expect(token.type, CodeTokenType.none);
    });

    test('creates CodeToken with specified values', () {
      final token = CodeToken()
        ..text = 'test'
        ..type = CodeTokenType.keyword;

      expect(token.text, 'test');
      expect(token.type, CodeTokenType.keyword);
    });
  });

  group('Language', () {
    test('base Language class identifies keywords, constants, and types', () {
      final language = Language();

      // Test with sample tokens
      final keywordToken = CodeToken()..text = 'if';
      final constantToken = CodeToken()..text = 'NULL';
      final typeToken = CodeToken()..text = 'int';

      // Base Language class should recognize common keywords
      expect(language.isKeyword(keywordToken), true);

      // Base Language should recognize common constants
      expect(language.isConstant(constantToken), true);

      // Base Language should recognize common types
      expect(language.isType(typeToken), true);
    });
  });

  group('CLanguage', () {
    test('CLanguage identifies C-specific keywords', () {
      final cLanguage = CLanguage();

      final cKeywordToken = CodeToken()..text = 'typedef';
      final cTypeToken = CodeToken()..text = 'size_t';

      expect(cLanguage.isKeyword(cKeywordToken), true);
      expect(cLanguage.isType(cTypeToken), true);
    });
  });

  group('CppLanguage', () {
    test('CppLanguage identifies C++-specific keywords', () {
      final cppLanguage = CppLanguage();

      final cppKeywordToken = CodeToken()..text = 'class';
      final cppConstantToken = CodeToken()..text = 'nullptr';

      expect(cppLanguage.isKeyword(cppKeywordToken), true);
      expect(cppLanguage.isConstant(cppConstantToken), true);
    });
  });
}
