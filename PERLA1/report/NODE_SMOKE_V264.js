const fs = require('fs');
const path = require('path');
const html = fs.readFileSync(path.join(__dirname, '..', '01_GIOCO_PRONTO_LOCAL_TEST', 'index.html'), 'utf8');
const checks = {
  buildId: html.includes("PERLA1_V264_ROOF_COST_WATCHDOG_EMERGENCY_SAFE_LOCAL"),
  baseBuild: html.includes("PERLA1_V263_ROOF_MID_DISTANCE_BRANCH_LOCK_SAFE_LOCAL"),
  v264Flag: html.includes('PERLA_V264_ROOF_COST_WATCHDOG_EMERGENCY_SAFE'),
  thresholds: html.includes('PERLA_V264_ROOF_WARNING_MS = 10.0') && html.includes('PERLA_V264_ROOF_PRESSURE_MS = 12.0') && html.includes('PERLA_V264_ROOF_EMERGENCY_MS = 14.0'),
  sampleThresholds: html.includes('PERLA_V264_ROOF_WARNING_SAMPLES = 7000') && html.includes('PERLA_V264_ROOF_PRESSURE_SAMPLES = 9000') && html.includes('PERLA_V264_ROOF_EMERGENCY_SAMPLES = 12000'),
  pathIndependent: html.includes('perlaRoofCostWatchdogApplyLoopBudgetV264') && html.includes('roofCostWatchdogPathIndependentV264=true'),
  loopHook: html.includes('v264PredictedSamples') && html.includes('v264_roof_cost_watchdog_'),
  finalizeHook: html.includes('perlaRoofCostWatchdogFinalizeFrameV264(drawStats)'),
  summary: html.includes('function perlaRoofCostWatchdogSummaryV264'),
  toggle: html.includes('function perlaRoofCostWatchdogToggleV264'),
  mode: html.includes('function perlaRoofCostWatchdogModeV264Set'),
  download: html.includes('function perlaRoofCostWatchdogDownloadV264'),
  windowGlobals: html.includes('window.perlaRoofCostWatchdogSummaryV264') && html.includes('window.perlaRoofCostWatchdogToggleV264'),
  recorderMetadata: html.includes("phase:'V264 roof cost watchdog emergency safe'") && html.includes('baseBuild:PERLA_V264_BASE_BUILD'),
  recorderV264: html.includes('roofCostWatchdogV264:{enabled:!!d.roofCostWatchdogEnabledV264'),
  v263Preserved: html.includes('perlaRoofBranchLockSummaryV263'),
  v262Preserved: html.includes('perlaCoverageStableSummaryV262'),
  v261Preserved: html.includes('perlaCoverageSurfaceSummaryV261'),
  v260Preserved: html.includes('perlaLongViewBudgetSummaryV260'),
  v259Preserved: html.includes('perlaRoofHotspotSummaryV259'),
  rainPreserved: html.includes('rain_skybox_depth_anchor_fix') && html.includes('PERLA_V257_RAIN_SKYBOX_DEPTH_ANCHOR_FIX'),
  noPatchOnlyMention: !html.includes('SOLO_FILE_DA_SOSTITUIRE')
};
const missing = Object.entries(checks).filter(([,v])=>!v).map(([k])=>k);
const result = { ok: missing.length === 0, generatedAt: new Date().toISOString(), checks, missing };
fs.writeFileSync(path.join(__dirname, 'NODE_SMOKE_V264_OUTPUT.json'), JSON.stringify(result, null, 2));
console.log(JSON.stringify(result, null, 2));
if (missing.length) process.exit(1);
