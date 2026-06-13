PERLA1 V138Q — MICROFLORA DIRECTIONAL RELOCATION SAFE

Base reale: PERLA1_V138P_MICROFLORA_VISUAL_MASK_BUSH_DECKCHAIR_SAFE.

Intervento:
- Migliorato il pass V138P di microflora visual-mask.
- Prima di rimuovere erba/fiori/aghi/pigne fuori dal footprint visivo sicuro, V138Q calcola un vettore di fuga dai punti del footprint che toccano terra/strada/decal/sentiero e prova a spostare lo sprite verso erba piena.
- Se la relocation direzionale fallisce, usa fallback a corona; se fallisce anche quello, rimuove.

Non toccati:
- Torre V136 e tetto integrato.
- Broadphase V137.
- Tetti/reception/bagni/tettoie V121.
- Pergola/festoni.
- Alberi, pini, palme.
- PNG e manifest.

Report mock:
- checked: 880
- alreadySafe: 251
- moved: 350
- removed: 279
- directionalMoved: 248
- fallbackMoved: 102

File report: REPORT_V138Q_MICROFLORA_DIRECTIONAL_RELOCATION.json
