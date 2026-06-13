const fs = require('fs');
const path = require('path');
const html = fs.readFileSync(path.join(__dirname, '..', '01_GIOCO_PRONTO_LOCAL_TEST', 'index.html'), 'utf8');
const checks = {
  buildId: html.includes("PERLA1_V265_COVERAGE_ULTRA_BUDGET_EDGE_RAIL_SAFE_LOCAL"),
  baseBuild: html.includes("PERLA1_V264_ROOF_COST_WATCHDOG_EMERGENCY_SAFE_LOCAL"),
  v265Flag: html.includes('PERLA_V265_COVERAGE_ULTRA_BUDGET_EDGE_RAIL_SAFE'),
  v265PatchMode: html.includes("coverage_ultra_budget_edge_rail_safe"),
  ultraBudgetConstants: html.includes('PERLA_V265_RAIN_EMERGENCY_STEP_X') && html.includes('PERLA_V265_STORM_EMERGENCY_STEP_Y'),
  edgeRailFunctions: html.includes('function perlaCoverageDrawRoofEdgeRailV265') && html.includes('function perlaCoverageDrawPergolaEdgeRailV265'),
  depthAwareRail: html.includes('roofVisibleAt(sx,sy,d,roof') && html.includes("'roof_edge_rail_v265'") && html.includes("'pergola_edge_rail_v265'"),
  noOverlayFinal: html.includes('drawSprite') && html.indexOf('perlaCoverageDrawRoofEdgeRailV265') < html.indexOf('spriteRenderList.forEach'),
  v264WatchdogPreserved: html.includes('perlaRoofCostWatchdogSummaryV264') && html.includes('perlaRoofCostWatchdogApplyLoopBudgetV264'),
  v265HookRoof: html.includes('perlaCoverageUltraBudgetApplyRoofLoopV265') && html.includes('v265_ultra_budget_'),
  v265HookCanopy: html.includes('perlaCoverageCanopyScanStepV265'),
  v265HookPergola: html.includes('perlaCoveragePergolaExtraStepsV265') && html.includes('perlaCoverageDrawPergolaEdgeRailV265(drawStats)'),
  v265Finalize: html.includes('perlaCoverageEdgeRailFinalizeV265(drawStats)'),
  v265Recorder: html.includes('coverageEdgeRailV265:{enabled:!!d.coverageEdgeRailEnabledV265'),
  v265Baseline: html.includes('base.v265={coverageUltraBudgetEdgeRail'),
  v265WindowGlobals: html.includes('window.perlaCoverageEdgeRailSummaryV265') && html.includes('window.perlaCoverageEdgeRailToggleV265') && html.includes('window.perlaCoverageEdgeRailDownloadV265'),
  v263Preserved: html.includes('perlaRoofBranchLockSummaryV263'),
  v262Preserved: html.includes('perlaCoverageStableSummaryV262'),
  v261Preserved: html.includes('perlaCoverageSurfaceSummaryV261'),
  v260Preserved: html.includes('perlaLongViewBudgetSummaryV260'),
  v259Preserved: html.includes('perlaRoofHotspotSummaryV259'),
  rainPreserved: html.includes('PERLA_V257_RAIN_SKYBOX_DEPTH_ANCHOR_FIX') && html.includes('rain_skybox_depth_anchor_fix'),
  noPatchOnlyMention: !html.includes('SOLO_FILE_DA_SOSTITUIRE')
};
const missing = Object.entries(checks).filter(([,v])=>!v).map(([k])=>k);
const result = { ok: missing.length === 0, generatedAt: new Date().toISOString(), checks, missing };
fs.writeFileSync(path.join(__dirname, 'NODE_SMOKE_V265_OUTPUT.json'), JSON.stringify(result, null, 2));
console.log(JSON.stringify(result, null, 2));
if (missing.length) process.exit(1);
