import 'package:dateparser/src/generated_data.dart';
import 'package:dateparser_core/dateparser_core.dart';

void main(List<String> args) {
  final data = GeneratedData('en');
  final content = data.preprocess(args.first);

  final scanner = Scanner(content, data: data);
  while (true) {
    final token = scanner.scanToken();
    if (token.type == TokenType.CT_EOF) {
      break;
    }

    print(token);
  }
}
