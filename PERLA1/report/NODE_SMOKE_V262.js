const fs = require('fs');
const path = require('path');
const html = fs.readFileSync(path.join(__dirname, '..', '01_GIOCO_PRONTO_LOCAL_TEST', 'index.html'), 'utf8');
const checks = {
  buildId: html.includes("PERLA1_V262_COVERAGE_STABLE_EDGE_REPAIR_SAFE_LOCAL"),
  baseBuild: html.includes("PERLA1_V261_ROOF_PERGOLA_HARD_CAP_SAFE_LOCAL"),
  v262Flag: html.includes('PERLA_V262_COVERAGE_STABLE_EDGE_REPAIR_SAFE'),
  stableSummary: html.includes('function perlaCoverageStableSummaryV262'),
  stableToggle: html.includes('function perlaCoverageStableToggleV262'),
  stableMode: html.includes('function perlaCoverageStableModeV262Set'),
  stableDownload: html.includes('function perlaCoverageStableDownloadV262'),
  edgeBandConst: html.includes('PERLA_V262_EDGE_FULL_QUALITY_BAND_PX'),
  hysteresis: html.includes('PERLA_V262_CLEAR_HYSTERESIS_FRAMES') && html.includes('heldLevel'),
  emergencyOnly: html.includes('coverage_emergency_cap_v262') && html.includes('coverage_stable_budget_v262'),
  roofPathLabels: html.includes('coveragePathLabelsV262') && html.includes('unknown_roof_path'),
  uncappedRoofMetric: html.includes('coverageUncappedRoofSamplesV262'),
  recorderMetadata: html.includes("phase:'V262 coverage stable edge repair safe'") && html.includes('baseBuild:PERLA_V262_BASE_BUILD'),
  recorderCoverageV262: html.includes('coverageV262:{enabled:!!d.coverageV262Enabled'),
  v259Preserved: html.includes('perlaRoofHotspotSummaryV259'),
  v260Preserved: html.includes('perlaLongViewBudgetSummaryV260'),
  v261Preserved: html.includes('perlaCoverageSurfaceSummaryV261'),
  windowGlobals: html.includes('window.perlaCoverageStableSummaryV262') && html.includes('window.perlaCoverageStableToggleV262'),
  rainPreserved: html.includes('rain_skybox_depth_anchor_fix') && html.includes('PERLA_V257_RAIN_SKYBOX_DEPTH_ANCHOR_FIX'),
  noPatchOnlyMention: !html.includes('SOLO_FILE_DA_SOSTITUIRE')
};
const missing = Object.entries(checks).filter(([,v])=>!v).map(([k])=>k);
const result = { ok: missing.length === 0, generatedAt: new Date().toISOString(), checks, missing };
fs.writeFileSync(path.join(__dirname, 'NODE_SMOKE_V262_OUTPUT.json'), JSON.stringify(result, null, 2));
console.log(JSON.stringify(result, null, 2));
if (missing.length) process.exit(1);
