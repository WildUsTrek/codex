PERLA1 V169 — SKYBOX EDGE-DEPROJECTED LOCK SAFE

Base reale: V163 USER MASK ATMOSPHERIC ALPHA SAFE.
Non deriva da V164/V165/V166/V167/V168 come codice base: quei rami sono stati esperimenti diagnostici.

Obiettivo:
- correggere il difetto rimasto in V166/V168, dove le montagne alte a nord si deformavano come un muro vicino, soprattutto ai bordi dell’inquadratura;
- seguire la diagnosi reale: V168 era quasi identica a V166 perché il target linearizzato cameraX*atan(k) coincideva con atan(cameraX*k) proprio agli estremi.

Intervento:
- solo index.html;
- asset sky/cloud V163 copiati byte-identici e rinominati V169;
- nessun cambio a fog, palette, mare, mappa, collisioni, tetti, torre, sprite, ombre, pergola, lago, barca o festoni;
- nuovo mapping edge_deprojected_lock_safe:
  centro = ancoraggio V166 con atan(cameraX*k);
  bordi = de-proiezione progressiva verso cameraX*k, che è realmente diverso agli estremi;
  micro-span continui da 2 px; nessun Math.floor(sxFloat);
  cloud/velatura caricato ma non disegnato, per isolare il fondale.

Test reale consigliato:
- stesso punto davanti alla torre;
- ruotare verso nord;
- controllare se le montagne dietro/ai bordi deformano meno rispetto a V166/V168.
