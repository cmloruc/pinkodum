import '../models/element_balance.dart';

/// Pin kodundaki 9 haneye göre element dağılımı ve enerji dengesi hesaplar.
///
/// Element tablosu:
///   1 → Hava  / Baskın
///   5 → Hava  / Edilgen
///   2 → Su    / Edilgen
///   7 → Su    / Edilgen
///   3 → Ateş  / Baskın
///   6 → Ateş  / Baskın
///   4 → Toprak / Edilgen
///   8 → Toprak / Baskın
///   9 → Denge  / +0.5 Baskın +0.5 Edilgen
///
/// Enerji tipi eşiği:
///   fark >= 1.5  → Baskın
///   fark <= -1.5 → Edilgen
///   diğer        → Dengeli
class ElementBalanceCalculator {
  const ElementBalanceCalculator();

  static const double balanceThreshold = 1.5;

  static const String elementAir = 'Hava';
  static const String elementWater = 'Su';
  static const String elementFire = 'Ateş';
  static const String elementEarth = 'Toprak';
  static const String elementBalance9 = 'Denge';

  static const String energyDominant = 'Baskın';
  static const String energyPassive = 'Edilgen';
  static const String energyBalanced = 'Dengeli';

  ElementBalance calculate(List<int> pinCode) {
    assert(pinCode.length == 9, 'Pin kodu 9 haneli olmalı');

    var air = 0;
    var water = 0;
    var fire = 0;
    var earth = 0;
    var balance9 = 0;
    var dominant = 0.0;
    var passive = 0.0;

    for (final digit in pinCode) {
      switch (digit) {
        case 1:
          air++;
          dominant += 1;
        case 5:
          air++;
          passive += 1;
        case 2:
          water++;
          passive += 1;
        case 7:
          water++;
          passive += 1;
        case 3:
          fire++;
          dominant += 1;
        case 6:
          fire++;
          dominant += 1;
        case 4:
          earth++;
          passive += 1;
        case 8:
          earth++;
          dominant += 1;
        case 9:
          balance9++;
          dominant += 0.5;
          passive += 0.5;
      }
    }

    final dominantElement = _findDominant(air, water, fire, earth);
    final weakestElement = _findWeakest(air, water, fire, earth);
    final energyType = _determineEnergyType(dominant, passive);

    return ElementBalance(
      air: air,
      water: water,
      fire: fire,
      earth: earth,
      balanceNine: balance9,
      dominantScore: dominant,
      passiveScore: passive,
      dominantElement: dominantElement,
      weakestElement: weakestElement,
      energyType: energyType,
    );
  }

  String _findDominant(int air, int water, int fire, int earth) {
    final max = [air, water, fire, earth].reduce((a, b) => a > b ? a : b);
    if (air == max) return elementAir;
    if (water == max) return elementWater;
    if (fire == max) return elementFire;
    return elementEarth;
  }

  String _findWeakest(int air, int water, int fire, int earth) {
    final min = [air, water, fire, earth].reduce((a, b) => a < b ? a : b);
    // Birden fazla element aynı düşük değerdeyse öncelik sırası: Su → Toprak → Ateş → Hava
    if (water == min) return elementWater;
    if (earth == min) return elementEarth;
    if (fire == min) return elementFire;
    return elementAir;
  }

  String _determineEnergyType(double dominant, double passive) {
    final diff = dominant - passive;
    if (diff >= balanceThreshold) return energyDominant;
    if (diff <= -balanceThreshold) return energyPassive;
    return energyBalanced;
  }
}
