PERLA1 V249 — RAIN NEAR REVEAL ENVELOPE SAFE LOCAL

Base reale: PERLA1_V248_RAIN_UNIFIED_TRANSITION_CONTROLLER_SAFE_LOCAL.
Tipo patch: rain-only, near-only, draw-time envelope.

Obiettivo:
- correggere le 2/3 raffiche fastidiose della sola pioggia near quando parte la pioggia o quando il player esce da una tettoia/copertura;
- preservare controller V248, rotazione/angular prefill, middle/far density, asset, mappa, collisioni, tetti, skybox, sprite placement e audio.

Interventi:
- aggiunto Near Reveal Envelope V249 per bucket near;
- envelope near per weather_start, shelter_exit, shelter_edge e stable_covered;
- applicato draw-time damping solo su alpha/width/maxLen near;
- aggiunto near segment rise cap per evitare crescita percettiva a botta;
- aggiunti debug getRainNearRevealEnvelopeSummaryV249/download/toggle.

Test visivo non eseguito in browser reale: validazione tecnica e runtime mock, test utente richiesto su avvio rain e uscita tettoia.
