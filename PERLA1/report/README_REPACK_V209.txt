# PERLA1 V209 — Door Rain Plane World-Space

Base reale: PERLA1_V208_AUTHORITATIVE_DOOR_PORTAL_RAIN_FIX_LOCAL.

V209 cambia approccio per la pioggia indoor vista porta: non corregge più yTop/yBottom screen-space o percentuali fisse, ma genera un piano/portal sheet di pioggia in world-space appena fuori dalla porta mappata. Il piano viene proiettato in screen-space, diviso in micro-range, controllato da ZBuffer/CeilingDepthBuffer dove disponibile e sostituito da pioggia full-screen quando la soglia/apertura è abbastanza libera.

Preservati: V204 audio, V200 roof budget, V201 rain/cloud budget, V185 fondale, mappa/collisioni/worldgen/sprite/pergola/torre/canopy.

Check statici eseguiti: node --check OK, PNG refs OK, ZIP/TAR.GZ integrity da eseguire in packaging.
