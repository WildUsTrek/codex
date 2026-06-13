PERLA1 V258A — PHASE 1 REAL QUICK WINS COMPLETE SAFE LOCAL
================================================================
Data: 2026-06-12
Build: PERLA1_V258A_PHASE1_REAL_QUICK_WINS_COMPLETE_SAFE_LOCAL
Base reale: PERLA1_V258_PERFORMANCE_BASELINE_DEBUG_OVERHEAD_SAFE_LOCAL

SCOPO
-----
Completare davvero la Fase 1/3 dei Quick Wins performance. La V258 resta una baseline parziale: V258A aggiunge i quick wins reali rimasti, senza passare a Fase 2 e senza rimuovere codice/asset.

INTERVENTI
----------
1. Deep draw stats lazy/on-demand:
   - aggiunto gate V258A per statistiche profonde;
   - il frame normale non clona piu' checklist rain/debug;
   - export/debug/recorder deep possono chiedere un frame profondo.

2. Riduzione overhead diagnostico rain:
   - le assegnazioni `drawStats.*Checklist = CHECKLIST.slice()` sono state sostituite con `perlaAttachChecklistV258A(...)`;
   - le summary usano `perlaChecklistForSummaryV258A(...)`;
   - dopo patch non restano occorrenze raw `CHECKLIST.slice()` nel JS.

3. Smart performance recorder:
   - `perlaPerfStart([options])`
   - `perlaPerfMark(label)`
   - `perlaPerfStatus()`
   - `perlaPerfStop()`
   - `perlaPerfStopAndDownload()`
   - alias espliciti V258A equivalenti.

4. Minimap:
   - comportamento default invariato;
   - V258A misura il costo minimappa e lo include nei report, ma non applica throttle automatico.

5. Debug export:
   - il pulsante/export debug richiede un one-shot deep frame prima di scaricare il report.

COME USARE IL RECORDER SMART
----------------------------
Aprire console browser e lanciare:

  perlaPerfStart()

Poi fare un giro nei punti pesanti: pineta, pergola, camper/festoni, torre, tettoie, nord/skybox, rain, storm.
Per segnare punti manuali:

  perlaPerfMark('nome punto')

Per vedere stato:

  perlaPerfStatus()

Per fermare e scaricare il JSON ordinato:

  perlaPerfStopAndDownload()

Per una sessione piu' profonda:

  perlaPerfStart({deep:true})

PRESERVATO
----------
- mappa, fMap, cMap, roadMask, objectBlock;
- generateWorld e ordine worldgen;
- asset PNG e ASSET_MANIFEST;
- rain output, lifecycle, spawn/refill/canKeep;
- V248-V257 rain;
- skybox V257;
- tetti, torre, pergola, festoni, sprite, collisioni;
- minimappa default;
- audio, input, CSS layout.

CHECK ESEGUITI
--------------
- node --check su script estratto V258A: OK;
- Node VM smoke V258A: OK;
- Node VM smart recorder smoke: OK;
- asset refs 108, missing 0;
- PNG asset modificati vs V258: 0;
- cartella patch-only assente;
- ZIP/TAR.GZ integrity da verificare nel repack finale.

NOTA ONESTA
-----------
Non e' stato possibile considerare il test browser reale come sostituito dal VM smoke. Il recorder smart e i comandi console sono stati validati in ambiente mock Node, ma la conferma visuale/performance va fatta nel browser reale.
