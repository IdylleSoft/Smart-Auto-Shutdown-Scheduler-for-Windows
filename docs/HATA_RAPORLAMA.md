# Hata raporlama

Raporlama mevcut `hata_raporlama_aktif` ayarına bağlıdır. Bu değişiklik
ayarın varsayılanını değiştirmez. Ayar okunamazsa rapor oluşturulmaz.

- Temizlenmiş raporlar uygulamanın veri klasöründeki `hata_raporlari`
  dizinine atomik JSON dosyaları olarak yazılır. Store ve Trial kendi
  veri klasörlerini kullanır.
- En fazla 20 rapor, en fazla 7 gün saklanır. Aynı hata tek kayıtta
  birleştirilir ve rapora oluşma sayısı ile ilk/son oluşma zamanı eklenir.
  İlk oluşum hemen gönderilir; teslim edilen aynı hata sonraki bir saat
  içinde yinelenirse tek bir takip raporunda biriktirilir.
- Kayıttan sonra ve uygulamanın açılışında arka planda gönderim denenir.
  Ağ/HTTP hatasında dosya saklanır. Uygulama açık kaldığı sürece 5 dakika,
  15 dakika ve daha sonra saatte bir yeniden denenir. Yeni hata oluşması
  beklemeyi keserek kuyruğu hemen çalıştırır. Arayüz ağ isteğini beklemez.
- Rapor Worker tarafından okunabilir bir `.json` belgesine dönüştürülür ve
  Telegram `sendDocument` ile tek dosya halinde gönderilir. Bu davranış için
  güncel `worker.txt` kodunun Cloudflare'a deploy edilmesi gerekir.
- HTTP 200 ve JSON `ok: true`, Telegram dosya yüklemesinin başarılı olduğunu
  belirtir. Bu onay alınınca yerel dosya silinir. Sunucu teslim edip yanıt yolda
  kaybolursa aynı dosya yeniden gelebilir; rapor kimliği eşleştirmeyi sağlar.
  Tam olarak bir kere teslim garantisi yoktur.
- Kullanıcı raporlamayı kapatınca veya ayarları sıfırlayınca kuyruk silinir.
  Kapatmadan önce ağa çıkmış bir istek geri alınamaz.

Yakalama kapsamı: ana süreç ve açılış istisnaları (kancalar kurulduktan
sonra), Python thread/unraisable istisnaları, JS köprüsündeki API
istisnaları, mevcut Timer/monitör sarmalayıcıları, uygulama günlüğündeki
ERROR/CRITICAL kayıtları, dashboard/widget JavaScript error ve
unhandledrejection olayları, script/stylesheet yükleme hataları, WebView2
süreç hata/yanıt vermeme olayları ve önceki oturumun temiz kapanmadığının
algılanması. Python `faulthandler`, ölümcül Python/native hatalarda tüm
thread'lerin sınırlı izini yerel dosyaya yazmayı dener.

`oturum_durumu.json`, her 10 saniyede Python kalp atışıyla ve görünür ana
arayüzün kalp atışıyla güncellenir. Ana pencerenin gerçek `closed` olayında
oturum temiz kapanmış olarak işaretlenir. Önceki oturum bu işareti bırakamazsa
sonraki açılışta hata raporu oluşturulur. Tepside gizlenen pencere kapanmış
sayılmaz ve gizliyken arayüz donması değerlendirilmez.

Kanıtsız temiz-kapanış eksikliği yalnızca D1 istatistiğinde tutulur ve
Telegram'a gönderilmez. Faulthandler metninde `Windows fatal exception` ile
birlikte WebView2/`evaluate_js` izi bulunursa kayıt `WebView2 native/COM
hatası` olarak ayrı gruplandırılır ve normal hata bildirim hattına alınır.
Eski istemcilerin genel başlıkla gönderdiği aynı iz Worker tarafından da
yeniden sınıflandırılır. Ana pencereye Python'dan yapılan JS çağrıları,
WebView `loaded` olana kadar bekleyen tek gönderici kuyruğunda seri yürütülür.

Raporlama kendisi hata üretirse yeni rapor döngüsü başlatmaz. Kullanıcı
girdileri/yerel değişkenler topluca toplanmaz. Metinler ve parametreler
kaydedilmeden önce dosya yolları, URL, e-posta ve bilinen hassas alanlar
temizlenir. Serbest metin maskelemesi her olası kişisel bilgiyi tanıyacağının
garantisi değildir; yeni rapor alanları eklenirken ayrıca incelenmelidir.

Görev Yöneticisi ile sonlandırma, elektrik kesintisi ve bazı native çökmeler
çalışan süreç tarafından raporlanamaz; sonraki açılışta temiz kapanış işareti
eksikliği üzerinden algılanır. Bu durumların kesin nedeni birbirinden ayırt
edilemez. Faulthandler devreye giremediyse yalnızca oturum zamanları ve aktif
görev türleri bulunur. Sistem ham bellek dökümü toplamaz veya göndermez.

Testler: `python -m pytest tests/test_hata_raporlama.py` ve
`node tests/test_hata_raporlama_js.cjs`. Ağ taklit edilir; gerçek Telegram
mesajı gönderilmez.
