PERLA1 V240 — COLUMN FRAGMENT STABLE SURFACE DRAW PROTOTYPE
============================================================

Build:
PERLA1_V240_COLUMN_FRAGMENT_STABLE_SURFACE_DRAW_PROTOTYPE_LOCAL

Base reale:
PERLA1_V239A_COLUMN_FRAGMENT_SURFACE_CONTINUITY_DIAGNOSTIC_LOCAL

Scopo:
V240 introduce il primo draw controllato delle superfici candidate_stable individuate dalla diagnostica V239A.
Non è una soluzione finale del sistema muri alti: è un prototipo visivo controllato per verificare se le superfici stabili possono essere rese senza tornare a buchi, fasce legacy, overdraw o muri fantasma.

Intervento:
- mantenuta la pipeline V239/V239A di Column Fragment + Surface Continuity;
- aggiunto V240 Stable Surface Controlled Draw Prototype;
- selezione solo di candidate_stable;
- candidate_borderline e rejected non vengono disegnate;
- conflitti tra superfici sovrapposte risolti per colonna con policy: stable_surface_lowest_risk_then_longest_run_then_nearest_depth;
- draw testurizzato a colonna usando la texture muro reale e tX/rawTop/lineH del wall layer;
- draw inserito dopo wallcasting/legacy guards e prima di roof/sprite/weather layer;
- nessun aggiornamento di ZBuffer, WallTopBuffer, WallBottomBuffer, WallOcclusionRanges, sprite occlusion o rain occlusion;
- aggiunto debug window.__PERLA_DEBUG__.getStableSurfaceDrawSummary().

Vincoli preservati:
- V237 resta chiuso;
- V227-V232 draw legacy non riattivati;
- nessun nuovo DDA;
- nessuno span renderer legacy;
- nessuna modifica a mappa/collisioni/assets/objectBlock/roadMask/pioggia/auto/skybox/tetti/torre/reception/bagni;
- PNG invariati.

Comandi debug:
window.__PERLA_DEBUG__.getStableSurfaceDrawSummary()
window.__PERLA_DEBUG__.getColumnFragmentSurfaceSummary()
window.__PERLA_DEBUG__.getColumnFragmentDebugSnapshot()
perlaDownloadColumnFragmentDebugReport()

Nota operativa:
V240 non aggiorna ancora le occlusioni sprite/rain/ZBuffer. Se la superficie visiva appare ma sprite/pioggia non sono ancora coerenti dietro il nuovo muro, questo è un rischio previsto e dichiarato dal campo v240OcclusionDivergenceRisk=true.
