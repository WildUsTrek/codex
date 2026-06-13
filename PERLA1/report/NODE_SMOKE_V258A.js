const fs=require('fs'); const vm=require('vm');
const html=fs.readFileSync('/mnt/data/perla_v258a_work/PERLA1_V258A_PHASE1_REAL_QUICK_WINS_COMPLETE_SAFE_LOCAL/01_GIOCO_PRONTO_LOCAL_TEST/index.html','utf8');
const js=html.slice(html.indexOf('<script>')+8, html.lastIndexOf('</script>'));
function fakeCtx(){
  const grad={addColorStop(){}};
  return new Proxy({
    canvas:{width:800,height:450}, imageSmoothingEnabled:false, fillStyle:'#000', strokeStyle:'#000', globalAlpha:1, lineWidth:1,
    createLinearGradient(){return grad;}, createRadialGradient(){return grad;},
    measureText(t){return {width:String(t||'').length*8};},
    getImageData(){return {data:new Uint8ClampedArray(4)}}
  }, {get(t,p){ if(p in t) return t[p]; return function(){return undefined;}; }, set(t,p,v){ t[p]=v; return true; }});
}
function fakeEl(id){
  const cls={add(){},remove(){},toggle(){},contains(){return false;}};
  return {
    id, style:{setProperty(){}, removeProperty(){}}, dataset:{}, classList:cls, hidden:false, textContent:'', innerHTML:'', width:id==='screen'?800:128, height:id==='screen'?450:128,
    getContext(){return fakeCtx();}, addEventListener(){}, removeEventListener(){}, appendChild(){}, remove(){}, click(){}, focus(){},
    getBoundingClientRect(){return {x:0,y:0,width:this.width||100,height:this.height||40,left:0,top:0,right:this.width||100,bottom:this.height||40};},
    setAttribute(){}, removeAttribute(){}, querySelector(){return fakeEl('qs');}
  };
}
const elements=new Map();
const document={
  title:'', hidden:false, visibilityState:'visible',
  documentElement:{classList:{add(){},remove(){},toggle(){}}, style:{setProperty(){}}},
  body:{appendChild(){}, removeChild(){}},
  getElementById(id){ if(!elements.has(id)) elements.set(id,fakeEl(id)); return elements.get(id); },
  createElement(tag){ return fakeEl(tag); },
  addEventListener(){}, removeEventListener(){}, hasFocus(){return true;},
  querySelector(){return fakeEl('query');}, querySelectorAll(){return [];}
};
let rafCount=0;
const context={
  console, document, window:null, globalThis:null, self:null,
  navigator:{onLine:true,userAgent:'node-smoke',platform:'linux',language:'it-IT',languages:['it-IT'],maxTouchPoints:0,hardwareConcurrency:4,vendor:'',clipboard:null},
  location:{href:'node://smoke'}, screen:{orientation:{type:'landscape-primary',angle:0}}, addEventListener(){}, removeEventListener(){},
  innerWidth:800, innerHeight:600, outerWidth:800, outerHeight:600, devicePixelRatio:1,
  visualViewport:{offsetLeft:0,offsetTop:0,width:800,height:600,scale:1,pageLeft:0,pageTop:0,addEventListener(){}},
  performance:{now(){return Date.now();}, memory:null},
  requestAnimationFrame(cb){ if(rafCount++<2) setTimeout(()=>cb(Date.now()),0); return rafCount; },
  cancelAnimationFrame(){}, setTimeout, clearTimeout, setInterval, clearInterval,
  Math, Date, Array, Object, Number, String, Boolean, RegExp, JSON, Promise, Map, Set, WeakMap, Uint8ClampedArray, Float32Array, Int32Array,
  Blob:function(parts,opts){this.parts=parts;this.opts=opts;}, URL:{createObjectURL(){return 'blob:fake';}, revokeObjectURL(){}},
  Image: class { constructor(){this.width=64; this.height=64; this.complete=false;} set src(v){this._src=v; this.complete=true; setTimeout(()=>{ if(this.onload) this.onload(); },0);} get src(){return this._src;} },
  AudioContext:function(){}, webkitAudioContext:function(){}, localStorage:{getItem(){return null;},setItem(){},removeItem(){}}, sessionStorage:{getItem(){return null;},setItem(){},removeItem(){}}
};
context.window=context; context.globalThis=context; context.self=context;
vm.createContext(context);
vm.runInContext(js, context, {timeout:60000});
setTimeout(()=>{
  const out={buildId:context.window.PERLA_BUILD_ID, hasDebug:!!context.window.__PERLA_DEBUG__, hasPerf:typeof context.window.perlaPerformanceV258A==='function', hasSmart:typeof context.window.perlaPerfStart==='function', hasSummary:typeof context.window.perlaLastDrawStatsSummaryV258==='function', debugText:document.getElementById('debugLine').textContent, perf: context.window.perlaPerformanceV258A ? context.window.perlaPerformanceV258A('node_smoke') : null, smartStatus: context.window.perlaPerfStatus ? context.window.perlaPerfStatus() : null, rafCount};
  console.log(JSON.stringify(out,null,2));
  process.exit(0);
},1000);
