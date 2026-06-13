PERLA1 V210 TRUE DOOR RAIN PLANE RENDERER LOCAL

Base reale: PERLA1_V209_DOOR_RAIN_PLANE_WORLDSPACE_LOCAL.

Scopo: rimuovere la soluzione intermedia mascherata per la pioggia vista dalla porta.
La pioggia porta ora usa un renderer dedicato drawDoorRainPlaneWorldSpaceV210(), non il vecchio compositing rainBuffer full-screen + ctx.clip/drawImage.

Check architetturali obbligatori V210:
1. Door rain non passa da perlaCompositeRainBufferV201.
2. Il renderer dedicato non usa ctx.clip/drawImage rainBuffer.
3. Esiste drawDoorRainPlaneWorldSpaceV210.
4. Open-screen/threshold forza full-screen rain quando l'apertura visiva è ampia.
5. Debug espone doorRainRendererPathV210, legacyRainCompositeUsedForDoorV210, portalFallbackV206UsedV210.

Preservati: audio V204, roof budget V200, global weather budget V201, fondale V185, mappa/collisioni/worldgen/sprite/pergola/torre/canopy.
