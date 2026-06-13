PERLA1 V264 — ROOF COST WATCHDOG EMERGENCY SAFE
====================================================

Build: PERLA1_V264_ROOF_COST_WATCHDOG_EMERGENCY_SAFE_LOCAL
Base reale: PERLA1_V263_ROOF_MID_DISTANCE_BRANCH_LOCK_SAFE_LOCAL
Generato: 2026-06-12T23:09:00.241674Z

Scopo
-----
Correggere il limite reale emerso dai report V263: il branch lock era troppo dipendente da owner/path/candidates.
Nei casi fascia_palme/erba il roof restava costoso con roof.samples ~30102/30573, uncappedRoofSamples enorme e roofBranchLockV263.enabled=false.

Intervento
----------
Aggiunto RoofCostWatchdogV264 path-independent, basato su costo reale/predetto:
- warning: roof.ms >= 10 o samples/uncapped > 7000
- pressure: roof.ms >= 12 o samples/uncapped > 9000 o visible > 5000
- emergency: roof.ms >= 14 o samples/uncapped > 12000 o visible > 6000 o drawWorld >= 18 con roof.ms >= 12

La guardia viene applicata prima del loop roof in drawSlopedRoofLayer2_5D usando una stima dei campioni roof bbox a step 2x2.
Non dipende da ownerId, pathLabel, V259 candidates o zona.

Comandi debug
-------------
perlaRoofCostWatchdogSummaryV264()
perlaRoofCostWatchdogToggleV264(false|true)
perlaRoofCostWatchdogModeV264('safe'|'debug'|'off')
perlaRoofCostWatchdogDownloadV264()

Validazione eseguita
--------------------
- node --check su EXTRACTED_INDEX_INLINE_SCRIPT_V264.js: OK
- NODE_SMOKE_V264: OK
- Asset check V264: PNG 116/116, hash cambiati 0, missing refs 0
- ZIP/TAR.GZ integrity da eseguire dopo packaging finale

Nota
----
Test browser reale non eseguito in questo ambiente. Testare clear/rain/storm su reception/bagni, punti con samples 30102/30573, pergola clear/storm.
