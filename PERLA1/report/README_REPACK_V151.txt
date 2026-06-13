PERLA1 V151 — PINETA TRAIL + WATER CORNER SOFTEN SAFE

Base: PERLA1_V150_SOFT_FLOORS_ROADS_WATER_SAFE_LOCAL
Output: PERLA1_V151_PINETA_TRAIL_WATER_CORNER_SOFTEN_SAFE_LOCAL

Contenuto patch:
1. Allargamento locale del piccolo tratto stretto del sentiero pineta/yoga storico vicino alla porta/imbocco.
2. Maschere visuali V151 per arrotondare angoli sabbia/terra-acqua.
3. Rounding lato terra e lato acqua, incluso mare e laghetto segreto quando i pattern lo permettono.
4. Outline cartoon ancora disattivato.
5. Nessun nuovo sprite, nessun PNG modificato, nessuna cartella patch-only.

Note tecniche:
- waterCornerLandMapV151 e waterCornerInnerMapV151 sono precalcolate.
- waterCornerMaskV151 lavora su sub-tile già esistenti, senza blur runtime.
- Il trail widening è volutamente locale: 5 dischi sulla prima curva del tracciato V31, non rifacimento pineta.

Check richiesti:
- Test visivo in ingresso pineta/yoga.
- Test visivo mare/spiaggia e laghetto segreto: gli angoli a L devono risultare meno quadrati.
- Controllo floorSegments/drawWorld in spiaggia e pineta.
