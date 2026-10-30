# Günlük Telegram kullanıcı özeti

Worker her gün Türkiye saatiyle **00:05**'te önceki takvim gününün kullanıcı
özetini mevcut Telegram sohbetine gönderir. Cloudflare UTC zamanlaması
`5 21 * * *` değeridir. Önceden bulunan pasif bakım zamanlaması korunur.

Kaynak `device_stats` tablosudur. Yeni kullanıcı, `first_seen_at` tarihi rapor
gününe denk gelen benzersiz anonim cihaz kimliğidir. Açılış sayısı bu ölçüme
eklenmez. Kimlik değişikliği yeni cihaz olarak sayılabilir.

Raporun alanları:

- Rapor günü kazanılan yeni kullanıcı sayısı.
- Önceki günün sayısı ve yüzde değişimi. Önceki gün sıfırsa yüzde `—` görünür.
- Rapor günü dahil son yedi günün yeni kullanıcı toplamı.
- Rapor gününün sonu itibarıyla toplam kayıtlı kullanıcı sayısı.
- O günkü yeni kullanıcıların tüm ülkeleri, kullanıcı sayısına göre azalan
  sırada ve eşitlikte ülke koduna göre listelenir. “Diğer” grubu yoktur;
  ülkesi tespit edilemeyenler varsa “Bilinmiyor” satırında gösterilir.
  Kaynak, cihazın ilk bilinen `country_code` alanıdır. Uzun listeler hiçbir
  ülke atlanmadan devam mesajlarına bölünür; her parça ayrı teslim kilidi kullanır.

Günlük aralık Türkiye 00:00 dahil, ertesi gün 00:00 hariçtir. SQLite UTC tarihleri
ve ISO-8601 tarihleri aynı sorguda desteklenir. Günlük yeni kullanıcı sıfır
olduğunda da özet gönderilir.

Günün sayısı geçmişteki bütün Türkiye takvim günlerinin en yüksek sayısını
**aşarsa** rapora “🏆 YENİ REKOR! 🎉” başlığı ve “Önceki zirve: 35 → 42” satırı eklenir.
Eşitlikte ve sıfır kullanıcı gününde rekor kutlaması gösterilmez. Önceden kayıt
yoksa ilk pozitif gün “İlk günlük rekor” olarak gösterilir. Karşılaştırma bütün
`first_seen_at` geçmişinden hesaplanır; rapor günü ve sonraki günler önceki
rekora katılmaz. Yeni tablo veya rekor durumu yazılması gerekmez.

Mevcut `notification_delivery` tablosundaki `daily_users:YYYY-MM-DD` teslim
anahtarı yeniden tetiklenmelerde kontrol edilir. Telegram başarısızlığı üç
kez denenir; başarısız teslim gönderildi olarak işaretlenmez. Devam eden
başarısızlık Cloudflare scheduled çalışmasına hata olarak yansır.

Uygulamanın açık olması gerekmez; yeni MSIX derlemesi gerekmez. Döngü deneme
bildirim tercihleri bu Worker günlük raporunu kontrol etmez.

Kontrol: `node tests/test_worker_gunluk_kullanici.cjs`

Yayın öncesi Worker kaynak kodu, ayarları ve zamanlamaları
`Worker-backup-20261021-daily-users` klasöründe tutulmuştur (Codex çalışma alanı).
