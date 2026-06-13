PERLA1 V200 — OUTDOOR ROOF BUDGET + CEILING COLOR + AUDIO BOOST

Base reale: PERLA1_V199_CLOSED_BUILDING_NEAR_ROOF_FALLBACK_RECOVERY_LOCAL.

Contenuto:
- Budget reale del roof fallback esterno davanti a porte/tetti anche quando il bounds e' full-like ma non espone v149Fallback.
- Soffitto/intradosso indoor derivato dalla palette del tetto, non grigio neutro.
- Passi e uccellini aumentati considerevolmente.

Non sono stati toccati mappa, collisioni, worldgen, asset PNG, fondale, meteo visivo, torre, canopy, pergola, sprite placement.

Test consigliato in console:
perlaRoofPerformanceV199()
perlaRoofQualityV199('auto')
perlaSetWeather('clear')
perlaSetWeather('storm')

Chiavi debug attese davanti al tetto esterno:
roofLoopDecisionV200 diverso da normal, roofOutdoorBudgetRealAppliedV200 true, roofSamplesSavedEstimateV200 > 0.
