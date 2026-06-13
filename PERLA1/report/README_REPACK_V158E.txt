PERLA1 V158E — SKYBOX SOFT CLOUD ATMOSPHERE SAFE
=================================================

Base reale: PERLA1_V158D_SKYBOX_PAINTED_PANORAMA_HAZE_SAFE_LOCAL
Linea base blindata preservata: V157.

Obiettivo:
- correggere V158D senza buttare il miglioramento strutturale;
- eliminare orizzonte bianco-latte e nord grigio-smog;
- rimuovere dettagli skybox fuori scala come alberi/triangoli;
- aggiungere nuvole come layer separato weather-ready;
- rendere tetti e muri lontani coerenti nello stesso colore atmosferico.

Modifiche principali:
- index.html aggiornato a PERLA1_V158E_SKYBOX_SOFT_CLOUD_ATMOSPHERE_SAFE_LOCAL;
- nuovo asset assets/raycast/sky_panorama_360_v158e.png;
- nuovo asset assets/raycast/cloud_layer_soft_v158e.png;
- manifest asset: tex 98 panorama, tex 99 cloud layer;
- environment palette V158E con day attivo e golden/night predisposti;
- drawSkyboxV158E usa panorama + cloud layer + velo aria/cielo, non bianco;
- drawExistingWallFogOverlay conserva alpha storica dist/25 e non limita pareti lontane;
- roofPremixedFogColorV106 usa lo stesso target atmosferico dei muri lontani.

Preservato:
- map/fMap/roadMask/cMap/objectBlock/collisioni/worldgen;
- roofSegments = 2 e geometria tetti V149;
- ombre, sprite placement, pineta/pergola, laghetto, barca, torre, festoni;
- nessuna cartella SOLO_FILE_DA_SOSTITUIRE.

Check eseguiti:
- node --check su JS estratto: OK;
- runtime smoke Node con DOM/canvas mock: OK;
- skybox panorama asset presente: OK;
- skybox cloud layer asset presente: OK;
- asset refs presenti: OK;
- integrita' ZIP/TAR.GZ da verificare nel pacchetto finale.
