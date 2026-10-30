-- Önce güncel worker.txt yayımlanmalı; eski Worker tabloları yeniden oluşturabilir.
-- Çalıştırmadan önce auto-shutdown-users veritabanını dışa aktarın.
-- Cihazlar, ülkeler, geri bildirimler ve hata raporları korunur.

DROP TABLE IF EXISTS session_errors;
DROP TABLE IF EXISTS session_events;
DROP TABLE IF EXISTS app_sessions;
DROP TABLE IF EXISTS interface_health;
DROP TABLE IF EXISTS interface_health_events;

-- Ortak tablolar henüz yoksa boş olarak oluşturulur.
CREATE TABLE IF NOT EXISTS notification_delivery (
  delivery_key TEXT PRIMARY KEY,
  created_ms INTEGER NOT NULL,
  sent_ms INTEGER,
  lease_until_ms INTEGER NOT NULL DEFAULT 0,
  lease_token TEXT NOT NULL DEFAULT ''
);
DELETE FROM notification_delivery
WHERE delivery_key GLOB 'interface_ready:*'
   OR delivery_key GLOB 'interface_load_recovered:*'
   OR delivery_key GLOB 'session_event:*';

CREATE TABLE IF NOT EXISTS device_activity_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  event_key TEXT UNIQUE,
  device_id TEXT NOT NULL,
  event_type TEXT NOT NULL,
  version TEXT NOT NULL,
  event_ms INTEGER NOT NULL,
  title TEXT NOT NULL DEFAULT '',
  fingerprint TEXT NOT NULL DEFAULT ''
);

-- Yeni şemaya kopyalama, ortak tablodaki sağlık sütunlarını da kaldırır.
-- Kopyalama başarısız olursa eski tabloyu silen sonraki adımlara GEÇMEYİN.
CREATE TABLE device_activity_log_without_health (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  event_key TEXT UNIQUE,
  device_id TEXT NOT NULL,
  event_type TEXT NOT NULL,
  version TEXT NOT NULL,
  event_ms INTEGER NOT NULL,
  title TEXT NOT NULL DEFAULT '',
  fingerprint TEXT NOT NULL DEFAULT ''
);
INSERT INTO device_activity_log_without_health
  (id, event_key, device_id, event_type, version, event_ms, title, fingerprint)
SELECT id, event_key, device_id, event_type, version, event_ms, title, fingerprint
FROM device_activity_log
WHERE event_type NOT IN ('interface_ready', 'interface_load_recovered', 'session_event');
DROP TABLE device_activity_log;
ALTER TABLE device_activity_log_without_health RENAME TO device_activity_log;
CREATE INDEX idx_device_activity_device_time
  ON device_activity_log (device_id, event_ms DESC);
CREATE INDEX idx_device_activity_time ON device_activity_log (event_ms);

-- Kontrol: ilk sorgu sıfır satır dönmeli.
SELECT name FROM sqlite_master
WHERE type = 'table'
AND name IN ('interface_health', 'interface_health_events', 'app_sessions', 'session_events', 'session_errors');
SELECT COUNT(*) AS remaining_health_activity FROM device_activity_log
WHERE event_type IN ('interface_ready', 'interface_load_recovered', 'session_event');
SELECT COUNT(*) AS remaining_health_delivery FROM notification_delivery
WHERE delivery_key GLOB 'interface_ready:*'
   OR delivery_key GLOB 'interface_load_recovered:*'
   OR delivery_key GLOB 'session_event:*';
PRAGMA table_info(device_activity_log);
