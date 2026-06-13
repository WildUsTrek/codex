PERLA1 V203 — AUDIO RESTORE + PORTAL RAIN REAL MASK REPAIR

Build: PERLA1_V203_AUDIO_RESTORE_PORTAL_MASK_REPAIR_LOCAL
Base: PERLA1_V202_PORTAL_RAIN_APERTURE_AUDIO_PRESENCE_LOCAL

Scopo:
- riparare l'errore V202 sui passi: stesso identico suono V201/V200, solo piu' alto;
- preservare il chirp/melodia originale degli uccellini come variante 0, aggiungendo nuove micro-melodie come varianti successive;
- correggere il fallimento reale della maschera verticale della pioggia indoor: maskedRanges X+Y ora viene davvero restituito e usato.

Interventi:
1. `perlaPlayFootstepV194()` riportata alla sintesi V201/V200, con volume piu' alto via `PERLA_AUDIO_FOOTSTEP_GAIN_V194 = 1.00` e `PERLA_AUDIO_FOOTSTEP_AMP_MULT_V197 = 8.65`.
2. `perlaPlayBirdChirpV194()` mantiene variante 0 originale V201/V200 e aggiunge sei micro-frasi melodiche; bus/chirp gain alzati.
3. `perlaWeatherVisualViewV201()` restituisce `maskedRanges`, non piu' `probe.ranges`.
4. `perlaWeatherPortalApertureForRangeV202()` usa hard guard V203 su `yTop/yBottom` per evitare colonne full-height.

Preservato:
- V200 roof budget;
- V201 rain buffer/cloud budget/portal continuity;
- V202 thunder multi-tap;
- fondale V185, mappa, collisioni, worldgen, sprite, torre, pergola, canopy, asset PNG.

Limiti:
- nessun test browser/audio reale nel container;
- controlli eseguiti: sintassi JS, riferimenti asset, integrita' ZIP/TAR.GZ, nessun PNG modificato.
