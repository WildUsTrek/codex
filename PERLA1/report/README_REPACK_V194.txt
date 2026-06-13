# PERLA1 — README REPACK V194 AUDIO MIX / AMBIENCE / FOOTSTEPS

Build: `PERLA1_V194_AUDIO_MIX_AMBIENCE_FOOTSTEPS_LOCAL`
Base reale: `PERLA1_V193_SKYBOX_CLOUDS_WEATHER_AUDIO_FIX_LOCAL`
Data: 2026-06-10

## Obiettivo

Correggere il difetto segnalato in V193: rumore pioggia troppo alto e leggermente distorto.
Aggiungere inoltre ambiente sonoro prudente:

- uccellini nei giorni di sole, soprattutto di giorno e all'aperto;
- vento nei giorni nuvolosi, con presenza più bassa anche in pioggia/tempesta;
- footstep audio quando il giocatore cammina;
- tuoni/lampi mantenuti sul volume V193 perché già approvato.

## Interventi

- Pioggia procedurale ricostruita con rumore più morbido e gain target molto più basso.
- Wind bed procedurale con gain prudente.
- Bird chirps procedurali a piccoli gruppi, solo con meteo sereno + luce diurna + player all'aperto.
- Footstep procedurali agganciati alla distanza reale percorsa dal player.
- Comandi console aggiunti:

```js
perlaWeatherAudioOn()
perlaWeatherAudioOff()
perlaAmbientAudioOn()
perlaAmbientAudioOff()
perlaFootstepsOn()
perlaFootstepsOff()
```

## Preservato

Non sono stati toccati fondale V185, cloud skybox V193, meteo visivo, ciclo giorno/notte, x10, mappa, collisioni, worldgen, tetti, torre, roofSegments, sprite placement, pergola, festoni, lago/barca, pavimenti, decal, PNG asset o launcher.

## Check

- node --check: OK.
- Asset PNG: 116.
- Riferimenti PNG: 108.
- Missing asset: 0.
- Nessuna cartella patch-only.

## Test reale consigliato

Aprire il gioco, fare un click/tasto per sbloccare Web Audio e provare:

```js
perlaWeatherAudioOn()
perlaSetWeather('clear')   // uccellini
perlaSetWeather('cloudy')  // vento
perlaSetWeather('rain')    // pioggia più bassa e morbida
perlaSetWeather('storm')   // tempesta + tuoni
perlaFootstepsOn()         // camminare per sentire i passi
```

Se un livello è ancora troppo alto/basso, regolare solo i target V194, non il bus dei tuoni.
