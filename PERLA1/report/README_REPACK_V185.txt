PERLA1 — README REPACK V185 DISTORTION TARGET 8% RESTORE

Build: PERLA1_V185_DISTORTION_TARGET_8PCT_RESTORE_LOCAL
Base reale: PERLA1_V184_DISTORTION_CONTROLLED_HORIZON_4PCT_LOCAL.zip

Scopo:
- Ripristinare il target di stiramento residuo del fondale da 4% a 8%.
- Conservare le correzioni UI/documentali della V184, inclusa la rimozione della scritta visibile V169/V125.
- Non cambiare architettura: V185 mantiene il renderer distortion-controlled, ma torna al target più morbido della V183.

Interventi codice:
- PERLA_BUILD_ID aggiornato a PERLA1_V185_DISTORTION_TARGET_8PCT_RESTORE_LOCAL.
- Renderer corrente rinominato/debuggato come V185.
- PERLA_ENV_HORIZON_MAX_STRETCH_TARGET_V185 = 1.08.
- Title, h2, loading e alert UI aggiornati a V185.

Preservato:
- mappa, collisioni, worldgen, tetti, torre, roofSegments, fog globale, sprite, ombre, pergola, festoni, lago/barca, pavimenti, decal, asset PNG, launcher.

Nota tecnica:
- La V184 con target 1.04 correggeva troppo presto e aumentava sensibilmente i draw/campionamenti percepiti. V185 torna al target 1.08, considerato più equilibrato dall'utente.

Nota test reale:
- Build tecnicamente validata. Test browser reale non eseguito in ambiente ChatGPT.
