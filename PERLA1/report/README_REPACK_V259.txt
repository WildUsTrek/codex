PERLA1 V259 — ROOF / CEILING HOTSPOT BUDGET SAFE

Base reale: PERLA1_V258A_PHASE1_REAL_QUICK_WINS_COMPLETE_SAFE_LOCAL
Build: PERLA1_V259_ROOF_CEILING_HOTSPOT_BUDGET_SAFE_LOCAL

Scopo:
Ridurre il costo roof/ceiling nei soli hotspot moderni emersi dal tour V258A: reception e bagni. Non è una patch pioggia, non è una patch sprite/floor/secret lake, non è rimozione pattumiera.

Comandi console nuovi:
- perlaRoofHotspotSummaryV259()
- perlaRoofHotspotColumnsV259()
- perlaRoofHotspotToggleV259(false) / perlaRoofHotspotToggleV259(true)
- perlaRoofHotspotModeV259("safe"|"debug"|"off")
- perlaRoofHotspotDownloadV259()

Uso test consigliato:
1. Testare davanti reception clear/storm.
2. Testare davanti bagni clear/storm.
3. Testare dentro bagni come controllo.
4. Testare pergola e secret lake solo come controlli non bersaglio.
5. Usare perlaPerfStart() e perlaPerfStopAndDownload() per confrontare con il tour V258A.

Rollback runtime immediato:
perlaRoofHotspotToggleV259(false)

Check eseguiti:
- node --check OK
- Node VM smoke OK
- Node VM roof hotspot smoke OK
- asset PNG invariati vs V258A
- missing asset 0

Nota onesta:
Il test browser reale resta obbligatorio per confermare assenza di flicker, tagli gronda o variazioni percettive dei tetti.
