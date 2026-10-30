# Gerçek paralaks katmanları

Durum: Kullanıcının isteğiyle deney geri alındı. dag-katmanli-paralaks sınıfı aktif değildir; uygulama eski dag-manzara-v2.png görselini ve aynı yönlü 3.2/1.92px uzak, 5.6/3.36px ön paralaksını kullanır. Aşağıdaki dosyalar ve üretim notları yalnızca arşivdir, aktif görünümü etkilemez.

Yerleşik imagegen ile eski dag-manzara-v2.png referansından iki şeffaf PNG hazırlandı. Orijinal değiştirilmedi. AI düzenlemesi piksel düzeyinde birebir kesim garantisi vermez; orman arkasındaki arazi tamamlandı.

- arayuz/gorseller/dag-uzak-v3.png: dağlar ve ormanın arkasına tamamlanan vadi.
- arayuz/gorseller/orman-on-v3.png: bağımsız ön orman/sırt silüeti.
- Konum +135px ve yatay 24px taşma payı korundu; iki dosya aynı CSS çerçevesine hizalanır.
- Uzak katman fareye ters yönde 1.5/0.9px, ön katman fare yönünde 5.6/3.36px hareket kullanır. Ayın hareketi değişmez.
- Vadi ışığı uzak araziyi takip eder. Azaltılmış hareket tercihinde tüm katmanlar sabittir.

## Geri alma

dashboard.html dosyasında app elemanından yalnızca dag-katmanli-paralaks sınıfını kaldırın. Önceki görsel, tonlar ve maskeli paralaks geri gelir. Yeni dosyaları silmek gerekmez.

## Kullanılan üretim komutları

### Uzak katman

Use case: background-extraction. Edit target: attached existing transparent blue night mountain landscape. Asset: BACKGROUND depth layer for exact compositing with the original. Keep original 16:9 canvas, peaks, perspective, palette, pixel positions, size and lower-half placement unchanged, do NOT crop or recenter. Remove only the nearest dark pine forest and its dark foreground slopes from both lower corners, revealing and seamlessly extending the blue distant mountain valley behind those foreground forests down to bottom edge. Keep all distant peaks and middle mountains unchanged. Above mountain skyline remains genuine alpha transparency, no sky/no black fill/no checkerboard. No new objects, text, fog, moon. Full-canvas transparent PNG, exact original framing. This is the far mountains layer.

### Ön katman

Use case: background-extraction. Edit target: attached existing transparent blue night mountain landscape. Asset: FOREGROUND depth layer for exact compositing with the original. Keep original 16:9 canvas and exact positions/size of near-black pine silhouettes and their attached foreground dark slopes at both left and right bottom corners. Remove ALL blue far and middle mountain peaks and valleys; make those removed pixels genuinely alpha transparent. Preserve the dark nearest forest slopes extending to bottom edge, the precise pine canopy outlines, existing texture and original framing. Do NOT crop, zoom or recenter isolated foreground. Upper half fully transparent; center valley opening transparent; no black sky, no checkerboard, no text/new trees. Full-canvas transparent PNG. This is only the near forest layer.
