/// Mock premium servisi — gerçek IAP entegrasyonuna kadar lokal state yönetir.
class PremiumService {
  bool _isPremium = false;
  int _credits = 0;

  bool get isPremium => _isPremium;
  int get credits => _credits;

  // Mock satın alma — Aşama 3'te App Store / Play Billing ile replace edilecek
  Future<bool> mockPurchase(PremiumPackage package) async {
    await Future.delayed(const Duration(milliseconds: 500));
    switch (package) {
      case PremiumPackage.singleDetail:
        _credits += 1;
      case PremiumPackage.relationshipDetail:
        _credits += 2;
      case PremiumPackage.monthly:
        _isPremium = true;
        _credits += 10;
      case PremiumPackage.yearly:
        _isPremium = true;
        _credits += 50;
    }
    return true;
  }

  bool canAfford(int requiredCredits) => _credits >= requiredCredits;

  void spendCredits(int amount) {
    if (_credits >= amount) _credits -= amount;
  }
}

enum PremiumPackage {
  singleDetail,
  relationshipDetail,
  monthly,
  yearly,
}
