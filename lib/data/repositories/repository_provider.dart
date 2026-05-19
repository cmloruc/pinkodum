import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'analysis_repository.dart';
import 'api_analysis_repository.dart';
import 'local_analysis_repository.dart';

/// Kullanıcı giriş yapmışsa ApiAnalysisRepository, yoksa LocalAnalysisRepository döner.
Future<AnalysisRepository> getRepository() async {
  final prefs = await SharedPreferences.getInstance();
  final auth = AuthService(prefs);
  if (auth.isLoggedIn) {
    return ApiAnalysisRepository(auth.token!);
  }
  return LocalAnalysisRepository(prefs);
}
