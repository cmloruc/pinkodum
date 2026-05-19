# Pin Kodum

Numeroloji temelli kişisel farkındalık uygulaması. Doğum tarihinden 9 haneli bir pin kodu hesaplayarak kişilik analizi ve ilişki yorumları sunar.

---

## Kurulum

### Gereksinimler

- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio veya VS Code (Flutter extension)
- Claude veya OpenAI API anahtarı (analiz için)

### Adımlar

```bash
# Repoyu klonla
git clone <repo-url>
cd pin_kodum

# Bağımlılıkları yükle
flutter pub get

# Uygulamayı çalıştır
flutter run
```

Uygulama açıldıktan sonra **Ayarlar** ekranından API anahtarı ve model seçimi yapılır.

---

## Proje Yapısı

```
lib/
├── main.dart                    # Giriş noktası
├── app/
│   ├── app.dart                 # MaterialApp
│   ├── router.dart              # GoRouter navigasyon
│   └── theme.dart               # Koyu mistik tema
├── core/
│   ├── constants/               # Renkler, metinler, tipler
│   ├── utils/                   # DateFormatter
│   └── widgets/                 # GradientCard, PinCodeDisplay, GoldButton
├── data/
│   ├── models/                  # PersonAnalysis, RelationshipAnalysis, Premium modeller
│   ├── repositories/            # AnalysisRepository interface + local impl
│   └── services/
│       ├── ai_analysis_service.dart        # Claude + OpenAI API çağrıları
│       ├── api_key_service.dart            # Sağlayıcı / model / anahtar yönetimi
│       ├── pin_code_calculator.dart        # 9 hane hesaplama algoritması
│       ├── element_balance_calculator.dart # Ateş / Toprak / Hava / Su dağılımı
│       ├── prompt_builder.dart             # AI prompt şablonları
│       ├── mock_analysis_service.dart      # API yoksa kullanılan mock
│       └── premium_service.dart            # Premium durum kontrolü
└── features/
    ├── onboarding/              # Splash + Onboarding
    ├── home/                    # Ana ekran
    ├── single_analysis/         # Tek kişi formu + sonuç + premium
    ├── relationship_analysis/   # İlişki formu + sonuç + premium
    ├── history/                 # Geçmiş analizler
    ├── insights/                # Günlük içgörü
    ├── premium/                 # Premium satın alma ekranı (mock)
    └── settings/                # Ayarlar (API anahtarı, model seçimi)
```

---

## Pin Kodu Algoritması

| Hane | Formül |
|---|---|
| H1 | Gün rakamları toplamı |
| H2 | Ay rakamları toplamı |
| H3 | Yıl rakamları toplamı |
| H4 | H1 + H2 + H3 |
| H5 | H1 + H4 |
| H6 | H1 + H2 |
| H7 | H2 + H3 |
| H8 | H6 + H7 |
| H9 | H1+H2+H3+H4+H5+H6+H7+H8 |

Tüm sonuçlar tek haneye indirilir (9'dan büyükse rakamlar tekrar toplanır).

**Örnek:** 29.10.1985 → `2-1-5-8-1-3-6-9-8`

---

## AI Analiz Sistemi

Uygulama Claude ve OpenAI API'lerini destekler. Ayarlar ekranından sağlayıcı ve model seçilebilir.

### Desteklenen Modeller

| Sağlayıcı | Model | Açıklama |
|---|---|---|
| Claude | claude-haiku-4-5-20251001 | Hızlı & ekonomik (varsayılan) |
| Claude | claude-sonnet-4-6 | Dengeli |
| Claude | claude-opus-4-7 | En güçlü |
| OpenAI | gpt-5-mini | Hızlı & ekonomik |
| OpenAI | gpt-5.2 | Güçlü |

### Analiz Türleri

- **Standart analiz** — özet, güç, uyarı (tek API çağrısı)
- **Premium tek kişi** — 9 hane detay, element profili, yaşam dersi, yıl mesajı (paralel 3 API çağrısı)
- **Premium ilişki** — 9 birleşik hane, dinamikler, sentez + eksik alan tamamlama (paralel çağrılar)

Claude isteklerinde system prompt `cache_control: ephemeral` ile cache'lenir.

---

## Test

```bash
flutter test
```

Testler `test/pin_code_calculator_test.dart` dosyasında bulunmaktadır.

---

## Bağımlılıklar

| Paket | Kullanım |
|---|---|
| `go_router` | Navigasyon |
| `flutter_riverpod` | State management (entegrasyon devam ediyor) |
| `hive_flutter` | Lokal veritabanı (geçiş planlanıyor) |
| `shared_preferences` | API anahtarı ve ayar saklama |
| `http` | AI API istekleri |
| `google_fonts` | Cinzel + Inter tipografi |
| `flutter_animate` | Animasyonlar |
| `lottie` | Splash / onboarding animasyonları (planlanıyor) |
| `intl` | Tarih formatlama / Türkçe |
| `uuid` | Analiz ID üretimi |

---

## Mimari Notlar

- `AnalysisRepository` interface olarak tanımlanmıştır. Backend entegrasyonunda sadece implementasyon değişir.
- `AiAnalysisService` Claude ve OpenAI'yi destekler; `ApiKeyService` sağlayıcı seçimini yönetir.
- API anahtarı şu an istemcide (`SharedPreferences`) saklanmaktadır — Aşama 3 backend entegrasyonunda sunucuya taşınacak.
- Tüm fiyatlar `AppStrings` içinde merkezi olarak tanımlıdır.
- Renk paleti ve tema `AppColors` + `theme.dart` içinde yönetilir.

---

## Hukuki Uyarı

Pin Kodum'da sunulan analizler numeroloji temelli kişisel farkındalık, eğlence ve yorum amaçlıdır. Tıbbi, psikolojik, hukuki, finansal veya profesyonel danışmanlık yerine geçmez. Uygulamadaki yorumlar kesinlik iddiası taşımaz.
