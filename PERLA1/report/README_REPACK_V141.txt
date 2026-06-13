PERLA1 V141 — SHADOW CACHE + TENT ANCHOR REPAIR SAFE LOCAL

Base: PERLA1_V138Q_MICROFLORA_DIRECTIONAL_RELOCATION_SAFE.

Contenuto patch:
- Ripristino ancoraggio originale V138Q per tutti gli sprite.
- Unica modifica ancoraggio: tende, con moltiplicatore 0.92 su groundSink originale 2.8.
- Rimosso renderer ombre a righe/fillRect.
- Nuovo renderer ombre cached: ombre morbide, tonde/ellittiche, semi-trasparenti, mai ridotte a linea.
- Ombre attive su categorie sicure: alberi/palme/tamerici, ombrelloni, tavoli bar, tende, auto/camper, vasi/piccoli oggetti.
- Ombre disattivate per microflora, aghi, pigne, fiori, erbe, cartelli e decal.
- Barca ignorata/preservata.
- Nessun PNG modificato.
- Nessuna modifica a tetti, torre, pergola, festoni, mappa/collisioni/worldgen.

Packaging:
- ZIP completo soltanto.
- Nessuna cartella SOLO_FILE_DA_SOSTITUIRE / patch-only.

Test eseguiti:
- node --check sul JS estratto: OK.
- runtime smoke Node con probe: OK.
- asset manifest missing 0.
- PNG invariati rispetto a V138Q.
- roofSegments 2.
- sprite runtime 1892.
- ZIP integrity OK.
