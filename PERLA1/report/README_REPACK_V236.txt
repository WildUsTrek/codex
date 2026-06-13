PERLA1 — README REPACK V236
Build: PERLA1_V236_ROOF_SUPPORT_SYNC_REAL_SAFE_LOCAL
Base reale: PERLA1_V235_TOWER_VISIBILITY_RAIN_MIDFIELD_SAFE_LOCAL
Data: 2026-06-11

CONTENUTO PACCHETTO
- 01_GIOCO_PRONTO_LOCAL_TEST/index.html aggiornato a V236.
- assets/raycast/ invariati rispetto a V235.
- launcher root aggiornati a V236.
- report/ aggiornato con STATUS, METODO, REPORT JSON e questo README.

INTERVENTO
V236 applica una correzione reale roof/support sync per tetti moderni owner 1/2:
- reception owner 1 / wallTex 2;
- bagni owner 2 / wallTex 3.

Il renderer non riattiva i pass V227-V232:
- no far-wall span draw;
- no height-step face draw;
- no continuous wall-run draw;
- no fake roof support pixel clip V232.

CHECK ESEGUITI
Vedere report/REPORT_V236_ROOF_SUPPORT_SYNC_REAL_SAFE.json per il dettaglio completo.

TEST VISIVO CONSIGLIATO
- Reception: guardare da sud/frontale e diagonale, muoversi alla soglia, ruotare lentamente.
- Bagni: guardare da ovest/sud e diagonale vicino a siepi/foreground, entrare/uscire e ruotare lentamente.
Criterio: fascia/eave/parte bassa tetto non deve sembrare sostenuta da siepi o muri foreground owner diverso.

NOTA ONESTA
Test browser/manuale reale non incluso nel repack automatico: serve verifica dell'utente in gioco.
