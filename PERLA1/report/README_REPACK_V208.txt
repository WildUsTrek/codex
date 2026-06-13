# PERLA1 V208 — Authoritative Door Portal Rain Fix

Base reale: V207.

V208 corregge il motivo reale per cui V207 poteva mostrare ancora la stessa finestra/colonna di pioggia: il descriptor non era autorevole, la soglia poteva disattivarsi fuori dal rettangolo room, il top Y era calcolato in modo conservativo e il fallback V206 poteva tornare nei casi mappati.

Intervento: descriptor primario, threshold band autonoma, proiezione Y corretta, bottomZ basso, no V206 fallback se porta mappata.

Preservati V204 audio, V200 roof budget, V201 weather budget, V185 fondale, mappa/collisioni/worldgen/sprite/pergola/torre/canopy.
