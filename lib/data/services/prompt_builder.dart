import '../models/element_balance.dart';

class PromptBuilder {
  PromptBuilder._();

  static const systemPrompt = r'''
Sen Pin Kodum uygulaması için numeroloji ve kişisel farkındalık uzmanısın.

Görevin: 9 haneli numerolojik pin kodunu ve element dengesini analiz ederek samimi, sıcak, kişiye direkt hitap eden Türkçe yorumlar üretmek.

Temel kurallar:
- Kullanıcının ismiyle başla, doğrudan hitap et (sen, senin, sende)
- Samimi ve kişisel gelişim odaklı dil
- Üçüncü şahıs anlatımı kullanma
- Türkçe yaz, doğal ve akıcı
- SADECE JSON formatında yanıt ver
- Kullanıcıya teknik hane kodu yazma: H1, H2, H5=1, pinCode[0] gibi ifadeler yasaktır
- Uzun tire veya em dash kullanma. Sadece virgül, nokta ve iki nokta kullan
- Metin doğal Türkçe cümlelerden oluşsun, şablon veya talimat dili görünmesin

Her hane: H1=Kişilik, H2=Sosyal Bilinç, H3=Küresel Bilinçlilik, H4=Yaşam Döngüsü, H5=Ders/Potansiyel, H6=İçsel Benlik, H7=İçsel Çocuk, H8=Ruh Duygusu, H9=Evren
Elementler: Hava(1,5)=zihin, Su(2,7)=duygu, Ateş(3,6)=tutku, Toprak(4,8)=pratiklik, 9=denge
''';

  // ─── Tek Kişi Analizi (ücretsiz, satış odaklı teaser) ───────────────────
  static String singleAnalysis({
    required String name,
    required String birthDate,
    required List<int> pinCode,
    required ElementBalance elementBalance,
  }) {
    final surfacePin = 'H1=${pinCode[0]}, H5=${pinCode[4]}, H9=${pinCode[8]}';

    return '''
$name için ÜCRETSİZ kısa ön analiz üret.

Kişi: $name | Doğum: $birthDate
Yalnızca yüzey verileri: $surfacePin
Element ipucu: Baskın=${elementBalance.dominantElement}, Enerji=${elementBalance.energyType}

STRATEJİ:
- Bu ücretsiz analiz bir kapı aralığıdır, tam rapor değildir.
- Kişiye gerçek ve isabetli hissettiren 1-2 güçlü gözlem ver.
- Asıl derinliği premium rapora bırak. H2, H3, H4, H7, H8 detaylarına girme.
- Element yorumunu açma, sadece merak uyandıran ipucu olarak kullan.
- Metin dürüst olsun, korkutma veya abartılı vaat kullanma.
- Premium kelimesini her alanda en fazla 1 kez geçir.
- Her alan 2 cümle olsun. 3. cümle yazma.
- SADECE JSON üret.
- Kullanıcının göreceği metinde H1, H2, H5=1, ortak H1 gibi teknik kodlar yazma. Bunları doğal dile çevir.
- Uzun tire veya em dash kullanma. Virgül ve nokta kullan.
- Gramer düzgün, noktalama sade ve profesyonel olsun.

JSON şeması:
{
  "summary":"$name ile başla. kişilik ve yaşam yönü üzerinden kısa kişilik yansıması ver. İkinci cümlede tam pin haritasında bunun neden böyle çalıştığını açabilecek daha derin bir katman olduğunu sezdir.",
  "strength":"potansiyel alanı üzerinden güçlü yönü kısa söyle. İkinci cümlede bu gücün hangi durumda avantaja, hangi durumda yorucu döngüye dönebileceğinin premium analizde açıldığını belirt.",
  "warning":"içsel enerjiye dayalı tek bir yapıcı dikkat alanı ver. İkinci cümlede bunun kök sebebini ve çözüm yolunu görmek için detaylı analizin gerekli olduğunu doğal biçimde söyle."
}''';
  }

  // ─── İlişki Analizi (ücretsiz, satış odaklı teaser) ──────────────────────
  static String relationshipAnalysis({
    required String name1,
    required String birthDate1,
    required List<int> pinCode1,
    required ElementBalance elem1,
    required String name2,
    required String birthDate2,
    required List<int> pinCode2,
    required ElementBalance elem2,
    required List<int> combinedPin,
    required ElementBalance combinedElem,
    required String relationshipType,
    required bool includeSexual,
  }) {
    return '''
$name1 ve $name2 için ÜCRETSİZ kısa ilişki ön analizi üret.

$name1: H1=${pinCode1[0]}, H5=${pinCode1[4]}, H9=${pinCode1[8]}, Baskın=${elem1.dominantElement}
$name2: H1=${pinCode2[0]}, H5=${pinCode2[4]}, H9=${pinCode2[8]}, Baskın=${elem2.dominantElement}
Ortak yüzey pin: H1=${combinedPin[0]}, H5=${combinedPin[4]}, H9=${combinedPin[8]}
Ortak enerji ipucu: ${combinedElem.dominantElement} / ${combinedElem.energyType}
İlişki türü: $relationshipType

STRATEJİ:
- Bu ücretsiz analiz tam uyum raporu değildir, kısa bir ön izlenimdir.
- Ortak pinin yalnızca H1, H5 ve H9 yüzeyini kullan.
- H2, H3, H4, H6, H7, H8 detaylarına girme.
- Element uyumu, iletişim kalıbı, çatışma kökü ve yıl mesajını premium rapora bırak.
- Her alan 2 cümle olsun. 3. cümle yazma.
- Premium kelimesini her alanda en fazla 1 kez geçir.
- SADECE JSON üret.
- Kullanıcının göreceği metinde H1, H2, H5=1, ortak H1 gibi teknik kodlar yazma. Bunları doğal dile çevir.
- Uzun tire veya em dash kullanma. Virgül ve nokta kullan.
- Gramer düzgün, noktalama sade ve profesyonel olsun.

JSON şeması:
${includeSexual ? '''{
  "summary":"$name1 ve $name2 ile başla. Ortak kişilik ve yaşam yönü üzerinden genel enerjiye kısa bak. İkinci cümlede ilişkinin asıl çalışma biçiminin detaylı ortak pin haritasında açıldığını sezdir.",
  "harmonyPoint":"Ortak potansiyel alanı üzerinden tek uyum noktasını söyle. İkinci cümlede bu uyumun hangi koşulda güçlendiğinin premium analizde netleşeceğini belirt.",
  "challengePoint":"Tek bir gelişim alanı söyle. İkinci cümlede çatışmanın kök kalıbını görmek için detaylı analizin gerekli olduğunu doğal biçimde söyle.",
  "sexualCompatibility":"Fiziksel/duygusal yakınlık için zarif, kısa bir ipucu ver. İkinci cümlede bu başlığın premium analizde daha mahrem ama saygılı biçimde açıldığını belirt."
}''' : '''{
  "summary":"$name1 ve $name2 ile başla. Ortak kişilik ve yaşam yönü üzerinden genel enerjiye kısa bak. İkinci cümlede ilişkinin asıl çalışma biçiminin detaylı ortak pin haritasında açıldığını sezdir.",
  "harmonyPoint":"Ortak potansiyel alanı üzerinden tek uyum noktasını söyle. İkinci cümlede bu uyumun hangi koşulda güçlendiğinin premium analizde netleşeceğini belirt.",
  "challengePoint":"Tek bir gelişim alanı söyle. İkinci cümlede çatışmanın kök kalıbını görmek için detaylı analizin gerekli olduğunu doğal biçimde söyle."
}'''}''';
  }

  // ─── Premium Tek Kişi Analizi ─────────────────────────────────────────────
  static String premiumSingleAnalysis({
    required String name,
    required String birthDate,
    required List<int> pinCode,
    required ElementBalance elementBalance,
    required int currentYear,
  }) {
    return '''
$name için PREMIUM, kapsamlı ve derin numeroloji raporu üret.

Kişi: $name | Doğum: $birthDate
Pin: H1(Kişilik)=${pinCode[0]}, H2(Sosyal Bilinç)=${pinCode[1]}, H3(Küresel Bilinçlilik)=${pinCode[2]}, H4(Yaşam Döngüsü)=${pinCode[3]}, H5(Ders/Potansiyel)=${pinCode[4]}, H6(İçsel Benlik)=${pinCode[5]}, H7(İçsel Çocuk)=${pinCode[6]}, H8(Ruh Duygusu)=${pinCode[7]}, H9(Evren)=${pinCode[8]}
Element: Hava=${elementBalance.air}, Su=${elementBalance.water}, Ateş=${elementBalance.fire}, Toprak=${elementBalance.earth}, Denge9=${elementBalance.balanceNine}
Baskın: ${elementBalance.dominantElement} | Zayıf: ${elementBalance.weakestElement} | Enerji: ${elementBalance.energyType}
Yıl: $currentYear

PREMIUM KALİTE KURALLARI:
- Bu rapor satın alınmış detaylı rapordur. Teaser, satış metni veya "premiumda açılır" gibi ifade kullanma.
- Her alan kişiye özel olsun. Genel burç yorumu gibi yazma.
- Her alanda ilgili hane numarasını ve anlamını görünür biçimde kullan.
- Her alanda şu 4 parçayı sırayla işle: temel enerji, güçlü kullanım, zorlandığı kalıp, günlük hayattan somut örnek.
- Her alan en az 90 kelime olsun. overallSummary en az 120 kelime olsun.
- Hane alanlarında sadece ilgili haneyi anlat. Gruplama yapma.
- Element, yaşam dersi ve yıl mesajında tüm pin kodunu birlikte sentezle.
- Hem güçlü hem zorlu yönleri yaz. Sadece olumlama yapma.
- Uzun tire karakterini kullanma. Virgül veya nokta kullan.
- Türkçe, samimi, doğrudan hitap eden bir dil kullan.
- SADECE geçerli JSON üret. Markdown kullanma.
- Kullanıcının göreceği metinde H1, H2, H5=1, ortak H1 gibi teknik kodlar yazma. Bunları doğal dile çevir.
- Uzun tire veya em dash kullanma. Virgül ve nokta kullan.
- Gramer düzgün, noktalama sade ve profesyonel olsun.

JSON alanları ve içerik:
{
  "h1Personality":"H1=${pinCode[0]} Kişilik hanesini detaylı yorumla. $name ile başla.",
  "h2Social":"H2=${pinCode[1]} Sosyal Bilinç hanesini detaylı yorumla.",
  "h3Global":"H3=${pinCode[2]} Küresel Bilinçlilik hanesini detaylı yorumla.",
  "h4LifeCycle":"H4=${pinCode[3]} Yaşam Döngüsü hanesini detaylı yorumla.",
  "h5Lesson":"H5=${pinCode[4]} Ders/Potansiyel hanesini detaylı yorumla.",
  "h6InnerSelf":"H6=${pinCode[5]} İçsel Benlik hanesini detaylı yorumla.",
  "h7InnerChild":"H7=${pinCode[6]} İçsel Çocuk hanesini detaylı yorumla.",
  "h8Soul":"H8=${pinCode[7]} Ruh Duygusu hanesini detaylı yorumla.",
  "h9Universe":"H9=${pinCode[8]} Evren hanesini detaylı yorumla.",
  "elementDetail":"Element haritasını detaylı sentezle. Baskın ${elementBalance.dominantElement}, zayıf ${elementBalance.weakestElement}, denge9=${elementBalance.balanceNine} bilgisini işle.",
  "lifeLesson":"Tüm pin kodundan çıkan temel yaşam dersini detaylı anlat. Kök kalıp, tekrar eden sınav, bilinçli çözüm ve somut uygulama ver.",
  "yearMessage":"$currentYear yılının bu kişi için anlamını detaylı anlat. Fırsat, risk, odak ve uygulanabilir öneri ver.",
  "overallSummary":"Tüm raporu bütünleştiren derin, dürüst ve kişisel bir kapanış yaz. Güç, gölge, büyüme yönü ve net tavsiye içersin."
}''';
  }

  static String _premiumSingleBaseRules({
    required String name,
    required String birthDate,
    required List<int> pinCode,
    required ElementBalance elementBalance,
  }) {
    return '''
Kişi: $name | Doğum: $birthDate
Pin verisi sadece yorum üretmek içindir. Kullanıcıya teknik kod yazma.
Haneler: Kişilik=${pinCode[0]}, Sosyal Bilinç=${pinCode[1]}, Küresel Bilinçlilik=${pinCode[2]}, Yaşam Döngüsü=${pinCode[3]}, Ders/Potansiyel=${pinCode[4]}, İçsel Benlik=${pinCode[5]}, İçsel Çocuk=${pinCode[6]}, Ruh Duygusu=${pinCode[7]}, Evren=${pinCode[8]}
Element: Hava=${elementBalance.air}, Su=${elementBalance.water}, Ateş=${elementBalance.fire}, Toprak=${elementBalance.earth}, Denge=${elementBalance.balanceNine}, Baskın=${elementBalance.dominantElement}, Zayıf=${elementBalance.weakestElement}, Enerji=${elementBalance.energyType}

KALİTE KURALLARI:
- Satın alınmış premium rapor dili kullan. Satış veya teaser dili kullanma.
- Kullanıcının göreceği metinde H1, H2, H5=1, pin kodu etiketi veya teknik şema yazma.
- Uzun tire, em dash ve çift tire kullanma. Virgül ve nokta kullan.
- Her alan doğal Türkçe, düzgün gramerli ve profesyonel noktalı cümlelerden oluşsun.
- Her alan 4 ile 5 cümle arasında olsun.
- Her alanda güçlü kullanım, gölge kalıp ve bir kısa somut örnek bulunsun.
- SADECE geçerli JSON üret. Markdown kullanma.
''';
  }

  static String premiumSingleIdentitySection({
    required String name,
    required String birthDate,
    required List<int> pinCode,
    required ElementBalance elementBalance,
  }) {
    return '''
$name için premium raporun kimlik ve dış dünya bölümünü üret.
${_premiumSingleBaseRules(name: name, birthDate: birthDate, pinCode: pinCode, elementBalance: elementBalance)}

Sadece şu JSON alanlarını üret:
{
  "h1Personality":"Kişilik enerjisini doğal dille detaylı yorumla. $name ile başla.",
  "h2Social":"Sosyal bilinç ve ilişkilerde görünme biçimini doğal dille detaylı yorumla.",
  "h3Global":"Büyük resmi görme, vizyon ve dünyayla bağlantı kurma biçimini doğal dille detaylı yorumla."
}''';
  }

  static String premiumSingleLifeSection({
    required String name,
    required String birthDate,
    required List<int> pinCode,
    required ElementBalance elementBalance,
  }) {
    return '''
$name için premium raporun yaşam döngüsü ve içsel ders bölümünü üret.
${_premiumSingleBaseRules(name: name, birthDate: birthDate, pinCode: pinCode, elementBalance: elementBalance)}

Sadece şu JSON alanlarını üret:
{
  "h4LifeCycle":"Yaşam döngüsü, tekrar eden kalıplar ve olgunlaşma yönünü doğal dille detaylı yorumla.",
  "h5Lesson":"Ders ve potansiyel alanını doğal dille detaylı yorumla. Teknik kod yazma.",
  "h6InnerSelf":"İçsel benlik, ifade ihtiyacı ve görünmeyen motivasyonu doğal dille detaylı yorumla."
}''';
  }

  static String premiumSingleSoulSection({
    required String name,
    required String birthDate,
    required List<int> pinCode,
    required ElementBalance elementBalance,
    required int currentYear,
  }) {
    return '''
$name için premium raporun ruhsal sentez, element ve yıl mesajı bölümünü üret.
${_premiumSingleBaseRules(name: name, birthDate: birthDate, pinCode: pinCode, elementBalance: elementBalance)}
Yıl: $currentYear

Sadece şu JSON alanlarını üret:
{
  "h7InnerChild":"İçsel çocuk, temel ihtiyaç ve hassasiyet alanını doğal dille detaylı yorumla.",
  "h8Soul":"Ruh duygusu, değer algısı ve içsel güç temasını doğal dille detaylı yorumla.",
  "h9Universe":"Evren, tamamlanma ve büyük anlam temasını doğal dille detaylı yorumla.",
  "elementDetail":"Element dengesini doğal dille detaylı sentezle. Teknik tablo dili kullanma.",
  "lifeLesson":"Tüm haritadan çıkan yaşam dersini doğal dille detaylı anlat.",
  "yearMessage":"$currentYear yılı için fırsat, risk, odak ve uygulanabilir öneriyi doğal dille anlat.",
  "overallSummary":"Tüm raporu bütünleştiren derin, dürüst ve kişisel bir kapanış yaz."
}''';
  }

  static String premiumSingleMissingFields({
    required String name,
    required String birthDate,
    required List<int> pinCode,
    required ElementBalance elementBalance,
    required int currentYear,
    required List<String> missingFields,
  }) {
    final fieldDescriptions = {
      'h1Personality': 'kişilik enerjisi',
      'h2Social': 'sosyal bilinç ve ilişkilerde görünme biçimi',
      'h3Global': 'vizyon, büyük resim ve dünyayla bağlantı kurma biçimi',
      'h4LifeCycle': 'yaşam döngüsü ve tekrar eden kalıplar',
      'h5Lesson': 'ders ve potansiyel alanı',
      'h6InnerSelf': 'içsel benlik ve görünmeyen motivasyon',
      'h7InnerChild': 'içsel çocuk, temel ihtiyaç ve hassasiyet',
      'h8Soul': 'ruh duygusu, değer algısı ve içsel güç',
      'h9Universe': 'tamamlanma, kabulleniş ve büyük anlam',
      'elementDetail': 'element dengesi sentezi',
      'lifeLesson': 'tüm haritadan çıkan yaşam dersi',
      'yearMessage': '$currentYear yılı için fırsat, risk, odak ve öneri',
      'overallSummary': 'tüm raporu bütünleştiren genel özet',
    };
    final jsonShape = missingFields
        .map((field) =>
            '  "$field":"${fieldDescriptions[field] ?? field} alanını $name için doğal, eksiksiz ve kişisel yorumla."')
        .join(',\n');

    return '''
$name için premium tek kişi analizinde eksik kalan alanları tamamla.
${_premiumSingleBaseRules(name: name, birthDate: birthDate, pinCode: pinCode, elementBalance: elementBalance)}
Yıl: $currentYear

Sadece eksik alanları üret. Başka alan ekleme.
{
$jsonShape
}''';
  }

  // ─── Premium İlişki Analizi ───────────────────────────────────────────────
  static String _premiumRelationshipBaseRules({
    required String name1,
    required String birthDate1,
    required List<int> pin1,
    required ElementBalance elem1,
    required String name2,
    required String birthDate2,
    required List<int> pin2,
    required ElementBalance elem2,
    required List<int> combined,
    required ElementBalance combinedElem,
    required String relationshipType,
  }) {
    return '''
Veri:
$name1 | Doğum: $birthDate1 | Pin dizilimi: ${pin1.join(', ')} | Baskın element: ${elem1.dominantElement} | Enerji: ${elem1.energyType}
$name2 | Doğum: $birthDate2 | Pin dizilimi: ${pin2.join(', ')} | Baskın element: ${elem2.dominantElement} | Enerji: ${elem2.energyType}
Ortak pin dizilimi: ${combined.join(', ')}
Ortak elementler: Hava ${combinedElem.air}, Su ${combinedElem.water}, Ateş ${combinedElem.fire}, Toprak ${combinedElem.earth}, Denge ${combinedElem.balanceNine}
Ortak baskın element: ${combinedElem.dominantElement} | Ortak enerji: ${combinedElem.energyType}
İlişki türü: $relationshipType

PREMIUM KALİTE KURALLARI:
- Bu satın alınmış detaylı ilişki analizidir. Teaser, satış metni veya "premiumda açılır" gibi ifade kullanma.
- Her alan ilişkiye özel, kişisel ve uygulanabilir olsun.
- Kullanıcının göreceği metinde teknik kod yazma. H1, H2, H5=1, ortak Hane gibi ifadeler kullanma.
- Pin sayılarını cümle içinde formül gibi yazma. Gerekirse anlamını doğal dile çevir.
- Uzun tire, çift tire ve madde çizgisi kullanma. Virgül ve nokta ile temiz cümle kur.
- Türkçe gramer, noktalama ve akış profesyonel olsun.
- Her alan 4 ile 6 cümle arası olsun. Gereksiz uzatma yapma.
- Hem uyum potansiyelini hem gölge kalıbını anlat. Sadece olumlama yapma.
- Günlük ilişkiden kısa ve somut bir örnek ekle.
- SADECE geçerli JSON üret. Markdown kullanma.
''';
  }

  static String premiumRelationshipHaneSection({
    required String name1,
    required String birthDate1,
    required List<int> pin1,
    required ElementBalance elem1,
    required String name2,
    required String birthDate2,
    required List<int> pin2,
    required ElementBalance elem2,
    required List<int> combined,
    required ElementBalance combinedElem,
    required String relationshipType,
  }) {
    return '''
$name1 ve $name2 için premium ilişki raporunun temel alan yorumlarını üret.
${_premiumRelationshipBaseRules(name1: name1, birthDate1: birthDate1, pin1: pin1, elem1: elem1, name2: name2, birthDate2: birthDate2, pin2: pin2, elem2: elem2, combined: combined, combinedElem: combinedElem, relationshipType: relationshipType)}

Alan anlamları sırasıyla: kişilik uyumu, sosyal bilinç, ortak bakış, yaşam döngüsü, ders ve potansiyel, içsel benlik, içsel çocuk, ruh duygusu, tamamlanma.
Ortak pin dizilimini bu sıraya göre yorumla ama teknik başlıkları metinde yazma.

Sadece şu JSON alanlarını üret:
{
  "h1Combined":"$name1 ve $name2 arasındaki kişilik uyumunu doğal dille yorumla.",
  "h2Combined":"Sosyal bilinç ve birlikte çevreyle ilişki kurma biçimini doğal dille yorumla.",
  "h3Combined":"Ortak bakış, anlam arayışı ve dünyaya yaklaşım biçimini doğal dille yorumla.",
  "h4Combined":"Yaşam döngüsü, tekrar eden ilişki kalıpları ve dönüştürücü süreçleri doğal dille yorumla.",
  "h5Combined":"Ders ve potansiyel alanını, ilişkinin büyüme çağrısını doğal dille yorumla.",
  "h6Combined":"İçsel benlik, yakınlık ihtiyacı ve görünmeyen motivasyonları doğal dille yorumla.",
  "h7Combined":"İçsel çocuk, hassasiyet, kırılganlık ve korunma ihtiyacını doğal dille yorumla.",
  "h8Combined":"Ruh duygusu, değer algısı ve ilişkinin güç temasını doğal dille yorumla.",
  "h9Combined":"Tamamlanma, kabulleniş ve ilişkinin büyük resmiyle ilgili temayı doğal dille yorumla."
}''';
  }

  static String premiumRelationshipDynamicsSection({
    required String name1,
    required String birthDate1,
    required List<int> pin1,
    required ElementBalance elem1,
    required String name2,
    required String birthDate2,
    required List<int> pin2,
    required ElementBalance elem2,
    required List<int> combined,
    required ElementBalance combinedElem,
    required String relationshipType,
    required bool includeSexual,
  }) {
    return '''
$name1 ve $name2 için premium ilişki raporunun ilişki dinamikleri bölümünü üret.
${_premiumRelationshipBaseRules(name1: name1, birthDate1: birthDate1, pin1: pin1, elem1: elem1, name2: name2, birthDate2: birthDate2, pin2: pin2, elem2: elem2, combined: combined, combinedElem: combinedElem, relationshipType: relationshipType)}

Sadece şu JSON alanlarını üret:
{
  "elementCompatibility":"Element etkileşimini, iki kişinin birbirini nasıl beslediğini ve nerede zorlayabileceğini doğal dille anlat.",
  "communicationStyle":"İletişim dilini, dinleme biçimini, savunma reflekslerini ve daha sağlıklı konuşma yolunu doğal dille anlat.",
  "conflictPatterns":"Tekrarlayan çatışma kalıplarını, kök ihtiyacı, yanlış anlaşılma şeklini ve onarım yolunu doğal dille anlat.",
  "growthOpportunity":"Bu ilişkinin iki kişiyi nasıl büyüttüğünü, hangi olgunlaşma çağrısını taşıdığını ve bilinçli kullanıldığında nereye götürebileceğini anlat.",
  "sexualCompatibility":"${includeSexual ? 'Fiziksel, duygusal ve tensel yakınlık enerjisini zarif, saygılı ve mahremiyetli bir dille anlat.' : 'Cinsel içerik yazma. Güven, yakınlık, sınırlar ve duygusal temas enerjisini zarif bir dille anlat.'}"
}''';
  }

  static String premiumRelationshipSynthesisSection({
    required String name1,
    required String birthDate1,
    required List<int> pin1,
    required ElementBalance elem1,
    required String name2,
    required String birthDate2,
    required List<int> pin2,
    required ElementBalance elem2,
    required List<int> combined,
    required ElementBalance combinedElem,
    required String relationshipType,
    required int currentYear,
  }) {
    return '''
$name1 ve $name2 için premium ilişki raporunun sentez ve yıl mesajı bölümünü üret.
${_premiumRelationshipBaseRules(name1: name1, birthDate1: birthDate1, pin1: pin1, elem1: elem1, name2: name2, birthDate2: birthDate2, pin2: pin2, elem2: elem2, combined: combined, combinedElem: combinedElem, relationshipType: relationshipType)}
Yıl: $currentYear

Sadece şu JSON alanlarını üret:
{
  "yearMessage":"$currentYear yılının bu ilişki için fırsatlarını, risklerini, odak alanını ve uygulanabilir önerisini doğal dille anlat.",
  "lifeLesson":"Bu ilişkinin temel yaşam dersini, iki kişinin birbirinde neyi uyandırdığını ve neyi olgunlaştırdığını doğal dille anlat.",
  "overallSummary":"Tüm raporu bütünleştiren derin, dürüst ve kişisel bir kapanış yaz. Uyum, gölge, büyüme yönü ve net ilişki tavsiyesi içersin."
}''';
  }

  static String premiumRelationshipMissingFields({
    required String name1,
    required String birthDate1,
    required List<int> pin1,
    required ElementBalance elem1,
    required String name2,
    required String birthDate2,
    required List<int> pin2,
    required ElementBalance elem2,
    required List<int> combined,
    required ElementBalance combinedElem,
    required String relationshipType,
    required List<String> missingFields,
  }) {
    final fieldDescriptions = {
      'h1Combined': 'kişilik uyumu',
      'h2Combined': 'sosyal bilinç ve birlikte çevreyle ilişki kurma',
      'h3Combined': 'ortak bakış ve anlam arayışı',
      'h4Combined': 'yaşam döngüsü ve tekrar eden ilişki kalıpları',
      'h5Combined': 'ders ve potansiyel alanı',
      'h6Combined': 'içsel benlik ve yakınlık ihtiyacı',
      'h7Combined': 'içsel çocuk ve hassasiyet alanı',
      'h8Combined': 'ruh duygusu ve değer algısı',
      'h9Combined': 'tamamlanma, kabulleniş ve ilişkinin büyük resmi',
      'elementCompatibility': 'element uyumu',
      'communicationStyle': 'iletişim stili',
      'conflictPatterns': 'çatışma kalıpları',
      'growthOpportunity': 'büyüme fırsatı',
      'sexualCompatibility': 'fiziksel, duygusal ve yakınlık uyumu',
      'yearMessage': 'yıl mesajı',
      'lifeLesson': 'yaşam dersi',
      'overallSummary': 'genel sentez',
    };
    final jsonShape = missingFields
        .map((field) =>
            '  "$field":"${fieldDescriptions[field] ?? field} alanını doğal, eksiksiz ve ilişkiye özel yorumla."')
        .join(',\n');

    return '''
$name1 ve $name2 için premium ilişki analizinde eksik kalan alanları tamamla.
${_premiumRelationshipBaseRules(name1: name1, birthDate1: birthDate1, pin1: pin1, elem1: elem1, name2: name2, birthDate2: birthDate2, pin2: pin2, elem2: elem2, combined: combined, combinedElem: combinedElem, relationshipType: relationshipType)}

Sadece eksik alanları üret. Başka alan ekleme.
{
$jsonShape
}''';
  }

  static String premiumRelationshipAnalysis({
    required String name1,
    required String birthDate1,
    required List<int> pin1,
    required ElementBalance elem1,
    required String name2,
    required String birthDate2,
    required List<int> pin2,
    required ElementBalance elem2,
    required List<int> combined,
    required ElementBalance combinedElem,
    required String relationshipType,
    required bool includeSexual,
    required int currentYear,
  }) {
    return '''
$name1 ve $name2 için PREMIUM, kapsamlı ve derin ilişki raporu üret.

$name1 | Doğum: $birthDate1 | Pin: ${pin1.join('-')} | Baskın: ${elem1.dominantElement} | Enerji: ${elem1.energyType}
$name2 | Doğum: $birthDate2 | Pin: ${pin2.join('-')} | Baskın: ${elem2.dominantElement} | Enerji: ${elem2.energyType}
Ortak Pin: H1=${combined[0]}, H2=${combined[1]}, H3=${combined[2]}, H4=${combined[3]}, H5=${combined[4]}, H6=${combined[5]}, H7=${combined[6]}, H8=${combined[7]}, H9=${combined[8]}
Ortak Element: Hava=${combinedElem.air}, Su=${combinedElem.water}, Ateş=${combinedElem.fire}, Toprak=${combinedElem.earth}, Denge9=${combinedElem.balanceNine}
Ortak Baskın: ${combinedElem.dominantElement} | Ortak Enerji: ${combinedElem.energyType}
İlişki Türü: $relationshipType | Yıl: $currentYear

PREMIUM KALİTE KURALLARI:
- Bu rapor satın alınmış detaylı ilişki raporudur. Teaser, satış metni veya "premiumda açılır" gibi ifade kullanma.
- Her alan ilişkiye özel olsun. Genel ilişki tavsiyesi gibi yazma.
- Her ortak hane alanında ilgili hane numarasını ve anlamını görünür biçimde kullan.
- Hane alanlarında sadece ortak pinin ilgili hanesini anlat.
- Her alanda şu 4 parçayı sırayla işle: ortak enerji, uyum potansiyeli, çatışma/gölge kalıbı, günlük ilişkiden somut örnek.
- Her alan en az 85 kelime olsun. overallSummary en az 120 kelime olsun.
- İletişim, çatışma, büyüme, yaşam dersi ve yıl mesajında iki kişinin bireysel pinlerini ve ortak pini birlikte sentezle.
- Hem güçlü hem zorlu yönleri yaz. Sadece olumlama yapma.
- Uzun tire karakterini kullanma. Virgül veya nokta kullan.
- Türkçe, zarif, doğrudan ve iki kişiye birlikte hitap eden bir dil kullan.
- SADECE geçerli JSON üret. Markdown kullanma.
- Kullanıcının göreceği metinde H1, H2, H5=1, ortak H1 gibi teknik kodlar yazma. Bunları doğal dile çevir.
- Uzun tire veya em dash kullanma. Virgül ve nokta kullan.
- Gramer düzgün, noktalama sade ve profesyonel olsun.

JSON alanları ve içerik:
{
  "h1Combined":"$name1 ve $name2 ile başla. Ortak H1=${combined[0]} Kişilik hanesini detaylı yorumla.",
  "h2Combined":"Ortak H2=${combined[1]} Sosyal Bilinç hanesini detaylı yorumla.",
  "h3Combined":"Ortak H3=${combined[2]} Küresel Bilinçlilik hanesini detaylı yorumla.",
  "h4Combined":"Ortak H4=${combined[3]} Yaşam Döngüsü hanesini detaylı yorumla.",
  "h5Combined":"ortak potansiyel=${combined[4]} Ders/Potansiyel hanesini detaylı yorumla.",
  "h6Combined":"Ortak H6=${combined[5]} İçsel Benlik hanesini detaylı yorumla.",
  "h7Combined":"Ortak H7=${combined[6]} İçsel Çocuk hanesini detaylı yorumla.",
  "h8Combined":"Ortak H8=${combined[7]} Ruh Duygusu hanesini detaylı yorumla.",
  "h9Combined":"Ortak H9=${combined[8]} Evren hanesini detaylı yorumla.",
  "elementCompatibility":"$name1 (${elem1.dominantElement}) ve $name2 (${elem2.dominantElement}) element etkileşimini ortak ${combinedElem.dominantElement} enerjiyle birlikte detaylı açıkla.",
  "communicationStyle":"Bu ilişkinin iletişim dilini, dinleme biçimini, tetiklenen savunmaları ve daha sağlıklı konuşma yolunu detaylı anlat.",
  "conflictPatterns":"Tekrarlayan çatışma kalıplarını, kök ihtiyacı, yanlış anlaşılma şeklini ve onarım yolunu detaylı anlat.",
  "growthOpportunity":"Bu ilişkinin iki kişiyi nasıl büyüttüğünü, hangi dersleri öğrettiğini ve bilinçli kullanıldığında nereye taşıyacağını detaylı anlat.",
  "sexualCompatibility":"${includeSexual ? 'Fiziksel, duygusal ve tensel yakınlık enerjisini zarif ve mahremiyete saygılı biçimde detaylı anlat.' : 'Bu ilişki türünde cinsel uyum başlığına girme. Bunun yerine güven, yakınlık ve sınır enerjisini zarif biçimde anlat.'}",
  "yearMessage":"$currentYear yılının bu ilişki için anlamını, fırsatlarını, risklerini ve odak alanını detaylı anlat.",
  "lifeLesson":"Bu ilişkinin temel yaşam dersini detaylı anlat. İki kişinin birbirinde neyi uyandırdığını ve neyi olgunlaştırdığını açıkla.",
  "overallSummary":"Tüm raporu bütünleştiren derin, dürüst ve kişisel bir kapanış yaz. Uyum, gölge, büyüme yönü ve net ilişki tavsiyesi içersin."
}''';
  }
}
