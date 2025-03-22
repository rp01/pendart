import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pendart/parser.dart';

void main() {
  group('PendartParser - Basic Functionality', () {
    late PendartParser parser;

    setUp(() {
      parser = PendartParser();
    });

    test('initializes with default modifiers', () {
      // Verify that modifiers are initialized correctly
      expect(parser.modifierMap.length, 11);
      expect(parser.modifierMap["°"], "gray");
      expect(parser.modifierMap["⁰"], "orange");
      expect(parser.modifierMap["⁹"], "green");
    });

    test('getCleanedText replaces tabs with spaces', () {
      final result = parser.getCleanedText("Line1\n\tIndented\n\t\tDouble", 4);
      expect(result, "Line1\n    Indented\n        Double\n");
    });

    test('getCleanedText ensures text ends with newline', () {
      final result = parser.getCleanedText("Text without newline", 4);
      expect(result.endsWith('\n'), true);
    });

    test('getCleanedText removes carriage returns', () {
      final result = parser.getCleanedText("Line1\r\nLine2", 4);
      expect(result, "Line1\nLine2\n");
    });
  });

  group('PendartParser - Token Generation', () {
    late PendartParser parser;

    setUp(() {
      parser = PendartParser();
    });

    test('creates text token correctly', () {
      List<Token> tokens = parser.getTokenArray("Simple text");
      expect(tokens.length, isPositive);
      expect(tokens.first.type, TokenType.text);
      expect(tokens.first.text, "S");
    });

    test('creates heading tokens correctly', () {
      List<Token> tokens = parser.getTokenArray("! Heading 1\n!! Heading 2");

      // First token should be a heading1
      expect(tokens.first.type, TokenType.heading1);
      expect(tokens.first.text, "Heading 1");

      // Find heading2 token
      final heading2Token =
          tokens.where((t) => t.type == TokenType.heading2).first;
      expect(heading2Token.text, "Heading 2");
    });

    test('creates formatting tokens correctly', () {
      List<Token> tokens =
          parser.getTokenArray("**bold** %%italic%% ~~strike~~ __underline__");

      // Check for bold tokens
      expect(tokens.where((t) => t.type == TokenType.bold).length, 2);

      // Check for italic tokens
      expect(tokens.where((t) => t.type == TokenType.italic).length, 2);

      // Check for strikethrough tokens
      expect(tokens.where((t) => t.type == TokenType.strikethrough).length, 2);

      // Check for underline tokens
      expect(tokens.where((t) => t.type == TokenType.underline).length, 2);
    });

    test('creates checkbox tokens correctly', () {
      List<Token> tokens =
          parser.getTokenArray("[] Unchecked task\n[x] Checked task");

      // Find checkbox tokens
      final uncheckedToken =
          tokens.where((t) => t.type == TokenType.checkbox).first;
      final checkedToken = tokens
          .where((t) =>
              t.type == TokenType.checkbox && t.attributes["checked"] == "true")
          .first;

      expect(uncheckedToken.text, "Unchecked task");
      expect(uncheckedToken.attributes["checked"], "false");

      expect(checkedToken.text, "Checked task");
      expect(checkedToken.attributes["checked"], "true");
    });

    test('creates link tokens correctly', () {
      List<Token> tokens = parser.getTokenArray("@@https://example.com@@");

      // Find link token
      final linkToken = tokens.where((t) => t.type == TokenType.link).first;
      expect(linkToken.attributes["href"], "https://example.com");
      expect(linkToken.attributes["error"], null);
    });

    // Test for link with non-secure URL showing error
    test('handles non-secure link URLs correctly', () {
      List<Token> tokens = parser.getTokenArray("@@http://example.com@@");

      // Find link token
      final linkToken = tokens.where((t) => t.type == TokenType.link).first;
      expect(linkToken.attributes["href"], null);
      expect(linkToken.attributes["error"],
          "Only secure (https) URLs are supported");
    });

    // Test for potentially unsafe link showing error
    test('handles potentially unsafe link URLs correctly', () {
      List<Token> tokens = parser
          .getTokenArray("@@https://evil.com?param=javascript:alert('xss')@@");

      // Find link token
      final linkToken = tokens.where((t) => t.type == TokenType.link).first;
      expect(linkToken.attributes["href"],
          "https://evil.com?param=javascript:alert('xss')");
      expect(linkToken.attributes["error"], "Potentially unsafe URL");
    });

    test('creates image tokens correctly', () {
      List<Token> tokens =
          parser.getTokenArray("[[https://example.com/image.jpg]]");

      // Verify that image tokens are created
      final imageTokens = tokens.where((t) => t.type == TokenType.image);
      expect(imageTokens.isNotEmpty, true);

      if (imageTokens.isNotEmpty) {
        final imageToken = imageTokens.first;
        expect(imageToken.attributes["src"], "https://example.com/image.jpg");
      }
    });

    // Test for image with non-secure URL showing error
    test('handles non-secure image URLs correctly', () {
      List<Token> tokens = parser.getTokenArray("[[image.jpg]]");

      // Find image tokens
      final imageTokens = tokens.where((t) => t.type == TokenType.image);
      expect(imageTokens.isNotEmpty, true);

      if (imageTokens.isNotEmpty) {
        final imageToken = imageTokens.first;
        expect(imageToken.attributes["src"], null);
        expect(imageToken.attributes["error"],
            "Only secure (https) URLs are supported");
      }
    });

    test('creates code span tokens correctly', () {
      List<Token> tokens = parser.getTokenArray("`code`");

      // Find code span token
      final codeToken = tokens.where((t) => t.type == TokenType.codeSpan).first;
      expect(codeToken.text, "code");
    });

    test('handles escaped characters correctly', () {
      List<Token> tokens = parser.getTokenArray("¬**not bold¬**");

      // Should be text tokens, not formatting
      expect(tokens.where((t) => t.type == TokenType.bold).length, 0);
      expect(tokens.where((t) => t.isEscaped).length, 2);
    });
  });

  group('PendartParser - Widget Building', () {
    late PendartParser parser;
    late BuildContext testContext;

    setUp(() {
      parser = PendartParser();
    });

    testWidgets('processText creates widgets for simple text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              testContext = context;
              return Container();
            },
          ),
        ),
      );

      final widgets = parser.processText("Simple text", testContext);

      // The text spans might be split due to our link handling changes
      // So we look for at least one widget that is a RichText
      expect(widgets.where((w) => w is RichText).length, greaterThan(0));
    });

    testWidgets('processText creates heading widgets',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              testContext = context;
              return Container();
            },
          ),
        ),
      );

      final widgets = parser.processText("! Heading 1", testContext);

      // Find the Text widget for the heading
      final headingWidget = widgets.whereType<Text>().first;
      expect(headingWidget.data, "Heading 1");

      // Check the style is a headline style (only check the font size)
      expect(headingWidget.style?.fontSize, greaterThan(20));
    });

    testWidgets('processText creates checkbox widgets',
        (WidgetTester tester) async {
      bool? checkboxChanged;
      int? tokenIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              testContext = context;
              return Container();
            },
          ),
        ),
      );

      final widgets = parser.processText("[] Task Item", testContext,
          onCheckboxChanged: (index, value) {
        tokenIndex = index;
        checkboxChanged = value;
      });

      // Find any widget containing a Checkbox and simulate tapping it
      Checkbox? checkbox;
      bool foundCheckbox = false;

      // Search through all widgets for a Checkbox
      for (final widget in widgets) {
        if (widget is Row) {
          for (final child in widget.children) {
            if (child is Checkbox) {
              checkbox = child;
              foundCheckbox = true;
              break;
            }
          }
        }
        if (foundCheckbox) break;
      }

      expect(foundCheckbox, true);

      if (checkbox != null) {
        // Simulate checkbox tap
        checkbox.onChanged?.call(true);

        // Verify callback was triggered
        expect(tokenIndex, isNotNull);
        expect(checkboxChanged, true);
      }
    });

    testWidgets('processText creates horizontal rule widget',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              testContext = context;
              return Container();
            },
          ),
        ),
      );

      final widgets = parser.processText("---", testContext);

      expect(widgets.whereType<Divider>().length, greaterThan(0));
    });

    testWidgets('processText creates code block widget',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              testContext = context;
              return Container();
            },
          ),
        ),
      );

      final widgets = parser.processText(":::\ncode block\n:::", testContext);

      expect(widgets.whereType<Container>().length, greaterThan(0));

      // Check the container has a background color
      final container = widgets.whereType<Container>().first;
      expect(container.color, isNotNull);
    });

    testWidgets('processText handles formatting correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              testContext = context;
              return Container();
            },
          ),
        ),
      );

      final boldWidgets = parser.processText("**bold text**", testContext);
      final italicWidgets = parser.processText("%%italic text%%", testContext);

      // Check that we have RichText widgets for formatted text
      expect(boldWidgets.whereType<RichText>().length, greaterThan(0));
      expect(italicWidgets.whereType<RichText>().length, greaterThan(0));
    });
  });

  group('PendartParser - Tag Management', () {
    late PendartParser parser;

    setUp(() {
      parser = PendartParser();
    });

    test('addTag adds a tag correctly', () {
      parser.addTag("test", "definition");
      expect(parser.tagArray.length, 1);
      expect(parser.tagArray.first.name, "test");
      expect(parser.tagArray.first.definitionArray.first, "definition");
    });

    test('addTag adds multiple definitions to existing tag', () {
      parser.addTag("test", "definition1");
      parser.addTag("test", "definition2");

      expect(parser.tagArray.length, 1);
      expect(parser.tagArray.first.definitionArray.length, 2);
      expect(parser.tagArray.first.definitionArray[1], "definition2");
    });

    test('removeTag removes a tag correctly', () {
      parser.addTag("test1", "definition1");
      parser.addTag("test2", "definition2");

      expect(parser.tagArray.length, 2);

      parser.removeTag("test1");
      expect(parser.tagArray.length, 1);
      expect(parser.tagArray.first.name, "test2");
    });
  });

  group('PendartParser - StringBuilder', () {
    test('StringBuilder correctly builds strings', () {
      StringBuilder builder = StringBuilder();
      builder.write("Hello");
      builder.write(" ");
      builder.write("World");

      expect(builder.toString(), "Hello World");
    });
  });
}
