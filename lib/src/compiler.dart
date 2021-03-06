import 'dart:io';

import 'package:dateparser/src/debug.dart';
import 'package:dateparser/src/token.dart';
import 'package:dateparser/src/utils.dart';
import 'package:dateparser/src/value.dart';

import 'chunk.dart';
import 'scanner.dart';

class Parser {
  Parser(this.source, this.chunk) : scanner = Scanner(source);

  final String source;
  final Chunk chunk;
  final Scanner scanner;

  Token previous = Token.empty();
  Token current = Token.empty();

  bool hadError = false;
  bool panicMode = false;

  bool compile() {
    advance();
    expression();
    consume(TokenType.EOF, "Expect end of expression.");
    endCompiler();
    return !hadError;
  }

  void advance() {
    previous = current;

    while (true) {
      current = scanner.scanToken();
      if (current.type != TokenType.ERROR) break;

      errorAtCurrent(current.value);
    }
  }

  void consume(TokenType type, String message) {
    if (current.type == type) {
      advance();
      return;
    }

    errorAtCurrent(message);
  }

  bool match(TokenType type) {
    if (!check(type)) return false;
    advance();
    return true;
  }

  bool check(TokenType type) {
    return current.type == type;
  }

  void endCompiler() {
    emitReturn();

    // DEBUG: Comment out when testing is done
    if (!hadError) {
      disassembleChunk(chunk, 'code');
    }
    // DEBUG
  }

  // Expressions.

  void expression() {
    relative();
  }

  void relative() {
    if (match(TokenType.YESTERDAY)) {
      emitConstant(Value.number(1));
      emitByte(OpCode.DURATION_DAYS.index);
      emitByte(OpCode.DIRECTION_AGO.index);
      emitByte(OpCode.INTO_DATE.index);
    } else if (match(TokenType.TODAY)) {
      emitConstant(Value.number(0));
      emitByte(OpCode.DURATION_DAYS.index);
      emitByte(OpCode.DIRECTION_AGO.index);
      emitByte(OpCode.INTO_DATE.index);
    } else if (match(TokenType.TOMORROW)) {
      emitConstant(Value.number(1));
      emitByte(OpCode.DURATION_DAYS.index);
      emitByte(OpCode.DIRECTION_REMAINING.index);
      emitByte(OpCode.INTO_DATE.index);
    } else if (match(TokenType.IN)) {
      inExact();
    } else {
      exact();
    }
  }

  void inExact() {
    durationChain();
    emitByte(OpCode.DIRECTION_REMAINING.index);
  }

  void exact() {
    durationChain();
    direction();
  }

  void durationChain() {
    duration();
    if (match(TokenType.COMMA)) {
      bool hitAnd = false;
      do {
        if (match(TokenType.AND)) {
          hitAnd = true;
          break;
        }

        duration();
        emitByte(OpCode.ADD.index);
      } while (match(TokenType.COMMA));

      if (hitAnd || match(TokenType.AND)) {
        duration();
        emitByte(OpCode.ADD.index);
      }
    }
  }

  void duration() {
    if (match(TokenType.NUMBER)) {
      emitConstant(Value.number(double.parse(previous.value)));
      timeframe();
    } else {
      errorAtCurrent("Expect a number or 'a'.");
    }
  }

  void timeframe() {
    if (match(TokenType.MOMENT)) {
      emitByte(OpCode.DURATION_MOMENT.index);
    } else if (match(TokenType.SECOND)) {
      emitByte(OpCode.DURATION_SECONDS.index);
    } else if (match(TokenType.MINUTE)) {
      emitByte(OpCode.DURATION_MINUTES.index);
    } else if (match(TokenType.HOUR)) {
      emitByte(OpCode.DURATION_HOURS.index);
    } else if (match(TokenType.DAY)) {
      emitByte(OpCode.DURATION_DAYS.index);
    } else if (match(TokenType.WEEK)) {
      emitConstant(Value.number(7));
      emitByte(OpCode.MULTIPLY.index);
      emitByte(OpCode.DURATION_DAYS.index);
    } else if (match(TokenType.MONTH)) {
      // TODO: add days depending on calender month
      emitConstant(Value.number(30.437)); // Average days per month.
      emitByte(OpCode.MULTIPLY.index);
      emitByte(OpCode.DURATION_DAYS.index);
    } else if (match(TokenType.YEAR)) {
      // TODO: account for leap year.
      emitConstant(Value.number(365.25)); // Average days per year.
      emitByte(OpCode.MULTIPLY.index);
      emitByte(OpCode.DURATION_DAYS.index);
    } else if (match(TokenType.DECADE)) {
      // TODO: account for leap year.
      final dayCount = (8.0 * 365.0) + (2.0 * 366.0);
      emitConstant(Value.number(dayCount));
      emitByte(OpCode.MULTIPLY.index);
      emitByte(OpCode.DURATION_DAYS.index);
    } else {
      errorAtCurrent("Expect a timeframe indicator.");
    }

    // TODO: add year and decade support
  }

  void direction() {
    if (match(TokenType.AGO)) {
      emitByte(OpCode.DIRECTION_AGO.index);
    } else if (match(TokenType.IN)) {
      emitByte(OpCode.DIRECTION_REMAINING.index);
    } else {
      error("Expect time direction such as 'ago' or 'remaining'.");
    }
  }

  void number() {
    final value = double.parse(previous.value);
    emitConstant(Value.number(value));
  }

  // Byte.

  void emitByte(int byte) {
    chunk.writeRaw(byte);
  }

  void emitBytes(int byte1, int byte2) {
    chunk.writeRaw(byte1);
    chunk.writeRaw(byte2);
  }

  void emitReturn() {
    emitByte(OpCode.RETURN.index);
  }

  // Constants.

  void emitConstant(Value value) {
    emitBytes(OpCode.CONSTANT.index, makeConstant(value));
  }

  int makeConstant(Value value) {
    final constant = chunk.addConstant(value);
    return constant;
  }

  // Errors.

  void errorAtCurrent(String message) {
    errorAt(current, message);
  }

  void error(String message) {
    errorAt(previous, message);
  }

  void errorAt(Token token, message) {
    if (panicMode) return;
    panicMode = true;

    stdout.write('Error');

    if (token.type == TokenType.EOF) {
      stdout.write(' at end');
    } else if (token.type == TokenType.ERROR) {
      // Nothing.
    } else {
      stdout.write(" at '${token.value}'");
    }

    stdout.write(": $message\n");
    hadError = true;
  }
}
