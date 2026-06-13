PERLA1 V241 — WORLD WALL REGISTRY + HIERARCHY DIAGNOSTIC

Build:
PERLA1_V241_WORLD_WALL_REGISTRY_HIERARCHY_DIAGNOSTIC_LOCAL

Base reale:
PERLA1_V240A_STABLE_SURFACE_FAMILY_DRAW_REFINEMENT_LOCAL

Scopo:
V241 non e' una patch visuale finale. Spegne di default il draw instabile V240A, preserva la diagnostica V239/V239A/V240/V240A, e introduce un registry topologico mondo dei muri alti semplici costruito una sola volta dopo generateWorld da map/wallHeightMap.

Interventi:
- Build ID/UI/launcher aggiornati a V241.
- V240A family draw disattivato di default: il debug resta disponibile, ma non produce piu' draw visuale.
- Nuovo World Wall Registry V241 diagnostic-only.
- Registry costruito una volta dopo generateWorld, non dentro drawWorld e non ad ogni rotazione camera.
- Scope registry volutamente prudente: solo muri semplici outdoor tex=1, owner=0, wallH>=1.9; esclusi tower/reception/bath/texture speciali/sistemi tetto.
- Indici leggeri byLine/byCell per evitare scan globale per-frame.
- Projection dry-run per frame: candidati vicini/frustum, contratto gerarchico su foreground wall e CeilingDepthBuffer, drawnColumns=0/drawnPixels=0.
- Confronto V240A surfaces/family vs registry: matchRegistrySegment, surface frame-only, edge touch, registry cells.

Nuovi comandi debug:
window.__PERLA_DEBUG__.getWorldWallRegistrySummary()
window.__PERLA_DEBUG__.getWorldWallRegistryProjectionSummary()
perlaDownloadColumnFragmentDebugReport()

Il download completo ora produce:
PERLA1_V241_WORLD_WALL_REGISTRY_DEBUG_*.json

Sezioni attese nel JSON:
- worldWallRegistry
- registryProjection
- hierarchyContract
- v240aComparison
- stableSurfaceDraw
- stableWallFamilyDraw
- antiRegression

Vincoli rispettati:
- Nessun draw registry.
- Nessun nuovo DDA pesante.
- Nessun overlay post-wallcasting.
- Nessuno scan globale map/wallHeightMap dentro drawWorld.
- Nessun aggiornamento ZBuffer/sprite/rain occlusion.
- V227-V232 draw legacy restano spenti.
- V237 resta chiuso.
- Mappa/collisioni/assets/pioggia/auto/skybox/tetti/torre/reception/bagni non toccati.
- PNG invariati.
- Patch-only assente.

Nota test:
La prova decisiva e' scaricare 2/3 report ruotando lentamente negli stessi punti erba/bath_garden. Se segmentKey registry resta stabile mentre V240A family/surface cambia, il registry ha valore diagnostico. Se anche il registry cambia identita' o classifica male edge-slab/gerarchia, non si procede a draw.

Generato: 2026-06-12T01:13:50Z
