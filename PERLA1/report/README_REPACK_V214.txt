PERLA1 V214 — Door Rain Draw-Order Ceiling/Canopy Replay
=========================================================

Base reale: PERLA1_V213_DOOR_RAIN_CEILING_CAP_EARLY_FULLSCREEN_LOCAL.
Build prodotta: PERLA1_V214_DOOR_RAIN_DRAW_ORDER_CEILING_REPLAY_LOCAL.

Scopo
-----
Correggere il fallimento V213: V213 non ridisegnava davvero la tettoia/soffitto davanti alla pioggia, ma ritoccava ancora yTop tramite buffer/fallback. V214 implementa la checklist approvata: mondo -> door rain -> cover reale replayata davanti.

Implementazione
---------------
- Door rain resta su renderer dedicato V210.
- V213 yTop cap viene disabilitato come soluzione primaria.
- I segmenti soffitto/tettoia realmente usati nel frame vengono raccolti.
- Dopo drawWeatherOverlayV190(), se la door rain è attiva, V214 applica clipping sui range porta e replaya:
  - drawRoofLayer2_5D()
  - drawModernCoverCeilingSegment()
  - drawDeferredCanopySegmentsV121()
- Nessun vecchio rainBuffer+clip per la porta.
- Nessun nuovo tuning prospettico yTop.

Checklist V214
--------------
1. mondo/muri/soffitto/tetti disegnati prima;
2. door rain dedicata disegnata dopo;
3. cover soffitto/tettoia replayata subito dopo la rain;
4. funzioni correnti usate, non elementi obsoleti;
5. pioggia coperta per draw order.

Nota
----
Non è stato eseguito test visivo browser reale in questa sandbox. Sono stati eseguiti controlli statici, logici e integrità pacchetto.
