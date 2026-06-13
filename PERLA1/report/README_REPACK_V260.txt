PERLA1 V260 — LONG VIEW SPRITE/FLOOR BUDGET SAFE

Build: PERLA1_V260_LONG_VIEW_SPRITE_FLOOR_BUDGET_SAFE_LOCAL
Base:  PERLA1_V259_ROOF_CEILING_HOTSPOT_BUDGET_SAFE_LOCAL
Data:  2026-06-12T18:31:31Z

Scopo:
- Ridurre i picchi residui da visuale lunga dopo V259.
- Intervento solo render-time: sprite candidate prefilter safe, sprite screen-size LOD, stripe-step LOD far/tiny, floor far band budget.
- Non tocca tetti V259, rain V248-V257, mappa, worldgen, collisioni, asset, minimappa default.

Comandi console:
- perlaLongViewBudgetSummaryV260()
- perlaLongViewBudgetToggleV260(false) / perlaLongViewBudgetToggleV260(true)
- perlaLongViewBudgetModeV260('safe'|'debug'|'off')
- perlaLongViewBudgetDownloadV260()
- perlaPerfStart(); perlaPerfMark('zona'); perlaPerfStopAndDownload()

Check automatici eseguiti:
- node --check: OK
- Node VM smoke: OK
- PNG invariati vs V259: 0
- PNG count: 116
- asset refs PNG: 108
- missing refs: 0

Test browser consigliato:
1. Storm su erba visuale lunga X65/Y25.
2. Fascia palme storm.
3. Pineta2_s_path storm.
4. Pergola storm, rotazione lenta.
5. Bagni/reception solo controllo regressione V259.

Se vedi popping o impoverimento:
perlaLongViewBudgetToggleV260(false)
