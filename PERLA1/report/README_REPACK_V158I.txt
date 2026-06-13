PERLA1_V158I_BALANCED_GEOGRAPHIC_VISIBILITY_SAFE_LOCAL

Base tecnica: PERLA1_V158H_ATMOSPHERIC_LANDMARKS_COLOR_REPAIR_SAFE_LOCAL, derivata dalla linea V158F/V157 blindata.

Obiettivo:
- mantenere il cielo/fog pulito della V158H;
- rendere nuovamente leggibili i landmark geografici senza tornare a smog, bande, fondali incollati o dettagli fuori scala;
- usare profili geografici gradualmente sfumati: bordo alto leggibile, corpo dissolto nel colore dell'orizzonte;
- preservare pareti lontane senza culling/distance cap.

File modificati/aggiunti:
- 01_GIOCO_PRONTO_LOCAL_TEST/index.html
- 01_GIOCO_PRONTO_LOCAL_TEST/assets/raycast/sky_panorama_360_v158i.png
- 01_GIOCO_PRONTO_LOCAL_TEST/assets/raycast/cloud_layer_soft_v158i.png
- STATUS_PROGETTO_E_DIPENDENZE_PERLA1.txt
- METODO_LAVORO_ANTI_REGRESSIONE_PERLA1.txt
- README_REPACK_V158I.txt
- REPORT_V158I_BALANCED_GEOGRAPHIC_VISIBILITY_SAFE.json

Asset V158H sky/cloud rimossi dal pacchetto corrente per evitare riferimenti obsoleti; il manifest usa tex 98/99 V158I.

Preservato:
- nessun limite alla visibilita' delle pareti lontane;
- nessun culling o distance cap;
- nessuna modifica a map/fMap/roadMask/cMap/objectBlock/collisioni/worldgen;
- nessuna modifica a roof geometry/gable/self-depth/roofSegments;
- sprite placement, ombre, pineta/pergola, laghetto/riva, barca, torre, festoni.

Check principali:
- node --check OK;
- smoke Node con DOM/canvas mock OK;
- map 150x88;
- sprites 1938;
- roofSegments 2;
- asset refs 108;
- asset missing 0;
- seam skybox 0.0;
- full-band rows 0;
- nessun dark visible pixel con lum<120 e alpha>20;
- ZIP/TAR.GZ integrity OK.
