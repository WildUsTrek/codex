# PERLA1_V271_REAL_CEILING_CLONE_SIDE_AWARE_CONTINUITY_SAFE_LOCAL

Data generazione: 2026-06-13T01:20:53
Base reale usata: `PERLA1_V270_REAL_CEILING_CLONE_EAVE_SAFE_LOCAL`.

## Scopo

V271 mantiene il passo corretto della V270: il clone del soffitto/gronda passa dallo stesso path reale del soffitto moderno (`drawModernCoverCeilingSegment()`), non da una fascia/riga esterna come V269. La patch corregge i limiti osservati nella V270:

- il lato sud del clone era troppo corto o troppo coperto;
- il clone era ancora troppo esterno-only;
- dentro/sotto copertura poteva restare visibile il profilo interno del roof V267 invece del soffitto.

## Interventi

- Aggiunti parametri side-aware: nord, sud, est e ovest non usano piu' una sola sporgenza uniforme.
- Aumentato moderatamente il lato sud (`PERLA_V271_EAVE_OUTSET_SOUTH_WORLD = .72`) senza renderlo overlay.
- Aggiunta `innerContinuityBand` per dare continuita' vicino al bordo interno senza sostituire il soffitto interno profondo.
- Aggiunta guardia `perlaRealCeilingCloneContinuityCeilingWinsOverRoofV271()`: quando il player e' dentro/sotto ModernCover e il ceiling stesso-owner e' presente, il profilo interno del roof non deve vincere.
- Preservati V267 roof silhouette main, V270 real ceiling clone path, V264/V265 budget/watchdog.
- V268/V269 restano assenti: nessun eave permissivo V268, nessuna falsa fascia perimetrale V269.

## Comandi debug

```js
perlaRealCeilingCloneContinuitySummaryV271()
perlaRealCeilingCloneContinuityToggleV271(false)
perlaRealCeilingCloneContinuityToggleV271(true)
perlaRealCeilingCloneContinuityModeV271('safe')
perlaRealCeilingCloneContinuityModeV271('debug')
perlaRealCeilingCloneContinuityModeV271('off')
perlaRealCeilingCloneContinuityDownloadV271()
```

## Metriche chiave

- `sideAwareOutsetApplied`
- `southClonePixels`
- `southOutsetBoostApplied`
- `innerContinuityBandApplied`
- `innerContinuityPixels`
- `innerRoofProfileSuppressed`
- `ceilingWonOverRoofProfile`
- `originalRoofFillStillOff`
- `v268LogicAbsent`
- `v269FakeBandAbsent`
- `overlayPrevented`
- `performancePreserved`

## Check eseguiti qui

- `node --check` sullo script inline estratto: OK.
- Smoke statico V271: OK.
- PNG count invariato rispetto a V270: 124.
- PNG hash modificati: 0.
- Asset refs manifest: 108.
- Asset missing: 0.
- Nessuna cartella patch-only.

Browser reale non eseguito in questo ambiente.
