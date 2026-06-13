PERLA1 V138P — MICROFLORA VISUAL MASK + BUSH CLEANUP + DECKCHAIR AUDIT

Base reale: PERLA1_V138O_MICROFLORA_FOOTPRINT_SAFE.

Interventi:
- Aggiunta maschera visuale post-buildFloorVisualMaps per microflora: erba/fiori/aghi/pigne non vengono più valutati solo su floorType/roadMask/logica centrale, ma anche su roadSoftEdgeMap, trailSoftEdgeMap, floorDecalMap e floorMicroDecalMap.
- La microflora può stare solo su erba/pineta visivamente coerente; se il footprint invade bordi di strada, sentieri morbidi, decal terra/strada/sabbia/consumo viene spostata vicino a terreno sicuro oppure rimossa.
- Rimossa la logica solo-centro che lasciava ciuffi d'erba apparentemente sulla terra pur avendo coordinate su erba.
- Rimosso il cespuglio/bush vicino a coordinate gameplay X 45.47 / Y 62.84.
- Audit deckchair/sdraio: non introdotte nuove ombre runtime o asset shadow; PNG preservato, con controllo report.

Preservati:
- Torre V136 integrata.
- Broadphase V137.
- Tetti/tettoie V121, pergola V90, festoni V105.
- Asset PNG, salvo nessuna modifica diretta in questa patch.
- Mappa/collisioni/roadMask principali, salvo rebuild objectBlock/roadMask coerente dopo rimozioni sprite.

Check:
- node --check su script estratto: OK.
- Runtime mock/debug: OK.
- asset manifest: invariato.
- roofSegments: 2.
- patch-only assente.
