// ignore_for_file: constant_identifier_names

class Token {
  const Token(this.type, this.value, this.line);
  const Token.empty() : this(TokenType.CT_ERROR, "", 0);

  final int line;
  final TokenType type;
  final String value;

  @override
  String toString() {
    return '$runtimeType($type, $value, $line)';
  }
}

enum TokenType {
  // Single-character tokens.
  COMMA,

  DECADE, // Timeframe.
  YEAR,
  MONTH,
  WEEK,
  DAY,
  HOUR,
  MINUTE,
  SECOND,
  MOMENT,

  AGO, // Relative.
  IN,

  AND,

  // Literals.
  NUMBER,
  identifier, // TODO: to be removed

  CT_SKIP,
  CT_ERROR,
  CT_EOF,
}

const keywords = <String, TokenType>{
  // Timeframes.
  'decade': TokenType.DECADE,
  'year': TokenType.YEAR,
  'month': TokenType.MONTH,
  'week': TokenType.WEEK,
  'day': TokenType.DAY,
  'hour': TokenType.HOUR,
  'minute': TokenType.MINUTE,
  'second': TokenType.SECOND,
  'moment': TokenType.MOMENT,

  // Relative.
  'ago': TokenType.AGO,
  'in': TokenType.IN,

  // Other.
  'and': TokenType.AND,
};
