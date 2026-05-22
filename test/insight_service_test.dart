import 'package:flutter_test/flutter_test.dart';
import 'package:pin_kodum/data/services/element_balance_calculator.dart';
import 'package:pin_kodum/data/services/insight_service.dart';

void main() {
  const service = InsightService();
  const balanceCalculator = ElementBalanceCalculator();
  final balance = balanceCalculator.calculate([2, 1, 5, 8, 1, 3, 6, 9, 8]);

  group('InsightService personal rotation', () {
    test('daily insight changes across consecutive days', () {
      final messages = [
        DateTime(2026, 5, 20),
        DateTime(2026, 5, 21),
        DateTime(2026, 5, 22),
      ].map((date) {
        return service.getPersonalDailyInsight(
          name: 'Cumali',
          date: date,
          birthDate: DateTime(1985, 10, 29),
          pinCode: [2, 1, 5, 8, 1, 3, 6, 9, 8],
          elementBalance: balance,
        );
      }).toSet();

      expect(messages.length, 3);
    });

    test('affirmation changes with the day in personal mode', () {
      final today = service.getPersonalAffirmation(
        name: 'Cumali',
        date: DateTime(2026, 5, 20),
        elementBalance: balance,
      );
      final tomorrow = service.getPersonalAffirmation(
        name: 'Cumali',
        date: DateTime(2026, 5, 21),
        elementBalance: balance,
      );

      expect(today, isNot(tomorrow));
    });

    test('weekly theme changes when the week changes in personal mode', () {
      final firstWeek = service.getPersonalWeeklyTheme(
        date: DateTime(2026, 5, 2),
        elementBalance: balance,
      );
      final laterWeek = service.getPersonalWeeklyTheme(
        date: DateTime(2026, 5, 16),
        elementBalance: balance,
      );

      expect(firstWeek, isNot(laterWeek));
    });
  });
}
