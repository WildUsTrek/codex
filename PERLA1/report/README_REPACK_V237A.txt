PERLA1 — README REPACK V237A
Build: PERLA1_V237A_SAFE_EMERGING_WALL_LAYER_DEBUG_OFF_LOCAL
Base reale: PERLA1_V236_ROOF_SUPPORT_SYNC_REAL_SAFE_LOCAL

Contenuto:
- 01_GIOCO_PRONTO_LOCAL_TEST/index.html aggiornato a V237A.
- launcher root aggiornati a V237A.
- report/ aggiornato con STATUS, METODO, README e REPORT JSON.

Scopo V237A:
Preparare il prototipo “safe emerging wall layer” per il problema muri alti dietro muri bassi, ma con flag visuale spento.
PERLA_V237_SAFE_EMERGING_WALL_LAYER_PROTOTYPE = false.

Cosa NON cambia:
- nessun nuovo draw visivo V237;
- nessun nuovo DDA;
- nessuna ColumnWallHitStack;
- nessuna modifica a mappa/collisioni/worldgen/assets/PNG;
- nessuna modifica a pioggia, torre, auto, skybox o roof/support sync V236.

Test consigliato:
Confrontare V237A con V236: reception, bagni, torre, auto/parcheggio, pioggia e aree con siepi devono restare visivamente identiche.
L'eventuale test attivo del prototipo va fatto solo con una futura V237B separata.
