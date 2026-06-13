PERLA1 V222 — World Rain Arch Profiles

Build: PERLA1_V222_WORLD_RAIN_ARCH_PROFILES_LOCAL
Base reale: PERLA1_V221_LOCAL_V216_SHELTER_OCCLUSION_GATE_LOCAL

Scopo:
- Chiudere il cantiere V201-V221 basato su rain overlay 2D, portali, yTop/yBottom, replay V216/V221 come path primario.
- Introdurre anagrafe autorevole di edifici/ripari e pioggia world-space a particelle leggere.

Interventi:
1. Aggiunti profili architettonici V222: reception_main, bath_main, bar_canopy_main, game_room_canopy_main, yoga_canopy_main.
2. bath_main usa porta reale edificio; il varco del muro cespuglioso bath_garden e' escluso dalla semantica porta.
3. bar/yoga/sala giochi sono tettoie aperte senza door resolver.
4. Aggiunte rainCoveredMapV222/rainOpenSkyMapV222/rainProfileIdMapV222.
5. Aggiunto renderer drawWorldRainParticlesV222: gocce in coordinate mondo, spawn solo open sky, clipping con ZBuffer e CeilingDepthBuffer.
6. drawWeatherOverlayV190 usa V222 come path primario per rain/storm e disattiva compositing rain buffer 2D in quel caso.
7. drawWorld non usa piu' V216/V221 replay come path primario quando V222 e' attivo.
8. Debug V222 esportato in drawStats e window.__PERLA_DEBUG__.

Preservato:
- Mappa/collisioni/roadMask/objectBlock/worldgen/sprite/asset PNG.
- Tetti, canopy, roof budget, fondale, audio meteo, pergola, festoni, torre, lago/barca, pavimenti.

Check eseguiti:
- node --check su JS estratto: OK.
- asset manifest missing: 0.
- report/ presente.
- nessuna cartella patch-only prevista.

Test visivo obbligatorio:
- Bagni: fuori dal muro cespuglioso deve piovere normalmente; la porta vera e' quella dell'edificio bagni.
- Reception: niente gocce che nascono dal soffitto/architrave.
- Bar/yoga/sala giochi: tettoie aperte, nessuna porta falsa.
- Generale: muri e tetti devono occultare/tagliare la rain per profondita'.

Nota onesta:
Non e' stato eseguito test browser visivo nel container. La build e' verificata staticamente e pronta per test reale utente.
