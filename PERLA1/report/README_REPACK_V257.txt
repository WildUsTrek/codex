PERLA1 V257 — RAIN SKYBOX DEPTH ANCHOR FIX SAFE LOCAL

Base reale: PERLA1_V256_RAIN_OPEN_SHELTER_VISIBILITY_RESTORE_SAFE_LOCAL
Build prodotta: PERLA1_V257_RAIN_SKYBOX_DEPTH_ANCHOR_FIX_SAFE_LOCAL
Data: 2026-06-12

OBIETTIVO
Correggere il difetto minore residuo: gocce mid/far percepite come ferme/stampate su skybox o fondale quando il player guarda verso un limite mappa/fondale vicino, in particolare vicino al muro nord.

DIAGNOSI
Il difetto non appartiene piu a near, reservoir, shelter o controller. La causa e' il compositing di pioggia mid/far sopra uno skybox non z-bufferato quando davanti alla camera manca profondita mondo reale sufficiente.

INTERVENTO
Aggiunto Rain Skybox Depth Anchor Gate V257 dopo V256 nella pipeline:
V250 -> V252 -> V253 -> V254 -> V255 -> V256 -> V257 -> draw finale.

Il gate:
- calcola forward world depth limit davanti alla camera;
- valuta rischio skybox/backplate per segmenti mid/far/nearBlend morbida;
- riduce alpha/width/maxLen o salta segmenti ad alto rischio;
- preserva i segmenti open shelter restore V256;
- non tocca lifecycle, spawn/refill/canKeep, mappe, rainCovered/rainOpenSky, skybox renderer, asset o tetti.

DEBUG
Comandi principali:
window.__PERLA_DEBUG__.toggleRainUnifiedDebugV257()
window.__PERLA_DEBUG__.getRainSkyboxDepthAnchorSummaryV257()
window.__PERLA_DEBUG__.downloadRainSkyboxDepthAnchorReportV257()
window.__PERLA_DEBUG__.setRainSkyboxDepthAnchorFixV257(false/true)

CHECK ESEGUITI
- node --check: OK
- VM smoke exports/toggle/draw: OK
- gate unitario V257 su caso fondale/muro vicino: OK
- asset refs 108 / missing 0
- PNG gioco 116, modificati vs V256 0
- PowerShell $Var: problematici 0
- ZIP/TAR.GZ integrity: verificati al packaging

TEST VISIVO CONSIGLIATO
1. Nord vicino al muro nord: guardare fondale/skybox e verificare che le gocce non sembrino piu adesivi immobili.
2. Outdoor stabile lontano dai bordi: pioggia invariata o quasi.
3. Porte/tettoie aperte V256: rain ancora visibile fuori da aperture.
4. Uscita tettoia: non devono tornare le tre scariche.
5. Storm: intenso ma senza gocce stampate sullo sfondo.

NOTA ONESTA
Non e' stato eseguito test visivo browser reale in questo ambiente; la build e' verificata tecnicamente via parsing, VM smoke e controlli di integrita.
