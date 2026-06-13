# README REPACK V246 — RAIN VFX STABILIZER SAFE

Build prodotta: `PERLA1_V246_RAIN_VFX_STABILIZER_SAFE_LOCAL`
Base reale: `PERLA1_V245_HIGH_WALL_DIAGNOSTICS_RUNTIME_OFF_SAFE_LOCAL`
Data: 2026-06-12

## Scopo
Patch rain-only per stabilizzare la pioggia V245 senza riaprire high-wall/V300/V301 e senza toccare mappa, collisioni, asset, tetti, skybox, sprite placement o audio.

## Interventi applicati
- Aggiunto blocco V246 `PERLA_V246_RAIN_VFX_STABILIZER`.
- Aggiunto warmup meteo rain/storm per evitare ingresso improvviso.
- Aggiunto shelter hysteresis + `shelterBlend` per evitare flip al bordo tettoia.
- Trasformato il refill V224/V235 da batch istantaneo a refill queue rate-limited.
- Aggiunto fade-in a tier per gocce nuove/refillate.
- Aggiunti target visibili near/mid/far per riequilibrare il risultato percepito.
- Ammorbidita near rain durante warmup, edge shelter e copertura parziale.
- Aggiunto debug/export: `getRainVfxStabilizerSummaryV246()`, `downloadRainVfxStabilizerReportV246()`, `setRainVfxStabilizerV246(enabled)`.

## Preservato
- `map`, `fMap`, `cMap`, `roadMask`, `objectBlock`, `noNature`, `zoneMask` non modificati.
- Asset PNG invariati.
- `ASSET_MANIFEST` invariato.
- Sloped Roof Casting / V236 roof support sync preservati.
- Torre, pergola, festoni, skybox, sprite placement preservati.
- High-wall diagnostics V245 restano runtime-off.
- V234 rain airspace e V235 midfield restano preservati, ma governati da V246 refill queue.

## Check eseguiti
- `node --check report/EXTRACTED_INDEX_INLINE_SCRIPT_V246.js`: OK.
- Runtime mock desktop: OK.
- Runtime mock mobile portrait: OK.
- Runtime mock mobile landscape: OK.
- Rain probe Node con `drawWorld()` e weather rain: OK.
- Asset refs unici: 108, missing: 0.
- PNG totali: 116, PNG cambiati rispetto a V245: 0.
- Mappa runtime mock: 150×88.
- Sprite runtime mock: 1938.
- Roof segments runtime mock: 2.
- High-wall runtime: `runtimeEnabled=false`, `drawAttempted=false`, `drawnColumns=0`, `zBufferUpdated=false`, `spriteOcclusionUpdated=false`, `rainOcclusionUpdated=false`.

## Test browser reale
Non eseguito in questa sessione. Serve test visivo in browser locale, soprattutto: bordo tettoia bar/yoga/sala giochi, pioggia da fermo outdoor, entrata/uscita lenta da tettoia, storm.

## Archive finali
- ZIP integrity: OK.
- TAR.GZ integrity: OK.
- Cartella patch-only: assente.
