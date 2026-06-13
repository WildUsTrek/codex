PERLA1 V233 — OVERDRAW ROLLBACK STABILITY LOCAL

Base reale: PERLA1_V232_SPECIAL_WALL_SUPPORT_TOWER_CAR_SAFE_LOCAL
Build prodotta: PERLA1_V233_OVERDRAW_ROLLBACK_STABILITY_LOCAL

Scopo:
- Fermare l'accumulo di overdraw/glitch introdotto dai pass V227-V232.
- Spegnere il draw primario extra di far-wall spans V228, height-step faces V229 e continuous wall-runs V230/V231.
- Conservare i miglioramenti provati: sprite seal V229, distanza muri > sprite V228, rain camera volume V226, bath authority, e controllo tetto torre contro muri alti, ma sincronizzato meglio col corpo.
- Pulire title/h2/loading e rendere PERLA_BUILD_ID accessibile da console.

Interventi:
1. draw extra V228/V229/V230 spenti nel path normale tramite flag V233.
2. Occlusion buffer base V227 preservato per sprite/rain.
3. Fake roof support pixel clip V232 neutralizzato perché non sincronizzava davvero roof/support owner.
4. Tower roof/body sync V233: il tetto torre non viene bloccato prima del corpo se il corpo emerge sopra il muro foreground.
5. Build ID esposto come window.PERLA_BUILD_ID e window.__PERLA_BUILD_ID__.

Note:
- La patch privilegia stabilità e pulizia visiva rispetto alla continuità perfetta dei muri alti dietro muri bassi.
- Non sono stati modificati asset, mappa, collisioni, roadMask, objectBlock, skybox, audio, sprite placement o groundSink.
