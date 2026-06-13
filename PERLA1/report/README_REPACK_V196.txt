PERLA1 V196 — AUDIO TIMING / BIRDS / RAIN MIX

Build: PERLA1_V196_AUDIO_TIMING_BIRDS_RAIN_MIX_LOCAL
Base reale: PERLA1_V195_WEATHER_CLOUD_LAYER_VISIBILITY_LOCAL.zip

Intervento chirurgico:
- passi audio almeno 3 volte più lenti;
- uccellini circa 6 volte meno frequenti;
- pause uccelli variabili e non sempre uguali;
- 6 varianti procedurali di uccellini;
- pioggia audio abbassata ancora e resa meno brillante/meno aggressiva;
- volume tuoni/lampi preservato.

Sistemi non toccati:
- fondale V185;
- cloud layer/meteo visivo V195;
- ciclo giorno/notte;
- meteo settimanale;
- x10;
- mappa/collisioni/worldgen;
- tetti/torre/roofSegments;
- sprite/pergola/festoni/lago/pavimenti/decal;
- asset PNG;
- launcher.

Comandi test:
perlaWeatherAudioOn()
perlaSetWeather('clear')   // uccellini
perlaSetWeather('rain')    // pioggia più bassa
perlaSetWeather('storm')   // tempesta, tuoni invariati
perlaFootstepsOn()
perlaEnv()

Nota: test browser/audio reale non eseguito in packaging; da fare in gioco perché Web Audio richiede contesto browser e interazione utente.
