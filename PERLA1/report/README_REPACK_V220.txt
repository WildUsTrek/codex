PERLA1 V220 — V216 Occlusion Method Restored

Base: PERLA1_V219_LOCAL_V216_CEILING_COVERAGE_RESTORE_LOCAL.

Scopo: chiudere l'errore identificato in V219: il replay V216 funzionante era stato disattivato e sostituito dal path filtrato V218/V219.

Interventi principali:
- ripristinato `drawDoorRainExactCeilingReplayV216(...)` come metodo attivo di occlusione post-rain;
- il replay V216 riceve solo rect soffitto/canopy compatibili con V216, non floor/wall;
- disattivato `drawLocalShelterReplayV218(...)` come path finale della cover;
- aggiunto replay locale muri/architravi dopo la cover V216;
- debug V220 dedicato e UI aggiornata.

Non sono stati modificati PNG, mappa, collisioni, worldgen, audio o fondale.
