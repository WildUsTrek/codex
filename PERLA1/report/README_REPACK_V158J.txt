PERLA1 V158J — HORIZON LANDMARK ANCHOR FIX SAFE

Base reale: PERLA1_V158I_BALANCED_GEOGRAPHIC_VISIBILITY_SAFE_LOCAL, derivata dalla linea V157 blindata.

Problema corretto:
- In V158I l'isola sud risultava una semplice riga nel cielo: profilo troppo alto nel PNG, corpo troppo dissolto e mancato controllo della quota dopo la proiezione reale del raycaster.

Intervento V158J:
- nuovo asset assets/raycast/sky_panorama_360_v158j.png;
- nuovo nome layer nuvole assets/raycast/cloud_layer_soft_v158j.png;
- landmark sud abbassato e dotato di massa verticale minima;
- base dell'isola dissolta verso aria/mare, non sospesa;
- colline/foreste/montagne conservano profili sfumati ma meno lineari;
- aggiunto debug/check landmarkProjectedSouthYRangeV158J;
- nessun limite visibilita' pareti lontane.

Preservato:
- map/fMap/roadMask/cMap/objectBlock/collisioni/worldgen;
- tetti/roofSegments/gable/self-depth;
- sprite placement;
- ombre, pineta/pergola, laghetto/riva, barca, torre, festoni.

