// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import '../../../tool/code_completion/metrics_util.dart';

void main() {
  group('ArithmeticMeanComputer', () {
    test('empty', () {
      var computer = ArithmeticMeanComputer('empty');
      expect(computer.sum, equals(0));
      expect(computer.count, equals(0));
    });

    test('clear', () {
      var computer = ArithmeticMeanComputer('name');
      computer.addValue(5);
      computer.addValue(5);
      computer.addValue(5);

      expect(computer.sum, equals(15));
      expect(computer.count, equals(3));
      computer.clear();

      expect(computer.sum, equals(0));
      expect(computer.count, equals(0));
    });

    test('mean', () {
      var computer = ArithmeticMeanComputer('name');
      computer.addValue(1);
      computer.addValue(2);
      computer.addValue(3);
      computer.addValue(4);
      computer.addValue(5);

      expect(computer.sum, equals(15));
      expect(computer.count, equals(5));
      expect(computer.mean, equals(15 / 5));
    });
  });

  group('Counter', () {
    test('empty', () {
      var counter = Counter('empty');
      expect(counter.map, isEmpty);
      expect(counter.totalCount, equals(0));
    });

    test('clear', () {
      var counter = Counter('name');
      counter.count('bucket-1');
      expect(counter.map, isNotEmpty);
      expect(counter.totalCount, equals(1));

      counter.clear();
      expect(counter.map, isEmpty);
      expect(counter.totalCount, equals(0));
    });

    test('getCountOf', () {
      var counter = Counter('name');
      counter.count('bucket-1');
      counter.count('bucket-2');
      counter.count('bucket-2');
      counter.count('bucket-3', 3);
      expect(counter.name, equals('name'));
      expect(counter.map, isNotEmpty);
      expect(counter.totalCount, equals(6)); // 1 + 2 + 3
      expect(counter.getCountOf('bucket-0'), equals(0));
      expect(counter.getCountOf('bucket-1'), equals(1));
      expect(counter.getCountOf('bucket-2'), equals(2));
      expect(counter.getCountOf('bucket-3'), equals(3));
    });
  });

  group('DistributionComputer', () {
    test('displayString', () {
      var computer = DistributionComputer();
      expect(
        computer.displayString(),
        '[0] 0 [10] 0 [20] 0 [30] 0 [40] 0 [50] 0 '
        '[60] 0 [70] 0 [80] 0 [90] 0 [100] 0',
      );

      for (var value in [
        3, // 0-9
        12, 15, // 10-19
        23, 24, 26, // 20-29
        30, 31, 31, 35, // 30-39
        42, 42, 42, 42, 42, // 40-49
        52, 53, 54, 55, 56, 57, // 50-59
        63, // 60-69
        72, 79, // 70-79
        83, 84, 86, // 80-89
        90, 91, 91, 99, // 90-99
        100, 110, 120, 5000, // 100+
      ]) {
        computer.addValue(value);
      }
      expect(
        computer.displayString(),
        '[0] 1 [10] 2 [20] 3 [30] 4 [40] 5 [50] 6 '
        '[60] 1 [70] 2 [80] 3 [90] 4 [100] 4',
      );
    });
  });

  group('MeanReciprocalRankComputer', () {
    test('empty', () {
      var computer = MeanReciprocalRankComputer('');
      expect(computer.count, equals(0));
      expect(computer.mrr, equals(0));
    });

    test('clear', () {
      var computer = MeanReciprocalRankComputer('');
      computer.addRank(2);
      expect(computer.count, equals(1));
      expect(computer.mrr, equals(1 / 2));
      expect(computer.mrr_5, equals(1 / 2));

      computer.clear();
      expect(computer.count, equals(0));
      expect(computer.mrr, equals(0));
      expect(computer.mrr_5, equals(0));
    });

    test('mrr- single value', () {
      var computer = MeanReciprocalRankComputer('');
      computer.addRank(3);
      computer.addRank(3);
      computer.addRank(3);
      computer.addRank(3);
      computer.addRank(3);
      expect(computer.count, equals(5));
      expect(computer.mrr, doubleEquals(1 / 3));
      expect(computer.mrr_5, doubleEquals(1 / 3));
    });

    test('mrr- example', () {
      var computer = MeanReciprocalRankComputer('');
      computer.addRank(3);
      computer.addRank(2);
      computer.addRank(1);
      expect(computer.count, equals(3));
      expect(computer.mrr, doubleEquals(11 / 18));
      expect(computer.mrr_5, doubleEquals(11 / 18));
    });

    test('mrr- max rank', () {
      var computer = MeanReciprocalRankComputer('');
      computer.addRank(6);
      computer.addRank(5);
      computer.addRank(4);
      computer.addRank(3);
      computer.addRank(2);
      computer.addRank(1);
      expect(computer.count, equals(6));
      expect(computer.mrr, greaterThan(computer.mrr_5));
    });
  });

  group('PercentileComputer', () {
    test('empty', () {
      var computer = PercentileComputer('empty', valueLimit: 2000);
      expect(computer.median, equals(0));
      expect(computer.valueCount, equals(0));
    });

    test('clear', () {
      var computer = PercentileComputer('name', valueLimit: 2000);
      computer.addValue(4);
      computer.addValue(5);
      computer.addValue(6);
      computer.addValue(3000);

      expect(computer.median, equals(5));
      expect(computer.valueCount, equals(3));
      expect(computer.aboveValueMaxCount, equals(1));
      computer.clear();

      expect(computer.median, equals(0));
      expect(computer.valueCount, equals(0));
      expect(computer.aboveValueMaxCount, equals(0));
      expect(computer.aboveValueMaxSamples, isEmpty);
    });

    test('percentiles', () {
      var computer = PercentileComputer('name', valueLimit: 2000);
      for (var i = 0; i < 100; i++) {
        computer.addValue(i);
      }

      expect(computer.median, equals(50));
      expect(computer.p90, equals(90));
      expect(computer.p95, equals(95));
    });

    test('values above maxValue', () {
      var computer = PercentileComputer('name', valueLimit: 2000);

      computer.addValue(1);
      computer.addValue(2);
      computer.addValue(3);
      computer.addValue(2500);
      computer.addValue(3000);

      expect(computer.median, equals(2));
      expect(computer.aboveValueMaxCount, equals(2));
      expect(computer.aboveValueMaxSamples, equals([2500, 3000]));
    });
  });

  group('Place', () {
    test('none', () {
      var place = Place.none();
      expect(place.numerator, equals(0));
      expect(place.denominator, equals(0));
      expect(place.rank, equals(0));
      expect(place, equals(Place.none()));
      expect(place == Place(1, 1), isFalse);
    });

    test('default', () {
      var place = Place(10, 20);
      expect(place.numerator, equals(10));
      expect(place.rank, equals(10));
      expect(place.denominator, equals(20));
      expect(place, equals(Place(10, 20)));
      expect(place == Place(1, 2), isFalse);
      expect(place == Place(10, 200), isFalse);
      expect(place == Place(1, 20), isFalse);
    });
  });
}

/// Returns matcher that can compare double values.
Matcher doubleEquals(double expected) => _DoubleEquals(expected);

class _DoubleEquals extends Matcher {
  final double _value;
  final int fractionDigits = 10;

  const _DoubleEquals(this._value);

  @override
  Description describe(Description description) =>
      description.add(_value.toString());

  @override
  bool matches(item, Map<Object?, Object?> matchState) {
    return item is num &&
        num.parse(item.toStringAsFixed(fractionDigits)) ==
            num.parse(_value.toStringAsFixed(fractionDigits));
  }
}
