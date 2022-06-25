import 'dart:io';

import 'package:dateparser_core/src/debug.dart';

import 'chunk.dart';
import 'value.dart';

enum InterpretResult {
  ok,
  compileError,
  runtimeError,
}

class VM {
  VM(this.chunk);

  final Chunk chunk;
  final List<Value> stack = [];

  int ip = 0;

  InterpretResult run() {
    while (true) {
      // DEBUG: Comment out when testing is done
      // stdout.write('     ');
      // for (final value in stack.reversed) {
      //   stdout.write('[$value]');
      // }
      // stdout.write('\n');
      // disassembleIntruction(chunk, ip);
      // End DEBUG

      final instruction = read().toCode();
      switch (instruction) {
        case OpCode.PUSH_DATETIME_NOW:
          push(Value.dateTime(DateTime.now()));
          break;
        case OpCode.INTO_DATE:
          final dateTime = (pop() as DateTimeValue).value;
          final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
          push(Value.dateTime(date));
          break;

        case OpCode.DURATION_DAYS:
          final count = (pop() as NumberValue).value;
          final duration = Duration(days: count.toInt());
          push(Value.duration(duration));
          break;
        case OpCode.DURATION_HOURS:
          final count = (pop() as NumberValue).value;
          final duration = Duration(hours: count.toInt());
          push(Value.duration(duration));
          break;
        case OpCode.DURATION_MINUTES:
          final count = (pop() as NumberValue).value;
          final duration = Duration(minutes: count.toInt());
          push(Value.duration(duration));
          break;
        case OpCode.DURATION_SECONDS:
          final count = (pop() as NumberValue).value;
          final duration = Duration(seconds: count.toInt());
          push(Value.duration(duration));
          break;
        case OpCode.DURATION_MOMENT:
          pop();
          push(Value.duration(Duration()));
          break;

        case OpCode.DIRECTION_AGO:
          final duration = pop() as DurationValue;
          final dateTime = DateTime.now().subtract(duration.value);
          push(Value.dateTime(dateTime));
          break;
        case OpCode.DIRECTION_REMAINING:
          final duration = pop() as DurationValue;
          final dateTime = DateTime.now().add(duration.value);
          push(Value.dateTime(dateTime));
          break;

        case OpCode.CONSTANT:
          final constant = readConstant();
          push(constant);
          break;

        case OpCode.ADD:
          final a = pop();
          final b = pop();
          push(a + b);
          break;
        case OpCode.MULTIPLY:
          final a = pop();
          final b = pop();
          push(a * b);
          break;

        case OpCode.RETURN:
          return InterpretResult.ok;
      }
    }
  }

  int read() {
    return chunk.code[ip++];
  }

  Value readConstant() {
    return chunk.constants[read()];
  }

  void push(Value value) => stack.add(value);
  Value pop() => stack.removeLast();
}
