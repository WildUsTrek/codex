PERLA1 V223 — World Rain Nearfield + Bath Authority

Build: PERLA1_V223_WORLD_RAIN_NEARFIELD_BATH_AUTHORITY_LOCAL
Base reale: PERLA1_V222_WORLD_RAIN_ARCH_PROFILES_LOCAL

Scopo:
- Consolidare la V222 senza riaprire il cantiere portali/replay.
- Rendere la pioggia world-space piu' credibile: piu' alta, piu' veloce, meno effetto piuma.
- Aggiungere near-field rain davanti al player per evitare zone asciutte vicino a muri/siepi.
- Rendere bath_garden outdoor per il meteo e bath_main unica autorita' porta bagni.

Interventi:
1. Aggiunto flag V223 PERLA_V223_WORLD_RAIN_NEARFIELD_BATH_AUTHORITY.
2. Aumentati topZ, speed, lunghezza e densita' particelle rain/storm.
3. Aggiunto near-field spawn 0.28-2.55 tile, con bias frontale e raggio quadratico per riempire lo spazio prima dei muri vicini.
4. drawWeatherOverlayV190 bypassa visualView/portal/shelter legacy per il path primario world-rain V223.
5. Aggiunta isWeatherOutdoorAtV223(): bath_garden e' outdoor scoperto; indoor edificio bagni e canopy restano coperti.
6. bath_main resta closed_building con realDoor; il varco del muro cespuglioso e' escluso dalla semantica porta.
7. Debug V223 aggiunto: rainRendererModeV223, rainNearFieldEnabledV223, rainTopZV223, bathGardenWeatherOutdoorV223, bathMainAuthorityV223, legacyBathDoorResolverDisabledV223.

Preservato:
- Mappa, collisioni, roadMask, objectBlock, worldgen, sprite, asset PNG.
- Tetti/roof budget/canopy renderer, skybox/fondale, audio meteo, pergola, festoni, torre, lago/barca, pavimenti, minimappa, controlli mobile.

Check previsti/eseguiti nel repack:
- node --check su JS estratto.
- asset refs/missing.
- ZIP/TAR.GZ integrity.
- assenza cartella patch-only.

Test visivo obbligatorio:
- Pioggia piu' veloce e alta, non piu' piumosa.
- Davanti a muri cespugliosi outdoor: la pioggia continua a cadere nello spazio fra player e muro.
- Dietro i muri: la pioggia resta nascosta da ZBuffer.
- bath_garden: deve piovere normalmente.
- varco cespuglio bagni: non e' porta meteo.
- porta reale edificio bagni: unica soglia valida.
- bar/yoga/sala giochi: tettoie aperte senza porte false.

Nota onesta:
Non e' stato eseguito test browser visivo nel container. La build e' verificata staticamente e pronta per test reale utente.
