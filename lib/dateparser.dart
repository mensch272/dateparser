library dateparser;

import 'package:dateparser/src/generated_data.dart';
import 'package:dateparser_core/dateparser_core.dart';

DateTime parse(String source, {LocaleData? locale}) {
  final data = locale ?? GeneratedData('en');
  source = data.preprocess(source);

  final chunk = Chunk();
  final parser = Parser(source, chunk, data: data);
  if (!parser.compile()) {
    throw Exception(); // FIXME: custom exception class
  }

  final vm = VM(chunk);
  final result = vm.run();
  switch (result) {
    case InterpretResult.ok:
      break;
    case InterpretResult.compileError:
    case InterpretResult.runtimeError:
      throw Exception(); // FIXME: custom exception class
  }

  final value = vm.stack.removeLast();
  if (value is! DateTimeValue) {
    throw Exception(); // FIXME: custom exception class
  }

  return value.value;
}
