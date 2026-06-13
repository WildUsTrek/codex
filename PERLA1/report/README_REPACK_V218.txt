PERLA1 V218 — LOCAL SHELTER REPLAY LOW GATE FLOOR OCCLUDER

Base reale: PERLA1_V217_DOOR_RAIN_SELECTIVE_REPLAY_PROFILES_LOCAL.

Intervento:
- pioggia globale/full-screen sotto riparo attivo;
- sistema unico SHELTER_REPLAY_PROFILES_V218;
- profili reception, bagni, bar, sala giochi, sala yoga;
- replay locale selettivo di ceiling/canopy/floor/wall rects del profilo attivo;
- yoga/bar/sala giochi trattati come tettoie aperte, senza porte false;
- bagni/reception trattati come edifici chiusi con porta reale, muri/front wall replayati sopra cover;
- floor occluder/low gate bottom-only per fascia bassa, senza ricostruire il portale completo;
- nessun replay globale di tutti i rect;
- V215 solid cover e V216/V217 replay globale non sono path attivi.

Check dichiarabili:
- node --check OK se REPORT_V218 riporta node_check_ok=true;
- asset manifest senza PNG mancanti;
- PNG invariati rispetto a V217;
- ZIP/TAR.GZ integrity da verificare sul pacchetto finale.

Nota: non e' stato eseguito test browser/visivo reale nella sessione.
