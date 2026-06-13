PERLA1 V195 — WEATHER CLOUD LAYER VISIBILITY

Base reale: PERLA1_V194_AUDIO_MIX_AMBIENCE_FOOTSTEPS_LOCAL.zip

Obiettivo:
- Rendere cloudy/rain/storm molto più leggibili e minacciosi nel cielo.
- Usare solo il cloud layer esistente, dentro il renderer V185 distortion-controlled.
- Non reintrodurre ellissi/blob screen-space V192.

Interventi:
- drawDistortionControlledEnvironmentImageV185() ora applica il parametro canvasFilter.
- cloudy/rain/storm hanno filtri cloud più scuri/contrastati.
- cloudy/rain/storm hanno più passaggi/bank dello stesso asset cloud.

Preservato:
- Fondale V185, target 1.08, mappa, collisioni, worldgen, tetti, torre, roofSegments, sprite, pergola, festoni, lago/barca, pavimenti, decal, asset PNG, launcher, audio V194.

Test consigliato in browser:
perlaSetWeather('cloudy')
perlaSetWeather('rain')
perlaSetWeather('storm')
perlaEnv()

Nota:
La resa visiva va verificata in gioco. I check automatici confermano integrità tecnica, asset e assenza dei vecchi blob ellittici.
