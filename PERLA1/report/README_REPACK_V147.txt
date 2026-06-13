PERLA1 V147 — PINETA / PERGOLA PERFORMANCE SAFE

Build prodotta: PERLA1_V147_PINETA_PERGOLA_PERFORMANCE_SAFE_LOCAL
Base reale: PERLA1_V146_FLOWER_SHADOW_STATUE_STONES_FINAL_SAFE_LOCAL

Interventi:
- broadphase desktop più realistica: maxDist 82 invece di 999, con slack/FOV ancora conservativi;
- LOD conservativo per micro-dettagli lontani: erbe, aghi, pigne, fiori, sassi piccoli;
- riduzione drawImage per alberi lontani in pinete dense tramite stripe-step controllato e depth-safe;
- skip ombre albero lontane quando la scena è molto densa, preservando ombre vicine/medie;
- ottimizzazione pergola conservativa: solo campionamento/padding in casi quasi full-screen, nessun cambio logico/artistico alla pergola;
- preservati PNG, tetti, torre, festoni, barca, mappa, collisioni, worldgen, sassi, fiori, statua moderna, tende, tamerici ripuliti;
- nessuna cartella patch-only inclusa.
