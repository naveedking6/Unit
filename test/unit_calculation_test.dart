import 'package:flutter_test/flutter_test.dart';
import 'package:unit_saathi/models/unit_record.dart';

void main() {
  group('UnitCalculator.calculateTotal', () {
    test('1000 -> 1050 = 50', () {
      expect(UnitCalculator.calculateTotal(startUnit: 1000, endUnit: 1050), 50);
    });

    test('1250 -> 1300 = 50', () {
      expect(UnitCalculator.calculateTotal(startUnit: 1250, endUnit: 1300), 50);
    });

    test('1500 -> 1500 = 0', () {
      expect(UnitCalculator.calculateTotal(startUnit: 1500, endUnit: 1500), 0);
    });

    test('1500 -> 1400 throws with correct Urdu message', () {
      expect(
        () => UnitCalculator.calculateTotal(startUnit: 1500, endUnit: 1400),
        throwsA(isA<InvalidUnitException>().having(
          (e) => e.urduMessage,
          'urduMessage',
          UnitCalculator.errEndLessThanStart,
        )),
      );
    });

    test('empty start throws start-required message', () {
      expect(
        () => UnitCalculator.calculateTotal(startUnit: null, endUnit: 100),
        throwsA(isA<InvalidUnitException>().having(
          (e) => e.urduMessage,
          'urduMessage',
          UnitCalculator.errStartRequired,
        )),
      );
    });

    test('empty end throws end-required message', () {
      expect(
        () => UnitCalculator.calculateTotal(startUnit: 100, endUnit: null),
        throwsA(isA<InvalidUnitException>().having(
          (e) => e.urduMessage,
          'urduMessage',
          UnitCalculator.errEndRequired,
        )),
      );
    });

    test('large readings do not overflow or lose precision', () {
      expect(UnitCalculator.calculateTotal(startUnit: 999999, endUnit: 1000050), 51);
    });

    test('zero-to-zero is valid and zero', () {
      expect(UnitCalculator.calculateTotal(startUnit: 0, endUnit: 0), 0);
    });
  });

  group('UnitRecord.totalUnit', () {
    test('computes total from stored start/end, never mutates them', () {
      final r = UnitRecord(
        name: 'نوید',
        date: DateTime(2026, 8, 9),
        startUnit: 1250,
        endUnit: 1300,
        createdAt: DateTime(2026, 8, 9),
      );
      expect(r.totalUnit, 50);
      expect(r.startUnit, 1250);
      expect(r.endUnit, 1300);
    });

    test('round-trips through toMap/fromMap without changing values', () {
      final r = UnitRecord(
        id: 7,
        name: 'نوید',
        date: DateTime(2026, 8, 9),
        startUnit: 5000,
        endUnit: 5020,
        createdAt: DateTime(2026, 8, 9, 10, 30),
      );
      final restored = UnitRecord.fromMap(r.toMap());
      expect(restored.startUnit, 5000);
      expect(restored.endUnit, 5020);
      expect(restored.totalUnit, 20);
      expect(restored.name, 'نوید');
    });
  });

  group('Monthly totals', () {
    test('sums multiple records correctly (20 + 50 + 30 = 100)', () {
      final records = [
        UnitRecord(name: 'نوید', date: DateTime(2026, 8, 1), startUnit: 0, endUnit: 20, createdAt: DateTime.now()),
        UnitRecord(name: 'نوید', date: DateTime(2026, 8, 2), startUnit: 20, endUnit: 70, createdAt: DateTime.now()),
        UnitRecord(name: 'نوید', date: DateTime(2026, 8, 3), startUnit: 70, endUnit: 100, createdAt: DateTime.now()),
      ];
      final total = records.fold<int>(0, (sum, r) => sum + r.totalUnit);
      expect(total, 100);
    });

    test('no artificial limit on number of daily records', () {
      final records = List.generate(
        365,
        (i) => UnitRecord(
          name: 'نوید',
          date: DateTime(2026, 1, 1).add(Duration(days: i)),
          startUnit: i * 10,
          endUnit: i * 10 + 5,
          createdAt: DateTime.now(),
        ),
      );
      expect(records.length, 365);
      expect(records.fold<int>(0, (s, r) => s + r.totalUnit), 365 * 5);
    });
  });
}
