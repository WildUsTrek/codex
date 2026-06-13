PERLA1 V190 — SMOOTH CLOCK FULL WEATHER

Base reale:
- PERLA1_V189_ENVIRONMENT_DAYCYCLE_HELPERS_LOCAL
- linea stabile V185 preservata per fondale/skybox.

Scopo:
- aggiungere transizioni cromatiche morbide tra bucket giorno/notte;
- aggiungere orologio digitale HUD visibile;
- aggiungere meteo completo a giornate con distribuzione 3/7 sole, 2/7 nuvole, 1/7 pioggia, 1/7 tempesta.

Comandi console principali:
- perlaEnv()
- perlaNextCycle()
- perlaSetTime(19)
- dormi()
- perlaWeather()
- perlaSetWeather('clear')
- perlaSetWeather('cloudy')
- perlaSetWeather('rain')
- perlaSetWeather('storm')
- perlaNextWeather()
- perlaCommand('meteo','rain')
- perlaCommand('storm')

Note meteo:
- il meteo cambia a giornata;
- la sequenza settimanale è mescolata e non ripete sempre lo stesso ordine;
- l'override manuale resta valido per la giornata corrente;
- al giorno successivo riprende la pianificazione randomizzata.

Preservato:
- mappa/collisioni/worldgen;
- tetti/torre/roofSegments;
- sprite/ombre/pergola/festoni/lago/pavimenti/decal;
- asset PNG;
- launcher;
- fondale V185 target 1.08.

Test consigliato in browser:
1. perlaEnv()
2. perlaNextCycle()
3. perlaSetWeather('cloudy')
4. perlaSetWeather('rain')
5. perlaSetWeather('storm')
6. perlaNextWeather()
7. dormi()
8. perlaEnv()
