const fs=require('fs');
const path=require('path');

const root=path.resolve(__dirname,'..');
const htmlPath=path.join(root,'01_GIOCO_PRONTO_LOCAL_TEST','index.html');
const html=fs.readFileSync(htmlPath,'utf8');
const scripts=[...html.matchAll(/<script\b[^>]*>([\s\S]*?)<\/script>/gi)].map(m=>m[1]);
const code=scripts.join('\n');

let parseOk=true;
let parseError=null;
try{
  new Function(code);
}catch(err){
  parseOk=false;
  parseError=err && (err.stack || err.message) || String(err);
}

const required=[
 'PERLA1_V272_REAL_ROOF_UNDERSIDE_EAVE_NEAR_GEOMETRY_SAFE_LOCAL',
 'PERLA_V272_REAL_ROOF_UNDERSIDE_EAVE_NEAR_GEOMETRY_SAFE',
 'PERLA_V272_BASE_BUILD',
 'PERLA_V272_FORBID_ORIGINAL_ROOF_FILL',
 'PERLA_V272_FORBID_FAKE_PERIMETER_BAND',
 'perlaRealRoofUndersideEavePassV272',
 'perlaRealRoofUndersideEaveFacesV272',
 'perlaRealRoofUndersideEaveDrawPolyV272',
 'perlaRealRoofUndersideEaveVisibleAtV272',
 'perlaRealRoofUndersideEaveSummaryV272',
 'perlaRealRoofUndersideEaveToggleV272',
 'perlaRealRoofUndersideEaveModeV272',
 'perlaRealRoofUndersideEaveDownloadV272',
 'drawSlopedRoofGableCaps2_5D(time, drawStats);\n    if(typeof perlaRealRoofUndersideEavePassV272',
 'PERLA_V267_ORIGINAL_ROOF_FILL_DEFAULT_ENABLED = false',
 'perlaRealCeilingCloneContinuitySummaryV271',
 'perlaRoofSilhouetteMainSummaryV267',
];

const forbidden=[
 'function perlaExternalSoffitEave',
 'perlaExternalSoffitEaveSummaryV269',
 'function perlaRoofEaveClip',
 'perlaRoofEaveClipSummaryV268',
 'PERLA_V268_ROOF_EAVE',
 'PERLA_V267_ORIGINAL_ROOF_FILL_DEFAULT_ENABLED = true'
];

const missing=required.filter(s=>!html.includes(s));
const presentForbidden=forbidden.filter(s=>html.includes(s));
const build=(html.match(/const PERLA_BUILD_ID = '([^']+)'/)||[])[1]||null;
const ok=parseOk && missing.length===0 && presentForbidden.length===0 && build==='PERLA1_V272_REAL_ROOF_UNDERSIDE_EAVE_NEAR_GEOMETRY_SAFE_LOCAL';

const out={
  ok,
  parseOk,
  parseError,
  missing,
  presentForbidden,
  build,
  scripts:scripts.length,
  htmlBytes:html.length,
  v272Symbols:(html.match(/V272|realRoofUndersideEave/g)||[]).length
};

fs.writeFileSync(path.join(__dirname,'NODE_SMOKE_V272_OUTPUT.json'), JSON.stringify(out,null,2));
if(!ok){
  console.error(JSON.stringify(out,null,2));
  process.exit(1);
}
console.log(JSON.stringify(out,null,2));
