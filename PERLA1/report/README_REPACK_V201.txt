# PERLA1 V201 — Weather Portal Continuity + Storm Render Budget

Build: `PERLA1_V201_WEATHER_PORTAL_CONTINUITY_STORM_BUDGET_LOCAL`
Base reale: `PERLA1_V200_OUTDOOR_ROOF_BUDGET_CEILING_AUDIO_BOOST_LOCAL`

## Scopo
Patch mirata al sistema meteo visuale dopo il successo V200 sui tetti:
- eliminare il pop-up della pioggia entrando/uscendo dalle porte;
- evitare che la pioggia sparisca fuori mentre il player e' indoor ma guarda attraverso la porta;
- ridurre il costo storm/rain tramite rain buffer offscreen e cloud budget dinamico;
- non toccare tetti/fondale/mappa/sprite/audio architetturale.

## Modifiche principali
- `PERLA_WEATHER_PORTAL_CONTINUITY_V201`: ray probe leggero su colonne camera per stimare vista outdoor anche da indoor.
- `weatherOutdoorViewFactorV201`: fattore smussato temporale, non binario, per evitare pop-up.
- `PERLA_WEATHER_RAIN_BUFFER_V201`: pioggia disegnata su canvas offscreen e compositata sul main canvas.
- Portal rain mask: indoor con vista fuori disegna pioggia solo sulle colonne di apertura outdoor.
- `PERLA_WEATHER_STORM_RENDER_BUDGET_V201`: nuvole rain/storm con span/pass ridotti quando roof/governor/frame indicano carico.

## Preservato
- V200 roof budget reale e ceiling color fix.
- V200 audio boost passi/uccellini.
- V199 indoor skip e roof governor.
- V185 fondale target stretch 1.08.
- Mappa, collisioni, objectBlock, worldgen, asset PNG, sprite, pergola, festoni, lago/barca, torre/canopy.

## Debug console utili
```js
perlaWeatherPerformanceV198()
perlaRoofPerformanceV199()
perlaSetWeather('storm')
```

Campi attesi:
- `weatherPortalContinuityV201: true`
- `weatherOutdoorViewFactorV201`
- `weatherRainBufferV201: true`
- `weatherRainDrawsV201`
- `weatherRainBufferLineDrawsV201`
- `weatherRainCompositeDrawsV201`
- `weatherCloudBudgetV201`
- `weatherCloudBudgetLevelV201`

## Note test
Testare soprattutto:
1. Tempesta davanti a reception/bagni.
2. Entrata/uscita porta in tempesta.
3. Indoor guardando fuori.
4. Indoor guardando muro/soffitto.
5. Clear/cloudy per assenza regressioni.
