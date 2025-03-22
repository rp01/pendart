import 'package:flutter/material.dart';

// -- TYPES/CLASSES

/// Base language class for syntax highlighting
class Language {
  bool isConstant(CodeToken codeToken) {
    return codeToken.text == "false" || codeToken.text == "true";
  }

  bool isType(CodeToken codeToken) {
    return false;
  }

  bool isKeyword(CodeToken codeToken) {
    return codeToken.text == "if" ||
        codeToken.text == "else" ||
        codeToken.text == "do" ||
        codeToken.text == "while" ||
        codeToken.text == "for" ||
        codeToken.text == "switch" ||
        codeToken.text == "case" ||
        codeToken.text == "default" ||
        codeToken.text == "break" ||
        codeToken.text == "continue" ||
        codeToken.text == "return";
  }
}

class CLanguage extends Language {
  @override
  bool isConstant(CodeToken codeToken) {
    return codeToken.text == "false" || codeToken.text == "true";
  }

  @override
  bool isType(CodeToken codeToken) {
    return codeToken.text == "void" ||
        codeToken.text == "bool" ||
        codeToken.text == "char" ||
        codeToken.text == "short" ||
        codeToken.text == "int" ||
        codeToken.text == "long" ||
        codeToken.text == "signed" ||
        codeToken.text == "unsigned" ||
        codeToken.text == "float" ||
        codeToken.text == "double" ||
        codeToken.text == "auto";
  }

  @override
  bool isKeyword(CodeToken codeToken) {
    return codeToken.text == "if" ||
        codeToken.text == "else" ||
        codeToken.text == "do" ||
        codeToken.text == "while" ||
        codeToken.text == "for" ||
        codeToken.text == "switch" ||
        codeToken.text == "case" ||
        codeToken.text == "default" ||
        codeToken.text == "break" ||
        codeToken.text == "continue" ||
        codeToken.text == "return" ||
        codeToken.text == "goto" ||
        codeToken.text == "sizeof" ||
        codeToken.text == "struct" ||
        codeToken.text == "union" ||
        codeToken.text == "enum" ||
        codeToken.text == "typedef" ||
        codeToken.text == "const" ||
        codeToken.text == "register" ||
        codeToken.text == "volatile" ||
        codeToken.text == "restrict" ||
        codeToken.text == "inline" ||
        codeToken.text == "static" ||
        codeToken.text == "extern" ||
        codeToken.text == "asm";
  }
}

class CppLanguage extends Language {
  @override
  bool isConstant(CodeToken codeToken) {
    return codeToken.text == "false" ||
        codeToken.text == "true" ||
        codeToken.text == "nullptr";
  }

  @override
  bool isType(CodeToken codeToken) {
    return codeToken.text == "void" ||
        codeToken.text == "bool" ||
        codeToken.text == "char" ||
        codeToken.text == "short" ||
        codeToken.text == "int" ||
        codeToken.text == "long" ||
        codeToken.text == "signed" ||
        codeToken.text == "unsigned" ||
        codeToken.text == "float" ||
        codeToken.text == "double" ||
        codeToken.text == "auto";
  }

  @override
  bool isKeyword(CodeToken codeToken) {
    return codeToken.text == "if" ||
        codeToken.text == "else" ||
        codeToken.text == "do" ||
        codeToken.text == "while" ||
        codeToken.text == "for" ||
        codeToken.text == "switch" ||
        codeToken.text == "case" ||
        codeToken.text == "default" ||
        codeToken.text == "break" ||
        codeToken.text == "continue" ||
        codeToken.text == "return" ||
        codeToken.text == "goto" ||
        codeToken.text == "try" ||
        codeToken.text == "catch" ||
        codeToken.text == "throw" ||
        codeToken.text == "new" ||
        codeToken.text == "delete" ||
        codeToken.text == "this" ||
        codeToken.text == "sizeof" ||
        codeToken.text == "reinterpret_cast" ||
        codeToken.text == "static_cast" ||
        codeToken.text == "dynamic_cast" ||
        codeToken.text == "using" ||
        codeToken.text == "namespace" ||
        codeToken.text == "public" ||
        codeToken.text == "protected" ||
        codeToken.text == "private" ||
        codeToken.text == "template" ||
        codeToken.text == "typename" ||
        codeToken.text == "class" ||
        codeToken.text == "struct" ||
        codeToken.text == "union" ||
        codeToken.text == "enum" ||
        codeToken.text == "typedef" ||
        codeToken.text == "operator" ||
        codeToken.text == "virtual" ||
        codeToken.text == "final" ||
        codeToken.text == "override" ||
        codeToken.text == "const" ||
        codeToken.text == "mutable" ||
        codeToken.text == "volatile" ||
        codeToken.text == "register" ||
        codeToken.text == "explicit" ||
        codeToken.text == "friend" ||
        codeToken.text == "inline" ||
        codeToken.text == "static" ||
        codeToken.text == "extern";
  }
}

// Continue with the C#, D, Java, JavaScript, TypeScript language classes similar to the ones above
// ...

/// Enum for code token types
enum CodeTokenType {
  none,
  shortComment,
  longComment,
  string,
  number,
  constant,
  type,
  keyword,
  pragma,
  lowerCaseIdentifier,
  upperCaseIdentifier,
  minorCaseIdentifier,
  majorCaseIdentifier,
  identifier,
  operator,
  separator,
  delimiter,
  special,
  spacing,
}

/// Represents a token in code for syntax highlighting
class CodeToken {
  CodeTokenType type = CodeTokenType.none;
  String text = "";
}

/// Represents a token in the Pendown markup
class Token {
  String text = "";
  bool startsLine = false;
  bool isSpace = false;
  bool isEscaped = false;
}

/// Represents a tag definition in Pendown
class Tag {
  String name = "";
  List<String> definitionArray = [];
  int definitionIndex = 0;
}

// -- UTILITY EXTENSIONS

extension StringUtils on String {
  bool isDigit() {
    return length == 1 && compareTo('0') >= 0 && compareTo('9') <= 0;
  }

  bool isAlpha() {
    return length == 1 &&
        ((compareTo('a') >= 0 && compareTo('z') <= 0) ||
            (compareTo('A') >= 0 && compareTo('Z') <= 0));
  }

  bool isLower() {
    return compareTo('a') >= 0 && compareTo('z') <= 0;
  }

  bool isUpper() {
    return compareTo('A') >= 0 && compareTo('Z') <= 0;
  }

  String toLower() {
    return toLowerCase();
  }

  String toUpper() {
    return toUpperCase();
  }
}

// -- FUNCTIONS

/// Replace tabulations with spaces
String replaceTabulations(String text, int tabulationSpaceCount) {
  String replacedText =
      text.replaceAll("\t\t", "\t    ").replaceAll("\n\t", "\n    ");

  if (replacedText.contains('\t')) {
    StringBuffer buffer = StringBuffer();
    int lineCharacterIndex = 0;

    for (int i = 0; i < replacedText.length; i++) {
      String character = replacedText[i];

      if (character == '\t') {
        do {
          buffer.write(' ');
          lineCharacterIndex++;
        } while ((lineCharacterIndex % tabulationSpaceCount) != 0);
      } else {
        buffer.write(character);

        if (character == '\n') {
          lineCharacterIndex = 0;
        } else {
          lineCharacterIndex++;
        }
      }
    }

    return buffer.toString();
  } else {
    return replacedText;
  }
}

/// Get cleaned text with normalized line endings and tabs replaced
String getCleanedText(String text, int tabulationSpaceCount) {
  String cleanedText =
      replaceTabulations(text, tabulationSpaceCount).replaceAll("\r", "");

  if (!cleanedText.endsWith('\n')) {
    cleanedText += '\n';
  }

  return cleanedText;
}

/// Check if a character is alphabetical
bool isAlphabeticalCharacter(String character) {
  return (character.compareTo('a') >= 0 && character.compareTo('z') <= 0) ||
      (character.compareTo('A') >= 0 && character.compareTo('Z') <= 0);
}

/// Check if a character is decimal
bool isDecimalCharacter(String character) {
  return character.compareTo('0') >= 0 && character.compareTo('9') <= 0;
}

/// Check if a character is hexadecimal
bool isHexadecimalCharacter(String character) {
  return (character.compareTo('0') >= 0 && character.compareTo('9') <= 0) ||
      (character.compareTo('a') >= 0 && character.compareTo('f') <= 0) ||
      (character.compareTo('A') >= 0 && character.compareTo('F') <= 0);
}

/// Get the value of a hexadecimal character
int getHexadecimalCharacterValue(String character) {
  if (character.compareTo('0') >= 0 && character.compareTo('9') <= 0) {
    return character.codeUnitAt(0) - 48;
  } else if (character.compareTo('a') >= 0 && character.compareTo('f') <= 0) {
    return character.codeUnitAt(0) - 87;
  } else if (character.compareTo('A') >= 0 && character.compareTo('F') <= 0) {
    return character.codeUnitAt(0) - 55;
  } else {
    return 0;
  }
}

/// Convert a hex color string to a Flutter Color object
Color getColor(String color) {
  if (color.length == 4) {
    int red = getHexadecimalCharacterValue(color[0]);
    int green = getHexadecimalCharacterValue(color[1]);
    int blue = getHexadecimalCharacterValue(color[2]);
    int alpha = getHexadecimalCharacterValue(color[3]);

    red += red * 16;
    green += green * 16;
    blue += blue * 16;
    alpha += alpha * 16;

    return Color.fromRGBO(red, green, blue, alpha / 255.0);
  } else if (color.length == 8) {
    int red = getHexadecimalCharacterValue(color[0]) * 16 +
        getHexadecimalCharacterValue(color[1]);
    int green = getHexadecimalCharacterValue(color[2]) * 16 +
        getHexadecimalCharacterValue(color[3]);
    int blue = getHexadecimalCharacterValue(color[4]) * 16 +
        getHexadecimalCharacterValue(color[5]);
    int alpha = getHexadecimalCharacterValue(color[6]) * 16 +
        getHexadecimalCharacterValue(color[7]);

    return Color.fromRGBO(red, green, blue, alpha / 255.0);
  } else {
    // Default case - convert hex to Color
    return Color(int.parse("0xFF${color.replaceAll('#', '')}"));
  }
}

/// Check if a size has a CSS unit
bool hasUnit(String size) {
  return size == "auto" ||
      size.endsWith("%") ||
      size.endsWith("ch") ||
      size.endsWith("cm") ||
      size.endsWith("em") ||
      size.endsWith("ex") ||
      size.endsWith("in") ||
      size.endsWith("mm") ||
      size.endsWith("pc") ||
      size.endsWith("pt") ||
      size.endsWith("px") ||
      size.endsWith("rem") ||
      size.endsWith("vh") ||
      size.endsWith("vmax") ||
      size.endsWith("vmin") ||
      size.endsWith("vw");
}

/// Get the file format from a URL
String getFormat(String url) {
  int dotCharacterIndex;

  if (url.startsWith('#')) {
    dotCharacterIndex = url.lastIndexOf('=');
  } else {
    dotCharacterIndex = url.lastIndexOf('.');
  }

  if (dotCharacterIndex >= 0) {
    return url.substring(dotCharacterIndex + 1);
  } else {
    return "";
  }
}

/// Check if a format is an image format
bool isImageFormat(String format) {
  return format == "apng" ||
      format == "bmp" ||
      format == "gif" ||
      format == "ico" ||
      format == "jpg" ||
      format == "jpeg" ||
      format == "png" ||
      format == "svg";
}

/// Get the image source for an image
String getImageSource(String url, String format) {
  if (url.startsWith('#')) {
    return "data:image/$format;base64,${url.substring(1, url.length - format.length)}";
  } else {
    return url;
  }
}

/// Get the appropriate language for a file extension
Language getLanguage(String filePath, String fileExtension) {
  String path = filePath;

  if (fileExtension.isNotEmpty) {
    if (fileExtension.startsWith('.')) {
      path = fileExtension;
    } else {
      path = ".$fileExtension";
    }
  }

  if (path.endsWith(".c") || path.endsWith(".h")) {
    return CLanguage();
  } else if (path.endsWith(".cpp") ||
      path.endsWith(".hpp") ||
      path.endsWith(".cxx") ||
      path.endsWith(".hxx")) {
    return CppLanguage();
  }
  // Add the rest of the language detection logic
  // ...
  else {
    return Language();
  }
}

// Add token parsing and processing functions
// ...

// -- PENDOWN FLUTTER WIDGETS

/// Widget to render Pendown content
class PendownText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const PendownText(this.text, {Key? key, this.style}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Process the Pendown markup and generate a widget tree
    // This is where we'll convert the markup to a set of Flutter widgets
    return _buildWidgetTree(context);
  }

  Widget _buildWidgetTree(BuildContext context) {
    // Process the text and generate widgets
    // TODO: Implement the actual widget generation logic
    return Text("Pendown renderer not fully implemented yet");
  }
}
