# PERLA1 V239 — Column Fragment Compositor Diagnostic

Build: `PERLA1_V239_COLUMN_FRAGMENT_COMPOSITOR_DIAGNOSTIC_LOCAL`  
Base reale: `PERLA1_V238_CLEAN_DISABLE_SAFE_EMERGING_WALL_EXPERIMENTS_LOCAL`

## Identità

V239 introduce la prima fase del sistema **Column Fragment / Vertical Span Compositor** in modalità diagnostic-first. Non è una patch di resa finale e non disegna nuovi muri per default.

## Interventi

- Aggiornato build ID/UI/launcher a V239.
- Aggiunte costanti V239 con `PERLA_V239_COLUMN_FRAGMENT_DRAW_ENABLED = false` e `PERLA_V239_COLUMN_FRAGMENT_DRY_RUN = true`.
- Aggiunto data model dei frammenti verticali per colonna.
- Aggiunto collector diagnostico da foreground wall + `wallLayersForColumnV227` già esistenti + blocker ceiling/coverage passivi.
- Aggiunto resolver dry-run delle bande verticali.
- Aggiunti sample per-colonna e contatori di hierarchy/reject.
- Aggiunto report JSON scaricabile.

## Comandi debug

```js
perlaDownloadColumnFragmentDebugReport()
window.__PERLA_DEBUG__.downloadColumnFragmentDebugReport()
window.__PERLA_DEBUG__.getColumnFragmentDebugSnapshot()
```

## Vincoli preservati

- Nessun nuovo DDA aggiunto.
- Nessun renderer span/overlay riattivato.
- Nessun draw V239 attivo di default.
- Ramo V237 resta chiuso dalla V238.
- V233/V234/V235/V236/V237A1/V238 preservati.
- Nessuna modifica a PNG, mappa, collisioni, worldgen, objectBlock, roadMask, skybox, pioggia, auto, tetti, torre, reception/bagni.

## Check

- `node --check`: OK.
- Asset refs: 108.
- Asset missing: 0.
- PNG modificati rispetto a V238: 0.
- Browser interattivo reale non eseguito nel container: Chromium/Playwright è stato bloccato dall'ambiente (`ERR_BLOCKED_BY_ADMINISTRATOR`).

## Interpretazione corretta

V239 deve essere testata nel browser reale con draw off: la resa visiva deve restare come V238. Il valore della patch è il JSON: davanti ai muri problematici deve dire se il compositore vede frammenti/bande coerenti o se serve passare a un sistema ancora più topologico.
