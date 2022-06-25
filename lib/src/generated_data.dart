import 'package:dateparser/generated/generated.dart' as generated;
import 'package:dateparser/src/cache_mixin.dart';
import 'package:dateparser_core/dateparser_core.dart';

class GeneratedData extends LocaleData with CacheMixin {
  GeneratedData(this.locale) : data = generated.data[_getLang(locale)]!;

  final String locale;
  final Map<String, dynamic> data;

  String get lang => _getLang(locale);

  /// Whether the data is locale specific.
  bool get isLocale => locale.contains('-');

  Map<String, dynamic>? get localeData => data['localeSpecific'][locale];

  @override
  Map<String, String> get relativeType {
    return cachedData('relativeType', () {
      Map<String, String> map = data['relativeType'];

      if (!isLocale) {
        return map;
      }

      final other = localeData?['relativeType'];
      if (other != null) {
        map = {...map, ...other};
      }

      return map;
    });
  }

  @override
  Map<RegExp, String> get relativeTypeRegex {
    return cachedData(
      'relativeTypeRegex',
      () {
        final map = <RegExp, String>{
          for (final entry in data['relativeTypeRegex'].entries)
            RegExp(entry.key): entry.value,
        };

        if (!isLocale) {
          return map;
        }

        for (final entry
            in localeData?['relativeTypeRegex']?.entries ?? const {}) {
          map[RegExp(entry.key)] = entry.value;
        }

        return Map.fromEntries(
          map.entries.toList()
            ..sort(
              (a, b) => b.key.pattern.length.compareTo(a.key.pattern.length),
            ),
        );
      },
    );
  }

  @override
  Map<String, String> get simplifications => data['simplifications'];

  @override
  Map<RegExp, String> get simplificationsRegex {
    return cachedData(
      'simplificationsRegex',
      () => {
        for (final entry in data['simplificationsRegex'].entries)
          RegExp(entry.key): entry.value
      },
    );
  }

  @override
  Set<String> get skip => data['skip'];

  @override
  Map<String, TokenType> get tokenMap => {
        ...data['tokenMap'],
        if (isLocale) ...?localeData?['tokenMap'],
      };
}

String _getLang(String lang) =>
    lang.contains('-') ? lang.split('-').first : lang;
