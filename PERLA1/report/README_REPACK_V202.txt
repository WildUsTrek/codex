# PERLA1 V202 — Portal Rain Aperture + Audio Presence

Build: `PERLA1_V202_PORTAL_RAIN_APERTURE_AUDIO_PRESENCE_LOCAL`
Base reale: `PERLA1_V201_WEATHER_PORTAL_CONTINUITY_STORM_BUDGET_LOCAL`

## Scopo
Correggere la V201 senza riaprire tetti/fondale:
- pioggia indoor attraverso porte con maschera X+Y, non solo X;
- passi molto piu' presenti;
- uccellini piu' forti e con vere micro-melodie;
- tuono/lampo con eco forte multi-tap.

## Cosa testare
1. Entrare in reception/bagni durante storm/rain e guardare fuori dalla porta:
   - la pioggia deve essere visibile fuori;
   - non deve piu' piovere a colonna sopra/sotto l'ingresso.
2. Clear day:
   - uccellini piu' presenti e con frasi diverse.
3. Camminata:
   - passi piu' udibili anche con meteo attivo.
4. Storm:
   - tuono con eco/coda piu' credibile.

## Console/debug utili
```js
perlaSetWeather('storm')
perlaWeatherPerformanceV198()
perlaSetWeather('clear')
perlaWeatherAudioOn()
perlaFootstepsOn()
```

## Preservato
V200 roof budget, V201 rain buffer/cloud budget, V185 fondale, mappa/collisioni/worldgen/sprite/pergola/torre/canopy.
