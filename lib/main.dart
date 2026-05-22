import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_config.dart';
import 'core/services/theme_service.dart';
import 'data/services/auth_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.instance.init();
  unawaited(_initializeFcm());

  // Durum çubuğu rengi
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Yalnızca dikey ekran yönü
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const PinKodumApp());
}

Future<void> _initializeFcm() async {
  if (!_isMobilePlatform) return;

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    await _setupFcm();
  } catch (e) {
    debugPrint('FCM init skipped: $e');
  }
}

Future<void> _setupFcm() async {
  final messaging = FirebaseMessaging.instance;
  try {
    // Screenshot modunda bildirim izni isteme
    const screenshotMode = bool.fromEnvironment('SCREENSHOT_MODE', defaultValue: false);
    if (!screenshotMode) {
      await messaging.requestPermission(alert: true, badge: true, sound: true);
    }
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _getFcmToken(messaging);
    if (token != null) await _saveFcmToken(token);

    messaging.onTokenRefresh.listen(
      _saveFcmToken,
      onError: (Object error) => debugPrint('FCM token refresh error: $error'),
    );
    FirebaseMessaging.onMessage.listen(_showForegroundMessage);

    // Giris yapilinca token'i tekrar kaydet.
    AuthService.authChanges.addListener(() {
      unawaited(_syncFcmToken(messaging));
    });
  } catch (e) {
    debugPrint('FCM setup error: $e');
  }
}

void _showForegroundMessage(RemoteMessage message) {
  final notification = message.notification;
  final title = notification?.title ?? message.data['title'] as String?;
  final body = notification?.body ?? message.data['body'] as String?;
  if (title == null && body == null) return;

  final messenger = rootScaffoldMessengerKey.currentState;
  messenger
    ?..hideCurrentMaterialBanner()
    ..showMaterialBanner(
      MaterialBanner(
        backgroundColor: AppColors.surface,
        leading:
            Icon(Icons.notifications_active_outlined, color: AppColors.action),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (body != null) ...[
              const SizedBox(height: 2),
              Text(body, style: TextStyle(color: AppColors.textSecondary)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => messenger.hideCurrentMaterialBanner(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
}

Future<void> _syncFcmToken(FirebaseMessaging messaging) async {
  final token = await _getFcmToken(messaging);
  if (token != null) await _saveFcmToken(token);
}

Future<String?> _getFcmToken(FirebaseMessaging messaging) async {
  try {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final apnsToken = await _waitForApnsToken(messaging);
      if (apnsToken == null) return null;
    }

    return messaging.getToken();
  } catch (e) {
    debugPrint('FCM token error: $e');
    return null;
  }
}

Future<String?> _waitForApnsToken(FirebaseMessaging messaging) async {
  for (var attempt = 0; attempt < 5; attempt++) {
    final token = await messaging.getAPNSToken();
    if (token != null) return token;
    await Future<void>.delayed(const Duration(seconds: 1));
  }

  debugPrint('FCM token skipped: APNs token is not ready.');
  return null;
}

Future<void> _saveFcmToken(String token) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final auth = AuthService(prefs);
    debugPrint(
        'FCM: isLoggedIn=${auth.isLoggedIn}, token length=${token.length}');
    if (!auth.isLoggedIn) return;
    final res = await http
        .patch(
          Uri.parse('${AppConfig.backendBaseUrl}/auth/fcm-token'),
          headers: {
            'authorization': 'Bearer ${auth.token}',
            'content-type': 'application/json',
          },
          body: jsonEncode({'token': token}),
        )
        .timeout(const Duration(seconds: 10));
    debugPrint('FCM save result: ${res.statusCode}');
  } catch (e) {
    debugPrint('FCM save error: $e');
  }
}

bool get _isMobilePlatform {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}
