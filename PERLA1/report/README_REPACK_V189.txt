PERLA1 — README REPACK V189 ENVIRONMENT DAY CYCLE HELPERS

Build: PERLA1_V189_ENVIRONMENT_DAYCYCLE_HELPERS_LOCAL
Base reale: PERLA1_V185_DISTORTION_TARGET_8PCT_RESTORE_LOCAL.zip

Scopo:
- Unire in una sola patch proporzionata V187 + V188 + V189.
- V187: correggere la stringa debug innocua del renderer V185 che citava ancora 1.04/4% pur avendo costante reale 1.08.
- V188: introdurre un ciclo giorno/notte a bucket con giornata di gioco di 45 minuti reali.
- V189: aggiungere helper preparatorio per fog target corrente e comandi console/game-command per test rapido.

Interventi codice:
- PERLA_BUILD_ID aggiornato a PERLA1_V189_ENVIRONMENT_DAYCYCLE_HELPERS_LOCAL.
- UI title/h2/loading/alert aggiornati a V189.
- Estese le palette ambiente legacy V163 con bucket: deepNight, dawn, morning, day, golden, sunset, night.
- Aggiunto stato perlaEnvironmentStateV188 con timeOfDay, bucket, contatori skip/cache e debug.
- Aggiunto updateEnvironmentCycleV188(deltaMs): una giornata completa dura 45 minuti reali; avanzamento frame clampato a 1000ms per evitare salti enormi dopo pausa/tab hidden.
- Aggiunto comando dormi/game sleep: skip +8 ore tramite perlaSleepCommandV188(), window.dormi(), window.perlaDormi(), window.perlaHandleGameCommand('dormi') o evento CustomEvent('perla:command').
- Aggiunti comandi console: perlaEnv(), perlaSetTime(19), perlaSkipHours(8), perlaNextCycle(), perlaCommand('sunset'), perlaCommand('skip', 8), dormi().
- Aggiunti helper V189: getCurrentFogTargetRGBV189() e getCurrentFogNearRGBV189(); roofFogTargetRGBV163 ora passa dall'helper senza creare un fog parallelo.
- Debug snapshot e drawStats includono environmentCycleV188 e comandi disponibili.
- Debug line in basso mostra bucket/orario ambiente corrente.

Preservato:
- Renderer fondale V185 distortion-controlled e target 1.08.
- Asset PNG e manifest.
- mappa, fMap, roadMask, cMap, objectBlock, collisioni, worldgen.
- tetti, torre, roofSegments, Sloped Roof Casting, gable caps.
- sprite placement, ombre, pergola, festoni, lago/barca, pavimenti, decal, launcher.
- Nessuna nuova architettura skybox/fondale; nessun WebGL; nessuna lightmap; nessun meteo/particelle.

Comandi rapidi da console browser:
- perlaEnv()
- perlaNextCycle()
- perlaSetTime(5)
- perlaSetTime(19)
- perlaCommand('dawn')
- perlaCommand('sunset')
- perlaCommand('skip', 8)
- dormi()

Nota test reale:
- Build tecnicamente validata con node --check, unit test ambiente, controllo asset e integrità archivi.
- Test browser reale/manuale in game non eseguito in ambiente ChatGPT: verificare in browser i bucket dawn/morning/day/golden/sunset/night/deepNight con i comandi sopra.
