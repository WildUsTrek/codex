const fs=require('fs'), vm=require('vm');
const code=fs.readFileSync('report/EXTRACTED_INDEX_INLINE_SCRIPT_V252.js','utf8');
class Path2D{ constructor(){this.ops=[];} moveTo(x,y){this.ops.push(['m',x,y]);} lineTo(x,y){this.ops.push(['l',x,y]);} }
const noop=()=>{};
const ctx={save:noop,restore:noop,beginPath:noop,moveTo:noop,lineTo:noop,stroke:noop,fill:noop,fillRect:noop,clearRect:noop,drawImage:noop,arc:noop,ellipse:noop,rect:noop,clip:noop,translate:noop,rotate:noop,scale:noop,createLinearGradient(){return {addColorStop:noop}},measureText(){return {width:10}},setLineDash:noop,strokeRect:noop,fillText:noop,strokeText:noop,closePath:noop};
const style={setProperty:()=>{},removeProperty:()=>{}};
const el={style,dataset:{},classList:{add:noop,remove:noop,toggle:noop,contains:()=>false},addEventListener:noop,removeEventListener:noop,appendChild:noop,remove:noop,setAttribute:noop,getAttribute:()=>null,querySelector:()=>el,querySelectorAll:()=>[],innerHTML:'',textContent:'',value:'',checked:false,width:800,height:450,getContext:()=>ctx,focus:noop,blur:noop};
const document={body:el,documentElement:el,createElement:(tag)=> tag==='canvas'?Object.assign({},el,{getContext:()=>ctx,toDataURL:()=>''}):Object.assign({},el),getElementById:()=>el,querySelector:()=>el,querySelectorAll:()=>[],addEventListener:noop,removeEventListener:noop};
const window={document,addEventListener:noop,removeEventListener:noop,innerWidth:800,innerHeight:450,devicePixelRatio:1,__PERLA_DEBUG__:{},location:{href:'http://localhost/'},URL:{createObjectURL:()=>'',revokeObjectURL:noop}};
const navigator={maxTouchPoints:0}; window.navigator=navigator; window.matchMedia=()=>({matches:false,addEventListener:()=>{},removeEventListener:()=>{}});
const sandbox={window,document,navigator,console,Path2D,Image:class{set src(v){this._src=v; if(this.onload) setTimeout(()=>this.onload(),0)}},Audio:class{play(){return Promise.resolve()} pause(){}},localStorage:{getItem:()=>null,setItem:noop,removeItem:noop},performance:{now:()=>1000},requestAnimationFrame:noop,cancelAnimationFrame:noop,setTimeout,clearTimeout,setInterval,clearInterval,Blob:class{},URL:window.URL,Math,Date,Array,Object,Number,String,Boolean,JSON,parseInt,parseFloat,isFinite};
sandbox.globalThis=sandbox; sandbox.self=window;
vm.createContext(sandbox);
try { vm.runInContext(code,sandbox,{timeout:30000}); console.log('vm smoke ok', !!sandbox.window.__PERLA_DEBUG__.getRainNearPhaseDesyncSummaryV252); }
catch(e){ console.error(e && e.stack || e); process.exit(1); }
