PERLA1 — README REPACK V191 — TIME ACCELERATION X10 TEST HELPER

Build: PERLA1_V191_TIME_ACCELERATION_X10_TEST_LOCAL
Base reale: PERLA1_V190_SMOOTH_CLOCK_FULL_WEATHER_LOCAL

Scopo:
Aggiungere comandi console per accelerare il tempo di gioco, in particolare x10, così da testare rapidamente ciclo giorno/notte, transizioni morbide e meteo giornaliero.

Comandi principali:
- perlaTimeX10()          -> accelera il tempo ambiente x10
- perlaTimeNormal()       -> torna al tempo normale x1
- perlaSetTimeScale(10)   -> imposta moltiplicatore manuale
- perlaTimeScale(10)      -> alias console
- perlaCommand('x10')     -> alias comando
- perlaCommand('tempo',10)-> alias comando italiano
- perlaCommand('x1')      -> torna x1
- perlaCommand('normale') -> torna x1
- perlaEnv()              -> mostra stato completo

Note:
- Default invariato: x1.
- x10 riduce la giornata da 45 minuti reali effettivi a circa 4,5 minuti reali.
- Il moltiplicatore accelera solo Environment/time/weather cycle; non accelera movimento, animazioni o gameplay.
- timeScale=0 congela il ciclo ambiente per screenshot/test.

Preservato:
Fondale V185, meteo V190, mappa, collisioni, worldgen, tetti, torre, sprite, pergola, festoni, lago/barca, pavimenti, decal, asset PNG, launcher.

Test browser reale consigliato:
perlaEnv(); perlaTimeX10(); attendere qualche transizione; perlaTimeNormal(); perlaEnv().
