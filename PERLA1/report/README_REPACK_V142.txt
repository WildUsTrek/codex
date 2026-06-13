PERLA1_V142_SHADOW_VISIBILITY_TAMARISK_TENT_SHADOW_SAFE_LOCAL

Base reale: PERLA1_V141_SHADOW_CACHE_TENT_ANCHOR_SAFE_LOCAL
Linea base: V141 deriva da V138Q blindata.

Scopo:
- Correggere il tuning residuo delle ombre V141 senza riaprire V139/V140.
- Rendere le ombre cached più visibili ma ancora morbide e semi-trasparenti.
- Correggere la scala vicino/lontano: l'ombra non deve diventare piccola quando ci si avvicina allo sprite.
- Lasciare le tende in pace come ancoraggio V141; aggiungere/rendere percepibile solo la loro ombra.
- Alzare appena i tamerici dal terreno con micro-eccezione mirata.

Interventi:
- Build id aggiornato a PERLA1_V142_SHADOW_VISIBILITY_TAMARISK_TENT_SHADOW_SAFE_LOCAL.
- Mantiene il renderer ombre cached V141, ma aumenta alpha, dimensioni massime e near-scale.
- Aggiunge curva sizeScale: nearBoost + farSizeFade, così vicino l'ombra cresce/stabilizza e lontano sfuma senza collassare in riga.
- Aggiunge profili *_v142 per alberi/palme/tamerici/ombrelloni/tavoli/tende/auto/camper/vasi/oggetti.
- Tende: ancoraggio V141 invariato, profilo ombra tent_round_v142 più visibile.
- Tamerici: solo tex 54/55/56 o kind tamarisk ricevono moltiplicatore anchor 0.94 per alzarli poco.
- Barca tex 84 / rowboat ancora esclusa e preservata.
- Microflora tex 12/13/27/28/29/30/31/40/41/88/89/90 ancora shadowless.

Non toccati:
- asset PNG;
- mappa/collisioni/objectBlock/roadMask;
- tetti, RoofSelfDepthBuffer, torre V136, pergola, festoni;
- pavimenti/microflora placement;
- barca;
- cartella patch-only: assente per regola PERLA1.

Check:
- node --check OK sullo script estratto.
- Runtime smoke Node OK: mappa 150x88, sprites 1892, roofSegments 2, manifest 91 gruppi, texture loaded 91, floor visual presente.
- Probe runtime V142 OK: flag v142ShadowVisibilityTamariskTentShadow true; tent_round_v142 visto nel probe camper_road.
- Asset manifest: 103 PNG referenziati, missing 0, 111 PNG totali invariati.
- ZIP finale: gioco completo + launcher/server root + TXT aggiornati, nessuna cartella SOLO_FILE_DA_SOSTITUIRE.
