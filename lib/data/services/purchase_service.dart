import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_config.dart';
import 'auth_service.dart';

/// Kredi paket tanımları — App Store Connect'teki ürün ID'leriyle eşleşmeli.
class CreditProduct {
  final String id;
  final String title;
  final String description;
  final int credits;
  final String priceLabel; // App Store'dan dolduğunda güncellenir

  const CreditProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.credits,
    required this.priceLabel,
  });
}

const kCreditProducts = [
  CreditProduct(
    id: 'com.pinkodum.app.credits5',
    title: '5 Kredi',
    description: '5 standart analiz',
    credits: 5,
    priceLabel: '₺49,99',
  ),
  CreditProduct(
    id: 'com.pinkodum.app.credits20',
    title: '20 Kredi',
    description: '20 standart analiz',
    credits: 20,
    priceLabel: '₺149,99',
  ),
  CreditProduct(
    id: 'com.pinkodum.app.credits50',
    title: '50 Kredi',
    description: '50 standart analiz',
    credits: 50,
    priceLabel: '₺299,99',
  ),
];

// Analiz türü başına kredi maliyeti
const kCreditsPerSingleAnalysis = 1;
const kCreditsPerPremiumAnalysis = 3;
const kCreditsPerRelationshipAnalysis = 1;
const kCreditsPerRelationshipPremium = 3;

class PurchaseService {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  bool _available = false;
  bool get isAvailable => _available;

  Future<void> init() async {
    _available = await _iap.isAvailable();
    if (!_available) return;

    final ids = kCreditProducts.map((p) => p.id).toSet();
    final response = await _iap.queryProductDetails(ids);
    _products = response.productDetails;
  }

  void listenPurchases(
    Future<void> Function(PurchaseDetails) onPurchase,
  ) {
    _subscription?.cancel();
    _subscription = _iap.purchaseStream.listen((purchases) {
      for (final purchase in purchases) {
        onPurchase(purchase);
      }
    });
  }

  Future<bool> buy(ProductDetails product) async {
    final param = PurchaseParam(productDetails: product);
    return _iap.buyConsumable(purchaseParam: param);
  }

  /// Satın alma Apple tarafından onaylandıktan sonra backend'e gönderir.
  Future<int?> verifyWithBackend(PurchaseDetails purchase) async {
    final prefs = await SharedPreferences.getInstance();
    final auth = AuthService(prefs);
    if (!auth.isLoggedIn) return null;

    final receiptData = purchase.verificationData.serverVerificationData;
    final res = await http.post(
      Uri.parse('${AppConfig.backendBaseUrl}/purchases/verify'),
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer ${auth.token}',
      },
      body: jsonEncode({
        'productId': purchase.productID,
        'transactionId': purchase.purchaseID ?? '',
        'platform': 'ios',
        'receiptData': receiptData,
      }),
    ).timeout(const Duration(seconds: 15));

    if (res.statusCode == 201) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return body['totalCredits'] as int?;
    }
    return null;
  }

  Future<void> completePurchase(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
