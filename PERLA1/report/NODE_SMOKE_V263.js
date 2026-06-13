const fs = require('fs');
const path = require('path');
const html = fs.readFileSync(path.join(__dirname, '..', '01_GIOCO_PRONTO_LOCAL_TEST', 'index.html'), 'utf8');
const checks = {
  buildId: html.includes("PERLA1_V263_ROOF_MID_DISTANCE_BRANCH_LOCK_SAFE_LOCAL"),
  baseBuild: html.includes("PERLA1_V262_COVERAGE_STABLE_EDGE_REPAIR_SAFE_LOCAL"),
  v263Flag: html.includes('PERLA_V263_ROOF_MID_DISTANCE_BRANCH_LOCK_SAFE'),
  branchLockStep: html.includes('PERLA_V263_ROOF_BRANCH_LOCK_STEP_X = 7') && html.includes('PERLA_V263_ROOF_BRANCH_LOCK_STEP_Y = 5'),
  emergencyStep: html.includes('PERLA_V263_ROOF_BRANCH_LOCK_EMERGENCY_STEP_X = 9') && html.includes('PERLA_V263_ROOF_BRANCH_LOCK_EMERGENCY_STEP_Y = 7'),
  noNearFullCost: html.includes('V263: no near/full-cost exception') && html.includes('roofBranchLockNoNearFullCostV263'),
  branchLockDecision: html.includes('roof_branch_lock_stable_v263') && html.includes('v263_no_15200_branch'),
  summary: html.includes('function perlaRoofBranchLockSummaryV263'),
  toggle: html.includes('function perlaRoofBranchLockToggleV263'),
  mode: html.includes('function perlaRoofBranchLockModeV263Set'),
  download: html.includes('function perlaRoofBranchLockDownloadV263'),
  windowGlobals: html.includes('window.perlaRoofBranchLockSummaryV263') && html.includes('window.perlaRoofBranchLockToggleV263'),
  recorderMetadata: html.includes("phase:'V263 roof mid-distance branch lock safe'") && html.includes('baseBuild:PERLA_V263_BASE_BUILD'),
  recorderV263: html.includes('roofBranchLockV263:{enabled:!!d.roofBranchLockV263'),
  v259Preserved: html.includes('perlaRoofHotspotSummaryV259'),
  v260Preserved: html.includes('perlaLongViewBudgetSummaryV260'),
  v261Preserved: html.includes('perlaCoverageSurfaceSummaryV261'),
  v262Preserved: html.includes('perlaCoverageStableSummaryV262'),
  rainPreserved: html.includes('rain_skybox_depth_anchor_fix') && html.includes('PERLA_V257_RAIN_SKYBOX_DEPTH_ANCHOR_FIX'),
  noPatchOnlyMention: !html.includes('SOLO_FILE_DA_SOSTITUIRE')
};
const missing = Object.entries(checks).filter(([,v])=>!v).map(([k])=>k);
const result = { ok: missing.length === 0, generatedAt: new Date().toISOString(), checks, missing };
fs.writeFileSync(path.join(__dirname, 'NODE_SMOKE_V263_OUTPUT.json'), JSON.stringify(result, null, 2));
console.log(JSON.stringify(result, null, 2));
if (missing.length) process.exit(1);
