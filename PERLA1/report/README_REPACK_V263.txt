PERLA1 V263 — ROOF MID-DISTANCE BRANCH LOCK SAFE
=================================================

Build: PERLA1_V263_ROOF_MID_DISTANCE_BRANCH_LOCK_SAFE_LOCAL
Base reale: PERLA1_V262_COVERAGE_STABLE_EDGE_REPAIR_SAFE_LOCAL
Generato: 2026-06-12T20:09:10.161648

Scopo:
Correggere V262, che nei report reali peggiorava i draw davanti al roof/reception e lasciava alternare il ramo economico (~5290 samples) con il ramo costoso (15200 samples). V263 blocca il branch moderno owner 1/2 in una modalità economica stabile, senza eccezione full-cost in near.

Comandi debug principali:
- perlaRoofBranchLockSummaryV263()
- perlaRoofBranchLockToggleV263(false/true)
- perlaRoofBranchLockModeV263('safe'|'debug'|'off')
- perlaRoofBranchLockDownloadV263()

Compatibilità preservata:
- perlaRoofHotspotSummaryV259()
- perlaLongViewBudgetSummaryV260()
- perlaCoverageSurfaceSummaryV261()
- perlaCoverageStableSummaryV262()

Check statici eseguiti:
- node --check su EXTRACTED_INDEX_INLINE_SCRIPT_V263.js
- NODE_SMOKE_V263.js
- asset PNG invariati rispetto a V262
- asset refs/missing verificati
- ZIP/TAR.GZ completi, nessuna cartella patch-only

Browser reale non eseguito in questo ambiente. Test consigliati:
- clear/rain/storm davanti reception roof a media distanza
- near reception roof: verificare niente ritorno a full-cost
- bath_garden grande tetto
- pergola clear/storm
- confrontare roof.samples: non deve ricomparire stabilmente 15200 nei punti critici.
