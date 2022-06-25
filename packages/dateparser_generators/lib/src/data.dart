import 'dart:convert';
import 'dart:io';

import 'package:code_builder/code_builder.dart';
import 'package:dateparser_core/dateparser_core.dart';
import 'package:yaml/yaml.dart';

class Data {
  const Data(this.lang, this.info, this.others);

  static Future<Data> fromLang(String lang) async {
    return Data(
      lang,
      jsonDecode(
        await File('data/translation_data/$lang.json').readAsString(),
      ),
      Map.from(loadYaml(
        await File('data/supplementary_data/$lang.yaml').readAsString(),
      )),
    );
  }

  final String lang;
  final Map<String, dynamic> info;
  final Map<String, dynamic> others;

  Set<String> get skip => {for (final value in others['skip']) value};

  Map<String, Expression> tokenMap(
    Map<String, dynamic> info, [
    Map<String, dynamic> others = const {},
  ]) {
    final map = <String, Expression>{};

    for (final entry in keywords.entries) {
      for (final value in info[entry.key] ?? const []) {
        map[value] = referCore(entry.value.toString());
      }

      for (final value in others[entry.key] ?? const []) {
        map[value] = referCore(entry.value.toString());
      }
    }

    return map;
  }

  Map<String, String> relativeType(
    Map<String, dynamic> info, [
    Map<String, dynamic> others = const {},
  ]) {
    final map = <String, String>{
      for (final entry in info['relative-type']?.entries ?? [])
        for (final value in entry.value) value: entry.key,
      for (final entry in others['relative-type']?.entries ?? [])
        for (final value in entry.value) value: entry.key,
    };

    return Map.fromEntries(
      map.entries.toList()
        ..sort(
          (a, b) => b.key.length.compareTo(a.key.length),
        ),
    );
  }

  Map<Expression, Expression> relativeTypeRegex(
    Map<String, dynamic> info, [
    Map<String, dynamic> others = const {},
  ]) {
    final map = <Expression, Expression>{
      for (final entry in info['relative-type-regex']?.entries ?? [])
        for (final value in entry.value)
          literalString(value, raw: true): literalString(entry.key, raw: true),
      for (final entry in others['relative-type-regex']?.entries ?? [])
        for (final value in entry.value)
          literalString(value, raw: true): literalString(entry.key, raw: true),
    };

    return Map.fromEntries(
      map.entries.toList()
        ..sort(
          (a, b) => b.key.code.toString().compareTo(a.key.code.toString()),
        ),
    );
  }

  Map<String, String> get simplifications {
    return {
      for (final map in others['simplifications']!)
        for (final entry in map.entries) entry.key: entry.value
    };
  }

  Map<Expression, Expression> get simplificationsRegex {
    final map = {
      for (final map in others['simplifications-regex']!)
        for (final entry in map.entries)
          literalString(entry.key, raw: true):
              literalString(entry.value, raw: true)
    };

    return Map.fromEntries(
      map.entries.toList()
        ..sort(
          (a, b) => b.key.code.toString().compareTo(a.key.code.toString()),
        ),
    );
  }

  Map<String, dynamic> get localeSpecific {
    final map = <String, Expression>{};
    for (final entry in (info['locale_specific'] ?? {}).entries) {
      map[entry.key] = buildLocaleSpecific(entry.value);
    }

    return map;
  }

  Expression buildLocaleSpecific(Map<String, dynamic> localeInfo) {
    final localeTokenMap = tokenMap(localeInfo);
    final localeRelativeType = relativeType(localeInfo);
    final localeRelativeTypeRegex = relativeTypeRegex(localeInfo);

    return literal({
      'name': localeInfo['name'],
      if (localeTokenMap.isNotEmpty) 'tokenMap': localeTokenMap,
      if (localeRelativeType.isNotEmpty) 'relativeType': localeRelativeType,
      if (localeRelativeTypeRegex.isNotEmpty)
        'relativeTypeRegex': localeRelativeTypeRegex,
    });
  }

  String build() {
    final emitter = DartEmitter.scoped();

    final data = literal({
      'name': info['name'],
      'skip': skip,
      'tokenMap': tokenMap(info, others),
      'relativeType': relativeType(info, others),
      'relativeTypeRegex': relativeTypeRegex(info, others),
      'simplifications': simplifications,
      'simplificationsRegex': simplificationsRegex,
      'localeSpecific': localeSpecific,
    });

    final library = Library(
      (b) => b.body.addAll([
        Code('const data = <String, dynamic>${data.accept(emitter)};'),
      ]),
    );

    return library.accept(emitter).toString();
  }

  Expression referCore(String symbol) {
    return refer(symbol, 'package:dateparser_core/dateparser_core.dart');
  }
}
