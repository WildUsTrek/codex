README REPACK V265 — COVERAGE ULTRA BUDGET EDGE RAIL SAFE
Build: PERLA1_V265_COVERAGE_ULTRA_BUDGET_EDGE_RAIL_SAFE_LOCAL
Base reale: PERLA1_V264_ROOF_COST_WATCHDOG_EMERGENCY_SAFE_LOCAL
Generato: 2026-06-12T23:28:44

SCOPO
- Mantenere V264 come autorita' prestazionale basata su costo reale.
- Abbassare ulteriormente il budget interno di roof/canopy/pergola, soprattutto con rain/storm.
- Recuperare la qualita' visiva dei bordi zigrinati con edge rail leggero e depth-aware.

INTERVENTI
1. Aggiunti flag e costanti V265:
   - PERLA_V265_COVERAGE_ULTRA_BUDGET_EDGE_RAIL_SAFE
   - profili step clear/rain/storm per pressure/emergency
   - extra step pergola rain/storm
   - step canopy rain/storm
2. Hook roof:
   - dopo V264, V265 puo' aumentare solo il passo interno del loop roof secondo meteo e livello di costo.
   - nessun ritorno a campionamento pieno.
3. Edge rail tetti:
   - per i tetti visibili vengono tracciati eave/ridge/cap con linee world-projected.
   - il disegno passa da roofVisibleAt(), quindi rispetta ZBuffer, WallTop/Bottom, ceiling depth e gerarchia roof/muri.
   - non e' overlay finale screen-space.
4. Canopy/pergola:
   - canopy usa scan step piu' severo in rain/storm.
   - pergola riceve extra budget interno in rain/storm.
   - pergola edge rail leggero sul profilo, sempre con roofVisibleAt().
5. Debug:
   - perlaCoverageEdgeRailSummaryV265()
   - perlaCoverageEdgeRailToggleV265()
   - perlaCoverageEdgeRailModeV265()
   - perlaCoverageEdgeRailDownloadV265()

SISTEMI PRESERVATI
- rain lifecycle/output V248-V257: non modificato.
- skybox: non modificato.
- worldgen e map/fMap/cMap/roadMask/objectBlock: non modificati.
- asset PNG: non modificati.
- floor globale, sprite placement, wall DDA, collisioni, audio/input/CSS/minimappa: non modificati.
- debug V259/V260/V261/V262/V263/V264 preservati.

CHECK ESEGUITI
- node --check su EXTRACTED_INDEX_INLINE_SCRIPT_V265.js: OK.
- NODE_SMOKE_V265: OK.
- asset PNG count/hash invariati: OK.
- missing manifest PNG refs: 0.

NON TESTATO REALMENTE QUI
- Browser/canvas reale con movimento camera.
- Test visivo diretto su clear/rain/storm davanti ai tetti e pergola.

TEST BROWSER CONSIGLIATI
- clear vicino/media/lontana distanza tetto reception/bagni.
- rain/storm tetto reception/bagni.
- clear/rain/storm pergola.
- camminata e rotazione lenta verificando: niente bordi zigrinati, niente rail sopra muri/sprite, draw non torna a 22 per tetti/pergola.
