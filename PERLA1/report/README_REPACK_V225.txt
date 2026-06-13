PERLA1 — README REPACK V225

Build: PERLA1_V225_RAIN_WALL_SPAN_CLIP_AIRSPACE_LOCAL
Base reale: PERLA1_V224_RAIN_VFX_LOD_FRUSTUM_REFILL_LOCAL
Data: 2026-06-11

OBIETTIVO
Correggere la pioggia world-space V224 nei casi in cui i muri cespugliosi venivano trattati come occlusori verticali infiniti. Un muro alto 1 cubo deve bloccare solo la propria sagoma visiva, non tutto il cielo dietro di sé.

INTERVENTI
- Aggiunta occlusione rain V225 basata su WallTopBuffer/WallBottomBuffer + ZBuffer.
- Eliminato il comportamento full-column ZBuffer per i sample di pioggia.
- Consentito rain-air sopra celle muro solo se la quota della goccia è sopra l'altezza stimata del muro + clearance.
- Aggiunto clipping parziale dei segmenti quando una goccia attraversa il bordo alto del muro o il bordo alto schermo.
- Aggiunto emergency refill no-cooldown quando la vista frontale resta troppo vuota durante corsa/rotazione.
- Preservati V223 bath authority/bath_garden outdoor e V224 LOD/refill/motion compensation.

PRESERVATO
Mappa, collisioni, worldgen, roadMask, objectBlock, sprite, asset PNG, tetti, roof budget, skybox/fondale, audio meteo, ciclo giorno/notte, comandi meteo, bar/yoga/sala giochi open canopy.

TEST ESEGUITI
- node --check su JS estratto: OK.
- Integrità ZIP/TAR.GZ: da verificare nel packaging finale.
- Nessun test browser/visivo reale eseguito in container.

TEST VISIVO OBBLIGATORIO
- Muro cespuglioso da vicino: pioggia sopra la siepe visibile, corpo siepe opaco.
- Yoga sotto tettoia: pioggia visibile fuori sopra i muri cespugliosi, non solo nel varco.
- Corridoi fra siepi: niente colonne artificiali.
- Gocce vicine: entrano dal bordo alto schermo quando attraversano y=0.
- Corsa/rotazione: emergency refill deve evitare vista asciutta.
