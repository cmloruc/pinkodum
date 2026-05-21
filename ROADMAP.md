# Pin Kodum — Yol Haritası

---

## Aşama 1 — Flutter MVP

**Durum:** Tamamlandı ✅

- [x] Flutter projesi kuruldu
- [x] Koyu mistik tema
- [x] Splash ekranı
- [x] Onboarding (3 adım + hukuki onay)
- [x] Ana ekran (kart yapısı)
- [x] PinCodeCalculator servisi (test edilebilir, izole)
- [x] Tek kişi analiz formu + sonuç ekranı
- [x] İlişki analiz formu + sonuç ekranı
- [x] Geçmiş analizler (SharedPreferences)
- [x] Günlük içgörü ekranı (mock)
- [x] Premium mock ekranı
- [x] Ayarlar ekranı
- [x] Hukuki uyarı metni
- [x] AnalysisRepository interface (backend'e hazır)
- [x] MockAnalysisService (AI'ya hazır interface)
- [x] Unit testler
- [x] README.md + ROADMAP.md

---

## Aşama 2 — AI Hibrit Analiz

**Durum:** Tamamlandı ✅ *(19 Mayıs 2026)*

- [x] Claude API entegrasyonu (birincil sağlayıcı)
- [x] OpenAI Responses API entegrasyonu (yedek sağlayıcı)
- [x] Prompt caching (Claude system prompt `cache_control: ephemeral`)
- [x] Tek kişi AI analizi (özet / güç / uyarı)
- [x] İlişki AI analizi (uyum / zorluk / cinsel uyum opsiyonel)
- [x] Premium tek kişi analizi — 9 hane detay + element + yaşam dersi + yıl mesajı
- [x] Premium ilişki analizi — paralel multi-call + eksik alan tamamlama
- [x] ElementBalanceCalculator + PromptBuilder servisleri
- [x] Fallback: API başarısız → hata kullanıcıya iletilir
- [x] Ayarlardan sağlayıcı (Claude / OpenAI) ve model seçimi
- [x] API anahtarı SharedPreferences'ta saklanır
- [x] `_sanitizeText` ile H1–H9 etiket temizleme
- [x] Hatalı JSON için `_parseLooseJsonObject` fallback parser
- [x] flutter_riverpod bağımlılığı eklendi
- [x] hive_flutter bağımlılığı eklendi
- [x] lottie bağımlılığı eklendi

---

## Aşama 3 — Backend Entegrasyonu

**Durum:** Büyük ölçüde tamamlandı ✅

- [x] NestJS API kurulumu
- [x] PostgreSQL veritabanı
- [x] Kullanıcı kayıt / giriş sistemi
- [ ] E-posta + Apple + Google OAuth
- [x] JWT auth
- [x] Analiz geçmişi backend'e taşınması
- [x] `LocalAnalysisRepository` → `ApiAnalysisRepository` swap
- [x] API anahtarı istemciden sunucuya taşınması (backend AI proxy)
- [x] Flutter: token yönetimi
- [x] Kayıt sırasında doğum tarihi alma
- [x] Profilde doğum tarihi ve kredi bakiyesi gösterme
- [x] Geçmiş analiz silme ve eski duplicate kayıt temizliği

---

## Aşama 4 — Ücretli Sistem

**Durum:** Altyapı tamamlandı, App Store Connect/TestFlight aşamasında 🔄

- [x] App Store In-App Purchase altyapısı
- [ ] Google Play Billing
- [x] Kredi sistemi backend implementasyonu
- [x] Tek seferlik detaylı analiz için kredi harcama
- [x] Kredi fiyat modeli: 1 kredi = 49 TL, tekil analiz = 2 kredi, ilişki analizi = 3 kredi
- [x] Premium paket: yıllık 899 TL, her ay 10 tekil + 10 ilişki hakkı
- [x] Günlük içgörü: premiumlara açık, normal kullanıcıya 1 krediyle 24 saat
- [ ] Aylık abonelik
- [ ] Yıllık abonelik
- [x] `MockPremiumService` → gerçek AI/premium akışı
- [ ] Satın alma geçmişi ekranı
- [x] Web'de IAP devre dışı, test modu açık
- [x] Apple Developer hesabı onayı
- [x] iOS In-App Purchase capability
- [ ] App Store Connect uygulama ve ürün tanımları
- [ ] TestFlight üzerinden IAP testi

---

## Aşama 5 — PDF Rapor

**Durum:** Uygulama içi PDF tamamlandı ✅

- [x] Tek kişi PDF raporu
- [x] Detaylı tek kişi PDF raporu
- [x] İlişki PDF raporu
- [x] Detaylı ilişki PDF raporu
- [ ] Pin Kodum logosu + filigran
- [x] Koyu tema + altın detaylı PDF tasarımı
- [x] Uygulamadaki pin kodu ağacı / element / baskın-edilgen bölümleri
- [x] PDF paylaşma (share_plus)
- [ ] Backend'den PDF üretimi

---

## Aşama 6 — Bildirimler

**Durum:** Yapılmadı

- [ ] Firebase Cloud Messaging entegrasyonu
- [ ] Günlük içgörü bildirimi (sabah)
- [ ] Haftalık tema bildirimi
- [ ] Yarım kalan analiz hatırlatması
- [ ] Kampanya / özel gün bildirimleri
- [ ] Bildirim tercih yönetimi (gerçek)

---

## Aşama 7 — Admin Panel

**Durum:** Yapılmadı

- [ ] Next.js admin panel
- [ ] Kullanıcı yönetimi
- [ ] Satın alma yönetimi
- [ ] Kredi yönetimi
- [ ] Analiz kayıtları görüntüleme
- [ ] Sabit yorum metinleri yönetimi (CMS)
- [ ] AI prompt yönetimi
- [ ] Paket / fiyat yönetimi
- [ ] Geri bildirim yönetimi
- [ ] Dashboard istatistikler

---

## Gelecek Fikirler (Backlog)

- [ ] Çoklu dil desteği (İngilizce, Almanca)
- [ ] Karanlık / açık tema seçeneği
- [ ] Numeroloji rehberi / blog
- [ ] Sosyal paylaşım (pin kodu kartı)
- [ ] Widget (iOS / Android)
- [ ] Apple Watch bağlantısı
- [ ] Arkadaşa hediye analiz
- [ ] Aile ağacı analizi

---

## Teknik Borç

- Riverpod state management — bağımlılık eklendi, ekranlara entegrasyon yapılmadı
- Hive ile SharedPreferences'ın kademeli değiştirilmesi
- Lottie animasyonları (splash ve onboarding için)
- E2E testler (Flutter Driver / Maestro)
- CI/CD pipeline (GitHub Actions)
- Firebase Analytics entegrasyonu
- Crashlytics entegrasyonu
- Flutter testleri tek komutta `--concurrency=1` ile çalıştırılmalı; paralel Flutter test komutları native-assets crash üretebiliyor
- OAuth girişleri ve App Store IAP gerçek cihaz/TestFlight testi bekliyor
