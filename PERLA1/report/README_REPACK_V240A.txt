PERLA1 V240A — STABLE SURFACE FAMILY DRAW REFINEMENT
=====================================================

Build:
PERLA1_V240A_STABLE_SURFACE_FAMILY_DRAW_REFINEMENT_LOCAL

Base reale:
PERLA1_V240_COLUMN_FRAGMENT_STABLE_SURFACE_DRAW_PROTOTYPE_LOCAL

Scopo:
V240A rifinisce il draw controllato V240 introducendo un livello di wall family/topologia sopra le superfici candidate_stable. L'obiettivo non e' disegnare di piu', ma disegnare meno, meglio e in modo piu' stabile quando si ruota la telecamera.

Intervento:
- mantenuta la pipeline V239/V239A/V240;
- aggiunto raggruppamento in famiglie topologiche di muro basate su tex, owner, wallH, orientamento e linea dominante della mappa;
- nuova winner policy: stable_wall_family_then_depth_continuity_then_run_then_risk;
- soppressione conservativa di pannelli isolati/torrette e segmenti frammentati;
- edge guard visivo per evitare slab ai bordi;
- piccola history diagnostica delle wall family per misurare stabilita' angolare senza inventare muri assenti nel frame corrente;
- draw ancora solo candidate_stable, mai borderline/rejected;
- rendering ancora basato su texture reale, tX/rawTop/lineH, side shade e fog storico esistente;
- nessun aggiornamento di ZBuffer, sprite occlusion o rain occlusion.

Nuovi debug:
window.__PERLA_DEBUG__.getStableWallFamilySummary()
window.__PERLA_DEBUG__.getStableSurfaceDrawSummary()
perlaDownloadColumnFragmentDebugReport()

Vincoli preservati:
- V237 resta chiuso;
- V227-V232 draw legacy non riattivati;
- nessun nuovo DDA, nessuno span renderer, nessun overlay post-wallcasting;
- nessuna modifica a mappa/collisioni/assets/objectBlock/roadMask/pioggia/auto/skybox/tetti/torre/reception/bagni;
- PNG invariati;
- patch-only assente.

Nota:
V240A non e' ancora la patch di occlusione finale: ZBuffer/sprite/rain restano volutamente non aggiornati. Se un muro visivo non occlude ancora sprite/pioggia, il rischio e' dichiarato e rimandato a una futura patch separata.
