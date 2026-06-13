PERLA1 V198 — WEATHER SKY PERFORMANCE RECOVERY

Base reale: PERLA1_V197_AUDIO_MIX_WIND_STEPS_BIRDS_LOCAL
Build: PERLA1_V198_WEATHER_SKY_PERFORMANCE_RECOVERY_LOCAL

Questa patch applica solo V198.1..V198.7:
- telemetria separata sky/weather/roof;
- cloud layer meteo budgetato nel mapping V185;
- cache offscreen pre-tint per nuvole scure;
- gating sotto tetto/interno;
- overlay pioggia ridotto sotto tetto;
- nessuna patch roof fallback V199;
- nessun nuovo asset e nessuna nuvola screen-space a ellissi.

Comando utile: perlaWeatherPerformanceV198()

Test browser reale richiesto: reception/tetto con storm, open sky storm/cloudy/rain, pergola storm.
