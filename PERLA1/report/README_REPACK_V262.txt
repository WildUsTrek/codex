PERLA1_V262_COVERAGE_STABLE_EDGE_REPAIR_SAFE_LOCAL

Base reale:
- PERLA1_V261_ROOF_PERGOLA_HARD_CAP_SAFE_LOCAL

Scopo:
- Riparare la regressione visiva V261: flickering tettoie in meteo sereno e bordi/contorni seghettati su tetti/pergola.
- Trasformare il cap V261 da modalità ordinaria alternata a emergency cap raro.
- Rendere ordinario uno stable coverage budget deterministico sugli interni delle coperture.
- Mantenere bordi, silhouette, gronde, gable/cap, linea muro-tetto, profilo pergola e pali in politica full-quality.
- Intercettare e diagnosticare il path roof non cappato emerso nel debug erba: roof.samples alto con hardCap 0.

Interventi:
- Build ID aggiornato a V262.
- Aggiunte costanti PERLA_V262_*.
- Aggiunti comandi:
  perlaCoverageStableSummaryV262()
  perlaCoverageStableToggleV262(false/true)
  perlaCoverageStableModeV262('safe'|'debug'|'off')
  perlaCoverageStableDownloadV262()
- V261 public API preservata:
  perlaCoverageSurfaceSummaryV261()
  perlaCoverageSurfaceToggleV261()
  perlaCoverageSurfaceModeV261()
  perlaCoverageSurfaceDownloadV261()
  perlaPergolaBudgetSummaryV261()
- Recorder smart aggiornato con coverageV262.
- Metadata recorder corretti: baseBuild V261, phase V262.
- Debug labels separati: roof_modern_reception, roof_modern_bath, roof_legacy_or_generic_closed, pergola, unknown_roof_path.

Preservato:
- worldgen
- map/fMap/cMap/roadMask/objectBlock
- asset PNG / ASSET_MANIFEST
- rain V248-V257
- skybox
- wall DDA
- sprite placement globale
- floor globale
- collisioni
- audio/input/CSS
- minimappa default
- debug V259/V260/V261

Validazione eseguita:
- node --check su report/EXTRACTED_INDEX_INLINE_SCRIPT_V262.js: OK
- node report/NODE_SMOKE_V262.js: OK
- ASSET_MANIFEST refs: 108
- missing asset: 0
- PNG count: 116
- PNG hashes changed vs V261: 0
- cartella patch-only: assente

Nota:
- Browser reale non eseguito in questo ambiente. Test consigliato: clear/storm davanti tettoie, clear/storm sotto/perimetro pergola, bath_garden grande tetto, erba roof path non cappato.
