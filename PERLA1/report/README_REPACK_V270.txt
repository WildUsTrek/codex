# PERLA1_V270_REAL_CEILING_CLONE_EAVE_SAFE_LOCAL

Base reale usata: `PERLA1_V267_ROOF_SILHOUETTE_MAIN_WALL_CLIP_SAFE_LOCAL`.

V268 e V269 non sono state usate come base. V269 e' stata bocciata perche' aveva creato una falsa fascia/riga esterna, non un clone reale del soffitto.

## Correzione V270

V270 non disegna piu' bande esterne dedicate. Il clone eave viene introdotto nel floor/ceiling casting: quando il ray/floor sample cade appena fuori dal footprint moderno reception/bagni ma dentro il piccolo overhang, il sistema assegna virtualmente `typeC` e `owner` del cover moderno. Di conseguenza il disegno passa dallo stesso `drawModernCoverCeilingSegment()` del soffitto interno.

Questo significa: stesso materiale, stesso fog, stessa proiezione, stesso path tecnico. I muri sono disegnati dopo, quindi mantengono autorita' visiva e coprono il clone senza overlay finale.

## Comandi debug

```js
perlaRealCeilingCloneSummaryV270()
perlaRealCeilingCloneToggleV270(false)
perlaRealCeilingCloneToggleV270(true)
perlaRealCeilingCloneModeV270('safe')
perlaRealCeilingCloneModeV270('debug')
perlaRealCeilingCloneModeV270('off')
perlaRealCeilingCloneDownloadV270()
```

## Check eseguiti

- node --check: OK
- smoke statico: OK
- PNG count: 116
- PNG hash modificati vs V267: 0
- ASSET_MANIFEST refs: 108
- missing refs: 0
- browser reale: non eseguito qui

