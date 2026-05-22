import '../mock/mock_data.dart';
import '../models/element_balance.dart';

class InsightService {
  const InsightService();

  String getDailyInsight(DateTime date) =>
      MockAnalysisData.getDailyInsight(date);

  String getWeeklyTheme(DateTime date) => MockAnalysisData.getWeeklyTheme(date);

  String getAffirmation(DateTime date) => MockAnalysisData.getAffirmation(date);

  String getPersonalDailyInsight({
    required String name,
    required DateTime date,
    required DateTime birthDate,
    required List<int> pinCode,
    required ElementBalance elementBalance,
    String? focusText,
  }) {
    final dayIndex = (date.day + date.month + date.year) % pinCode.length;
    final dayDigit = pinCode[dayIndex];
    final birthDateText =
        '${birthDate.day.toString().padLeft(2, '0')}.${birthDate.month.toString().padLeft(2, '0')}.${birthDate.year}';
    final elementMessage = _elementMessage(elementBalance.dominantElement);
    final weakMessage = _weakElementMessage(elementBalance.weakestElement);
    final energyMessage = _energyMessage(elementBalance.energyType);
    final focus = (focusText ?? '').trim();
    final dailyPulse = getDailyInsight(date);

    return [
      'Bugünün ritmi: $dailyPulse',
      '$name, $birthDateText doğum tarihinden çıkan pin haritanda bugün $dayDigit enerjisi öne çıkıyor. $elementMessage',
      energyMessage,
      weakMessage,
      if (focus.isNotEmpty) _shortFocus(focus),
    ].join(' ');
  }

  String getPersonalWeeklyTheme({
    required DateTime date,
    required ElementBalance elementBalance,
  }) {
    final weeklyTheme = getWeeklyTheme(date);
    return '$weeklyTheme. Pin haritana göre ${elementBalance.dominantElement} enerjini dengeli kullanırken ${elementBalance.weakestElement} tarafına bilinçli alan aç.';
  }

  String getPersonalAffirmation({
    required String name,
    required DateTime date,
    required ElementBalance elementBalance,
  }) {
    final affirmation = getAffirmation(date);
    final personalAnchor = switch (elementBalance.energyType) {
      'Baskın' => 'Gücümü sakinlikle yönlendiriyorum.',
      'Edilgen' =>
        'Kendi sesime alan açıyor ve ihtiyaçlarımı net ifade ediyorum.',
      _ => 'İçimdeki dengeye güveniyorum.',
    };

    return '$name, $affirmation $personalAnchor';
  }

  String _elementMessage(String element) {
    switch (element) {
      case 'Hava':
        return 'Zihnin hızlı çalışabilir, kararlarını netleştirirken gereksiz düşünce kalabalığını sadeleştirmen iyi gelir.';
      case 'Su':
        return 'Duyguların bugün sana güçlü sinyaller verebilir, hislerini bastırmadan ama onlara kapılmadan ilerle.';
      case 'Ateş':
        return 'Motivasyonun ve hareket isteğin yüksek olabilir, enerjini tek bir net adıma yöneltmek seni güçlendirir.';
      case 'Toprak':
        return 'Somut düzen, plan ve pratik adımlar bugün sana güven verir, küçük bir işi tamamlamak zihnini de rahatlatır.';
      default:
        return 'Bugün dengeyi korumak, acele kararlar yerine içindeki ritmi dinlemek önemli.';
    }
  }

  String _weakElementMessage(String element) {
    switch (element) {
      case 'Hava':
        return 'Zayıf hava alanın için bugün bir konuyu açıkça konuşmak veya yazıya dökmek iyi gelir.';
      case 'Su':
        return 'Zayıf su alanın için bugün ne hissettiğini fark etmek ve bunu yargılamadan kabul etmek önemli.';
      case 'Ateş':
        return 'Zayıf ateş alanın için bugün ertelediğin küçük bir adımı başlatmak enerjini toparlar.';
      case 'Toprak':
        return 'Zayıf toprak alanın için bugün bedenine, rutinine ve tamamlanabilir işlere dönmek iyi gelir.';
      default:
        return 'Eksik hissettiğin tarafı zorlamak yerine ona küçük ve nazik bir alan aç.';
    }
  }

  String _energyMessage(String energyType) {
    switch (energyType) {
      case 'Baskın':
        return 'Baskın enerji yapın bugün inisiyatif almak isteyebilir, ama gücünü yumuşak bir dille göstermek ilişkilerini rahatlatır.';
      case 'Edilgen':
        return 'Edilgen enerji yapın bugün uyumlanmaya yatkın olabilir, ama kendi ihtiyacını ertelememeye dikkat et.';
      default:
        return 'Dengeli enerji yapın bugün hem dinlemeyi hem karar almayı destekliyor, ölçülü ilerlemek sana iyi gelir.';
    }
  }

  String _shortFocus(String text) {
    final sentence = text
        .split(RegExp(r'(?<=[.!?])\s+'))
        .firstWhere((part) => part.trim().isNotEmpty, orElse: () => text)
        .trim();
    return sentence.length <= 160
        ? 'Bugünün kişisel ipucu: $sentence'
        : 'Bugünün kişisel ipucu: ${sentence.substring(0, 160).trim()}...';
  }
}
