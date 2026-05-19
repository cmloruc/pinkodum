import 'package:flutter_test/flutter_test.dart';
import 'package:pin_kodum/data/services/pin_code_calculator.dart';

void main() {
  const calc = PinCodeCalculator();

  group('PinCodeCalculator', () {
    test('29.10.1985 → [2,1,5,8,1,3,6,9,8]', () {
      final result = calc.calculate(DateTime(1985, 10, 29));
      expect(result, [2, 1, 5, 8, 1, 3, 6, 9, 8]);
    });

    test('12.11.1994 pin kodu 9 haneli olmalı', () {
      final result = calc.calculate(DateTime(1994, 11, 12));
      expect(result.length, 9);
    });

    test('Tüm haneler 1-9 arasında olmalı', () {
      final result = calc.calculate(DateTime(1990, 6, 15));
      for (final d in result) {
        expect(d, inInclusiveRange(1, 9));
      }
    });

    test('format() tire ile birleştirir', () {
      final pin = [2, 1, 5, 8, 1, 3, 6, 9, 8];
      expect(calc.format(pin), '2-1-5-8-1-3-6-9-8');
    });

    test('01.01.2000 çalışmalı', () {
      final result = calc.calculate(DateTime(2000, 1, 1));
      expect(result.length, 9);
    });
  });

  group('calculateCombined', () {
    test('karşılıklı toplama doğru çalışır', () {
      final pin1 = [5, 1, 3, 2, 7, 6, 4, 8, 9];
      final pin2 = [3, 2, 6, 7, 2, 3, 5, 1, 1];
      final combined = calc.calculateCombined(pin1, pin2);
      expect(combined[0], 8); // 5+3=8
      expect(combined[1], 3); // 1+2=3
      expect(combined[2], 9); // 3+6=9
      expect(combined.length, 9);
    });

    test('10\'u aşan toplam tek haneye indirilir', () {
      final pin1 = [9, 9, 9, 9, 9, 9, 9, 9, 9];
      final pin2 = [9, 9, 9, 9, 9, 9, 9, 9, 9];
      final combined = calc.calculateCombined(pin1, pin2);
      for (final d in combined) {
        expect(d, inInclusiveRange(1, 9));
      }
    });

    test('gerçek iki kişi için doğru çalışır', () {
      final pin1 = calc.calculate(DateTime(1985, 10, 29)); // [2,1,5,8,1,3,6,9,8]
      final pin2 = calc.calculate(DateTime(1994, 11, 12));
      final combined = calc.calculateCombined(pin1, pin2);
      expect(combined.length, 9);
      for (final d in combined) {
        expect(d, inInclusiveRange(1, 9));
      }
    });
  });
}
