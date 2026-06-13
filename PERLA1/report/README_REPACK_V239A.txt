PERLA1 V239A — COLUMN FRAGMENT SURFACE CONTINUITY DIAGNOSTIC
================================================================
Build: PERLA1_V239A_COLUMN_FRAGMENT_SURFACE_CONTINUITY_DIAGNOSTIC_LOCAL
Base reale: PERLA1_V239_COLUMN_FRAGMENT_COMPOSITOR_DIAGNOSTIC_LOCAL
Data UTC: 2026-06-12T00:14:07.265099+00:00

IDENTITÀ
--------
V239A non è una patch visiva finale. È una diagnostica evoluta sopra V239.
Il draw resta disattivato: PERLA_V239_COLUMN_FRAGMENT_DRAW_ENABLED = false e PERLA_V239A_DRAW_ENABLED = false.

SCOPO
-----
Raggruppare le bande wouldDraw del Column Fragment / Vertical Span Compositor in superfici candidate orizzontali,
misurando continuità, gap, altezza media, stabilità di profondità, stabilità verticale, tex/owner, blocker e riskScore.

COMANDI DEBUG
-------------
perlaDownloadColumnFragmentDebugReport()
window.__PERLA_DEBUG__.downloadColumnFragmentDebugReport()
window.__PERLA_DEBUG__.getColumnFragmentDebugSnapshot()
window.__PERLA_DEBUG__.getColumnFragmentSurfaceSummary()
window.__PERLA_DEBUG__.getColumnFragmentSurfaceSummaryV239A()

VINCOLI RISPETTATI
------------------
- Nessun draw nuovo di muri alti.
- Nessun nuovo DDA pesante.
- Nessun renderer parallelo / overlay post-wallcasting.
- Nessuno span renderer.
- V237 resta chiuso.
- V227-V232 draw extra restano spenti.
- Nessuna modifica a mappa, collisioni, objectBlock, roadMask, asset PNG, pioggia, auto, skybox, tetti, torre, reception, bagni.
- PNG invariati rispetto a V239.

COSA GUARDARE NEL REPORT
------------------------
- surfaceContinuity.surfacesTotal
- surfaceContinuity.stableSurfaces
- surfaceContinuity.borderlineSurfaces
- surfaceContinuity.rejectedSurfaces
- topStableSurfaces
- topBorderlineSurfaces
- topRejectedSurfaces
- blockerSummary
- topRejectReasons

CRITERIO
--------
V239A è riuscita se il report chiarisce se esistono superfici emergenti continue e sicure candidate a una futura V240.
Non bisogna attivare draw finché topStableSurfaces / blockerSummary / rejectReasons non sono stati valutati su browser reale.
