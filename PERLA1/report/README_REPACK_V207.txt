# PERLA1 V207 — Door Portal Descriptor Rain Curtain

Base reale: V206.
V205 resta scartata.

Intervento:
- soluzione ibrida Portal Descriptor manuale + Door Rain Curtain;
- descriptor porta reception sud e bagni ovest;
- curtain ancorata alla porta proiettata, non a percentuali fisse schermo;
- threshold/uscita interna passa subito a pioggia full-screen;
- V206 fallback conservato solo se nessun descriptor viene riconosciuto.

Preservati:
- audio V204;
- V200 roof budget;
- V201 rain/cloud budget;
- V185 fondale;
- mappa/collisioni/worldgen/sprite/pergola/torre/canopy.

Check da verificare in browser reale:
1. Dentro reception lontano dalla porta, storm: pioggia nel vano, non sopra tetto/soffitto.
2. Dentro reception vicino alla soglia, guardando fuori: pioggia full-screen o quasi immediata, niente finestrella stretta.
3. Ruotando camera: X resta stabile e Y segue descriptor porta.
4. Bagni: comportamento analogo su porta ovest.
