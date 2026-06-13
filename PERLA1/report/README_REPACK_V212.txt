# PERLA1 V212 — Door Rain Aspect Lock + Early Fullscreen Threshold

Base reale: V211.

Patch mirata:
- aspect-lock 3:1 per il piano pioggia porta: altezza = larghezza proiettata / 3;
- bottom ancorato alla soglia/floor esterno;
- margini verticali minimi;
- early fullscreen entro circa 1 tile dalla soglia quando camera e open-screen indicano scena esterna aperta;
- preservato renderer dedicato V210, niente rainBuffer+clip per la porta;
- UI/versione in-game aggiornata a V212.

Preservati: V204 audio, V200 roof budget, V201 rain/cloud budget globale, V185 fondale, mappa/collisioni/worldgen/sprite/pergola/torre/canopy.
