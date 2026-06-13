PERLA1 V211 — Door Rain Portal 3x1 Geometry

Base reale: PERLA1_V210_TRUE_DOOR_RAIN_PLANE_RENDERER_LOCAL.

Scopo:
- correggere la sorgente geometrica del door rain plane usando il dato reale porta 3 blocchi larghezza x 1 blocco altezza;
- eliminare l’espansione min-height screen-space che poteva spingere la pioggia sopra tetto/soffitto;
- rafforzare override full-screen quando proiezione portale/apertura outdoor è ampia;
- mantenere il renderer dedicato V210 e il blocco anti rainBuffer+clip per la pioggia porta.

File principali modificati:
- 01_GIOCO_PRONTO_LOCAL_TEST/index.html
- launcher BAT/PowerShell
- report/METODO_LAVORO_ANTI_REGRESSIONE_PERLA1.txt
- report/STATUS_PROGETTO_E_DIPENDENZE_PERLA1.txt

Check statici:
- node --check: OK
- PNG missing: 0
- PNG modificati rispetto V210: 0
- cartella patch-only: assente

Nota: non è stato eseguito test visivo browser reale nel container.
