import 'dart:io';

import 'chunk.dart';

void disassembleChunk(Chunk chunk, String name) {
  print("== $name ==");
  for (var offset = 0; offset < chunk.code.length;) {
    offset = disassembleIntruction(chunk, offset);
  }
}

int disassembleIntruction(Chunk chunk, int offset) {
  stdout.write('${offset.toString().padLeft(4, "0")} ');

  final instruction = chunk.code[offset].toCode();
  switch (instruction) {
    case OpCode.PUSH_DATETIME_NOW:
      return simpleInstruction('OP_DATETIME_NOW', offset);
    case OpCode.INTO_DATE:
      return simpleInstruction('OP_INTO_DATE', offset);

    case OpCode.DURATION_DAYS:
      return simpleInstruction('OP_DURATION_DAYS', offset);
    case OpCode.DURATION_HOURS:
      return simpleInstruction('OP_DURATION_HOURS', offset);
    case OpCode.DURATION_MINUTES:
      return simpleInstruction('OP_DURATION_MINUTES', offset);
    case OpCode.DURATION_SECONDS:
      return simpleInstruction('OP_DURATION_SECONDS', offset);
    case OpCode.DURATION_MOMENT:
      return simpleInstruction('OP_DURATION_MOMENT', offset);

    case OpCode.DIRECTION_AGO:
      return simpleInstruction('OP_DIRECTION_AGO', offset);
    case OpCode.DIRECTION_REMAINING:
      return simpleInstruction('OP_DIRECTION_REMAINING', offset);

    case OpCode.CONSTANT:
      return constantInstruction('OP_CONSTANT', chunk, offset);

    case OpCode.ADD:
      return simpleInstruction('OP_ADD', offset);
    case OpCode.MULTIPLY:
      return simpleInstruction('OP_MULTIPLY', offset);

    case OpCode.RETURN:
      return simpleInstruction('OP_RETURN', offset);

    default:
      stdout.write("Unknown opcode $instruction\n");
      return offset + 1;
  }
}

int constantInstruction(String name, Chunk chunk, int offset) {
  int constant = chunk.code[offset + 1];
  stdout.write(
      '${name.toString().padRight(16, " ")} ${constant.toString().padLeft(4, "0")} \'');
  stdout.write(chunk.constants[constant]);
  stdout.write("'\n");
  return offset + 2;
}

int simpleInstruction(String name, int offset) {
  stdout.write('$name\n');
  return offset + 1;
}
