import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/services/theme_service.dart';
import 'router.dart';
import 'theme.dart';

final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class PinKodumApp extends StatelessWidget {
  const PinKodumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ThemeService.instance.notifier,
      builder: (context, _, __) => MaterialApp.router(
        title: 'Pin Kodum',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        routerConfig: buildRouter(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('tr', 'TR'),
          Locale('en', 'US'),
        ],
        locale: const Locale('tr', 'TR'),
      ),
    );
  }
}
