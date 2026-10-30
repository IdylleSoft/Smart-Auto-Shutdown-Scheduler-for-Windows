# Sağlık ve oturum verilerini kaldırma

Bu dosyanın hazırlanması canlı D1 verilerini silmez. İşlem Cloudflare'da
`auto-shutdown-users` veritabanının Console ekranında çalıştırılmalıdır.

1. Önce güncel `worker.txt` içeriğini yayımlayın. Eski Worker'ın çalışması
   kaldırılan tabloları yeniden oluşturabilir.
2. D1 veritabanını dışa aktararak yedek alın. Silme geri alınamaz;
   geri dönüş ancak yedekten mümkündür.
3. `D1_SAGLIK_OTURUM_TEMIZLE.sql` sorgularını sırasıyla çalıştırın.
   Bir sorgu hata verirse durun, sonraki sorgulara geçmeyin.
   Ortak cihaz tablosunun kopyalanması başarıyla tamamlanmadan
   `DROP TABLE device_activity_log` çalıştırılmamalıdır.
4. Son kontrol sorgularında eski beş tablo görünmemeli ve kalan sağlık
   etkinliği/teslim kaydı sayıları sıfır olmalıdır. Cihaz geçmişinde
   `elapsed_ms`, `js_error_count`, `recovery_count` sütunları bulunmamalıdır.

Silinenler: `interface_health`, `interface_health_events`, `app_sessions`, `session_events`,
`session_errors`; ortak cihaz geçmişindeki sağlık/oturum olayları ve sağlık
bildirimlerinin teslim kayıtları. Bu tablolara ait indeksler de silinir.

Korunanlar: cihaz ve ülke kayıtları, uygulama açılış sayıları, geri
bildirimler/görseller, hata grupları/örnekleri ve diğer bildirim teslim kayıtları.
Telegram'da önceden gönderilmiş mesajlar bu sorguyla silinmez.

Worker eski sağlık/oturum olaylarını sessizce karşılar; bu uyumluluk listesi
herhangi bir tablo oluşturmaz ve bildirim göndermez.
