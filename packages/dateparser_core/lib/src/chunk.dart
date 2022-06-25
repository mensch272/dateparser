// ignore_for_file: constant_identifier_names

import 'package:dateparser_core/src/value.dart';

enum OpCode {
  PUSH_DATETIME_NOW,
  INTO_DATE,

  DURATION_DAYS,
  DURATION_HOURS,
  DURATION_MINUTES,
  DURATION_SECONDS,
  DURATION_MOMENT,

  DIRECTION_AGO,
  DIRECTION_REMAINING,

  CONSTANT,

  ADD,
  MULTIPLY,

  RETURN;

  static from(int index) => OpCode.values[index];
}

extension ToCode on int {
  OpCode toCode() => OpCode.from(this);
}

class Chunk {
  Chunk();

  final List<int> code = [];
  final List<Value> constants = [];

  void write(OpCode code) {
    this.code.add(code.index);
  }

  void writeRaw(int code) {
    this.code.add(code);
  }

  int addConstant(Value value) {
    constants.add(value);
    return constants.length - 1;
  }
}
