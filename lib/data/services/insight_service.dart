import '../mock/mock_data.dart';

class InsightService {
  const InsightService();

  String getDailyInsight(DateTime date) =>
      MockAnalysisData.getDailyInsight(date);

  String getWeeklyTheme(DateTime date) =>
      MockAnalysisData.getWeeklyTheme(date);

  String getAffirmation(DateTime date) =>
      MockAnalysisData.getAffirmation(date);
}
