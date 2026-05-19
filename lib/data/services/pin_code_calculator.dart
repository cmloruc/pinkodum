/// Doğum tarihinden 9 haneli numerolojik pin kodu hesaplar.
///
/// Algoritma:
///   H1 = gün rakamlarının toplamı (tek haneye indirilmiş)
///   H2 = ay rakamlarının toplamı
///   H3 = yıl rakamlarının toplamı
///   H4 = H1 + H2 + H3
///   H5 = H1 + H4
///   H6 = H1 + H2
///   H7 = H2 + H3
///   H8 = H6 + H7
///   H9 = H1..H8 toplamı
///
/// Örnek: 29.10.1985 → [2,1,5,8,1,3,6,9,8]
class PinCodeCalculator {
  const PinCodeCalculator();

  /// [birthDate] için 9 haneli pin kodu döner.
  List<int> calculate(DateTime birthDate) {
    final h1 = _reduce(birthDate.day);
    final h2 = _reduce(birthDate.month);
    final h3 = _reduceNumber(birthDate.year);

    final h4 = _reduce(h1 + h2 + h3);
    final h5 = _reduce(h1 + h4);
    final h6 = _reduce(h1 + h2);
    final h7 = _reduce(h2 + h3);
    final h8 = _reduce(h6 + h7);
    final h9 = _reduce(h1 + h2 + h3 + h4 + h5 + h6 + h7 + h8);

    return [h1, h2, h3, h4, h5, h6, h7, h8, h9];
  }

  /// İki kişinin pin kodunu karşılıklı toplayıp ortak pin kodu üretir.
  /// Örnek: [5,…] + [3,…] → [8,…]
  List<int> calculateCombined(List<int> pin1, List<int> pin2) {
    assert(pin1.length == 9 && pin2.length == 9);
    return List.generate(9, (i) => _reduce(pin1[i] + pin2[i]));
  }

  /// Pin kodu listesini "X-X-X-X-X-X-X-X-X" formatında döner.
  String format(List<int> pinCode) => pinCode.join('-');

  /// Sayının rakamlarını tek haneye indirir (9'dan büyükse tekrar toplar).
  int _reduce(int number) {
    var n = number;
    while (n > 9) {
      n = _digitSum(n);
    }
    return n;
  }

  /// Çok basamaklı bir sayının rakamlarını tek haneye indirir.
  int _reduceNumber(int number) {
    return _reduce(_digitSum(number));
  }

  int _digitSum(int number) {
    var sum = 0;
    var n = number.abs();
    while (n > 0) {
      sum += n % 10;
      n ~/= 10;
    }
    return sum;
  }
}
