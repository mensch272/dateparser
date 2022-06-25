bool isLeapYear(int year) =>
    (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));

extension Sub on RegExp {
  String sub(String replacement, String source) {
    return source.replaceAllMapped(this, (match) {
      if (match.groupCount > 0) {
        var value = replacement;
        for (var i = 1; i <= match.groupCount; i++) {
          value = value.replaceAll('\\$i', match[i]!);
        }

        return value;
      } else {
        return replacement;
      }
    });
  }
}
