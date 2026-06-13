PERLA1 V229B — HEIGHT STEP CONST GUARD LOCAL

Base reale: PERLA1_V229_HEIGHT_STEP_WALL_FACES_SPRITE_SEAL_LOCAL
Tipo: hotfix chirurgico crash runtime.

Problema corretto:
Uncaught TypeError: invalid assignment to const 'y1' in sampleHeightStepFaceColumnV229.

Causa:
La V229 dichiarava `y1` come const, ma nello stesso metodo lo riassegnava durante il clipping contro il front-wall.

Intervento:
Solo `const y1` -> `let y1` nel blocco di sampling HeightStepFace.

Preservato:
- HeightStepFaces V229
- Sprite occlusion ground seal V229
- V228 far-wall spans / wall occlusion distance > sprite distance
- V226 camera rain volume
- V223 bath authority
- mappa/collisioni/worldgen/roadMask/objectBlock
- asset PNG, tetti, skybox, audio

Check attesi:
node --check, integrità ZIP/TAR.GZ, asset missing 0.

Nota:
Non è una patch visuale nuova: serve a sbloccare il test reale della V229 senza crash.
