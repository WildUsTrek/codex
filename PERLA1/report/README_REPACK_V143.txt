PERLA1_V143_GROUND_FOOTPRINT_SHADOW_SAFE_LOCAL

Base reale: PERLA1_V142_SHADOW_VISIBILITY_TAMARISK_TENT_SHADOW_SAFE_LOCAL
Data: 2026-06-08

Scopo:
- Correggere il bug reale delle ombre che sembravano rimpicciolirsi quando il player si avvicinava allo sprite.
- Rendere l ombra piu coerente con un footprint a terra: top piatto nascosto sotto la base dello sprite e fondo arrotondato/sfumato.

Intervento:
- Sostituita la cache ombra ellittica centrata con cache flat-top / rounded-bottom.
- drawSpriteContactShadowV141 resta come nome compatibile, ma internamente applica logica V143.
- L ombra usa shadowTopY/top-anchored, non piu cy clampato al centro.
- In near range niente maxW/maxH piccoli fissi: la dimensione cresce con lo sprite e viene eventualmente clippata dal bordo basso dello schermo.
- Fade/LOD dimensionale solo lontano.
- Tende lasciate in pace come ancoraggio V141/V142; aggiornata solo la forma/profilo ombra.
- Tamerici mantengono il lieve lift V142.
- Barca/lake_rowboat esclusa e preservata.
- Microflora, aghi, pigne, erbe, fiori e cartelli restano shadowless.

Non toccati:
- PNG/assets;
- mappa, collisioni, worldgen;
- tetti, torre V136, pergola, festoni;
- broadphase V137;
- microflora placement V138Q;
- barca.

Packaging:
- ZIP completo senza cartella SOLO_FILE_DA_SOSTITUIRE / patch-only.

Check eseguiti:
- node --check sullo script estratto: OK.
- runtime smoke Node: OK.
- runtime probe V143: OK, flag v143GroundFootprintShadow true.
- scale probe: a distanza 2/3/4/5 l ombra tree passa circa 138/90/66/52 px, quindi vicino cresce invece di rimpicciolirsi.
- PNG invariati rispetto a V142.
- roofSegments = 2 nei probe.
