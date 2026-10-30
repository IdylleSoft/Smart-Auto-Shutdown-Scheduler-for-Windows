# D1 yönetim paneli

Worker yayımlandıktan sonra panel şu adreslerden açılır:

- `/admin/errors` — hata grupları, filtreler ve son temizlenmiş teknik örnek
- `/admin/health` — `interface_ready` kayıtları
- `/admin/devices` — cihaz, sürüm, ülke ve açılış istatistikleri
- `/admin/devices/SAS-...` — tek cihazın profili, hata ilişkileri, arayüz
  sağlığı ve olay zaman çizelgesi

## Zorunlu Worker secret

Cloudflare Worker ayarlarında `ADMIN_PASSWORD` adında güçlü ve benzersiz bir
secret oluşturun. Bu secret yoksa bütün `/admin` yolları `503`, yanlışsa `401`
döndürür. Kullanıcı adı varsayılan olarak `admin` değeridir. İstenirse
`ADMIN_USERNAME` değişkeniyle değiştirilebilir.

Wrangler kullanılıyorsa:

```powershell
npx wrangler secret put ADMIN_PASSWORD
```

Tarayıcı `/admin/errors` açılırken yerleşik kullanıcı adı/parola penceresini
gösterir. Parola URL'ye veya sayfa HTML'ine yazılmaz.

## Önerilen Cloudflare Access katmanı

Cloudflare Zero Trust/Access içinde Worker alan adının hem `/admin` hem de
`/admin/*` yollarını kapsayan bir Self-hosted uygulama oluşturun ve yalnızca
yönetici e-posta adresine izin verin. Ardından Worker'a `ADMIN_EMAIL` değişkeni
olarak aynı e-posta adresini ekleyin.

`ADMIN_EMAIL` tanımlandığında panel hem doğru kullanıcı adı/parolayı hem de
Cloudflare Access'in ürettiği `Cf-Access-Authenticated-User-Email` başlığını
zorunlu tutar. Access henüz yapılandırılmadan `ADMIN_EMAIL` eklenirse tarayıcı
doğru parolayla bile `401` alır.

## Veri saklama davranışı

Yeni hata raporlarının son teknik örneği `error_samples` tablosunda tutulur.
Windows/POSIX kullanıcı dizinleri ve IP adresleri kayıt öncesinde maskelenir.
Eski hata gruplarının ayrıntısı ilk yeni tekrar geldiğinde otomatik oluşur.
Panel salt okunurdur; kayıt silme veya değiştirme işlemi sunmaz.

Cihaz profilindeki ayrıntılı açılış, `interface_ready` ve hata zaman çizelgesi
Worker'ın bu sürümü yayımlandıktan sonra oluşur ve en fazla 180 gün tutulur.
Eski kayıtlar için `device_stats`, `error_group_devices` ve `interface_health`
tablolarındaki mevcut toplu bilgiler profil sayfasında gösterilmeye devam eder.
