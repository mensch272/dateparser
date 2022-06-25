import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:dateparser/dateparser.dart';
import 'package:dateparser/src/generated_data.dart';

class SimpleBenchmark extends BenchmarkBase {
  SimpleBenchmark() : super('Simple');

  final data = GeneratedData('en-SG');

  @override
  void run() {
    parse('1 minute ago', locale: data);
  }

  @override
  void exercise() {
    for (var i = 0; i < 1000; i++) {
      run();
    }
  }
}

void main(List<String> args) {
  SimpleBenchmark().report();
}
