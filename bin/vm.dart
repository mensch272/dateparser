import 'package:dateparser/dateparser.dart';

void main(List<String> args) {
  final source = args.isNotEmpty ? args.first : 'day before yesterday';
  final dateTime = parse(source);

  print('');
  print('result: $dateTime');
}
