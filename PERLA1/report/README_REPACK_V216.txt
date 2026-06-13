PERLA1 V216 — DOOR RAIN EXACT CEILING RECT REPLAY
==================================================

Base reale:
- PERLA1_V215_DOOR_RAIN_SOLID_CEILING_OCCLUDER_LOCAL

Obiettivo unico:
- Sostituire il falso occlusore calcolato V215 con un sistema di capture/replay esatto dei rettangoli di soffitto/tettoia realmente disegnati dal motore.

Evidenza corretta:
- V215 calcolava una cover separata tramite WallTopBuffer/ZBuffer/candidati/fallback ratio.
- Questo introduceva un secondo sistema di verità, diverso dal soffitto effettivamente renderizzato.
- V216 non calcola più un bordo: cattura i fillRect reali del soffitto e li ridisegna identici dopo la rain.

Implementazione:
1. A inizio drawWorld viene creato un array frame-local `doorRainExactCeilingRectsFrameV216`.
2. `captureCeilingFillRectV216(...)` salva esattamente x/y/w/h/fillStyle/alpha/source/pass dei rettangoli realmente disegnati.
3. La cattura è stata inserita nei punti reali di disegno:
   - `drawModernCoverCeilingSegment(...)`
   - `drawCeilingSegment(...)`
   - `drawCanopySpanV121(...)`
4. Dopo `drawWeatherOverlayV190(...)` viene chiamato `drawDoorRainExactCeilingReplayV216(...)`.
5. V214 clipped replay e V215 solid cover calcolata sono disabilitati nel path attivo V216.

Vincoli rispettati:
- Nessun nuovo calcolo di copertura.
- Nessun percentile.
- Nessun fallback ratio.
- Nessun WallTopBuffer/ZBuffer come autorità primaria nel replay V216.
- Nessun `ctx.clip()`/`drawImage()`/rainBuffer nel replay V216.
- Nessun ritorno a `perlaCompositeRainBufferV201` per la door rain.

Nota test:
- Non è stato eseguito test visivo/browser reale in questa sessione.
- Sono stati eseguiti check statici, sintassi JS estratta e integrità pacchetto.
