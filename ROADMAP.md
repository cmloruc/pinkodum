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

**Durum:** Tamamlandı ✅ *(19 Mayıs 2025)*

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

**Tahmini:** Q3 2025

- [ ] NestJS API kurulumu
- [ ] PostgreSQL veritabanı
- [ ] Kullanıcı kayıt / giriş sistemi
- [ ] E-posta + Apple + Google OAuth
- [ ] JWT auth
- [ ] Analiz geçmişi backend'e taşınması
- [ ] `LocalAnalysisRepository` → `ApiAnalysisRepository` swap
- [ ] API anahtarı istemciden sunucuya taşınması (güvenlik)
- [ ] Flutter: token yönetimi

---

## Aşama 4 — Ücretli Sistem

**Tahmini:** Q3 2025

- [ ] App Store In-App Purchase
- [ ] Google Play Billing
- [ ] Kredi sistemi backend implementasyonu
- [ ] Tek seferlik analiz satın alma
- [ ] Aylık abonelik
- [ ] Yıllık abonelik
- [ ] `MockPremiumService` → gerçek `PremiumService` swap
- [ ] Satın alma geçmişi ekranı

---

## Aşama 5 — PDF Rapor

**Tahmini:** Q4 2025

- [ ] Tek kişi PDF raporu
- [ ] İlişki PDF raporu
- [ ] Pin Kodum logosu + filigran
- [ ] Koyu tema + altın detaylı PDF tasarımı
- [ ] PDF paylaşma (share_plus)
- [ ] Backend'den PDF üretimi

---

## Aşama 6 — Bildirimler

**Tahmini:** Q1 2026

- [ ] Firebase Cloud Messaging entegrasyonu
- [ ] Günlük içgörü bildirimi (sabah)
- [ ] Haftalık tema bildirimi
- [ ] Yarım kalan analiz hatırlatması
- [ ] Kampanya / özel gün bildirimleri
- [ ] Bildirim tercih yönetimi (gerçek)

---

## Aşama 7 — Admin Panel

**Tahmini:** Q1 2026

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
- API anahtarının istemcide saklanması geçici çözüm — Aşama 3'te backend'e taşınacak
