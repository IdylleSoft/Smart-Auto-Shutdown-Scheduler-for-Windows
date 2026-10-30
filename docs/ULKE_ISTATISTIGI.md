# Sıfırdan ülke istatistiği

1. Cloudflare D1 `auto-shutdown-users` konsolunda `ULKE_ISTATISTIGI.sql`
   içindeki iki sorguyu sırayla çalıştırın. `ALTER TABLE` yalnızca bir kez
   çalıştırılmalıdır; yeniden denemeden önce `PRAGMA table_info(device_stats);`
   ile `country_code` alanını kontrol edin.
2. Güncel `worker.txt` içeriğini Worker editörüne yapıştırıp deploy edin.
3. Bir cihazdan yeni olay geldikten sonra aşağıdaki salt okunur sorguyla
   ülke istatistiğini kontrol edin:

```sql
SELECT country_code, COUNT(*) AS device_count
FROM device_stats
WHERE country_code IS NOT NULL AND country_code <> ''
GROUP BY country_code
ORDER BY device_count DESC;
```

Eski hata kayıtları kullanılmaz. Ülkesi boş eski cihazlar yeniden bağlanınca
dahil olur. Yeni ana cihaz kaydı yalnızca uygulama açılışında oluşturulur;
diğer olaylar yalnızca mevcut cihazın boş ülke alanını doldurabilir.
İlk geçerli ülke sabit kalır; sonraki açılışlar veya VPN/ülke değişiklikleri
cihazı başka bir ülkeye taşımaz. Bu nedenle istatistik mevcut konum değil,
bu özelliğin açılmasından sonraki ilk bilinen ülkeye göre cihaz sayısıdır.
Ülke yalnızca Cloudflare `request.cf.country` üzerinden alınır, istemciden alınmaz.
Kimliği/ülkesi bilinmeyen cihazlar ülke sayısına eklenmez.

Telegram örneği: `🌍 Türkiye (5) / EN-TR`. Ülke sorgusu başarısızsa sayı
gösterilmez; mevcut açılış sayımı ve bildirim akışı devam eder.
Şema/kod yerel olarak hazırlanmıştır; canlı deploy ayrıca yapılmalıdır.
