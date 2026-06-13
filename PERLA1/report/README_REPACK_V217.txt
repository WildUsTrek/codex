PERLA1 V217 — Door Rain Selective Replay Profiles
=================================================

Base reale: PERLA1_V216_DOOR_RAIN_EXACT_CEILING_RECT_REPLAY_LOCAL
Build: PERLA1_V217_DOOR_RAIN_SELECTIVE_REPLAY_PROFILES_LOCAL

Scopo
-----
Preservare il passo avanti V216 (capture/replay esatto dei fillRect reali di soffitto/tettoia/canopy) eliminando il paradosso del replay globale: le tettoie non devono piu' apparire attraverso i muri.

Logica V217
-----------
- Capture ampio: continua a salvare i fillRect reali prodotti da drawModernCoverCeilingSegment, drawCeilingSegment e drawCanopySpanV121.
- Replay selettivo: dopo la rain vengono ridisegnati solo i rect autorizzati dal profilo attivo.
- Profili mappati: reception, bagni, bar, sala giochi, sala yoga.
- Canopy inclusi, ma solo se compatibili con profilo, owner/typeC/source e gate della porta/tettoia.
- Near-threshold fullscreen: se il player e' nella zona soglia del profilo e guarda verso fuori, la rain globale vince sulla door-plane.

Divieti rispettati
------------------
- Nessun replay globale V216 nel path attivo.
- Nessun solid cover calcolato V215 nel path attivo.
- Nessun WallTopBuffer come autorita' primaria del replay V217.
- Nessun percentile/fallback ratio.
- Nessuna cover inventata o offset manuale.
- Nessun ritorno al vecchio rainBuffer + ctx.clip + drawImage per la door rain.

Nota test
---------
Non e' stato eseguito test browser/visivo reale nel container. Sono stati eseguiti check statici, logici, node --check, asset e integrita' pacchetto.
