PERLA1 V149 — ROOF BOUNDS SAFETY FIX

Base: PERLA1_V148_ROOF_BOUNDS_PINETA_PERFORMANCE_SAFE_LOCAL.

Scopo:
- correggere il popping/sparizione/grigio momentaneo dei tetti reception/bagni introdotto dai bounds V148 durante rotazione camera.

Interventi:
- mantenuta cache statica V148 per planes/gable caps;
- resi prudenti i bounds screen-space dei roofSegments;
- fallback largo solo quando un tetto/cap è vicino o parzialmente dietro il near-plane;
- range gable più prudente;
- pineta V148 preservata senza ulteriori modifiche.

Non toccato:
PNG, mappa, collisioni, worldgen, pergola, festoni, torre, barca, sassi, fiori, statua, ombre, sprite placement.

Nessuna cartella SOLO_FILE_DA_SOSTITUIRE inclusa.
