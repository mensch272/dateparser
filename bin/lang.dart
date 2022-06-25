import 'package:dateparser/src/generated_data.dart';

void main(List<String> args) {
  final locale = args.isEmpty ? 'en' : args.first;
  final source = args.length < 2 ? '1h2m' : args[1];

  final data = GeneratedData(locale);

  print('simplify:');
  print(data.simplify(source));
  print('');
}
