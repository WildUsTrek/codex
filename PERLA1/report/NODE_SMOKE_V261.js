#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const root = process.argv[2] || process.cwd();
const htmlPath = path.join(root, '01_GIOCO_PRONTO_LOCAL_TEST', 'index.html');
const html = fs.readFileSync(htmlPath, 'utf8');
const checks = {
  buildId: html.includes('PERLA1_V261_ROOF_PERGOLA_HARD_CAP_SAFE_LOCAL'),
  baseBuild: html.includes('PERLA1_V260_LONG_VIEW_SPRITE_FLOOR_BUDGET_SAFE_LOCAL'),
  coverageSummary: html.includes('function perlaCoverageSurfaceSummaryV261'),
  coverageToggle: html.includes('function perlaCoverageSurfaceToggleV261'),
  coverageModeSet: html.includes('function perlaCoverageSurfaceModeV261Set'),
  coverageDownload: html.includes('function perlaCoverageSurfaceDownloadV261'),
  pergolaSummary: html.includes('function perlaPergolaBudgetSummaryV261'),
  roofDecisionHook: html.includes('perlaCoverageRoofDecisionV261(r,bounds,decision,drawStats)'),
  roofPlaneHook: html.includes('perlaCoverageShouldSkipRoofPlaneV261(sx,sy,pl,drawStats)'),
  modernCoverHook: html.includes('perlaCoverageModernCoverDecisionV261'),
  canopyHook: html.includes('perlaCoverageCanopySegmentDecisionV261'),
  pergolaHook: html.includes('perlaCoveragePergolaDecisionV261(bounds,drawStats)'),
  recorderCoverage: html.includes('coverageV261:{enabled:'),
  debugExports: html.includes('perlaCoverageSurfaceSummaryV261,') && html.includes('perlaPergolaBudgetSummaryV261,'),
  windowGlobals: html.includes('window.perlaCoverageSurfaceSummaryV261') && html.includes('window.perlaCoverageSurfaceModeV261'),
  v259Preserved: html.includes('function perlaRoofHotspotSummaryV259'),
  v260Preserved: html.includes('function perlaLongViewBudgetSummaryV260'),
  rainPreserved: html.includes('PERLA_V257_RAIN_SKYBOX_DEPTH_ANCHOR_FIX'),
  longViewPreserved: html.includes('PERLA_V260_LONG_VIEW_SPRITE_FLOOR_BUDGET_SAFE'),
  noPatchOnlyMention: !html.includes('patch-only')
};
const missing = Object.entries(checks).filter(([k,v]) => !v).map(([k]) => k);
const out = {ok: missing.length === 0, generatedAt: new Date().toISOString(), checks, missing};
console.log(JSON.stringify(out, null, 2));
process.exit(missing.length ? 1 : 0);
