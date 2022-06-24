import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as path;

import 'package:build/build.dart';
import 'package:yaml/yaml.dart';

class DataBuilder extends Builder {
  final String header = '''
// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: no_leading_underscores_for_library_prefixes
''';

  final data = jsonDecode(File('data/data.json').readAsStringSync());
  final formatter = DartFormatter();

  @override
  Map<String, List<String>> get buildExtensions {
    final langs = data['langs'];

    return {
      r'$lib$': [
        'generated/data/data.dart',
        for (final lang in langs) 'generated/data/lang/$lang.dart',
      ],
    };
  }

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    for (final lang in data['langs']) {
      await buildLang(buildStep, lang);
    }

    buildData(buildStep);
  }

  Future<void> buildLang(BuildStep buildStep, String lang) async {
    final info = jsonDecode(
      await File('data/translation_data/$lang.json').readAsString(),
    );

    final supp = loadYaml(
        await File('data/supplementary_data/$lang.yaml').readAsString());

    final data = """
      const data = {
        "translation": _translation,
        "supplementary": _supplementary, 
      };

      const _translation = ${jsonEncode(info)};
      const _supplementary = ${jsonEncode(supp)};
    """;

    writeLang(buildStep, lang, formatter.format(data));
  }

  void buildData(BuildStep buildStep) {
    final emitter = DartEmitter.scoped(orderDirectives: true);

    final dataLibrary = Library(
      (b) => b.body.addAll([
        Code([
          'const data = {',
          for (final lang in data['langs'])
            '"$lang": ${refer("data", 'lang/$lang.dart').accept(emitter)},',
          '};'
        ].join('\n')),
      ]),
    );

    write(
      buildStep,
      path.join('lib', 'generated/data/data.dart'),
      formatter.format(dataLibrary.accept(emitter).toString()),
    );
  }

  void writeLang(BuildStep buildStep, String lang, String contents) {
    final file = path.join('lib', 'generated/data/lang/$lang.dart');
    write(buildStep, file, contents);
  }

  void write(BuildStep buildStep, String path, String contents) {
    final id = AssetId(buildStep.inputId.package, path);

    contents = '$header\n$contents';
    buildStep.writeAsString(id, contents);
  }
}