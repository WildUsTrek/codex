PERLA1 — README REPACK V237A1
Build: PERLA1_V237A1_BATH_TILE_ALPHA_OPAQUE_SAFE_LOCAL
Base: PERLA1_V237A_SAFE_EMERGING_WALL_LAYER_DEBUG_OFF_LOCAL

TIPO PATCH
Micro-patch asset-only per correggere la semi-trasparenza preesistente del muro bagni.

COSA È STATO FATTO
- `assets/raycast/wall_tile_bath.png`: canale alpha reso opaco.
- RGB preservato.
- Dimensione 64x64 preservata.
- Nome file e manifest preservati.
- Versioning/debug aggiornati a V237A1.

COSA NON È STATO TOCCATO
- Renderer/wallcasting/drawWorld.
- `roofVisibleAt()` e V236 roof/support sync.
- V237A helper/prototipo, che resta debug-off e con flag false.
- Mappa, collisioni, worldgen, pioggia, torre, auto, skybox, altri PNG.

TEST CONSIGLIATO
Aprire i bagni in gioco e controllare da fronte/diagonale/laterale che la parte bianca/piastrellata del muro sia solida e non mostri più sagome interne. Verificare anche che V237 resti inactive/false in debug.
