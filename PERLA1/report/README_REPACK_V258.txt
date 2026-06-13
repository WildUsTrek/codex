PERLA1 V258 — PERFORMANCE BASELINE DEBUG OVERHEAD SAFE LOCAL
==============================================================

Base reale:
  PERLA1_V257_RAIN_SKYBOX_DEPTH_ANCHOR_FIX_SAFE_LOCAL

Build prodotta:
  PERLA1_V258_PERFORMANCE_BASELINE_DEBUG_OVERHEAD_SAFE_LOCAL

Scopo:
  Fase 1 del piano di pulizia/ottimizzazione: quick win a rischio bassissimo.
  Nessuna modifica a resa visiva Canvas, mappa, worldgen, asset, rain output, tetti, torre, pergola, sprite o skybox.

Interventi:
  - Aggiornato PERLA_BUILD_ID/UI/launcher a V258.
  - Throttle del clock HUD a 250 ms: evita innerHTML ogni frame.
  - Throttle della debugLine a 250 ms: evita textContent ogni frame.
  - Aggiunto report performance runtime esportabile:
      window.perlaPerformanceV258()
      window.perlaDownloadPerformanceV258()
      window.perlaLastDrawStatsSummaryV258()
  - Aggiunto audit pattumiera solo diagnostico: nessuna rimozione.

Preservato:
  - map/fMap/cMap/roadMask/objectBlock
  - ASSET_MANIFEST e PNG
  - V248-V257 rain chain/output
  - skybox V257
  - tetti/roofSegments/ZBuffer/CeilingDepthBuffer
  - sprite/pergola/festoni/torre/audio

Test consigliato in browser reale:
  1. Avviare con AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat.
  2. Provare asciutto, rain e storm.
  3. Da console eseguire window.perlaPerformanceV258().
  4. Dopo 30-60 secondi esportare window.perlaDownloadPerformanceV258().
  5. Verificare che HUD/debug si aggiornino normalmente, solo meno freneticamente.

Note:
  V258 non cancella codice morto e non archivia asset. La pulizia distruttiva e' rimandata a una V259 separata dopo validazione reale.
