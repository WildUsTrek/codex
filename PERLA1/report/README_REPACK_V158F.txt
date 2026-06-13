PERLA1_V158F_SKY_ATMOSPHERE_MINIMAL_PANORAMA_SAFE_LOCAL
=========================================================
Base operativa: PERLA1_V158E_SKYBOX_SOFT_CLOUD_ATMOSPHERE_SAFE_LOCAL, derivata dalla V157 reale blindata.
Scopo: correggere la direzione artistica dello skybox V158E senza riaprire sistemi blindati.

Interventi:
- Sostituito il panorama V158E con sky_panorama_360_v158f.png.
- Sostituito il layer nuvole V158E con cloud_layer_soft_v158f.png.
- Filosofia V158F: cielo grande e pulito, nuvole morbide separate, sagome lontanissime quasi fuse nell'aria.
- Rimosso il problema della fascia/fondale basso troppo visibile: il panorama non deve sembrare una seconda mappa.
- Mantenuto il layer nuvole separato e predisposto a futuri bucket meteo/vento/orario.
- Palette environment giorno corretta verso aria azzurro/ciano, senza bianco latte e senza grigio smog.
- Velo orizzonte ridotto a quasi impercettibile per evitare bande orizzontali.
- Tetti e muri lontani restano coerenti con lo stesso target atmosferico.

Vincoli rispettati:
- Nessun limite alla visibilita' delle pareti lontane.
- Nessun culling o distance cap aggiunto.
- Nessuna modifica a map, fMap, roadMask, cMap, objectBlock, collisioni o worldgen.
- Nessuna modifica a geometria tetti, roofSegments, gable caps, self-depth, ombre, sprite placement, pineta, pergola, laghetto, barca, torre o festoni.

Note:
- V158F non introduce ciclo giorno/notte reale, LightMap o emissive.
- Prepara solo una palette bucket future-ready, ma usa ancora il bucket day.
