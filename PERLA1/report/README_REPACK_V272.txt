# PERLA1_V272_REAL_ROOF_UNDERSIDE_EAVE_NEAR_GEOMETRY_SAFE_LOCAL

Data generazione: 2026-06-13
Base reale usata: `PERLA1_V271_REAL_CEILING_CLONE_SIDE_AWARE_CONTINUITY_SAFE_LOCAL`.

## Scopo

V272 corregge il blocco della V271 senza tornare al vecchio tetto costoso. La V271 clonava la gronda dentro il path floor/ceiling: corretto come gerarchia, ma fragile vicino alla near-plane e troppo basso rispetto al roof alto.

V272 aggiunge un pass roof-space reale per gronda/intradosso sui `roofSegments` moderni. Usa la geometria gia' registrata del tetto (`x0/x3/y0/y3`, core, `undersideZ`, `eaveZ`, `overhang`) e disegna facce budgetate north/south/east/west.

## Interventi

- Nuovo `perlaRealRoofUndersideEavePassV272()`.
- Hook in `drawRoofLayer2_5D()` dopo `drawSlopedRoofGableCaps2_5D()` e prima del tetto torre.
- Raster a colonne con cap:
  - `PERLA_V272_MAX_PIXELS_PER_FRAME = 10000`
  - `PERLA_V272_MAX_ROWS_PER_COLUMN = 18`
  - `PERLA_V272_MAX_COLUMNS_PER_ROOF = 520`
- Gate gerarchico con `roofVisibleAt(..., 'roof_fascia', z)`.
- Clip contro muri dello stesso owner per non verniciare la facciata.
- Debug/export:
  - `perlaRealRoofUndersideEaveSummaryV272()`
  - `perlaRealRoofUndersideEaveToggleV272(false/true)`
  - `perlaRealRoofUndersideEaveModeV272('safe'|'debug'|'off')`
  - `perlaRealRoofUndersideEaveDownloadV272()`

## Dipendenze preservate

- V267 resta autorita' per silhouette main e mantiene il vecchio roof fill sample-based OFF.
- V270/V271 restano nel codice/debug come storico e fallback del clone ceiling, ma V272 aggiunge l'autorita' roof-space per la gronda visibile.
- V264/V265 watchdog/budget restano attivi.
- V268/V269 restano assenti.
- Nessuna modifica ad asset, mappa, collisioni, rain, skybox, floor globale, sprite placement, audio/input/CSS/minimappa.

## Validazione

- `report/NODE_SMOKE_V272.js`: OK.
- Parsing inline JS con `new Function`: OK.
- Runtime Playwright fallback con Chrome:
  - reception nord/sud: V272 owner 1, 9360 pixel, `roofSamplesV106 = 0`.
  - bagno west/east/north/south: V272 owner 2, 9360 pixel, `roofSamplesV106 = 0`.
  - toggle off/on: off 0 pixel, on 9360 pixel.
  - caso ultra-vicino reception north: 0 pixel perche' la faccia reale e' sopra il viewport; nessun overlay finto introdotto.

Browser integrato non utilizzabile qui: fallisce in bootstrap con `CreateProcessAsUserW failed: 5`; validazione eseguita con Playwright + Chrome di sistema.
