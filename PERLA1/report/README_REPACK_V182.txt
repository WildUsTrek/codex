PERLA1 V182 — CENTER RAY + EDGE-DEPROJECTED ENVIRONMENT HORIZON

Base reale:
- PERLA1_V181_RAY_DIRECTION_ENVIRONMENT_HORIZON_LOCAL.zip

Scopo:
- Correggere la deformazione orizzontale ai bordi tornata in V181, senza buttare via il centro ray-direction/camera-plane corretto.

Intervento:
- Nuovo renderer attivo: PERLA_EDGE_DEPROJECTED_ENV_HORIZON_V182.
- V181 preservata ma disattivata: PERLA_RAY_DIRECTION_ENV_HORIZON_V181 = false.
- drawBackdrop chiama V182 come renderer primario.
- Il centro dello schermo resta ray-mapped come V181.
- I bordi applicano una de-proiezione leggera e progressiva stile V169, con EDGE_BLEND_MAX = 0.32.
- Altezza e ancoraggio verticale restano screenH*.50+18.
- Cloud layer non disegnato, come nei rami precedenti di isolamento.

Sistemi non toccati:
- mappa, collisioni, worldgen;
- tetti, torre, roofSegments;
- fog globale, sprite, ombre;
- pergola, festoni, lago/barca;
- pavimenti, decal, asset PNG, launcher.

Check eseguiti:
- node --check OK;
- mock drawWorld V182 OK;
- asset refs 108, missing 0;
- PNG presenti 116, invariati rispetto a V181;
- report/ presente;
- nessuna patch-only;
- ZIP e TAR.GZ integri.

Nota:
- Test browser reale non eseguito. Verificare in game davanti alla torre.
