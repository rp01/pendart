import 'package:flutter/material.dart';
import 'utils.dart';

/// Helper class for string building
class StringBuilder {
  final StringBuffer _buffer = StringBuffer();

  void write(String str) {
    _buffer.write(str);
  }

  @override
  String toString() {
    return _buffer.toString();
  }
}

/// Represents a token in the Pendart markup
class Token {
  String text = "";
  TokenType type = TokenType.text;
  bool startsLine = false;
  bool isSpace = false;
  bool isEscaped = false;
  Map<String, String> attributes = {};
}

/// Token types for Pendart markup
enum TokenType {
  text,
  heading1,
  heading2,
  heading3,
  heading4,
  heading5,
  heading6,
  bold,
  italic,
  superscript,
  subscript,
  strikethrough,
  underline,
  codeBlock,
  codeSpan,
  horizontalRule,
  pageBreak,
  lineBreak,
  checkbox,
  image,
  link,
  space,
  newline
}

/// Represents a tag definition in Pendart
class Tag {
  String name = "";
  List<String> definitionArray = [];
  int definitionIndex = 0;
}

/// Class for parsing Pendart markup and converting to Flutter widgets
class PendartParser {
  static const int tabulationSpaceCount = 4;
  static const int indentationSpaceCount = 4;

  final Map<String, String> modifierMap = {};
  final List<Tag> tagArray = [];

  PendartParser() {
    _initializeModifiers();
  }

  /// Initialize default modifiers
  void _initializeModifiers() {
    modifierMap["°"] = "gray";
    modifierMap["⁰"] = "orange";
    modifierMap["¹"] = "pink";
    modifierMap["²"] = "red";
    modifierMap["³"] = "blue";
    modifierMap["⁴"] = "violet";
    modifierMap["⁵"] = "cyan";
    modifierMap["⁶"] = "black";
    modifierMap["⁷"] = "yellow";
    modifierMap["⁸"] = "white";
    modifierMap["⁹"] = "green";
  }

  /// Get cleaned text with tabulations replaced with spaces
  String getCleanedText(String text, int tabSpaceCount) {
    // Replace tab characters with spaces
    String cleanedText = text;

    // Replace tab+tab with tab+spaces
    cleanedText = cleanedText.replaceAll("\t\t", "\t    ");
    cleanedText = cleanedText.replaceAll("\n\t", "\n    ");

    if (cleanedText.contains('\t')) {
      String replacedText = "";
      int lineCharacterIndex = 0;

      for (int charIndex = 0; charIndex < cleanedText.length; charIndex++) {
        String character = cleanedText[charIndex];

        if (character == '\t') {
          do {
            replacedText += ' ';
            lineCharacterIndex++;
          } while ((lineCharacterIndex % tabSpaceCount) != 0);
        } else {
          replacedText += character;

          if (character == '\n') {
            lineCharacterIndex = 0;
          } else {
            lineCharacterIndex++;
          }
        }
      }

      cleanedText = replacedText;
    }

    // Remove carriage returns and ensure the text ends with a newline
    cleanedText = cleanedText.replaceAll("\r", "");

    if (!cleanedText.endsWith('\n')) {
      cleanedText += '\n';
    }

    return cleanedText;
  }

  /// Get preprocessed text with code blocks highlighted
  String getPreprocessedText(String text) {
    String preprocessedText = getCleanedText(text, tabulationSpaceCount);
    List<String> lineArray = preprocessedText.split('\n');

    for (int lineIndex = 0; lineIndex < lineArray.length; lineIndex++) {
      String line = lineArray[lineIndex].trim();

      if (line.isEmpty) {
        lineArray[lineIndex] = "";
      } else if (line.startsWith(":::")) {
        // Handle code blocks with syntax highlighting
        if (line.startsWith(":::¨c¨") ||
            line.startsWith(":::¨h¨") ||
            line.startsWith(":::¨cpp¨") ||
            line.startsWith(":::¨hpp¨") ||
            line.startsWith(":::¨cxx¨") ||
            line.startsWith(":::¨hxx¨") ||
            line.startsWith(":::¨cs¨") ||
            line.startsWith(":::¨d¨") ||
            line.startsWith(":::¨java¨") ||
            line.startsWith(":::¨js¨") ||
            line.startsWith(":::¨ts¨")) {
          String fileExtension = line.split('¨')[1];
          String style = line.substring(line.substring(4).indexOf('¨') + 5);

          String codeText = "";
          int postLineIndex;

          for (postLineIndex = lineIndex + 1;
              postLineIndex < lineArray.length;
              postLineIndex++) {
            String codeLine = lineArray[postLineIndex];

            if (codeLine.trim() == ":::") {
              break;
            } else {
              codeText += codeLine;
              codeText += '\n';
            }
          }

          if (codeText.isNotEmpty) {
            codeText = getColorizedText(codeText, "", fileExtension, style);
            List<String> codeLineArray = codeText.split('\n');

            for (int codeLineIndex = 0;
                codeLineIndex < codeLineArray.length &&
                    lineIndex < postLineIndex;
                codeLineIndex++) {
              lineArray[lineIndex] = codeLineArray[codeLineIndex];
              lineIndex++;
            }
          }
        }
      }
    }

    return lineArray.join('\n');
  }

  /// Get text with colorized syntax highlighting
  String getColorizedText(
      String text, String filePath, String fileExtension, String style) {
    // Create map for color prefixes based on token types
    Map<int, String> colorPrefixes = {
      0: "", // None
      1: "°", // ShortComment (gray)
      2: "°", // LongComment (gray)
      3: "²", // String (red)
      4: "²", // Number (red)
      5: "²", // Constant (red)
      6: "²", // Type (red)
      7: "¹", // Keyword (pink)
      8: "²", // Pragma (red)
      9: "", // LowerCaseIdentifier
      10: "⁰", // UpperCaseIdentifier (orange)
      11: "", // MinorCaseIdentifier
      12: "", // MajorCaseIdentifier
      13: "²", // Identifier (red)
      14: "°", // Operator (gray)
      15: "°", // Separator (gray)
      16: "°", // Delimiter (gray)
      17: "°", // Special (gray)
      18: "", // Spacing
    };

    // Parse and tokenize code
    List<CodeToken> codeTokens = _getCodeTokens(text, fileExtension);

    // Apply color markers
    String colorizedText = ":::$style\n";

    for (int i = 0; i < codeTokens.length; i++) {
      CodeToken token = codeTokens[i];
      int tokenType = token.type.index;

      // Add color prefix if needed
      if (i == 0 ||
          colorPrefixes[tokenType] !=
              colorPrefixes[codeTokens[i - 1].type.index]) {
        colorizedText += colorPrefixes[tokenType] ?? "";
      }

      // Add token text
      colorizedText += token.text;

      // Add color suffix if needed
      if (i == codeTokens.length - 1 ||
          colorPrefixes[tokenType] !=
              colorPrefixes[codeTokens[i + 1].type.index]) {
        colorizedText += colorPrefixes[tokenType] ?? "";
      }
    }

    colorizedText += ":::\n";
    return colorizedText;
  }

  /// Parse code into tokens for syntax highlighting
  List<CodeToken> _getCodeTokens(String text, String fileExtension) {
    // Clean the text
    text = getCleanedText(text, tabulationSpaceCount);

    // Get the language based on file extension
    Language language = _getLanguageFromExtension(fileExtension);

    List<CodeToken> codeTokens = [];
    int charIndex = 0;
    CodeToken? currentToken;
    String? delimiterChar;

    while (charIndex <= text.length) {
      String char = charIndex < text.length ? text[charIndex] : "";
      String nextChar =
          (charIndex + 1) < text.length ? text[charIndex + 1] : "";

      if (currentToken != null) {
        // Continue an existing token
        if (currentToken.type == CodeTokenType.string) {
          if (char == delimiterChar) {
            currentToken.text += char;
            currentToken = null;
            delimiterChar = null;
          } else if (char == '\\' && nextChar.isNotEmpty) {
            currentToken.text += char + nextChar;
            charIndex += 2;
            continue;
          } else {
            currentToken.text += char;
          }
        } else if (currentToken.type == CodeTokenType.shortComment) {
          if (char == '\r' || char == '\n') {
            currentToken = null;
            continue;
          } else {
            currentToken.text += char;
          }
        } else if (currentToken.type == CodeTokenType.longComment) {
          if (char == '*' && nextChar == '/') {
            currentToken.text += "*/";
            currentToken = null;
            charIndex += 2;
            continue;
          } else {
            currentToken.text += char;
          }
        } else if ((currentToken.type == CodeTokenType.number &&
                (_isDigit(char) ||
                    (char == '.' && _isDigit(nextChar)) ||
                    _isAlpha(char))) ||
            (currentToken.type == CodeTokenType.identifier &&
                (_isAlpha(char) || _isDigit(char) || char == '_')) ||
            (currentToken.type == CodeTokenType.operator &&
                "~+-*/%^\$&|?:!=<>#".contains(char))) {
          currentToken.text += char;
        } else {
          // Token is complete, determine specific type for identifiers
          if (currentToken.type == CodeTokenType.identifier) {
            if (language.isConstant(currentToken)) {
              currentToken.type = CodeTokenType.constant;
            } else if (language.isType(currentToken)) {
              currentToken.type = CodeTokenType.type;
            } else if (language.isKeyword(currentToken)) {
              currentToken.type = CodeTokenType.keyword;
            } else if (currentToken.text.startsWith('#')) {
              currentToken.type = CodeTokenType.pragma;
            } else if (currentToken.text == currentToken.text.toLowerCase()) {
              currentToken.type = CodeTokenType.lowerCaseIdentifier;
            } else if (currentToken.text == currentToken.text.toUpperCase() &&
                currentToken.text.length >= 2) {
              currentToken.type = CodeTokenType.upperCaseIdentifier;
            } else if (currentToken.text[0].toLowerCase() ==
                currentToken.text[0]) {
              currentToken.type = CodeTokenType.minorCaseIdentifier;
            } else {
              currentToken.type = CodeTokenType.majorCaseIdentifier;
            }
          }

          codeTokens.add(currentToken);
          currentToken = null;
          continue;
        }
      }

      if (currentToken == null && char.isNotEmpty) {
        // Start a new token
        currentToken = CodeToken();

        if (char == '/' && nextChar == '/') {
          currentToken.type = CodeTokenType.shortComment;
          currentToken.text = "//";
          charIndex += 2;
          continue;
        } else if (char == '/' && nextChar == '*') {
          currentToken.type = CodeTokenType.longComment;
          currentToken.text = "/*";
          charIndex += 2;
          continue;
        } else if (char == '\'' || char == '"' || char == '`') {
          currentToken.type = CodeTokenType.string;
          currentToken.text = char;
          delimiterChar = char;
        } else if (_isDigit(char) || (char == '-' && _isDigit(nextChar))) {
          currentToken.type = CodeTokenType.number;
          currentToken.text = char;
        } else if (_isAlpha(char) ||
            char == '_' ||
            (char == '#' && _isAlpha(nextChar))) {
          currentToken.type = CodeTokenType.identifier;
          currentToken.text = char;
        } else if ("~+-*/%^\$&|!=<>#".contains(char)) {
          currentToken.type = CodeTokenType.operator;
          currentToken.text = char;
        } else if (".,;".contains(char)) {
          currentToken.type = CodeTokenType.separator;
          currentToken.text = char;
          codeTokens.add(currentToken);
          currentToken = null;
        } else if ("()[]{}".contains(char)) {
          currentToken.type = CodeTokenType.delimiter;
          currentToken.text = char;
          codeTokens.add(currentToken);
          currentToken = null;
        } else if (" \t\r\n".contains(char)) {
          currentToken.type = CodeTokenType.spacing;
          currentToken.text = char;
          codeTokens.add(currentToken);
          currentToken = null;
        } else {
          currentToken.type = CodeTokenType.special;
          currentToken.text = char;
          codeTokens.add(currentToken);
          currentToken = null;
        }
      }

      charIndex++;
    }

    return codeTokens;
  }

  /// Get language for syntax highlighting based on file extension
  Language _getLanguageFromExtension(String extension) {
    extension = extension.toLowerCase();

    if (extension == "c" || extension == "h") {
      return CLanguage();
    } else if (extension == "cpp" ||
        extension == "hpp" ||
        extension == "cxx" ||
        extension == "hxx") {
      return CppLanguage();
    }
    // else if (extension == "cs") {
    //   return CsharpLanguage();
    // } else if (extension == "d") {
    //   return DLanguage();
    // } else if (extension == "java") {
    //   return JavaLanguage();
    // } else if (extension == "js") {
    //   return JavaScriptLanguage();
    // } else if (extension == "ts") {
    //   return TypeScriptLanguage();
    // }

    else {
      return Language(); // Generic language
    }
  }

  // Helper methods for character detection
  bool _isDigit(String char) {
    return char.length == 1 &&
        char.codeUnitAt(0) >= 48 &&
        char.codeUnitAt(0) <= 57;
  }

  bool _isAlpha(String char) {
    return char.length == 1 &&
        ((char.codeUnitAt(0) >= 65 && char.codeUnitAt(0) <= 90) ||
            (char.codeUnitAt(0) >= 97 && char.codeUnitAt(0) <= 122));
  }

  /// Add a tag to the tag array
  void addTag(String name, String definition) {
    for (Tag tag in tagArray) {
      if (tag.name == name) {
        tag.definitionArray.add(definition);
        return;
      }
    }

    Tag tag = Tag();
    tag.name = name;
    tag.definitionArray.add(definition);
    tag.definitionIndex = 0;

    tagArray.add(tag);
  }

  /// Remove a tag from the tag array
  void removeTag(String name) {
    for (int i = 0; i < tagArray.length; i++) {
      if (tagArray[i].name == name) {
        tagArray.removeAt(i);
        return;
      }
    }
  }

  /// Get token array from Pendart text
  List<Token> getTokenArray(String text) {
    List<Token> tokenArray = [];
    bool tokenStartsLine = true;

    // State tracking for various formatting elements
    bool isInPre = false;
    bool isInBold = false;
    bool isInItalic = false;
    bool isInSuperscript = false;
    bool isInSubscript = false;
    bool isInStrikethrough = false;
    bool isInUnderline = false;
    bool isInLink = false;

    text = getCleanedText(text, tabulationSpaceCount);
    int charIndex = 0;

    while (charIndex < text.length) {
      Token token = Token();
      token.startsLine = tokenStartsLine;
      tokenStartsLine = false;

      // Handle escaped characters with ¬
      if (charIndex < text.length - 1 && text[charIndex] == '¬') {
        token.text = text[charIndex + 1];
        token.isEscaped = true;
        token.type = TokenType.text;
        charIndex += 2;
      }
      // Handle headings
      else if (token.startsLine && text.substring(charIndex).startsWith("!")) {
        int headingLevel = 0;
        while (charIndex < text.length && text[charIndex] == '!') {
          headingLevel++;
          charIndex++;
        }

        if (headingLevel >= 1 &&
            headingLevel <= 6 &&
            charIndex < text.length &&
            text[charIndex] == ' ') {
          // Skip the space after heading marker
          charIndex++;

          // Set token type based on heading level
          switch (headingLevel) {
            case 1:
              token.type = TokenType.heading1;
              break;
            case 2:
              token.type = TokenType.heading2;
              break;
            case 3:
              token.type = TokenType.heading3;
              break;
            case 4:
              token.type = TokenType.heading4;
              break;
            case 5:
              token.type = TokenType.heading5;
              break;
            case 6:
              token.type = TokenType.heading6;
              break;
          }

          // Collect heading text
          StringBuilder sb = StringBuilder();
          while (charIndex < text.length && text[charIndex] != '\n') {
            sb.write(text[charIndex]);
            charIndex++;
          }
          token.text = sb.toString();
        } else {
          token.text = _repeat("!", headingLevel);
          token.type = TokenType.text;
        }
      }
      // Handle bold **text**
      else if (text.substring(charIndex).startsWith("**")) {
        isInBold = !isInBold;
        token.type = TokenType.bold;
        token.text = ""; // Marker only, no text content
        charIndex += 2;
      }
      // Handle italic %%text%%
      else if (text.substring(charIndex).startsWith("%%")) {
        isInItalic = !isInItalic;
        token.type = TokenType.italic;
        token.text = ""; // Marker only, no text content
        charIndex += 2;
      }
      // Handle superscript ^^text^^
      else if (text.substring(charIndex).startsWith("^^")) {
        isInSuperscript = !isInSuperscript;
        token.type = TokenType.superscript;
        token.text = ""; // Marker only, no text content
        charIndex += 2;
      }
      // Handle subscript ,,text,,
      else if (text.substring(charIndex).startsWith(",,")) {
        isInSubscript = !isInSubscript;
        token.type = TokenType.subscript;
        token.text = ""; // Marker only, no text content
        charIndex += 2;
      }
      // Handle strikethrough ~~text~~
      else if (text.substring(charIndex).startsWith("~~")) {
        isInStrikethrough = !isInStrikethrough;
        token.type = TokenType.strikethrough;
        token.text = ""; // Marker only, no text content
        charIndex += 2;
      }
      // Handle underline __text__
      else if (text.substring(charIndex).startsWith("__")) {
        isInUnderline = !isInUnderline;
        token.type = TokenType.underline;
        token.text = ""; // Marker only, no text content
        charIndex += 2;
      }
      // Handle code block ::: text :::
      else if (text.substring(charIndex).startsWith(":::") && !isInPre) {
        isInPre = true;
        token.type = TokenType.codeBlock;
        token.text = ""; // Start marker, content will be collected separately
        charIndex += 3;
      } else if (text.substring(charIndex).startsWith(":::") && isInPre) {
        isInPre = false;
        token.type = TokenType.codeBlock;
        token.text = ""; // End marker, content already collected
        charIndex += 3;
      }
      // Handle horizontal rule
      else if (text.substring(charIndex).startsWith("---")) {
        token.type = TokenType.horizontalRule;
        token.text = "";
        charIndex += 3;
      }
      // Handle page break
      else if (text.substring(charIndex).startsWith("~~~")) {
        token.type = TokenType.pageBreak;
        token.text = "";
        charIndex += 3;
      }
      // Handle line break
      else if (text.substring(charIndex).startsWith("§")) {
        token.type = TokenType.lineBreak;
        token.text = "";
        charIndex += 1;
      }
      // Handle checkboxes [] and [x]
      else if (token.startsLine && text.substring(charIndex).startsWith("[")) {
        if (charIndex + 1 < text.length) {
          if (text[charIndex + 1] == ']') {
            // Unchecked checkbox
            token.type = TokenType.checkbox;
            token.attributes["checked"] = "false";
            charIndex += 2;

            // Get checkbox text
            StringBuilder checkboxText = StringBuilder();
            int tempCharIndex = charIndex;
            while (tempCharIndex < text.length && text[tempCharIndex] != '\n') {
              checkboxText.write(text[tempCharIndex]);
              tempCharIndex++;
            }
            token.text = checkboxText.toString().trim();
            charIndex = tempCharIndex;
          } else if (charIndex + 2 < text.length &&
              text[charIndex + 1] == 'x' &&
              text[charIndex + 2] == ']') {
            // Checked checkbox
            token.type = TokenType.checkbox;
            token.attributes["checked"] = "true";
            charIndex += 3;

            // Get checkbox text
            StringBuilder checkboxText = StringBuilder();
            int tempCharIndex = charIndex;
            while (tempCharIndex < text.length && text[tempCharIndex] != '\n') {
              checkboxText.write(text[tempCharIndex]);
              tempCharIndex++;
            }
            token.text = checkboxText.toString().trim();
            charIndex = tempCharIndex;
          } else {
            // Not a checkbox, just a regular character
            token.type = TokenType.text;
            token.text = text[charIndex];
            charIndex++;
          }
        } else {
          token.type = TokenType.text;
          token.text = text[charIndex];
          charIndex++;
        }
      }
      // Handle links
      else if (text.substring(charIndex).startsWith("@@")) {
        charIndex += 2;

        if (!isInLink) {
          isInLink = true;
          token.type = TokenType.link;

          // Extract URL
          StringBuilder url = StringBuilder();

          while (charIndex < text.length) {
            if (text[charIndex] == ' ') {
              // URL followed by text
              token.attributes["href"] = url.toString();
              token.text = ""; // Text will be collected separately
              charIndex++;
              break;
            } else if (charIndex + 1 < text.length &&
                text.substring(charIndex).startsWith("@@")) {
              // URL only, no text
              token.attributes["href"] = url.toString();
              token.text = url.toString();
              isInLink = false;
              charIndex += 2;
              break;
            } else {
              url.write(text[charIndex]);
              charIndex++;
            }
          }
        } else {
          isInLink = false;
          token.type = TokenType.link;
          token.text = ""; // End marker
        }
      }
      // Handle image [[image.jpg]]
      else if (text.substring(charIndex).startsWith("[[")) {
        charIndex += 2;
        StringBuilder imageData = StringBuilder();

        while (charIndex < text.length &&
            !text.substring(charIndex).startsWith("]]")) {
          imageData.write(text[charIndex]);
          charIndex++;
        }

        if (charIndex < text.length) {
          // Skip the closing ]]
          charIndex += 2;

          token.type = TokenType.image;

          // Parse image data (simplified - no size support)
          String imageStr = imageData.toString();
          String src = imageStr;

          // Remove any size specifications
          if (src.contains(":")) {
            src = src.split(":")[0];
          }

          token.attributes["src"] = src;
          token.text = "";
        }
      }
      // Handle code spans with backticks
      else if (text[charIndex] == '`') {
        charIndex++;
        token.type = TokenType.codeSpan;

        StringBuilder code = StringBuilder();
        while (charIndex < text.length && text[charIndex] != '`') {
          code.write(text[charIndex]);
          charIndex++;
        }

        if (charIndex < text.length) {
          charIndex++; // Skip closing backtick
        }

        token.text = code.toString();
      }
      // Handle spaces
      else if (text[charIndex] == ' ') {
        charIndex++;
        token.type = TokenType.space;
        token.text = " ";

        while (charIndex < text.length && text[charIndex] == ' ') {
          token.text += " ";
          charIndex++;
        }

        token.isSpace = true;
      }
      // Handle newlines
      else if (text[charIndex] == '\n') {
        charIndex++;
        token.type = TokenType.newline;
        token.text = "\n";
        tokenStartsLine = true;
      }
      // Handle regular characters
      else {
        token.type = TokenType.text;
        token.text = text[charIndex];
        charIndex++;
      }

      tokenArray.add(token);
    }

    return tokenArray;
  }

  /// Process Pendart text into a widget tree
  List<Widget> processText(String text, BuildContext context,
      {Function(int, bool)? onCheckboxChanged, bool enableCheckboxes = true}) {
    // Preprocess the text to handle code blocks
    String preprocessedText = getPreprocessedText(text);

    // Get tokens from preprocessed text
    List<Token> tokenArray = getTokenArray(preprocessedText);

    // Process tokens into widgets
    return _buildWidgetsFromTokens(
      tokenArray,
      context,
      onCheckboxChanged: onCheckboxChanged,
      enableCheckboxes: enableCheckboxes,
    );
  }

  /// Convert token array to Flutter widgets
  List<Widget> _buildWidgetsFromTokens(
      List<Token> tokenArray, BuildContext context,
      {Function(int, bool)? onCheckboxChanged, bool enableCheckboxes = true}) {
    List<Widget> widgets = [];
    List<InlineSpan> currentTextSpans = [];
    bool isParagraph = true;

    // Maps to track formatting states
    Map<TokenType, bool> formattingState = {
      TokenType.bold: false,
      TokenType.italic: false,
      TokenType.superscript: false,
      TokenType.subscript: false,
      TokenType.strikethrough: false,
      TokenType.underline: false,
      TokenType.link: false,
    };

    void _addTextSpan() {
      if (currentTextSpans.isNotEmpty) {
        widgets.add(RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: List.from(currentTextSpans),
          ),
        ));
        currentTextSpans = [];
      }
    }

    // Helper to get current style based on active formatting
    TextStyle _getCurrentStyle(TextStyle baseStyle) {
      TextStyle style = baseStyle;

      if (formattingState[TokenType.bold] == true) {
        style = style.copyWith(fontWeight: FontWeight.bold);
      }

      if (formattingState[TokenType.italic] == true) {
        style = style.copyWith(fontStyle: FontStyle.italic);
      }

      if (formattingState[TokenType.superscript] == true) {
        style = style.copyWith(
          fontSize: 10,
          height: 0.7,
        );
      }

      if (formattingState[TokenType.subscript] == true) {
        style = style.copyWith(
          fontSize: 10,
          height: 1.5,
        );
      }

      if (formattingState[TokenType.strikethrough] == true) {
        style = style.copyWith(
          decoration: TextDecoration.lineThrough,
        );
      }

      if (formattingState[TokenType.underline] == true) {
        style = style.copyWith(
          decoration: TextDecoration.underline,
        );
      }

      if (formattingState[TokenType.link] == true) {
        style = style.copyWith(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        );
      }

      return style;
    }

    for (int i = 0; i < tokenArray.length; i++) {
      Token token = tokenArray[i];
      TextStyle baseStyle = DefaultTextStyle.of(context).style;

      switch (token.type) {
        case TokenType.text:
          isParagraph = true;
          currentTextSpans.add(TextSpan(
            text: token.text,
            style: _getCurrentStyle(baseStyle),
          ));
          break;

        case TokenType.space:
          currentTextSpans.add(TextSpan(
            text: token.text,
            style: _getCurrentStyle(baseStyle),
          ));
          break;

        case TokenType.newline:
          if (isParagraph) {
            _addTextSpan();
            widgets.add(const SizedBox(height: 2)); // Paragraph spacing
          }
          break;

        case TokenType.heading1:
          _addTextSpan();
          isParagraph = false;
          widgets.add(Text(
            token.text,
            style: Theme.of(context).textTheme.headlineLarge,
          ));
          break;

        case TokenType.heading2:
          _addTextSpan();
          isParagraph = false;
          widgets.add(Text(
            token.text,
            style: Theme.of(context).textTheme.headlineMedium,
          ));
          break;

        case TokenType.heading3:
          _addTextSpan();
          isParagraph = false;
          widgets.add(Text(
            token.text,
            style: Theme.of(context).textTheme.headlineSmall,
          ));
          break;

        case TokenType.heading4:
          _addTextSpan();
          isParagraph = false;
          widgets.add(Text(
            token.text,
            style: Theme.of(context).textTheme.titleLarge,
          ));
          break;

        case TokenType.heading5:
          _addTextSpan();
          isParagraph = false;
          widgets.add(Text(
            token.text,
            style: Theme.of(context).textTheme.titleMedium,
          ));
          break;

        case TokenType.heading6:
          _addTextSpan();
          isParagraph = false;
          widgets.add(Text(
            token.text,
            style: Theme.of(context).textTheme.titleSmall,
          ));
          break;

        case TokenType.bold:
          // Toggle bold state
          formattingState[TokenType.bold] =
              !(formattingState[TokenType.bold] ?? false);
          break;

        case TokenType.italic:
          // Toggle italic state
          formattingState[TokenType.italic] =
              !(formattingState[TokenType.italic] ?? false);
          break;

        case TokenType.superscript:
          // Toggle superscript state
          formattingState[TokenType.superscript] =
              !(formattingState[TokenType.superscript] ?? false);
          break;

        case TokenType.subscript:
          // Toggle subscript state
          formattingState[TokenType.subscript] =
              !(formattingState[TokenType.subscript] ?? false);
          break;

        case TokenType.strikethrough:
          // Toggle strikethrough state
          formattingState[TokenType.strikethrough] =
              !(formattingState[TokenType.strikethrough] ?? false);
          break;

        case TokenType.underline:
          // Toggle underline state
          formattingState[TokenType.underline] =
              !(formattingState[TokenType.underline] ?? false);
          break;

        case TokenType.codeSpan:
          currentTextSpans.add(TextSpan(
            text: token.text,
            style: baseStyle.copyWith(
              fontFamily: 'monospace',
              backgroundColor: const Color(0xFFEEEEEE),
            ),
          ));
          break;

        case TokenType.codeBlock:
          // This is either the start or end of a code block
          if (i + 1 < tokenArray.length &&
              tokenArray[i + 1].type != TokenType.codeBlock) {
            // Start of code block, collect all text until end marker
            _addTextSpan();
            isParagraph = false;

            StringBuilder codeText = StringBuilder();
            int j = i + 1;
            while (j < tokenArray.length &&
                tokenArray[j].type != TokenType.codeBlock) {
              codeText.write(tokenArray[j].text);
              j++;
            }
            i = j; // Skip to end marker

            widgets.add(Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[200],
              child: Text(
                codeText.toString(),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
              ),
            ));
          }
          break;

        case TokenType.horizontalRule:
          _addTextSpan();
          widgets.add(Divider(color: Colors.grey[400]));
          break;

        case TokenType.lineBreak:
          _addTextSpan();
          widgets.add(const SizedBox(height: 8));
          break;

        case TokenType.checkbox:
          _addTextSpan();

          bool isChecked = token.attributes["checked"] == "true";

          widgets.add(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: enableCheckboxes && onCheckboxChanged != null
                      ? (bool? newValue) {
                          if (newValue != null) {
                            onCheckboxChanged(i, newValue);
                          }
                        }
                      : null, // Read-only checkbox if no callback
                ),
                Expanded(
                  child: Text(token.text),
                ),
              ],
            ),
          );
          break;

        case TokenType.image:
          _addTextSpan();

          String src = token.attributes["src"] ?? "";

          widgets.add(Image.network(src));
          break;

        case TokenType.link:
          // Toggle link state or display self-closing link
          if (token.text.isNotEmpty) {
            // Self-closing link with text
            currentTextSpans.add(TextSpan(
              text: token.text,
              style: baseStyle.copyWith(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              // Add gesture recognizer here if needed
            ));
          } else {
            // Toggle link state
            formattingState[TokenType.link] =
                !(formattingState[TokenType.link] ?? false);
          }
          break;

        default:
          // Handle any other token types
          currentTextSpans.add(TextSpan(text: token.text));
          break;
      }
    }

    _addTextSpan(); // Add any remaining text spans

    return widgets;
  }

  /// Create a repeated string
  String _repeat(String str, int count) {
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < count; i++) {
      buffer.write(str);
    }
    return buffer.toString();
  }
}
