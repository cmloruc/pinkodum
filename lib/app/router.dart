import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/person_analysis.dart';
import '../data/models/person_premium_analysis.dart';
import '../data/models/relationship_analysis.dart';
import '../data/models/relationship_premium_analysis.dart';
import '../features/history/history_screen.dart';
import '../features/home/home_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/premium/premium_screen.dart';
import '../features/relationship_analysis/relationship_form_screen.dart';
import '../features/relationship_analysis/relationship_premium_loading_screen.dart';
import '../features/relationship_analysis/relationship_premium_purchase_screen.dart';
import '../features/relationship_analysis/relationship_premium_result_screen.dart';
import '../features/relationship_analysis/relationship_result_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/single_analysis/premium_loading_screen.dart';
import '../features/single_analysis/premium_purchase_screen.dart';
import '../features/single_analysis/premium_result_screen.dart';
import '../features/single_analysis/single_analysis_form_screen.dart';
import '../features/single_analysis/single_analysis_result_screen.dart';
import '../features/admin/admin_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const singleForm = '/single-analysis';
  static const singleResult = '/single-analysis/result';
  static const relationshipForm = '/relationship-analysis';
  static const relationshipResult = '/relationship-analysis/result';
  static const history = '/history';
  static const insights = '/insights';
  static const premium = '/premium';
  static const premiumPurchase = '/premium-purchase';
  static const relPremiumPurchase = '/rel-premium-purchase';
  static const relPremiumLoading = '/rel-premium-loading';
  static const relPremiumResult = '/rel-premium-result';
  static const premiumLoading = '/premium-loading';
  static const premiumResult = '/premium-result';
  static const settings = '/settings';
  static const login = '/login';
  static const register = '/register';
  static const admin = '/admin';
}

class AnalysisRouteArgs<T> {
  final T analysis;
  final bool saveOnOpen;

  const AnalysisRouteArgs({
    required this.analysis,
    this.saveOnOpen = true,
  });
}

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.singleForm,
        builder: (_, __) => const SingleAnalysisFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.singleResult,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is AnalysisRouteArgs<PersonAnalysis>) {
            return SingleAnalysisResultScreen(
              analysis: extra.analysis,
              saveOnOpen: extra.saveOnOpen,
            );
          }
          return SingleAnalysisResultScreen(
            analysis: extra as PersonAnalysis,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.relationshipForm,
        builder: (_, __) => const RelationshipFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.relationshipResult,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is AnalysisRouteArgs<RelationshipAnalysis>) {
            return RelationshipResultScreen(
              analysis: extra.analysis,
              saveOnOpen: extra.saveOnOpen,
            );
          }
          return RelationshipResultScreen(
            analysis: extra as RelationshipAnalysis,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (_, __) => const HistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.insights,
        builder: (_, __) => const InsightsScreen(),
      ),
      GoRoute(
        path: AppRoutes.premium,
        builder: (_, __) => const PremiumScreen(),
      ),
      GoRoute(
        path: AppRoutes.premiumPurchase,
        builder: (context, state) {
          final analysis = state.extra as PersonAnalysis;
          return PremiumPurchaseScreen(analysis: analysis);
        },
      ),
      GoRoute(
        path: AppRoutes.premiumLoading,
        builder: (context, state) {
          final analysis = state.extra as PersonAnalysis;
          return PremiumLoadingScreen(analysis: analysis);
        },
      ),
      GoRoute(
        path: AppRoutes.premiumResult,
        builder: (context, state) {
          final analysis = state.extra as PersonPremiumAnalysis;
          return PremiumResultScreen(analysis: analysis);
        },
      ),
      GoRoute(
        path: AppRoutes.relPremiumPurchase,
        builder: (context, state) {
          final a = state.extra as RelationshipAnalysis;
          return RelationshipPremiumPurchaseScreen(analysis: a);
        },
      ),
      GoRoute(
        path: AppRoutes.relPremiumLoading,
        builder: (context, state) {
          final a = state.extra as RelationshipAnalysis;
          return RelationshipPremiumLoadingScreen(analysis: a);
        },
      ),
      GoRoute(
        path: AppRoutes.relPremiumResult,
        builder: (context, state) {
          final a = state.extra as RelationshipPremiumAnalysis;
          return RelationshipPremiumResultScreen(analysis: a);
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.admin,
        builder: (_, __) => const AdminScreen(),
      ),
    ],
    redirect: (context, state) async {
      if (state.matchedLocation == AppRoutes.splash) return null;
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getBool('onboarding_seen') ?? false;
      if (!seen && state.matchedLocation != AppRoutes.onboarding) {
        return AppRoutes.onboarding;
      }
      return null;
    },
    errorBuilder: (context, state) => const Scaffold(
      backgroundColor: Color(0xFF0A0E1A),
      body: Center(
        child: Text(
          'Sayfa bulunamadı',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    ),
  );
}
