PERLA1 V158D — SKYBOX PAINTED PANORAMA + HAZE SAFE
Base reale: PERLA1_V157_LAKE_SHORE_SEAM_CLEANUP_SAFE_LOCAL
Build: PERLA1_V158D_SKYBOX_PAINTED_PANORAMA_HAZE_SAFE_LOCAL

Obiettivo:
- Correggere il fallimento artistico V158/V158B/V158C senza limitare la visibilita' delle pareti lontane.
- Eliminare l'impressione di fondali che si schiantano tra loro.
- Usare un singolo asset panoramico continuo, piu' pittorico e piu' atmosferico.

Intervento:
- Nuovo asset unico: assets/raycast/sky_panorama_360_v158d.png, tex 98.
- Non sono quattro skybox: e' un solo bitmap 360 con profilo e colori continui.
- Geografia: Est colline -> Sud isolotto basso -> Ovest foreste -> Nord montagne -> Est colline.
- Isolotto basso e ancorato alla fascia d'orizzonte/mare-foschia comune.
- Raccordo fog: drawExistingWallFogOverlay conserva alpha storica V57; cambia solo il target colore lontano verso l'orizzonte V158D.
- Nessun culling, nessun limite di visibilita' e nessuna sparizione volontaria delle pareti lontane.

Preservato:
- map/fMap/roadMask/cMap/objectBlock/collisioni/worldgen.
- Tetti V149 e roofSegments=2.
- Ombre V144-V146, pineta/pergola performance, laghetto V157, sprite placement, barca, torre, festoni.
