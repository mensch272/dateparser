abstract class Value {
  const Value();

  factory Value.number(double value) = NumberValue;
  factory Value.duration(Duration duration) = DurationValue;
  factory Value.dateTime(DateTime dateTime) = DateTimeValue;

  Value operator *(Value other) {
    if (this is NumberValue) {
      final current = this as NumberValue;
      if (other is NumberValue) {
        final value = current.value * other.value;
        return Value.number(value);
      } else if (other is DurationValue) {
        final value = other.value * current.value;
        return Value.duration(value);
      }
    } else if (this is DurationValue && other is NumberValue) {
      final value = (this as DurationValue).value * other.value;
      return Value.duration(value);
    }

    throw TypeError();
  }

  Value operator +(Value other) {
    if (this is DurationValue && other is DurationValue) {
      final current = this as DurationValue;
      final value = current.value + other.value;
      return Value.duration(value);
    }

    throw TypeError();
  }
}

class NumberValue extends Value {
  const NumberValue(this.value);
  final double value;

  @override
  String toString() => value.toString();
}

class DurationValue extends Value {
  const DurationValue(this.value);
  final Duration value;

  @override
  String toString() => value.toString();
}

class DateTimeValue extends Value {
  const DateTimeValue(this.value);
  final DateTime value;

  @override
  String toString() => value.toString();
}
