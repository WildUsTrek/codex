const fs=require('fs');
const path='/mnt/data/v270_work/PERLA1_V270_REAL_CEILING_CLONE_EAVE_SAFE_LOCAL/01_GIOCO_PRONTO_LOCAL_TEST/index.html';
const s=fs.readFileSync(path,'utf8');
function assert(cond,msg){ if(!cond){ console.error('FAIL:',msg); process.exit(1); } }
assert(s.includes("PERLA1_V270_REAL_CEILING_CLONE_EAVE_SAFE_LOCAL"),'build id V270 missing');
assert(s.includes('function perlaRealCeilingCloneResolveV270'),'resolver missing');
assert(s.includes('drawModernCoverCeilingSegment(startXCeil,ceilDrawY,segW,curCeilOwner,curCeil,rowDist,floorBandH)'),'actual ceiling draw path missing');
assert(s.includes('const v270Clone=perlaRealCeilingCloneResolveV270(fX,fY,cX,cY,rowDist,drawStats);'),'floor/ceiling virtual clone hook missing');
assert(s.includes('PERLA_V270_FORBID_FAKE_PERIMETER_BANDS = true'),'fake band guard missing');
assert(s.includes('PERLA_V270_FORBID_V268_PERMISSIVE_EAVE = true'),'v268 permissive guard missing');
assert(!s.includes('perlaExternalSoffitEave'),'V269 fake external soffit code present');
assert(!s.includes('PERLA_V268_ROOF_EAVE_ANGLE_CLIP_REFINEMENT_SAFE'),'V268 code imported');
assert(s.includes('window.perlaRealCeilingCloneSummaryV270'),'window command missing');
console.log(JSON.stringify({ok:true, build:'PERLA1_V270_REAL_CEILING_CLONE_EAVE_SAFE_LOCAL', checks:8}, null, 2));
