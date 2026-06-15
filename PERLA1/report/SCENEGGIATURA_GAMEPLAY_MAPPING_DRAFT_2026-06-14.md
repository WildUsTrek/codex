# Sceneggiatura And Gameplay Mapping Draft - 2026-06-14

Status: preparatory mapping only. No runtime integration.

This draft applies `01_GIOCO_PRONTO_LOCAL_TEST/assets/rtp/SCENARIO_EVENT_MAPPING_PROTOCOL.md` to the first provided story/gameplay sources. It prepares atmosphere, entity placement, behavior loops, event structure, and validation rules for future JSON manifests.

## Sources Read

| Source | Role |
|---|---|
| `C:\Users\ASUS\Downloads\0 $$ app risorse RTP E BAKCUP $$\02_ storiboard\sceneggiatura.txt` | Primary narrative/gameplay source. Marked V8 Definitiva in text. |
| `C:\Users\ASUS\Downloads\0 $$ app risorse RTP E BAKCUP $$\GAME_DESIGN_DOCUMENT_SASSI_MANAGEMENT_V7.pdf` | Supporting system source. Confirms daily loop, hub economy, cart upgrades, comfort hazards, final boss requirements. |
| `C:\Users\ASUS\Downloads\0 $$ app risorse RTP E BAKCUP $$\02_ storiboard\STORIBOARD Dell'intro, inizio del gioco IMMAGINI CON TESTO.png` | Visual source for intro/startup comic. Optimization/integration should be done last. |

Source priority:

1. `sceneggiatura.txt` for current lore, tone, dialogue, character identity, and V8 gameplay refinements.
2. GDD V7 PDF for system structure where the V8 text is aligned or less detailed.
3. Storyboard image for visual rhythm and intro staging, not as a substitute for runtime event data.

## Tone And Atmosphere

Target atmosphere:

- comico-grottesco;
- satira balneare;
- campeggio caotico ma leggibile;
- management poverissimo ma ossessivo;
- raycaster world premium: alive, dense, reactive, but never visually noisy enough to hurt navigation.

World fantasy:

- Viareggio camping turned into a mineral disaster zone;
- Imperio weaponizes bureaucracy, rent, shower tokens, and fake tournament rhetoric;
- the protagonist is a broke outsider with a wheelbarrow;
- the camp slowly becomes a resistance economy through defeated/recruited characters.

Visual first impression:

- blinding summer light;
- sharp gravel replacing sand;
- cheap reception furniture, broken fan, piles of cash/papers;
- rusty wheelbarrow as the player identity/HUD anchor;
- comedy through cruelty, discomfort, and petty systems.

## Core Systems To Preserve

| System | Mapping implication |
|---|---|
| Daily bands | Every main character gets a schedule. NPCs/animals get inferred bands unless specified. |
| Comfort/stress | Placement must respect heat/zanzare risk zones and mitigation items. |
| EC and GD currencies | Events, hub jobs, rent, upgrades, and rewards must reference EC/GD. |
| Hub Piazzola | Central upgrade/rest/assignment area. Needs placeholder visuals before final assets. |
| Wheelbarrow inventory | Player-facing identity and upgrade progression. Needs placeholder states. |
| Battle app | Future separate app. For now, events use `battle_placeholder` with `won/lost` switch. |
| Sassi resources | Need collectible placeholders and zone-based spawn logic. |

## Intro Event Chain

Recommended event IDs:

| Event ID | Source | Description | Runtime status |
|---|---|---|---|
| `event.intro.imperio_order` | storyboard + sceneggiatura | Imperio orders cheap fake VIP sand from Prato. | cutscene/comic source, not world event yet |
| `event.intro.truck_arrival` | storyboard | Truck reaches Camping Sole, Mare & Zanzare. | cutscene/comic source |
| `event.intro.gravel_dump` | storyboard + lore | Ghiaione is dumped into the camping. | cutscene/comic source |
| `event.intro.crowd_revolt` | storyboard + lore | Guests protest; Imperio reframes disaster as tournament. | cutscene/comic source |
| `event.intro.player_wakeup` | storyboard + sceneggiatura | Player wakes on gravel, first-person hands/wheelbarrow. | runtime intro candidate |
| `event.intro.reception_debt` | storyboard + sceneggiatura | Imperio explains missing wallet, Tier 1 rent, 10 EC daily cost. | first dialogue/tutorial |

Intro implementation note:

- the comic image should be optimized and used last, after the live intro/runtime flow is mapped;
- the image is 768x2258 RGBA and currently 3,182,719 bytes;
- future optimization should likely produce responsive WebP/AVIF variants plus a panel metadata map, not one giant unstructured image if interactive timing is needed.

## Main Character Placement Draft

Coordinates are intentionally not final. Exact coordinates must be derived from the runtime map and verified against walkability, visibility, roofs/walls, event reachability, and sprite density.

| ID | Role | Placement | Time band | Behavior loop | Event/dialogue role |
|---|---|---|---|---|---|
| `imperio` | antagonist/main | Reception desk; final boss at reception night. | `morning`, `day`, `night`, `event_only` | mostly static behind desk; short idle gestures; no roaming unless cutscene. | intro debt, rent pressure, tournament announcement, final battle trigger |
| `nina_ciottolo` | main/recruitable | Area Lavatoio. | `morning` | short patrol between lavatoi, coin/gettoni spot, and notice board; suspicious idle. | morning challenger, hub worker `Accattonaggio`, resistance dialogue injection |
| `prof_ossidiana` | main/recruitable | Veranda del Bar. | `morning` | slow legalistic pacing near table/papers; faces player when approached. | morning challenger, hub worker `Audit Fiscale`, legal exposition |
| `orbo_granito` | main/recruitable | Spiaggia Libera. | `afternoon` | metal-detector sweep loop; pauses to scan suspicious ground. | afternoon challenger, hub worker `Metal Detector` |
| `teo_pietrafocaia` | main/recruitable | Area Barbecue. | `afternoon` | grill tending loop, turns between fire/wood/table; local radius. | afternoon challenger, barbecue dialogue, hub worker `Grigliata Clandestina` |
| `bruno_basalto` | main/recruitable | Area Calisthenics or rough training corner near stone piles. | `afternoon` | idle flex + short walk between weights/stone pile; avoid blocking path. | afternoon challenger, hub worker `Frantumazione Massi` |
| `lalla_lapillo` | main/recruitable | Area Yoga / prato ombreggiato. | `night` | ritual loop around mat/crystals; occasional sharp turns. | night challenger, hub worker `Purificazione` |
| `mara_selce` | main/recruitable | Pineta / zona tende oscura, near illegal charging/electric point. | `night` | minimal movement; shade/phone charging idle; short avoidance loop. | night challenger, hub worker `Riciclaggio Elettronica` |
| `zelda_quarzo` | main/recruitable | Palco Animazione / Disco Beach. | `night` | hyperactive stage loop; patrol must not crowd player route. | night challenger, hub worker `Lotteria Clandestina` |

Main-character battle placeholders:

- Each of the 8 recruitable main characters should have a `battle_placeholder`.
- `won`: grants EC reward, unique faction stone, and unlocks hub job.
- `lost`: no recruitment; optional comfort/resource penalty to be defined.
- Imperio final battle uses the same placeholder pattern until the separate battle app exists.

## NPC Placement Draft

NPCs get dialogue but no main portrait by default.

| ID | Suggested placement | Time band | Behavior loop | Notes |
|---|---|---|---|---|
| `loris_salvagente` | Lavatoi / stagnant puddle near no-pool area. | `day`, inferred | patrol puddle perimeter with whistle idle. | Good tutorial/comic NPC about fake lifeguard authority. |
| `franca_sottovuoto` | Piazzole/tende area, near cooler or storage. | `morning`, `afternoon`, inferred | short guarding loop around bag/cooler. | Can hint at containers/resources. |
| `dj_giacomo_tristezza` | Palco Animazione, subordinate to Zelda. | `night`, inferred | depressed stage shuffle; low-energy idle. | Should not overlap too tightly with Zelda event trigger. |
| `klaus_von_wurst` | Spiaggia Libera or sun-exposed path. | `afternoon`, inferred | slow painful pacing, frequent idle. | Heat hazard flavor NPC. |
| `ennio_verticale` | Bar/veranda or shaded crossword chair. | `morning`, `day`, inferred | seated/static if supported; otherwise tiny local loop. | Puzzle/hint flavor. |
| `kevin_predatore` | Spiaggia/shallow water edge. | `day`, inferred | erratic child patrol around bucket; no path blocking. | Animal/shoreline flavor, possible collectible hint. |
| `agente_igiene_007` | Pineta/behind bushes near hidden tent. | `night` or `event_only`, inferred | stealth peek loop; hides behind pines. | ASL/Imperio spy flavor; good hidden event candidate. |
| `nonna_pina` | Ombreggiata piazzola/card table. | `afternoon`, inferred | mostly static, card-shuffling idle. | Social hub flavor. |
| `cocco_bill` | Moving vendor path between beach, bar, and piazzole. | `day`, inferred | small vendor patrol; callout idle. | Can sell fake coconut/stone joke item. |

## Animal And Ambient Placement Draft

Animals should support atmosphere only unless future gameplay promotes them.

| Asset group | Suggested zone | Time band | Behavior |
|---|---|---|---|
| `seagull_1`, `seagull_2` | reception roof, beach edge, trash/coconut vendor route | `day`, `afternoon` | perch/short hop loop; occasional fly-by if supported |
| `cat` | piazzole, bar shadow, reception corner | `morning`, `night` | slow wander + sit idle |
| `dog` | camping entrance, piazzole, barbecue fringe | `day`, `afternoon` | patrol/sniff loop |
| `squirrel` | pineta | `morning`, `day` | short dart loop, avoid main paths |
| `lizard` | sunny walls/rocks | `afternoon` | static bask + quick step loop |
| `rana`, `rana_2` | lavatoi/puddle | `night`, `morning` | tiny hop loop |
| `bird_1`, `bird_2`, `bird_3` | trees/pineta | `morning`, `day` | perch/ambient movement |
| `bat` | pineta/night sky fringe | `night` | short loop, high placement if renderer supports it |
| `bees_iso_custom_cloud_shake_right` | barbecue, flowers, trash/food | `day`, `afternoon` | special ambient cloud |
| `mosquitoes_iso_custom_clouds_shake_down` | pineta, lavatoi, night routes | `night`, `storm_or_special_weather` | special ambient hazard marker |

Animal validation rule: no dialogue records for animals.

## Resources And Missing Asset Placeholders

Required placeholder classes:

| Placeholder | Gameplay purpose | Suggested representation until final art |
|---|---|---|
| `resource.ciottolo_base` | common pickup, low value | small stone pile/decal placeholder |
| `resource.quarzo_lucido` | medium value, Lalla economy | brighter stone placeholder |
| `resource.ghiaione_cantiere` | cheap construction gravel | rough gravel pile near dump/Area Zen VIP |
| `resource.basalto_pesante` | heavy/high value, Bruno/final readiness | dark heavy stone placeholder |
| `hub.piazzola_tier_1` | starting hub | tent/wheelbarrow scene placeholder |
| `hub.piazzola_tier_2` | upgraded hub | larger tent placeholder |
| `hub.piazzola_tier_3` | camper hub | camper placeholder |
| `upgrade.frigorifero` | consumable boost | small prop placeholder |
| `upgrade.telo_riflettente` | heat mitigation | awning/tarp placeholder |
| `upgrade.stendino_rinforzato` | wheelbarrow slots | stendino prop placeholder |
| `upgrade.banchetto_autogestito` | passive sale | market table placeholder |
| `upgrade.tenda_extra` | passive EC | extra tent placeholder |
| `wheelbarrow.tier_1_2_3` | HUD/inventory identity | first-person/carriola model states needed |

## Event Manifest Draft Shape

Future `rtp.events.json` should include at least:

```json
{
  "eventId": "event.challenge.teo_pietrafocaia",
  "eventType": "battle_placeholder",
  "participants": ["teo_pietrafocaia"],
  "location": {"zone": "barbecue", "placementSource": "gameplay_explicit"},
  "timeBand": "afternoon",
  "trigger": "interact",
  "conditions": ["teo_pietrafocaia.not_recruited"],
  "dialogueRefs": ["dialogue.teo.challenge.afternoon"],
  "battlePlaceholder": {
    "battleAppIntegrated": false,
    "testSwitch": {
      "enabled": true,
      "prompt": "Segnare questa battle come vinta o persa?",
      "outcomes": ["won", "lost"]
    }
  },
  "effectsOnWon": ["teo_pietrafocaia.recruited", "hub.job.grigliata_clandestina.unlock"],
  "effectsOnLost": ["challenge.retry_available"]
}
```

## Placement Pipeline For Future Work

Recommended sequence when creating real data:

1. Extract entity/event claims from sceneggiatura and gameplay docs.
2. Resolve IDs against `rtp.characters.json`.
3. Map explicit zones from docs.
4. Infer missing zones using role, biome, time band, and route clarity.
5. Inspect current PERLA1 map for walkability/visibility before assigning coordinates.
6. Produce dormant `rtp.placements.json`, `rtp.behaviors.json`, `rtp.dialogues.json`, and `rtp.events.json`.
7. Run no-paradox validation.
8. Only after approval, integrate runtime loader/UI/event logic.

## No-Paradox Checks To Apply

- Main characters appear in their documented bands unless a story event overrides them.
- Characters cannot be simultaneously recruited at hub and physically challenging the player unless the state machine allows post-recruitment ambient placement.
- NPCs may speak; animals do not.
- NPC portraits remain excluded by default.
- Imperio must be available for intro/rent pressure/final challenge without contradicting daily map placement.
- Final battle requires all 8 recruitments/stemmi, clean debt, required EC/tax state, and night window.
- Hub revenue is collected once daily at 08:00.
- Rent deadline and eviction rules must not softlock without warning.
- Battle placeholder branches must both preserve game-system testability.
- Missing resources/base/upgrades must be explicit placeholders.

## Open Questions

- Exact map coordinates for each zone need runtime map inspection.
- Whether recruited characters remain visible in their original zone after recruitment needs design choice.
- Whether NPCs have time schedules as strict as main characters is not fully specified.
- Final exact resource spawn density and collectible visual assets are not yet defined.
- Intro comic optimization should wait until the startup flow is chosen: full comic scroll, panel-by-panel cutscene, or hybrid.

