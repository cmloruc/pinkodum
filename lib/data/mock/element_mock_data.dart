import '../models/element_balance.dart';
import '../services/element_balance_calculator.dart';

/// Element haritası için mock yorum metinleri.
/// İleride AI API'ye geçildiğinde bu veriler prompt'a eklenir.
class ElementMockData {
  ElementMockData._();

  // ─── Tek kişi element yorumu ────────────────────────────────────────────────
  static String personalElementInsight(String name, ElementBalance e) {
    final dominantText = _dominantElementText[e.dominantElement] ?? '';
    final weakText = _weakElementText[e.weakestElement] ?? '';
    final energyText = _energyTypeText[e.energyType] ?? '';
    return '$name, $dominantText $energyText $weakText';
  }

  static const Map<String, String> _dominantElementText = {
    ElementBalanceCalculator.elementAir:
        'pin kodunda Hava elementi öne çıkıyor. '
        'Bu, zihinsel hareketliliğinin, gözlem gücünün ve iletişim ihtiyacının güçlü olduğunu gösteriyor. '
        'Fikirleri hızla işliyor, bağlantılar kuruyorsun ve çevrendeki değişimleri erkenden seziyorsun.',
    ElementBalanceCalculator.elementWater:
        'pin kodunda Su elementi öne çıkıyor. '
        'Bu, duygusal derinliğinin, sezgisel gücünün ve empati kapasitesinin belirleyici olduğunu gösteriyor. '
        'Hissederek anlıyorsun; insanların söylemediklerini bile fark edebiliyorsun.',
    ElementBalanceCalculator.elementFire:
        'pin kodunda Ateş elementi öne çıkıyor. '
        'Bu, içindeki tutkuyu, harekete geçme enerjisini ve ilham verme gücünü yansıtıyor. '
        'Bir şeye inandığında tüm enerjinle arkasında duruyorsun.',
    ElementBalanceCalculator.elementEarth:
        'pin kodunda Toprak elementi öne çıkıyor. '
        'Bu, pratik zekanını, sabır ve kararlılığını, sağlam temeller kurma içgüdünü gösteriyor. '
        'Güvenilir, tutarlı ve gerçekçi bir enerji taşıyorsun.',
  };

  static const Map<String, String> _energyTypeText = {
    ElementBalanceCalculator.energyDominant:
        'Baskın enerjin yüksek olduğu için hayatta beklemekten çok harekete geçmeye, '
        'karar almaya ve yön vermeye yatkınsın.',
    ElementBalanceCalculator.energyPassive:
        'Edilgen enerjin belirgin olduğu için dinlemeye, gözlemlemeye ve '
        'uyum sağlamaya doğal bir yatkınlığın var.',
    ElementBalanceCalculator.energyBalanced:
        'Baskın ve edilgen enerjin dengeli dağılmış; '
        'hem harekete geçebiliyor hem de durumu okuyabiliyorsun.',
  };

  static const Map<String, String> _weakElementText = {
    ElementBalanceCalculator.elementAir:
        'Hava elementi daha düşük olduğu için zaman zaman düşüncelerini '
        'netleştirmek ya da iletişimi akıcı tutmak biraz daha çaba gerektirebilir.',
    ElementBalanceCalculator.elementWater:
        'Su elementi daha düşük olduğu için bazen duygularını açıkça göstermek yerine '
        'önce mantıkla çözmeye çalışabilirsin. Duygusal ifadeye biraz daha alan açmak seni dengeleyebilir.',
    ElementBalanceCalculator.elementFire:
        'Ateş elementi daha düşük olduğu için tutku ve motivasyonu sürdürmek '
        'zaman zaman zorlanabilir. Seni gerçekten ateşleyen şeylere daha fazla yer açmak işe yarıyor.',
    ElementBalanceCalculator.elementEarth:
        'Toprak elementi daha düşük olduğu için bazen temelleri sağlamlaştırmak, '
        'sabırla ilerlemek ve somut adımlar atmak biraz daha çaba gerektirebilir.',
  };

  // ─── İlişki element uyumu yorumu ────────────────────────────────────────────
  static String relationshipElementInsight(
    String name1,
    String name2,
    ElementBalance e1,
    ElementBalance e2,
  ) {
    final sameElement = e1.dominantElement == e2.dominantElement;
    final energyCombo = '${e1.energyType}-${e2.energyType}';

    final elementNote = sameElement
        ? _sameElementNote(name1, name2, e1.dominantElement)
        : _differentElementNote(name1, name2, e1.dominantElement, e2.dominantElement);

    final energyNote = _energyComboNote(energyCombo, name1, name2);

    return '$elementNote\n\n$energyNote';
  }

  static String _sameElementNote(String n1, String n2, String element) {
    return '$n1 ve $n2\'nın ikisinde de $element elementi baskın. '
        'Ortak enerji güçlü; benzer şekilde tepki veriyor, benzer ihtiyaçlar taşıyorsunuz. '
        'Hızlı anlaşma potansiyeliniz yüksek, ama aynı zayıf yönleri birlikte büyütme riski de var. '
        'Birbirinizin zayıf noktalarında sabırlı olmak bu ilişkiyi güçlendirecek.';
  }

  static String _differentElementNote(
      String n1, String n2, String el1, String el2) {
    return '$n1\'ın $el1 elementi güçlü çalışırken, $n2\'nın $el2 elementi daha belirgin. '
        'Bu fark sizi zorlamak yerine tamamlayıcı bir dengeye dönüşebilir — '
        'biri düşünerek diğeri hissederek, biri harekete geçerek diğeri köklenerek ilerlediğinde '
        'birbirinizin eksik kaldığı yerleri kapatıyorsunuz. '
        'Birbirinizin ritmine alan tanımak bu dinamiği güzelleştiriyor.';
  }

  static String _energyComboNote(String combo, String n1, String n2) {
    switch (combo) {
      case 'Baskın-Baskın':
        return '$n1 ve $n2: İlişkide güçlü çekim ve yüksek hareket var. '
            'Karar alma, yön belirleme ve bazen inatlaşma konularında dikkat gerekebilir. '
            'Enerjilerinizi ortak bir hedefe yönelttiğinizde inanılmaz şeyler yaratabilirsiniz.';
      case 'Edilgen-Edilgen':
        return '$n1 ve $n2: İlişkide anlayış ve uyum güçlü. '
            'Ancak karar almak, adım atmak ve netleşmek zaman zaman bekleyebilir. '
            'Birbirinizi nazikçe harekete geçirmek bu bağa güzel bir denge katıyor.';
      case 'Dengeli-Dengeli':
        return '$n1 ve $n2: İlişkide karşılıklı alan tanıyan, uyumlu ve esnek bir yapı var. '
            'İkisinin de hem harekete geçebildiği hem de beklemeyi bilebildiği bu denge, '
            'uzun vadeli ilişkiler için çok değerli bir zemin.';
      case 'Baskın-Edilgen':
      case 'Edilgen-Baskın':
        return '$n1 ve $n2: İlişkide bir taraf daha çok yön veren, diğeri daha çok uyumlanan rolde kalabilir. '
            'Bu denge doğru kurulursa mükemmel tamamlayıcılık yaratır; '
            'önemli olan her iki tarafın da seçtiği rolde özgür hissetmesi.';
      case 'Baskın-Dengeli':
      case 'Dengeli-Baskın':
        return '$n1 ve $n2: Bir tarafın güçlü inisiyatifi ile diğerinin dengeli yaklaşımı '
            'bu ilişkide çok güzel bir ritim oluşturuyor. '
            'Hareket ve istikrar bir arada — bu nadir bir kombinasyon.';
      case 'Edilgen-Dengeli':
      case 'Dengeli-Edilgen':
        return '$n1 ve $n2: Dengeli enerji ile uyumlu yaklaşım bir arada. '
            'Bu ilişkide derin anlayış ve sıcaklık hâkim. '
            'Zaman zaman dışarıdan bir motivasyon ikinizi de harekete geçirebilir.';
      default:
        return '$n1 ve $n2\'nın enerji dinamiği, birbirini tamamlayan güzel bir denge taşıyor.';
    }
  }

  // ─── İlişki ortak/tamamlayıcı/sürtünme alanları ─────────────────────────────
  static String sharedStrength(ElementBalance e1, ElementBalance e2) {
    // En yüksek ortak element
    final maxShared = <String, int>{};
    maxShared['Hava'] = e1.air + e2.air;
    maxShared['Su'] = e1.water + e2.water;
    maxShared['Ateş'] = e1.fire + e2.fire;
    maxShared['Toprak'] = e1.earth + e2.earth;
    final best =
        maxShared.entries.reduce((a, b) => a.value > b.value ? a : b);
    return '${best.key} (toplam ${best.value})';
  }

  static String complementaryElements(ElementBalance e1, ElementBalance e2) {
    if (e1.dominantElement != e2.dominantElement) {
      return '${e1.dominantElement} & ${e2.dominantElement} — birbirini tamamlıyor';
    }
    return 'Ortak ${e1.dominantElement} enerjisi güçlü bir sinerji oluşturuyor';
  }

  static String frictionArea(ElementBalance e1, ElementBalance e2) {
    // En büyük fark olan element = potansiyel sürtünme
    final diffs = {
      'Hava': (e1.air - e2.air).abs(),
      'Su': (e1.water - e2.water).abs(),
      'Ateş': (e1.fire - e2.fire).abs(),
      'Toprak': (e1.earth - e2.earth).abs(),
    };
    final maxDiff =
        diffs.entries.reduce((a, b) => a.value > b.value ? a : b);
    if (maxDiff.value == 0) return 'Belirgin bir element farkı yok';
    return '${maxDiff.key} — bu alanda farklı yaklaşımlar olabilir';
  }
}
