PERLA1 — README REPACK V192 WEATHER VISIBILITY REBALANCE

Build: PERLA1_V192_WEATHER_VISIBILITY_REBALANCE_LOCAL
Base: PERLA1_V191_TIME_ACCELERATION_X10_TEST_LOCAL

Scopo:
Rendere il meteo V190/V191 molto più visibile: nuvoloni percepibili in cloudy/rain/storm e pioggia normale quasi intensa come tempesta, ma senza lampi.

Comandi test consigliati in console:
perlaSetWeather('cloudy')
perlaSetWeather('rain')
perlaSetWeather('storm')
perlaTimeX10()
perlaEnv()

Interventi:
- Profili meteo ribilanciati.
- Nuovo drawWeatherCloudDeckV192 per deck scuro/lumpy deterministico.
- drawWeatherCloudLayerV190 rinforzato con pass multipli.
- drawWeatherOverlayV190 rinforzato per pioggia normale heavyRain.

Preservato:
Fondale V185, ciclo V188/V190, timeScale V191, meteo a giorni, asset PNG, mappa, collisioni, worldgen, tetti, torre, sprite, pergola, festoni, lago, pavimenti, decal, launcher.

Check:
node --check OK; asset refs/missing OK; archivi integri.
