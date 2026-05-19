import 'package:flutter_test/flutter_test.dart';
import 'package:pin_kodum/data/services/element_balance_calculator.dart';

void main() {
  const calc = ElementBalanceCalculator();

  group('ElementBalanceCalculator', () {
    // Dokümanın test senaryosu: 29.10.1985 → [2,1,5,8,1,3,6,9,8]
    test('Cumali örneği — Hava:3 Su:1 Ateş:2 Toprak:2 Denge:1', () {
      final result = calc.calculate([2, 1, 5, 8, 1, 3, 6, 9, 8]);
      expect(result.air, 3);
      expect(result.water, 1);
      expect(result.fire, 2);
      expect(result.earth, 2);
      expect(result.balanceNine, 1);
    });

    // Baskın: 1+8+1+3+6+8=6 tam + 9'dan 0.5 = 6.5
    // Edilgen: 2+5=2 tam + 9'dan 0.5 = 2.5
    test('Baskın toplam 6.5, Edilgen toplam 2.5', () {
      final result = calc.calculate([2, 1, 5, 8, 1, 3, 6, 9, 8]);
      expect(result.dominantScore, 6.5);
      expect(result.passiveScore, 2.5);
    });

    test('Baskın element Hava, Zayıf element Su', () {
      final result = calc.calculate([2, 1, 5, 8, 1, 3, 6, 9, 8]);
      expect(result.dominantElement, ElementBalanceCalculator.elementAir);
      expect(result.weakestElement, ElementBalanceCalculator.elementWater);
    });

    test('Enerji tipi Baskın (fark 3.0 >= 1.5)', () {
      final result = calc.calculate([2, 1, 5, 8, 1, 3, 6, 9, 8]);
      expect(result.energyType, ElementBalanceCalculator.energyDominant);
    });

    test('9 sayısı 0.5 baskın + 0.5 edilgen ekler', () {
      final result = calc.calculate([9, 9, 9, 9, 9, 9, 9, 9, 9]);
      expect(result.dominantScore, 4.5);
      expect(result.passiveScore, 4.5);
      expect(result.balanceNine, 9);
      expect(result.energyType, ElementBalanceCalculator.energyBalanced);
    });

    test('Dengeli enerji tipi (-1.5 < fark < 1.5)', () {
      // 4 edilgen, 5 baskın → fark 1.0 < 1.5
      final result = calc.calculate([1, 2, 3, 4, 1, 2, 3, 4, 1]);
      expect(result.energyType, ElementBalanceCalculator.energyBalanced);
    });

    test('Edilgen enerji tipi', () {
      // Hepsi edilgen: 2,4,5,7,2,4,5,7,2
      final result = calc.calculate([2, 4, 5, 7, 2, 4, 5, 7, 2]);
      expect(result.energyType, ElementBalanceCalculator.energyPassive);
    });
  });
}
