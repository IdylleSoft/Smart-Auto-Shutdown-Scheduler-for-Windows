-- Cloudflare D1 konsolunda, yeni Worker deploy edilmeden önce bir kez çalıştırın.
-- Mevcut cihazlar ve açılış sayaçları korunur; ülke alanları boş başlar.
ALTER TABLE device_stats ADD COLUMN country_code TEXT;
CREATE INDEX IF NOT EXISTS idx_device_stats_country_code ON device_stats(country_code);
