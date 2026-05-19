class AppStrings {
  AppStrings._();

  // Uygulama
  static const String appName = 'Pin Kodum';
  static const String appTagline = 'Sayılarında gizli olan sırrı keşfet';

  // Onboarding
  static const List<String> onboardingTitles = [
    'Pin Kodunu Keşfet',
    'Kendini Daha İyi Tanı',
    'İçgörü Kazan',
  ];

  static const List<String> onboardingDescriptions = [
    'Doğum tarihin, sana özgü 9 haneli bir numerolojik pin kodu taşıyor. Bu kod, karakterinin derinliklerini yansıtıyor.',
    'Güçlü yönlerini, dikkat etmen gereken alanları ve ilişkilerindeki dinamikleri keşfet. Kendini anlamak, her şeyin başlangıcıdır.',
    'Günlük içgörüler, ilişki analizleri ve kişisel farkındalık raporlarıyla hayatına yeni bir perspektif katıyorsun.',
  ];

  static const String onboardingContinue = 'Devam Et';
  static const String onboardingSkip = 'Atla';
  static const String onboardingStart = 'Başla';

  // Ana Ekran
  static const String homeGreeting = 'Merhaba';
  static const String homeSubtitle = 'Bugün ne keşfetmek istersin?';
  static const String homeSingleAnalysis = 'Tek Kişi Analizi';
  static const String homeSingleAnalysisDesc = 'Kendi pin kodunu hesapla';
  static const String homeRelationshipAnalysis = 'İlişki Analizi';
  static const String homeRelationshipAnalysisDesc = 'İki kişi arasındaki enerjiyi keşfet';
  static const String homeDailyInsight = 'Günlük İçgörü';
  static const String homeDailyInsightDesc = 'Bugünkü mesajını al';
  static const String homeHistory = 'Geçmiş Analizler';
  static const String homeHistoryDesc = 'Önceki analizlerine bak';
  static const String homePremium = 'Premium';
  static const String homePremiumDesc = 'Detaylı analizleri aç';

  // Formlar
  static const String labelName = 'İsim';
  static const String labelBirthDate = 'Doğum Tarihi';
  static const String labelSelectDate = 'Tarih Seç';
  static const String labelRelationshipType = 'İlişki Türü';
  static const String labelPerson1 = '1. Kişi';
  static const String labelPerson2 = '2. Kişi';

  static const String btnCalculate = 'Pin Kodumu Hesapla';
  static const String btnCalculateRelationship = 'İlişki Kodunu Hesapla';
  static const String btnOpenDetailed = 'Detaylı Analizi Aç';
  static const String btnOpenRelationshipDetailed = 'Detaylı İlişki Analizini Aç';
  static const String btnSaveToHistory = 'Geçmişe Kaydet';
  static const String btnSaved = 'Kaydedildi ✓';
  static const String btnNewAnalysis = 'Yeni Analiz';

  // Validasyon
  static const String validationNameRequired = 'İsim boş bırakılamaz';
  static const String validationDateRequired = 'Doğum tarihi seçilmelidir';
  static const String validationFutureDate = 'Gelecek tarih seçilemez';
  static const String validationRelationshipRequired = 'İlişki türü seçilmelidir';

  // Analiz Sonucu
  static const String resultPinCode = 'Pin Kodun';
  static const String resultPersonality = 'Kişilik Özeti';
  static const String resultStrength = 'Güçlü Yönün';
  static const String resultWarning = 'Dikkat Edilmesi Gereken';
  static const String resultRelationshipEnergy = 'İlişki Enerjisi';
  static const String resultHarmony = 'Uyumlu Taraf';
  static const String resultChallenge = 'Zorlayıcı Alan';

  // İlişki Türleri
  static const List<String> relationshipTypes = [
    'Sevgili / Flört',
    'Evlilik / Eş',
    'Eski İlişki',
    'Arkadaşlık',
    'Aile İlişkisi',
    'İş Ortaklığı',
    'Anne - Çocuk',
    'Baba - Çocuk',
    'Diğer',
  ];

  // Geçmiş
  static const String historySingleTab = 'Tek Kişi';
  static const String historyRelationshipTab = 'İlişki';
  static const String historyEmpty = 'Henüz analiz yapılmadı';
  static const String historyEmptyDesc = 'İlk analizini yapmak için ana sayfaya dön';

  // Premium
  static const String premiumTitle = 'Premium\'a Geç';
  static const String premiumSubtitle = 'Detaylı analizlerle kendini daha derinlemesine keşfet';
  static const String premiumSingleDetail = 'Tek Kişi Detaylı Analiz';
  static const String premiumRelationshipDetail = 'İlişki Detaylı Analiz';
  static const String premiumMonthly = 'Aylık Premium';
  static const String premiumYearly = 'Yıllık Premium';
  static const String premiumMockNotice = 'Bu ekran geliştirme aşamasındadır. Yakında gerçek ödeme sistemi aktif olacak.';

  // Fiyatlar (kolayca değiştirilebilir)
  static const String priceSingleDetail = '99 ₺';
  static const String priceRelationshipDetail = '149 ₺';
  static const String priceMonthly = '199 ₺ / ay';
  static const String priceYearly = '999 ₺ / yıl';

  // Günlük İçgörü
  static const String insightTitle = 'Günlük İçgörün';
  static const String insightWeeklyTheme = 'Bu Haftanın Teması';
  static const String insightAffirmation = 'Günlük Olumlama';
  static const String insightPremiumTeaser = 'Detaylı Haftalık Yorum';
  static const String insightPremiumLocked = 'Bu içerik Premium üyelerine özeldir';

  // Ayarlar
  static const String settingsTitle = 'Ayarlar';
  static const String settingsNotifications = 'Bildirimler';
  static const String settingsNotificationsDesc = 'Günlük içgörü bildirimleri';
  static const String settingsLanguage = 'Dil';
  static const String settingsLanguageValue = 'Türkçe';
  static const String settingsPrivacy = 'Gizlilik Politikası';
  static const String settingsTerms = 'Kullanım Şartları';
  static const String settingsAbout = 'Uygulama Hakkında';
  static const String settingsVersion = 'Versiyon 1.0.0';
  static const String settingsDisclaimer = 'Kullanım Uyarısı';

  // Hukuki Uyarı
  static const String legalDisclaimer =
      'Pin Kodum\'da sunulan analizler numeroloji temelli kişisel farkındalık, eğlence ve yorum amaçlıdır. '
      'Tıbbi, psikolojik, hukuki, finansal veya profesyonel danışmanlık yerine geçmez. '
      'Uygulamadaki yorumlar kesinlik iddiası taşımaz.';

  static const String legalCheckboxText =
      'Pin Kodum analizlerinin kişisel farkındalık ve eğlence amaçlı olduğunu, '
      'profesyonel danışmanlık yerine geçmeyeceğini anladım.';

  // Hata mesajları
  static const String errorGeneral = 'Bir hata oluştu. Lütfen tekrar deneyin.';
  static const String errorSave = 'Kaydedilemedi. Lütfen tekrar deneyin.';

  // Kredi sistemi
  static const String creditFree = 'Ücretsiz';
  static const String credit1 = '1 Kredi';
  static const String credit2 = '2 Kredi';
  static const String creditIncluded = 'Premium\'a Dahil';
}
