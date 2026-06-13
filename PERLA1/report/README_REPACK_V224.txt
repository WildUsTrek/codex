PERLA1 — README REPACK V224

Build: PERLA1_V224_RAIN_VFX_LOD_FRUSTUM_REFILL_LOCAL
Base reale: PERLA1_V223_WORLD_RAIN_NEARFIELD_BATH_AUTHORITY_LOCAL
Data: 2026-06-11

OBIETTIVO
Stabilizzare la pioggia world-space introdotta in V222 e consolidata in V223, senza riaprire il vecchio cantiere overlay/portali/replay.

INTERVENTI
- Aggiunto Rain Volume Manager V224.
- Aggiunto distance LOD: gocce vicine lunghe, medie più corte, lontane corte/sottili.
- Aggiunto clamp pixel-length dei segmenti pioggia per impedire streak lunghi sullo sfondo.
- Aggiunto frustum refill su rotazioni brusche della camera.
- Aggiunta motion compensation su movimento/corsa del player.
- Aggiunto front visible minimum per mantenere piena la vista davanti.
- Convertito il render rain in bucket near/mid/far con alpha e lineWidth distinti.
- Preservata l’architettura V223: bath_garden outdoor, bath_main autorità bagni, bar/yoga/sala giochi open canopy, legacy overlay/door/replay non primari.

NON TOCCATO
- Mappa, collisioni, roadMask, objectBlock.
- Tetti, roofSegments, cMap, fog, skybox/fondale.
- Sprite placement, asset PNG, audio, ciclo meteo, comandi debug.

CHECK STATICI ATTESI
- node --check JS estratto: OK.
- asset PNG: invariati.
- missing asset refs: 0.
- ZIP/TAR.GZ integrity: OK al packaging.

TEST VISIVO CONSIGLIATO
1. Rain normale: gocce vicine lunghe, lontane corte.
2. Storm: più intensa ma non muro bianco.
3. Girare 90°/180° di scatto: nessuna zona asciutta improvvisa davanti.
4. Correre: non si deve più “superare” la pioggia.
5. Muri cespugliosi: pioggia davanti al muro, gocce dietro occluse.
6. Bagni: bath_garden outdoor, varco cespuglio non porta meteo, edificio asciutto dentro.

NOTA ONESTÀ
Patch verificata staticamente. Il test browser/visivo reale deve essere effettuato dall’utente.
