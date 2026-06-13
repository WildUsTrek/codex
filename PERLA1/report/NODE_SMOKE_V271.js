const fs=require('fs');
const path=require('path');
const root=path.resolve(__dirname,'..');
const html=fs.readFileSync(path.join(root,'01_GIOCO_PRONTO_LOCAL_TEST','index.html'),'utf8');
const required=[
 'PERLA1_V271_REAL_CEILING_CLONE_SIDE_AWARE_CONTINUITY_SAFE_LOCAL',
 'PERLA_V271_REAL_CEILING_CLONE_SIDE_AWARE_CONTINUITY_SAFE',
 'perlaRealCeilingCloneResolveV271',
 'perlaRealCeilingCloneContinuityCeilingWinsOverRoofV271',
 'perlaRealCeilingCloneContinuitySummaryV271',
 'perlaRealCeilingCloneContinuityToggleV271',
 'perlaRealCeilingCloneContinuityModeV271',
 'perlaRealCeilingCloneContinuityDownloadV271',
 'perlaRealCeilingCloneSummaryV270',
 'perlaRoofSilhouetteMainSummaryV267',
 'PERLA_V267_ORIGINAL_ROOF_FILL_DEFAULT_ENABLED = false',
 'drawModernCoverCeilingSegment',
];
const forbidden=[
 'function perlaExternalSoffitEave',
 'perlaExternalSoffitEaveSummaryV269',
 'function perlaRoofEaveClip',
 'perlaRoofEaveClipSummaryV268',
 'PERLA_V268_ROOF_EAVE'
];
const missing=required.filter(s=>!html.includes(s));
const presentForbidden=forbidden.filter(s=>html.includes(s));
const ok=missing.length===0 && presentForbidden.length===0;
const out={ok,missing,presentForbidden, build:(html.match(/const PERLA_BUILD_ID = '([^']+)'/)||[])[1]||null, htmlBytes:html.length};
fs.writeFileSync(path.join(__dirname,'NODE_SMOKE_V271_OUTPUT.json'), JSON.stringify(out,null,2));
if(!ok){ console.error(JSON.stringify(out,null,2)); process.exit(1); }
console.log(JSON.stringify(out,null,2));
