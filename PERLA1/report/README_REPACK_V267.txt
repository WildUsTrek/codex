PERLA1 V267 — ROOF SILHOUETTE MAIN WALL CLIP SAFE

Base reale: PERLA1_V266_ROOF_SILHOUETTE_MASK_BUDGET_HIERARCHY_SAFE_LOCAL
Build: PERLA1_V267_ROOF_SILHOUETTE_MAIN_WALL_CLIP_SAFE_LOCAL

Scopo:
- Promuovere la silhouette/mask continua V266 a renderer principale dei tetti.
- Lasciare il vecchio roof fill sample-based disattivato nel runtime normale.
- Aggiungere clipping severo contro muri/frontali/cespugli/ceiling/foreground, evitando che il tetto semplificato disegni parti interne sopra i muri davanti.

Interventi:
- Nuove costanti V267 e modalità safe/debug/off/original.
- perlaRoofSilhouetteMainClipSpanV267(): clip per colonna/span su WallTopBuffer, WallBottomBuffer, ZBuffer e CeilingDepthBuffer.
- perlaRoofSilhouetteMainShouldSkipOriginalFillV267(): spegne il fill roof sample-based nel runtime normale.
- La mask V266 continua a disegnare la silhouette, ma ora passa dal clipping V267 e scrive self-depth di base.
- Debug e smart recorder estesi con roofSilhouetteMainV267.

Comandi:
- perlaRoofSilhouetteMainSummaryV267()
- perlaRoofSilhouetteMainToggleV267(false/true)
- perlaRoofSilhouetteMainModeV267('safe'|'debug'|'off'|'original')
- perlaRoofSilhouetteMainDownloadV267()

Preservato:
- V264 watchdog, V265 edge rail, V266 mask/debug.
- rain, skybox, worldgen, map/fMap/cMap/roadMask/objectBlock, asset, floor globale, sprite placement, wall DDA, collisioni, audio/input/CSS/minimappa.

Validazione eseguita:
- node --check OK.
- smoke statico OK.
- asset PNG invariati/missing 0.
- ZIP/TAR integrity da report finale.
- Browser reale non eseguito in questo ambiente.
