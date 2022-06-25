import 'package:dateparser_core/src/token.dart';
import 'package:dateparser_core/src/utils.dart';

abstract class LocaleData {
  String preprocess(String source) {
    source = simplify(source);
    source = relative(source);
    return source;
  }

  String simplify(String source) {
    source = source
        .toLowerCase()
        .split(' ')
        .map((word) => simplifications[word] ?? word)
        .join(' ');

    for (final entry in simplificationsRegex.entries) {
      source = entry.key.sub(entry.value, source);
    }

    return source;
  }

  String relative(String source) {
    for (final entry in relativeType.entries.toList()
      ..sort(
        (a, b) => a.key.compareTo(b.key),
      )) {
      source = source.replaceAll(entry.key, entry.value);
    }

    for (final entry in relativeTypeRegex.entries) {
      source = entry.key.sub(entry.value, source);
    }

    return source;
  }

  /// Words that are not recorded in scanner.
  Set<String> get skip;

  Map<String, TokenType> get tokenMap;

  Map<String, String> get relativeType;

  Map<RegExp, String> get relativeTypeRegex;

  Map<String, String> get simplifications;

  Map<RegExp, String> get simplificationsRegex;
}
