# README REPACK V241A — Face Registry Canonicalization Diagnostic

Build: `PERLA1_V241A_FACE_REGISTRY_CANONICALIZATION_DIAGNOSTIC_LOCAL`
Base reale: `PERLA1_V241_WORLD_WALL_REGISTRY_HIERARCHY_DIAGNOSTIC_LOCAL`

## Scopo
V241A non introduce draw visivo. Trasforma il registry V241 da celle/segmenti grezzi a facce esposte canoniche diagnostiche.

Pipeline diagnostica:

```text
map / wallHeightMap
→ celle muro solide tex1 owner0 wallH2
→ facce esposte north/south/west/east
→ merge collineare canonico
→ faceKey stabile
→ projection dry-run
→ hierarchy contract
→ confronto V240A/V241
→ report JSON
```

## Comandi debug

```javascript
window.__PERLA_DEBUG__.getWorldWallFaceRegistrySummary()
window.__PERLA_DEBUG__.getWorldWallFaceProjectionSummary()
perlaDownloadColumnFragmentDebugReport()
```

Il download completo genera `PERLA1_V241A_FACE_REGISTRY_DEBUG_*.json`.

## Vincoli preservati
- V240A draw spento di default.
- V241 registry draw spento.
- V241A face registry draw spento.
- Nessun update ZBuffer/sprite/rain.
- Nessun nuovo DDA, span renderer, overlay o continuous wall-run.
- Nessuna modifica a mappa, collisioni, asset, pioggia, auto, skybox, tetti, torre, reception, bagni.
- Patch-only folder assente.
