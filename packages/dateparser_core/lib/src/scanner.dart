import 'package:characters/characters.dart';
import 'package:dateparser_core/dateparser_core.dart';
import 'package:dateparser_core/src/lang_data.dart';

class Scanner {
  Scanner(String content, {required this.data})
      : characters = content.characters.toList();

  final List<String> characters;
  final LocaleData data;

  int start = 0;
  int current = 0;

  int line = 1;

  Token scanToken() {
    skipWhitespace();
    start = current;

    if (isAtEnd) return makeToken(TokenType.CT_EOF);

    final c = advance();

    switch (c) {
      case ",":
        return makeToken(TokenType.COMMA);
      default:
        if (isDigit(c)) {
          return number();
        } else {
          return identifier();
        }
    }
  }

  bool get isAtEnd => current == characters.length;

  String peek() {
    return characters[current];
  }

  String? peekNext() {
    if (isAtEnd) return null;
    return characters[current + 1];
  }

  String advance() {
    return characters[current++];
  }

  Token makeToken(TokenType type) {
    return Token(type, characters.sublist(start, current).join(), line);
  }

  Token errorToken(String value) {
    return Token(TokenType.CT_ERROR, value, line);
  }

  void skipWhitespace() {
    while (!isAtEnd) {
      final c = peek();
      switch (c) {
        case " ":
        case "\r":
        case "\t":
          advance();
          break;
        case "\n":
          line++;
          advance();
          break;
        default:
          return;
      }
    }
  }

  bool isDigit(String? c) {
    switch (c) {
      case "0":
      case "1":
      case "2":
      case "3":
      case "4":
      case "5":
      case "6":
      case "7":
      case "8":
      case "9":
        return true;
      default:
        return false;
    }
  }

  bool isWhitespace(String c) {
    switch (c) {
      case " ":
      case "\r":
      case "\t":
        return true;
      default:
        return false;
    }
  }

  // Literals.

  Token identifier() {
    while (!isAtEnd) {
      final c = peek();
      if (isDigit(c) || isWhitespace(c) || c == ',') {
        break;
      }

      advance();
    }

    final value = characters.sublist(start, current).join();
    if (data.skip.contains(value)) {
      return makeToken(TokenType.CT_SKIP);
    }

    final keyword = keywords[value] ?? data.tokenMap[value];
    if (keyword != null) {
      return makeToken(keyword);
    }

    return makeToken(TokenType.identifier);
  }

  Token number() {
    while (isDigit(peek())) {
      advance();
    }

    if (peek() == "." && isDigit(peekNext())) {
      // Consume the ".".
      advance();

      while (isDigit(peek())) {
        advance();
      }
    }

    return makeToken(TokenType.NUMBER);
  }
}
