PERLA1_V199_CLOSED_BUILDING_NEAR_ROOF_FALLBACK_RECOVERY_LOCAL

Base reale usata:
PERLA1_V198A_AUDIO_LOUDER_STEPS_BIRDS_THUNDER_ECHO_LOCAL.zip

Scopo:
Recupero prestazioni mirato del fallback full dei tetti chiusi, emerso nei debug reali davanti/sotto reception e bagni.

Contenuto patch:
- Detector closed-building near-roof fallback.
- Indoor/cMap semantic skip del roof-top esterno quando la camera è sicuramente sotto la copertura dello stesso owner.
- Outdoor/soglia budget del fallback full: non salta il tetto, riduce solo il dense loop.
- Dynamic roof quality governor con isteresi: normal/budget/emergency.
- Debug runtime: perlaRoofPerformanceV199(), perlaRoofQualityV199().

Preservato:
V198 meteo/cloud performance recovery, V198A audio, mappa, collisioni, worldgen, sprite, pergola, festoni, lago/barca, pavimenti, decal, asset PNG, fog/fondale V185.

Test consigliati:
1. perlaSetWeather('storm')
2. davanti alla porta reception: perlaRoofPerformanceV199()
3. dentro reception ma lontano dalla soglia: perlaRoofPerformanceV199()
4. davanti/ dentro bagni: perlaRoofPerformanceV199()
5. ruotare lentamente su soglie e angoli; verificare che non compaiano buchi tetto/gronda/seam.

Nota:
La build è tecnicamente validata con check statici e integrità archivio. La validazione estetica/performance definitiva richiede browser reale.
