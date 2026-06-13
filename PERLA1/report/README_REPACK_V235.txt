PERLA1 V235 — TOWER VISIBILITY / RAIN MIDFIELD SAFE

Base reale: PERLA1_V234_RAIN_AIRSPACE_LOGIC_CAR_ANCHOR_SAFE_LOCAL.

Interventi:
1) Tower visibility stabilizer: aumenta il range del tower peek da 44 a 72 solo per la torre, calcola un candidato/screen span del footprint 2x2 e fa retry mirato sulle colonne del suo span quando la visibilità scende a zero o sotto soglia. Non riattiva wall-run e non riscrive il renderer torre.
2) Rain midfield outdoor volume: quando la pioggia è attiva, misura la presenza di gocce nel campo medio outdoor e, soprattutto se il player è sotto copertura, respawna in modo world-space una quota di particelle mid davanti alla camera. Indoor/cMap/rainCoveredMap/canopy restano autorità negativa.

Preservati:
- V233 rollback: far-wall span draw OFF, height-step draw OFF, continuous wall-run draw OFF.
- V234 rain airspace low-wall e car visual anchor lift.
- Mappa, collisioni, objectBlock, roadMask, asset PNG, roof geometry, skybox, audio/meteo generale.

Test richiesti:
- Torre a distanza da vari angoli: non deve sparire solo ruotando.
- Tetto torre non deve passare attraverso muri alti e non deve separarsi dal corpo.
- Sotto tettoia: vicino resta asciutto, fuori/midfield pioggia visibile.
- Muri bassi/siepi: pioggia sopra ancora visibile.
- Nessun ritorno fasce/glitch V232.
