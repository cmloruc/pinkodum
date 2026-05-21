import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
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
  final bool isSubscription;

  const CreditProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.credits,
    required this.priceLabel,
    this.isSubscription = false,
  });
}

const kCreditProducts = [
  CreditProduct(
    id: 'com.pinkodum.app.premium_yearly',
    title: 'Yıllık Premium',
    description: 'Her ay 10 tekil ve 10 ilişki analizi',
    credits: 0,
    priceLabel: '₺899 / yıl',
    isSubscription: true,
  ),
  CreditProduct(
    id: 'com.pinkodum.app.credits5',
    title: '5 Kredi',
    description: 'Tekil veya ilişki analizlerinde kullanılır',
    credits: 5,
    priceLabel: '₺245',
  ),
  CreditProduct(
    id: 'com.pinkodum.app.credits20',
    title: '20 Kredi',
    description: 'Daha fazla analiz için avantajlı paket',
    credits: 20,
    priceLabel: '₺980',
  ),
  CreditProduct(
    id: 'com.pinkodum.app.credits50',
    title: '50 Kredi',
    description: 'Yoğun kullanım için büyük kredi paketi',
    credits: 50,
    priceLabel: '₺2.450',
  ),
];

// Analiz türü başına kredi maliyeti
const kCreditUnitPriceTry = 49;
const kCreditsPerSingleAnalysis = 2;
const kCreditsPerPremiumAnalysis = 2;
const kCreditsPerRelationshipAnalysis = 3;
const kCreditsPerRelationshipPremium = 3;

class PurchaseService {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  bool _available = false;
  bool get isAvailable => _available;

  Future<void> init() async {
    if (kIsWeb) {
      _available = false;
      _products = [];
      return;
    }

    _available = await _iap.isAvailable();
    if (!_available) return;

    final ids = kCreditProducts.map((p) => p.id).toSet();
    final response = await _iap.queryProductDetails(ids);
    _products = response.productDetails;
  }

  void listenPurchases(
    Future<void> Function(PurchaseDetails) onPurchase,
  ) {
    if (kIsWeb) return;

    _subscription?.cancel();
    _subscription = _iap.purchaseStream.listen((purchases) {
      for (final purchase in purchases) {
        onPurchase(purchase);
      }
    });
  }

  Future<bool> buy(ProductDetails product) async {
    final param = PurchaseParam(productDetails: product);
    final productConfig = kCreditProducts
        .cast<CreditProduct?>()
        .firstWhere((p) => p?.id == product.id, orElse: () => null);
    if (productConfig?.isSubscription ?? false) {
      return _iap.buyNonConsumable(purchaseParam: param);
    }
    return _iap.buyConsumable(purchaseParam: param);
  }

  /// Satın alma Apple tarafından onaylandıktan sonra backend'e gönderir.
  Future<int> verifyWithBackend(PurchaseDetails purchase) async {
    final prefs = await SharedPreferences.getInstance();
    final auth = AuthService(prefs);
    if (!auth.isLoggedIn) {
      throw Exception('Satın alma doğrulaması için giriş yapılması gerekiyor.');
    }

    final transactionId = purchase.purchaseID;
    if (transactionId == null || transactionId.trim().isEmpty) {
      throw Exception('Satın alma işlem numarası alınamadı.');
    }
    final receiptData = purchase.verificationData.serverVerificationData;
    if (receiptData.trim().isEmpty) {
      throw Exception('Satın alma doğrulama verisi alınamadı.');
    }

    final res = await http
        .post(
          Uri.parse('${AppConfig.backendBaseUrl}/purchases/verify'),
          headers: {
            'content-type': 'application/json',
            'authorization': 'Bearer ${auth.token}',
          },
          body: jsonEncode({
            'productId': purchase.productID,
            'transactionId': transactionId,
            'platform': 'ios',
            'receiptData': receiptData,
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 201) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final totalCredits = body['totalCredits'];
      if (totalCredits is int) return totalCredits;
      throw Exception('Kredi bilgisi alınamadı.');
    }

    String? errorMessage;
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final message = body['message'];
      if (message is String && message.isNotEmpty) {
        errorMessage = message;
      }
      if (message is List && message.isNotEmpty) {
        errorMessage = message.join(' ');
      }
    } catch (_) {
      // JSON olmayan backend hatalarında genel mesajı kullan.
    }
    if (errorMessage != null) throw Exception(errorMessage);
    throw Exception('Satın alma doğrulanamadı.');
  }

  Future<void> completePurchase(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  Future<AuthUser> consumeAnalysisAccess(String type) async {
    final prefs = await SharedPreferences.getInstance();
    final auth = AuthService(prefs);
    if (!auth.isLoggedIn) {
      throw Exception('Analiz için giriş yapılması gerekiyor.');
    }

    final res = await http
        .post(
          Uri.parse('${AppConfig.backendBaseUrl}/purchases/consume-analysis'),
          headers: {
            'content-type': 'application/json',
            'authorization': 'Bearer ${auth.token}',
          },
          body: jsonEncode({'type': type}),
        )
        .timeout(const Duration(seconds: 15));

    final user = _handleUserResponse(res, 'Analiz hakkı kullanılamadı.');
    await auth.cacheUser(user);
    return user;
  }

  Future<AuthUser> unlockDailyInsight() async {
    final prefs = await SharedPreferences.getInstance();
    final auth = AuthService(prefs);
    if (!auth.isLoggedIn) {
      throw Exception('Günlük içgörü için giriş yapılması gerekiyor.');
    }

    final res = await http.post(
      Uri.parse('${AppConfig.backendBaseUrl}/purchases/unlock-daily-insight'),
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer ${auth.token}',
      },
    ).timeout(const Duration(seconds: 15));

    final user = _handleUserResponse(res, 'Günlük içgörü açılamadı.');
    await auth.cacheUser(user);
    return user;
  }

  AuthUser _handleUserResponse(http.Response res, String fallbackMessage) {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return AuthUser.fromJson(body);
    }

    final message = body['message'];
    if (message is String && message.isNotEmpty) {
      throw Exception(message);
    }
    if (message is List && message.isNotEmpty) {
      throw Exception(message.join(' '));
    }
    throw Exception(fallbackMessage);
  }

  void dispose() {
    _subscription?.cancel();
  }
}
