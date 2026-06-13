PERLA1_V152_LAKE_SHORE_SOFT_RING_BOAT_LIFT_SAFE_LOCAL

Base reale: PERLA1_V151_PINETA_TRAIL_WATER_CORNER_SOFTEN_SAFE_LOCAL.

Intervento V152:
- Patch mirata al laghetto segreto: contorno acqua/riva più morbido, tondo e visibile.
- Aggiunte quattro mappe visuali precalcolate, solo rendering:
  - lakeWaterRingMapV152
  - lakeSandInnerRingMapV152
  - lakeSandOuterRingMapV152
  - lakeGrassOuterRingMapV152
- La sabbia contro l'acqua viene sfumata con fascia umida/chiara.
- La sabbia contro l'erba viene sfumata con una corona verde/sabbiosa più organica.
- L'erba attorno alla sabbia riceve un alone sabbioso morbido.
- L'acqua del laghetto vicino alla riva riceve una sfumatura più leggibile e morbida.
- Barca del laghetto alzata leggermente: groundSink 4.75 -> 3.85.

Vincoli rispettati:
- Nessuna modifica a collisioni, fMap, roadMask, objectBlock, mappa logica o worldgen.
- Nessun PNG modificato.
- Nessun nuovo sprite.
- Tetti, ombre, pineta performance, pergola, torre, festoni, statua, sassi e fiori preservati.
- Outline cartoon ancora disattivato.
- Nessuna cartella SOLO_FILE_DA_SOSTITUIRE / patch-only nello ZIP.

Validazione tecnica:
- JS estratto da index.html: node --check OK.
- Runtime mock Node OK.
- V152 stats mock:
  - lakeWaterRingCellsV152: 48
  - lakeSandInnerRingCellsV152: 59
  - lakeSandOuterRingCellsV152: 59
  - lakeGrassOuterRingCellsV152: 108
  - subTileCells: 3971
  - nearSubTileCells: 3488
  - sprite runtime: 1938
  - roofSegments: 2
  - boat groundSink: 3.85
