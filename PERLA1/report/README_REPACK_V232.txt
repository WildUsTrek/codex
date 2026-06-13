PERLA1 V232 — SPECIAL WALL / SUPPORT / TOWER / CAR SAFE
Base reale: PERLA1_V231_CONTINUOUS_WALL_RUN_RASTER_TEXTURE_SAFE_LOCAL

Interventi:
- Continuous wall-run generic draw limitato a muri semplici/siepi; modern building, tower, roof/canopy/special owner soppressi dal draw generico.
- I run speciali possono restare occlusion-only o ai renderer originali; niente ridisegno generico della torre o muri moderni.
- Guardia prudente roof/support per tetti moderni vicini a foreground hedge: taglio fascia bassa/eave che sembrava poggiare sul cespuglio.
- Tower near-behind-wall: roof cap usa una guardia coerente con foreground wall, senza riscrivere il renderer torre.
- Auto/parcheggio: aumento prudente solo dell'altezza visiva della categoria parked_car/car tex; bottom anchor, collisioni, objectBlock, groundSink e asset invariati.

Preservato: mappa, collisioni, worldgen, tetti, asset, skybox, audio, meteo, sprite placement generale, V228 distanza muri>sprite, V229 sprite seal, V231 anti-righe verticali.
