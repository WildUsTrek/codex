# PERLA1 V261 — Roof/Pergola Hard Cap Safe

Build: `PERLA1_V261_ROOF_PERGOLA_HARD_CAP_SAFE_LOCAL`  
Base reale: `PERLA1_V260_LONG_VIEW_SPRITE_FLOOR_BUDGET_SAFE_LOCAL`  
Generato: 2026-06-12T18:59:35.638842+00:00

## Obiettivo

Il test reale utente indica che il mondo normale in tempesta resta attorno a 10–11 draw, mentre i picchi a 22–24 draw avvengono localmente davanti ai tetti e sotto/perimetro della pergola. V261 non continua il lavoro sprite/floor globale: introduce un hard cap locale per i sistemi coverage/tetto/pergola.

## Interventi principali

- Coverage Surface Profiler V261.
- Pressure state con media mobile, livelli safe/pressure/emergency.
- Hard cap roof/ceiling su owner moderni, con protezione near/edge/gable/cap/silhouette.
- Skip conservativo per roof plane fuori bbox/y-range e sampling interno ridotto solo sotto pressione.
- Hook su `drawModernCoverCeilingSegment()` per segmenti far owner 1/2 sotto pressione.
- Hard cap deferred canopy V121 tramite scan step variabile.
- Hard cap pergola V79/V90 tramite extra step progressivo sotto pressione.
- Metriche `coverageV261` nel recorder smart.
- Comandi debug/toggle/download.

## Comandi console

```js
perlaCoverageSurfaceSummaryV261()
perlaCoverageSurfaceToggleV261(false)
perlaCoverageSurfaceToggleV261(true)
perlaCoverageSurfaceModeV261("safe")
perlaCoverageSurfaceModeV261("debug")
perlaCoverageSurfaceModeV261("off")
perlaCoverageSurfaceDownloadV261()
perlaPergolaBudgetSummaryV261()
```

## Sistemi preservati

Non sono stati toccati worldgen, map/fMap/cMap/roadMask/objectBlock, asset PNG, rain lifecycle/output V248-V257, skybox, wall DDA core, sprite placement globale, floor globale, collisioni, audio/input/CSS, minimappa, V259 roof hotspot e V260 long-view budget.

## Validazione eseguita

- `node --check report/EXTRACTED_INDEX_INLINE_SCRIPT_V261.js`: OK.
- `report/NODE_SMOKE_V261.js`: OK.
- PNG count: 116.
- PNG hash changed vs V260: 0.
- PNG literal refs: 108.
- missing refs: 0.
- cartella patch-only: assente.

## Test browser reale richiesto

Il test browser reale non è stato eseguito dall'assistente. Test A/B consigliato, stesso punto e stessa tempesta:

```js
perlaCoverageSurfaceToggleV261(false)
perlaCoverageSurfaceToggleV261(true)
perlaCoverageSurfaceSummaryV261()
perlaPergolaBudgetSummaryV261()
```

Marker consigliati nel recorder:

```js
perlaPerfStart()
perlaPerfMark("mondo normale storm baseline")
perlaPerfMark("davanti reception/tetto storm")
perlaPerfMark("davanti bagni/tetto storm")
perlaPerfMark("sotto pergola storm")
perlaPerfMark("perimetro pergola storm")
perlaPerfStopAndDownload()
```
