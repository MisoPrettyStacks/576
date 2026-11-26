<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Kalshi XRP 15-Minute · Order Book Heatmap + Recorder</title>
<link href="https://fonts.googleapis.com/css2?family=Patrick+Hand&display=swap" rel="stylesheet">
<style>
:root{--bg:#121a24;--p:#1a2533;--b:#2a3a4d;--t:#e6edf5;--m:#8da0b8;--g:#21c577;--r:#f0504a;--a:#5aa9ff}
*{box-sizing:border-box}html,body{height:100%;margin:0}
body{background:var(--bg);color:var(--t);font:14px/1.45 system-ui,-apple-system,Segoe UI,sans-serif;display:flex;flex-direction:column;overflow:auto}
header{display:flex;flex-wrap:wrap;gap:10px;align-items:center;padding:8px 12px;border-bottom:1px solid var(--b)}
h1{font-size:15px;margin:0 8px 0 0}
.pill{padding:2px 9px;border-radius:99px;border:1px solid var(--b);color:var(--m);cursor:help}
.pill.ok{color:var(--g);border-color:#1d6b49}.pill.bad{color:var(--r);border-color:#7a2d2b}
.ctl{display:flex;align-items:center;gap:5px;color:var(--m)}
select,input,button{background:var(--p);color:var(--t);border:1px solid var(--b);border-radius:6px;padding:3px 6px;font:inherit}
button{cursor:pointer}button:hover{border-color:var(--a)}input[type=number]{width:70px}input[type=text]{width:190px}input[type=checkbox]{accent-color:var(--a)}
.gg{color:var(--g)}.rr{color:var(--r)}
em.n{color:var(--m);font-size:11px;font-style:normal;font-weight:400}
#intro{margin:8px 12px 0;background:var(--p);border:1px solid var(--b);border-radius:8px;padding:6px 12px;max-height:44vh;overflow:auto}
#intro summary{cursor:pointer;font-weight:600}
#intro .g{display:grid;grid-template-columns:repeat(auto-fit,minmax(250px,1fr));gap:12px}
#intro h4{margin:8px 0 4px;color:var(--a)}#intro p{margin:0 0 6px}#intro ul{margin:0 0 6px;padding-left:18px}
.bar{height:12px;border-radius:6px;background:linear-gradient(90deg,#17222e,#103864,#1870a8,#d6c43a,#e85030,#ffece6)}
.bl{display:flex;justify-content:space-between;color:var(--m);font-size:11px}
#sum{margin:8px 12px 0;padding:8px 12px;background:#17304d;border:1px solid #2f5282;border-radius:8px;line-height:1.5}
#stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:8px;padding:8px 12px}
.card{background:var(--p);border:1px solid var(--b);border-radius:8px;padding:6px 10px;cursor:help}
.card small{color:var(--m);display:block}.card b{font-size:16px}
main{display:flex;gap:8px;padding:0 12px 8px;min-height:700px}
#hmw{flex:1;display:flex;flex-direction:column;min-width:0;gap:4px}
.hmh{display:flex;flex-wrap:wrap;gap:6px 14px;align-items:center}
.lg{display:flex;align-items:center;gap:5px;color:var(--m);font-size:11px;cursor:help}.lg .bar{display:block;width:110px}
.hmh>span{color:var(--m);font-size:11px;cursor:help}
#hm{flex:1;position:relative;background:#16212d;border:1px solid var(--b);border-radius:8px;min-width:0;min-height:680px}
#hm canvas{position:absolute;inset:0;width:100%;height:100%}
aside{width:330px;display:flex;flex-direction:column;gap:8px}
.box{background:var(--p);border:1px solid var(--b);border-radius:8px;padding:6px 8px;overflow:hidden}
.box h3{margin:0 0 4px;font-size:12px;color:var(--m);text-transform:uppercase;letter-spacing:.05em;cursor:help}
#lad,#ts{font:12px ui-monospace,Menlo,monospace}
.row{display:flex;justify-content:space-between;position:relative;padding:0 4px;height:17px;line-height:17px}
.row i{position:absolute;right:0;top:1px;bottom:1px;opacity:.3;z-index:0}.row span{position:relative;z-index:1}
.a{color:var(--r)}.bd{color:var(--g)}.a i{background:var(--r)}.bd i{background:var(--g)}
.sp{text-align:center;color:var(--m);font-size:11px;padding:2px}
#log{overflow:auto;max-height:230px;font-size:12px}#log div{padding:2px 0;border-bottom:1px solid #243244}
#dat{display:flex;flex-wrap:wrap;gap:5px;margin-top:5px}#dat button{font-size:12px}
#store{color:var(--m);font-size:12px}
#tip{position:fixed;z-index:9;background:#0b1118;color:#fff;border:1px solid #3a516d;border-radius:6px;padding:6px 9px;max-width:310px;pointer-events:none;display:none;box-shadow:0 4px 18px #000a;white-space:pre-line}
footer{padding:4px 12px 10px;color:var(--m);font-size:11px}
@media(max-width:900px){main{flex-direction:column}#hm{flex:none;min-height:560px}#hmw{flex:none}aside{width:auto}}
</style></head><body>
<header>
<h1>Kalshi · XRP 15-minute · Heatmap + Recorder</h1>
<span class="pill" id="p1" data-tip="Connection to Kalshi's free public market data (order book + trades). Checked once a second.">Kalshi …</span>
<span class="pill" id="p2" data-tip="Live XRP/USD price from Kraken (free). Kalshi decides each market from an index (CF Benchmarks RTI), so this is a close stand-in, not the exact number.">XRP price …</span>
<span class="pill" id="p3" data-tip="Saving to your own browser (IndexedDB). Nothing is uploaded anywhere. Use the Download buttons on the right to keep your data.">Saving …</span>
<label class="ctl" data-tip="Which prices (in cents) the chart shows. Auto = 15¢ above and below the current price. Full = 1¢ to 99¢.">Zoom <select id="vr"><option value="auto">Auto ±15¢</option><option value="full">Full 1–99¢</option></select></label>
<label class="ctl" data-tip="Brightness. Slide left to also see small orders.">Brightness <input id="gam" type="range" min=".25" max="1" step=".05" value=".6" style="width:80px"></label>
<label class="ctl" data-tip="Orders of at least this many contracts count as BIG. They get notes on the chart and lines in the behavior log. One contract pays $1 if you are right.">Big = <input id="whale" type="number" value="100" min="1"> contracts</label>
<label class="ctl" data-tip="Shows or hides the white-text notes on the chart."><input type="checkbox" id="notes" checked> Notes on chart</label>
<label class="ctl" data-tip="Asks your device not to turn the screen off, so recording keeps running. Recording only works while this page stays open."><input type="checkbox" id="wake"> Keep screen awake</label>
<label class="ctl" data-tip="Only needed if your browser blocks direct access to Kalshi (CORS). Paste the address of your free Cloudflare Worker (see worker.js). Leave empty to try direct.">Proxy <input type="text" id="proxy" placeholder="https://your-worker.workers.dev"></label>
<button id="pause" data-tip="Freeze the picture. Recording keeps going in the background.">Pause</button>
</header>
<details id="intro" open><summary>👋 Start here: what is this market and how to read it (click to hide or show)</summary>
<div class="g">
<div><h4>The market</h4><p>Every 15 minutes Kalshi opens a new yes/no question: <b>“Will XRP be at or above the <u>target price</u> when this 15-minute window ends?”</b> The target is XRP’s price at the start of the window. <b>YES = UP</b>, <b>NO = DOWN</b>. A YES contract pays <b>$1</b> if UP, <b>$0</b> if not. The final price is the average of the last 60 prices in the last minute.</p></div>
<div><h4>Reading the price</h4><ul><li>YES price in cents ≈ the crowd’s chance of UP. <b>62¢ = about 62%</b>.</li><li>Buy YES at 62¢: you risk 62¢ to win 38¢. Buy NO at 38¢: you risk 38¢ to win 62¢.</li><li>Kalshi’s book only shows <b>bids</b>. A NO bid at 38¢ is the same as someone <i>offering</i> YES at 62¢, so this page shows everything on one YES scale (1–99¢).</li></ul></div>
<div><h4>The picture</h4><ul><li><b>Sideways</b> = the 15 minutes (starts empty, fills left to right, <b>resets every cycle</b>).</li><li><b>Up/down</b> = YES price in cents.</li><li><b>Color</b> = contracts waiting at that price. Dark blue = few, yellow = many, red/white = huge.</li><li><b>Bubbles</b> = trades by someone in a hurry. Teal = bet UP, pink = bet DOWN.</li><li><b>Bottom:</b> XRP price vs target, volume, and CVD (who is rushing).</li><li>The <b>last minute</b> is shaded: the result is an average, so single jumps matter less.</li></ul><div class="bar"></div><div class="bl"><span>almost nothing</span><span>a huge pile</span></div></div>
<div><h4>Saving data (for studying behavior)</h4><ul><li>Every second the page saves the whole book, XRP price, every trade, and every <b>change</b> in the book (added, pulled without trading, or filled).</li><li>It all stays in <b>your browser</b>. Download CSV/JSON any time on the right, or replay any saved cycle.</li><li>Recording only runs while this page is open. Keep the tab open (use “Keep screen awake”).</li></ul></div>
<div><h4>If you have a small account</h4><ul><li>Kalshi charges <b>fees</b> per contract; at small size they matter. Check the fee schedule.</li><li>Books are thin. A wide gap between best buy and best sell costs you money; use limit orders.</li><li>Prices can swing hard in the final minutes.</li><li>No chart predicts the future. Only risk money you can afford to lose. This is education, not advice.</li></ul></div>
<div><h4>Mini dictionary</h4><p><b>Contract</b>: one yes/no share. <b>Bid</b>: an offer to buy. <b>Spread</b>: gap between best buy and sell. <b>Aggressive trade</b>: buying/selling right now at the price available. <b>Pulled</b>: an order removed without trading. <b>CVD</b>: rushed UP bets minus rushed DOWN bets. <b>COB / SVP</b>: current book / what traded at each price this cycle. <b>Target / strike</b>: the price XRP must reach.</p></div>
</div></details>
<div id="sum">Looking for the current 15-minute market…</div>
<section id="stats"></section>
<main>
<div id="hmw"><div class="hmh">
<b data-tip="One column per second of the current 15-minute market. Together they show how piles of orders appear, move and vanish. A new, empty picture starts every 15 minutes.">Order book over the 15-minute window <em class="n">(YES price in cents)</em></b>
<span class="lg" data-tip="Color key. Dark blue = few contracts waiting. Yellow = many. Red/white = the biggest piles."><span>few</span><i class="bar"></i><span>huge pile</span></span>
<span data-tip="Bubbles are trades by someone in a hurry. Teal = they bet UP (bought YES). Pink = they bet DOWN (bought NO). Bigger = more contracts.">○ teal = bet UP · ○ pink = bet DOWN · line = YES price</span>
<span id="mode" style="color:var(--g)">● LIVE</span></div>
<div id="hm"><canvas id="c"></canvas><canvas id="o"></canvas></div></div>
<aside>
<div class="box"><h3 data-tip="Replay any cycle you have saved, or go back to live. Replays use your saved data, so you can study what happened step by step.">Replay saved cycles</h3><select id="cyc" style="width:100%"><option value="">Live (current cycle)</option></select></div>
<div class="box"><h3 data-tip="Every price where people wait to trade, on one YES scale. Red rows on top = people betting DOWN (shown as YES offers). Green rows below = people betting UP (YES bids).">Waiting orders <em class="n">(YES price ladder)</em></h3><div id="lad"></div></div>
<div class="box"><h3 data-tip="The latest real trades in this market. Green = bet UP in a hurry. Red = bet DOWN in a hurry.">Trades as they happen</h3><div id="ts"></div></div>
<div class="box"><h3 data-tip="Plain-English lines about what the crowd just did: big orders added, big orders pulled without trading, big orders filled, rushed bets. Each is saved with XRP price and time left, so you can study what triggers what.">Behavior log <em class="n">(what people just did)</em></h3><div id="log"></div></div>
<div class="box"><h3 data-tip="Everything is saved in your browser only. Download it to analyze in Excel, Python, etc. Snapshots = the book every second. Trades = every trade. Events = every change in the book with context.">Saved data</h3><div id="store"></div>
<div id="dat"><button data-x="snaps">Book CSV</button><button data-x="trades">Trades CSV</button><button data-x="events">Events CSV</button><button data-x="cycles">Cycles CSV</button><button data-x="json">Everything JSON</button><button data-x="clear" style="color:var(--r)">Delete all</button></div></div>
</aside></main>
<footer>Data: Kalshi public API (market, order book, trades) and Kraken public WebSocket (XRP price). Free, no keys. Educational tool, not financial advice. Prediction markets involve risk of loss.</footer>
<div id="tip"></div>
<script>
const KB_DEFAULT='https://external-api.kalshi.com',SER='KXXRP15M',N=900;
const $=id=>document.getElementById(id),fm=n=>n>=1e6?(n/1e6).toFixed(2)+'M':n>=1e3?(n/1e3).toFixed(1)+'K':n%1?n.toFixed(1):n.toFixed(0),fx=p=>p==null?'–':'$'+p.toFixed(4);
const S={live:null,replay:null,spot:null,paused:false,mouse:null,v:null,cache:[],mx:1,k:0,seen:new Set(),logs:0};
const Q={snaps:[],trades:[],events:[],cycles:[]};
let LS={get:k=>{try{return localStorage.getItem(k)}catch(e){return null}},set:(k,v)=>{try{localStorage.setItem(k,v)}catch(e){}}};
$('proxy').value=LS.get('proxy')||'';$('proxy').onchange=()=>{LS.set('proxy',$('proxy').value.trim());S.err=0};
const tip=$('tip');
function showTip(t,x,y){tip.textContent=t;tip.style.display='block';tip.style.left=Math.min(x+14,innerWidth-320)+'px';tip.style.top=Math.min(y+16,innerHeight-140)+'px'}
document.addEventListener('mousemove',e=>{if(e.target===$('o'))return;const el=e.target.closest&&e.target.closest('[data-tip]');if(!el){tip.style.display='none';return}showTip(el.dataset.tip,e.clientX,e.clientY)});
// ---------- storage (IndexedDB)
let db;
const dbOpen=()=>new Promise(r=>{try{const q=indexedDB.open('kalshi_xrp15m',1);q.onupgradeneeded=()=>{const d=q.result;d.createObjectStore('cycles',{keyPath:'tk'});for(const s of['snaps','events']){d.createObjectStore(s,{autoIncrement:true}).createIndex('tk','tk')}d.createObjectStore('trades',{keyPath:'id'}).createIndex('tk','tk')};q.onsuccess=()=>{db=q.result;r()};q.onerror=()=>r()}catch(e){r()}});
const put=(st,rows)=>new Promise(r=>{if(!db||!rows.length)return r();const t=db.transaction(st,'readwrite'),s=t.objectStore(st);rows.forEach(x=>s.put(x));t.oncomplete=r;t.onerror=r;t.onabort=r});
const getAll=(st,tk)=>new Promise(r=>{if(!db)return r([]);const s=db.transaction(st).objectStore(st),q=tk?s.index('tk').getAll(IDBKeyRange.only(tk)):s.getAll();q.onsuccess=()=>r(q.result);q.onerror=()=>r([])});
const cnt=st=>new Promise(r=>{if(!db)return r(0);const q=db.transaction(st).objectStore(st).count();q.onsuccess=()=>r(q.result);q.onerror=()=>r(0)});
async function flush(){const a=Q.snaps.splice(0),b=Q.trades.splice(0),c=Q.events.splice(0),d=Q.cycles.splice(0);await Promise.all([put('snaps',a),put('trades',b),put('events',c),put('cycles',d)]);stats()}
async function stats(){if(!db){$('p3').textContent='Saving off';$('p3').className='pill bad';return}
  const [a,b,c,d]=await Promise.all(['cycles','snaps','trades','events'].map(cnt));$('p3').textContent='Saving ✓ '+a+' cycles';$('p3').className='pill ok';
  $('store').textContent=`${a} cycles · ${fm(b)} book snapshots · ${fm(c)} trades · ${fm(d)} book changes saved on this device.`}
setInterval(flush,5000);addEventListener('pagehide',flush);
async function cycList(){const cs=(await getAll('cycles')).sort((x,y)=>y.close-x.close).slice(0,60),sel=$('cyc'),v=sel.value;
  sel.innerHTML='<option value="">Live (current cycle)</option>'+cs.map(c=>`<option value="${c.tk}">${new Date(c.close).toLocaleString([],{month:'short',day:'numeric',hour:'2-digit',minute:'2-digit'})} · target ${c.target??'–'} · ${c.result?c.result.toUpperCase():'pending'}</option>`).join('');sel.value=v}
function dl(name,text,type){const a=document.createElement('a');a.href=URL.createObjectURL(new Blob([text],{type:type||'text/csv'}));a.download=name;a.click()}
const csv=(rows,cols)=>cols.join(',')+'\n'+rows.map(r=>cols.map(c=>{let v=r[c];if(v==null)v='';if(typeof v==='object')v=JSON.stringify(v);v=String(v);return /[",\n]/.test(v)?'"'+v.replace(/"/g,'""')+'"':v}).join(',')).join('\n');
$('dat').onclick=async e=>{const x=e.target.dataset.x;if(!x)return;await flush();const stamp=new Date().toISOString().slice(0,16).replace(/[:T]/g,'-');
  if(x==='snaps')dl(`kalshi_xrp15m_book_${stamp}.csv`,csv(await getAll('snaps'),['tk','t','sec','tleft','spot','spot_vs_target_pct','yes_bid','yes_ask','mid','spread','yes_bids','no_bids']));
  else if(x==='trades')dl(`kalshi_xrp15m_trades_${stamp}.csv`,csv(await getAll('trades'),['id','tk','t','sec','tleft','yes_price','contracts','taker','spot']));
  else if(x==='events')dl(`kalshi_xrp15m_events_${stamp}.csv`,csv(await getAll('events'),['tk','t','sec','tleft','kind','side','yes_price','delta','size_before','traded','spot','spot_vs_target_pct','mid','spread']));
  else if(x==='cycles')dl(`kalshi_xrp15m_cycles_${stamp}.csv`,csv(await getAll('cycles'),['tk','title','open','close','target','result','expiration_value']));
  else if(x==='json')dl(`kalshi_xrp15m_all_${stamp}.json`,JSON.stringify({cycles:await getAll('cycles'),snaps:await getAll('snaps'),trades:await getAll('trades'),events:await getAll('events')}),'application/json');
  else if(x==='clear'&&confirm('Delete ALL saved Kalshi data on this device? This cannot be undone.')){for(const s of['cycles','snaps','trades','events'])await new Promise(r=>{const t=db.transaction(s,'readwrite');t.objectStore(s).clear();t.oncomplete=r});stats();cycList()}};
// ---------- Kalshi API
const base=()=>($('proxy').value.trim().replace(/\/$/,''))||KB_DEFAULT;
async function api(p){const r=await fetch(base()+'/trade-api/v2'+p);if(!r.ok)throw new Error('HTTP '+r.status);return r.json()}
const mk=m=>({tk:m.ticker,m,title:m.title||m.yes_sub_title||m.ticker,close:Date.parse(m.close_time),t0:Date.parse(m.close_time)-9e5,target:m.floor_strike!=null?+m.floor_strike:null,snaps:new Array(N),trades:[],vp:new Map(),last:null});
const cents=s=>Math.round(parseFloat(s)*100);
async function findMarket(){const j=await api(`/markets?series_ticker=${SER}&status=open&limit=20`),now=Date.now();
  const ms=(j.markets||[]).filter(m=>Date.parse(m.close_time)>now).sort((a,b)=>Date.parse(a.close_time)-Date.parse(b.close_time));
  const m=ms[0];if(!m||Date.parse(m.close_time)-9e5>now+1500){S.wait=m?Date.parse(m.close_time)-9e5:0;return}
  S.wait=0;if(S.live&&S.live.tk===m.ticker)return;
  const D=mk(m);S.live=D;S.seen=new Set();S.prev=null;S.logs=0;
  Q.cycles.push({tk:D.tk,title:D.title,open:D.t0,close:D.close,target:D.target,result:'',expiration_value:''});cycList();addLog(`🔄 New 15-minute market started. Target price ${fx(D.target)}. The picture has been reset.`,'#5aa9ff');
  if(S.old)setTimeout(()=>settle(S.old,0),30000);S.old=D.tk;}
async function settle(tk,i){try{const j=await api('/markets/'+tk),m=j.market||j;if(m.result){Q.cycles.push({tk,title:m.title||'',open:Date.parse(m.close_time)-9e5,close:Date.parse(m.close_time),target:m.floor_strike??null,result:m.result,expiration_value:m.expiration_value??''});flush().then(cycList);return}}catch(e){}if(i<8)setTimeout(()=>settle(tk,i+1),20000)}
function pushSnap(D,s){D.snaps[s.sec]=s;D.last=s}
async function poll(){if(S.busy)return;S.busy=1;try{
  const now=Date.now();if(!S.live||now>=S.live.close)await findMarket();
  const D=S.live;if(!D){S.busy=0;return}
  const [ob,tr]=await Promise.all([api(`/markets/${D.tk}/orderbook`),api(`/markets/trades?ticker=${D.tk}&limit=200&min_ts=${Math.floor(D.t0/1000)-1}`)]);
  const o=ob.orderbook_fp||ob.orderbook||{},conv=a=>(a||[]).map(x=>[cents(x[0]),parseFloat(x[1])]).filter(x=>x[1]>0);
  const yb=conv(o.yes_dollars),nb=conv(o.no_dollars),sec=Math.min(N-1,Math.max(0,Math.floor((now-D.t0)/1000)));
  const ybid=yb.length?Math.max(...yb.map(x=>x[0])):null,nbid=nb.length?Math.max(...nb.map(x=>x[0])):null,yask=nbid!=null?100-nbid:null;
  const mid=ybid!=null&&yask!=null?(ybid+yask)/2:(ybid??yask??50),spot=S.spot;
  // trades
  const newT=[];for(const t of (tr.trades||[]).reverse()){if(S.seen.has(t.trade_id))continue;S.seen.add(t.trade_id);const tt=Date.parse(t.created_time),ts=Math.min(N-1,Math.max(0,Math.floor((tt-D.t0)/1000)));
    const x={id:t.trade_id,tk:D.tk,t:tt,sec:ts,tleft:Math.round((D.close-tt)/1000),yes_price:cents(t.yes_price_dollars),contracts:parseFloat(t.count_fp),taker:(t.taker_outcome_side||t.taker_side||'yes'),spot};
    D.trades.push(x);Q.trades.push(x);newT.push(x);addVP(D,x);
    if(x.contracts>=+$('whale').value&&D.tk===S.live.tk)addLog(`${x.taker==='yes'?'<b class="gg">Bet UP</b>':'<b class="rr">Bet DOWN</b>'} in a hurry: ${fm(x.contracts)} contracts at ${x.yes_price}¢ (${Math.floor(x.tleft/60)}:${String(x.tleft%60).padStart(2,'0')} left)`)}
  // book snapshot (+ fill small gaps)
  const sp=ybid!=null&&yask!=null?yask-ybid:null,tgt=D.target,svt=spot&&tgt?+((spot/tgt-1)*100).toFixed(4):null;
  const s={tk:D.tk,t:now,sec,tleft:Math.round((D.close-now)/1000),spot,spot_vs_target_pct:svt,yes_bid:ybid,yes_ask:yask,mid,spread:sp,yes_bids:yb,no_bids:nb,yb,nb};
  if(D.last&&sec-D.last.sec>1&&sec-D.last.sec<6)for(let q=D.last.sec+1;q<sec;q++)D.snaps[q]={...D.last,sec:q};
  pushSnap(D,s);const {yb:_a,nb:_b,...rec}=s;Q.snaps.push(rec);
  detect(D,s,newT);S.prev=s;S.err=0;$('p1').textContent='Kalshi live';$('p1').className='pill ok';
  }catch(e){S.err=(S.err||0)+1;$('p1').className='pill bad';$('p1').textContent=e.name==='TypeError'?'Kalshi blocked? set Proxy':'Kalshi '+e.message}
  finally{S.busy=0;update()}}
function addVP(D,x){let e=D.vp.get(x.yes_price);if(!e){e={b:0,s:0};D.vp.set(x.yes_price,e)}x.taker==='yes'?e.b+=x.contracts:e.s+=x.contracts}
function detect(D,s,newT){const p=S.prev;if(!p||p.tk!==s.tk)return;const big=+$('whale').value;
  const lv=(a,b)=>{const m=new Map();a.forEach(x=>m.set('bid'+x[0],x[1]));b.forEach(x=>m.set('ask'+(100-x[0]),x[1]));return m},A=lv(p.yb,p.nb),B=lv(s.yb,s.nb);
  const tr=(side,price)=>newT.filter(t=>t.yes_price===price&&(side==='ask'?t.taker==='yes':t.taker==='no')).reduce((q,t)=>q+t.contracts,0);
  for(const k of new Set([...A.keys(),...B.keys()])){const a=A.get(k)||0,b=B.get(k)||0,d=b-a;if(Math.abs(d)<1)continue;const side=k.slice(0,3),price=+k.slice(3),traded=tr(side,price);
    let kind=d>0?'added':traded>=Math.abs(d)*.8?'filled':'pulled';
    Q.events.push({tk:s.tk,t:s.t,sec:s.sec,tleft:s.tleft,kind,side,yes_price:price,delta:d,size_before:a,traded,spot:s.spot,spot_vs_target_pct:s.spot_vs_target_pct,mid:s.mid,spread:s.spread});
    if(Math.abs(d)>=big){const w=side==='bid'?'UP bets':'DOWN bets';
      addLog(kind==='added'?`➕ Someone added <b>${fm(d)}</b> contracts of ${w} at ${price}¢`:kind==='filled'?`✅ <b>${fm(-d)}</b> contracts of ${w} at ${price}¢ got <b>traded</b>`:`🚫 <b>${fm(-d)}</b> contracts of ${w} at ${price}¢ were <b>pulled</b> without trading`,kind==='pulled'?'#ffb454':kind==='added'?'#5aa9ff':'#21c577')}}}
function addLog(h,c){const d=document.createElement('div');d.style.borderLeft='3px solid '+(c||'#2a3a4d');d.style.paddingLeft='6px';d.innerHTML=`<span style="color:var(--m)">${new Date().toLocaleTimeString([],{hour12:false})}</span> ${h}`;const l=$('log');l.prepend(d);while(l.children.length>60)l.lastChild.remove()}
// ---------- spot price (Kraken)
(function go(){const ws=new WebSocket('wss://ws.kraken.com/v2');
  ws.onopen=()=>{ws.send(JSON.stringify({method:'subscribe',params:{channel:'ticker',symbol:['XRP/USD']}}));$('p2').className='pill ok';$('p2').textContent='XRP price live'};
  ws.onmessage=e=>{try{const m=JSON.parse(e.data);if(m.channel==='ticker'&&m.data&&m.data[0]){const d=m.data[0];S.spot=d.last||(d.bid+d.ask)/2}}catch(x){}};
  ws.onclose=()=>{$('p2').className='pill bad';$('p2').textContent='XRP price reconnecting…';setTimeout(go,2000)};ws.onerror=()=>ws.close()})();
// ---------- UI cards
const CARDS=[['up','Chance of UP','(YES price)','The YES price in cents is the crowd’s chance that XRP ends this window at or above the target. 62¢ means about 62%.','If you buy YES at this price you risk that many cents to win the rest of a dollar. A high price means a small win if right and a big loss if wrong.'],
['tgt','Target price','(strike)','XRP must be at or above this at the end of the window for YES to win. It is XRP’s price when the window started.','Your question is simply: “Will XRP be above this line at the end?”'],
['spot','XRP right now','(vs target)','Live XRP/USD from Kraken and how far it is from the target. Kalshi’s official price is an index (CF Benchmarks), so it can differ a little.','Being just above or below the target with little time left makes the YES price swing wildly.'],
['left','Time left','(this cycle)','Time until this 15-minute market closes. A new one starts right after. The last minute is settled on an average of 60 prices.','Less time left means price moves matter more and prices can jump. Do not enter late without a plan.'],
['spr','Price gap','(spread)','Gap in cents between the best YES buy and best YES sell. A small gap is cheaper for you.','A wide gap is a hidden cost. Use limit orders (you pick the price).'],
['dy','UP bets waiting','(YES bids)','Total contracts waiting to buy YES (bet UP) across the whole book.','More UP bets waiting can cushion the YES price if it drops.'],
['dn','DOWN bets waiting','(NO bids)','Total contracts waiting to buy NO (bet DOWN) across the whole book.','More DOWN bets waiting can cap how high YES goes.'],
['vol','Traded this cycle','(contracts)','Total contracts traded since this window began. Each contract pays $1 to the winner.','Low volume means a thin market where one order can move the price.'],
['cvd','Who is rushing','(CVD)','Contracts bought by people in a hurry betting UP minus those betting DOWN, this cycle. Plus = UP rushers. Minus = DOWN rushers.','If XRP is rising but this is red, the move may be weak.']];
$('stats').innerHTML=CARDS.map(c=>`<div class="card" data-tip="${c[3]}\n\n💡 For you: ${c[4]}"><small>${c[1]} <em class="n">${c[2]}</em></small><b id="s_${c[0]}">–</b></div>`).join('');
const sv=(k,v,c)=>{const e=$('s_'+k);e.textContent=v;e.style.color=c||''};
const D_=()=>S.replay||S.live;
function update(){const D=S.live;if(!D)return;const l=D.last,tl=Math.max(0,Math.round((D.close-Date.now())/1000)),tt=`${Math.floor(tl/60)}:${String(tl%60).padStart(2,'0')}`,spot=S.spot;
  sv('left',tt,tl<60?'var(--r)':'');sv('tgt',fx(D.target));
  if(spot&&D.target){const p=(spot/D.target-1)*100;sv('spot',fx(spot)+' ('+(p>=0?'+':'')+p.toFixed(3)+'%)',p>=0?'var(--g)':'var(--r)')}else sv('spot',fx(spot));
  if(l){const up=l.mid;sv('up',up.toFixed(0)+'%',up>55?'var(--g)':up<45?'var(--r)':'');sv('spr',l.spread!=null?l.spread+'¢':'–');
    sv('dy',fm(l.yb.reduce((a,x)=>a+x[1],0)),'var(--g)');sv('dn',fm(l.nb.reduce((a,x)=>a+x[1],0)),'var(--r)');
    let v=0,c=0;for(const t of D.trades){v+=t.contracts;c+=t.taker==='yes'?t.contracts:-t.contracts}sv('vol',fm(v));sv('cvd',(c>=0?'+':'−')+fm(Math.abs(c)),c>=0?'var(--g)':'var(--r)');
    const above=spot&&D.target?spot>=D.target:null,pct=spot&&D.target?((spot/D.target-1)*100).toFixed(3):null;
    $('sum').innerHTML=`<b>In simple words, right now:</b> Kalshi says there is about a <b>${up.toFixed(0)}% chance</b> XRP ends this 15-minute window <b class="gg">at or above ${fx(D.target)}</b>. XRP is <b>${fx(spot)}</b>${above==null?'':`, which is <b class="${above?'gg':'rr'}">${above?'above':'below'}</b> the target by ${Math.abs(pct)}%`}. <b>${tt}</b> left.<br>${c>0?'People rushing in are mostly betting <b class="gg">UP</b>.':c<0?'People rushing in are mostly betting <b class="rr">DOWN</b>.':'No clear rush either way yet.'} ${tl<60?'<b>Last minute:</b> the result is the average of 60 prices, so one jump matters less.':''}<br>💡 <b>For you:</b> buying YES at ${l.yes_ask??'–'}¢ risks ${l.yes_ask??'–'}¢ to win ${l.yes_ask!=null?100-l.yes_ask:'–'}¢ (before fees). ${l.spread>3?'The gap is wide right now, so use a limit order. ':''}<br><i>A description, not a prediction or advice. Everything is being saved so you can study it later.</i>`;
    ladder(l);ts(D)}
  else $('sum').textContent=S.wait?`Next 15-minute market starts at ${new Date(S.wait).toLocaleTimeString()}. Waiting…`:'Connecting to Kalshi…';
  if(!S.paused&&!S.replay)draw()}
function ladder(l){const A=l.nb.map(x=>[100-x[0],x[1]]).sort((a,b)=>a[0]-b[0]).slice(0,9).reverse(),B=l.yb.slice().sort((a,b)=>b[0]-a[0]).slice(0,9),mx=Math.max(1,...A.map(x=>x[1]),...B.map(x=>x[1]));
  const row=(x,c)=>`<div class="row ${c}" data-tip="${c=='a'?'People betting DOWN: they offer YES at':'People betting UP: they bid YES at'} ${x[0]}¢. ${fm(x[1])} contracts waiting."><i style="width:${x[1]/mx*100}%"></i><span>${x[0]}¢</span><span>${fm(x[1])}</span><span>${x[0]}%</span></div>`;
  $('lad').innerHTML='<div class="row" style="color:var(--m)"><span>YES price</span><span>Contracts</span><span>Chance</span></div>'+A.map(x=>row(x,'a')).join('')+`<div class="sp">gap ${l.spread??'–'}¢ <em class="n">(spread)</em></div>`+B.map(x=>row(x,'bd')).join('')}
function ts(D){$('ts').innerHTML='<div class="row" style="color:var(--m)"><span>Time</span><span>YES price</span><span>Contracts</span></div>'+D.trades.slice(-12).reverse().map(t=>`<div class="row ${t.taker==='yes'?'bd':'a'}" data-tip="${t.taker==='yes'?'Someone bet UP in a hurry':'Someone bet DOWN in a hurry'}: ${fm(t.contracts)} contracts at ${t.yes_price}¢."><span>${new Date(t.t).toLocaleTimeString([],{hour12:false})}</span><span>${t.yes_price}¢ ${t.taker==='yes'?'UP':'DOWN'}</span><span>${fm(t.contracts)}</span></div>`).join('')}
// ---------- drawing
const LUT=(()=>{const st=[[0,23,34,46],[.18,16,56,100],[.4,24,112,168],[.6,214,196,58],[.8,232,80,48],[1,255,236,230]],o=[];for(let i=0;i<256;i++){const v=i/255;let k=1;while(st[k][0]<v)k++;const a=st[k-1],b=st[k],f=(v-a[0])/(b[0]-a[0]);o.push(`rgb(${a[1]+(b[1]-a[1])*f|0},${a[2]+(b[2]-a[2])*f|0},${a[3]+(b[3]-a[3])*f|0})`)}return o})();
const cv=$('c'),ov=$('o'),cx=cv.getContext('2d'),ox=ov.getContext('2d');
function size(){const r=$('hm').getBoundingClientRect(),d=devicePixelRatio||1;for(const c of[cv,ov]){c.width=r.width*d;c.height=r.height*d}cx.setTransform(d,0,0,d,0,0);ox.setTransform(d,0,0,d,0,0);S.W=r.width;S.H=r.height;draw()}
addEventListener('resize',size);['vr','gam','notes'].forEach(i=>$(i).oninput=draw);if(document.fonts)document.fonts.load('15px "Patrick Hand"').then(draw);
$('pause').onclick=e=>{S.paused=!S.paused;e.target.textContent=S.paused?'Resume':'Pause';if(!S.paused)draw()};
$('cyc').onchange=async e=>{const tk=e.target.value;if(!tk){S.replay=null;$('mode').textContent='● LIVE';$('mode').style.color='var(--g)';draw();return}
  const c=(await getAll('cycles')).find(x=>x.tk===tk);if(!c)return;const D=mk({ticker:tk,close_time:new Date(c.close).toISOString(),floor_strike:c.target,title:c.title});
  for(const s of await getAll('snaps',tk)){s.yb=s.yes_bids;s.nb=s.no_bids;D.snaps[s.sec]=s;D.last=s}
  for(const t of await getAll('trades',tk)){D.trades.push(t);addVP(D,t)}S.replay=D;$('mode').textContent='⏪ REPLAY '+new Date(c.close).toLocaleTimeString();$('mode').style.color='#ffb454';draw()};
function wrap(t,w){const L=[];let l='';for(const x of t.split(' ')){const m=l?l+' '+x:x;if(cx.measureText(m).width>w&&l){L.push(l);l=x}else l=m}L.push(l);return L}
function note(t,x,y,w,fill,fs){fs=fs||15;cx.font=fs+'px "Patrick Hand","Comic Sans MS",cursive';const L=wrap(t,w-16),lh=fs+4,h=L.length*lh+10;cx.save();if(fill){cx.fillStyle=fill;cx.fillRect(x,y,w,h)}else{cx.shadowColor='#000';cx.shadowBlur=5}cx.fillStyle='#fff';L.forEach((l,i)=>cx.fillText(l,x+8,y+fs+3+i*lh));cx.restore();return h}
function ell(x,y,rx,ry){cx.save();cx.strokeStyle='#fff';cx.lineWidth=2;cx.setLineDash([7,5]);cx.beginPath();cx.ellipse(x,y,rx,ry,0,0,7);cx.stroke();cx.restore()}
function arrow(x1,y1,x2,y2){cx.save();cx.strokeStyle='#fff';cx.fillStyle='#fff';cx.lineWidth=1.5;cx.beginPath();cx.moveTo(x1,y1);cx.lineTo(x2,y2);cx.stroke();const a=Math.atan2(y2-y1,x2-x1);cx.beginPath();cx.moveTo(x2,y2);cx.lineTo(x2-9*Math.cos(a-.4),y2-9*Math.sin(a-.4));cx.lineTo(x2-9*Math.cos(a+.4),y2-9*Math.sin(a+.4));cx.fill();cx.restore()}
function draw(){const D=D_(),W=S.W,H=S.H;if(!W)return;cx.fillStyle='#16212d';cx.fillRect(0,0,W,H);
  if(!D){cx.fillStyle='#8da0b8';cx.font='15px system-ui';cx.fillText('Waiting for the current 15-minute market…',20,40);return}
  const live=!S.replay,NP=W<720?1:3,PNW=58,AX=62,SPH=60,VOLH=30,CVDH=40,TAX=18,PW=W-AX-NP*PNW,PH=H-SPH-VOLH-CVDH-TAX,cw=PW/N,nowSec=live?Math.min(N,(Date.now()-D.t0)/1000):N;
  let lastS=D.last;const mid0=lastS?lastS.mid:50;let lo=1,hi=99;if($('vr').value==='auto'){lo=Math.max(1,Math.round(mid0)-15);hi=Math.min(99,lo+30);lo=Math.max(1,hi-30)}
  const nr=hi-lo+1,rh=PH/nr,Y=c=>PH-(c-lo+.5)/nr*PH,X=sec=>sec*cw;S.v={PW,PH,AX,PNW,NP,SPH,VOLH,CVDH,lo,hi,nr,rh,cw,D};
  S.cache=new Array(N);const vals=[];
  for(let sc=0;sc<N;sc++){const s=D.snaps[sc];if(!s)continue;const r=new Float32Array(nr);for(const [c,n] of s.yb)if(c>=lo&&c<=hi)r[c-lo]+=n;for(const [c,n] of s.nb){const yc=100-c;if(yc>=lo&&yc<=hi)r[yc-lo]+=n}S.cache[sc]=r;for(let i=0;i<nr;i++)if(r[i]>0)vals.push(r[i])}
  vals.sort((a,b)=>a-b);const mx=vals[vals.length*.985|0]||1;S.mx=mx,g=+$('gam').value;
  for(let sc=0;sc<N;sc++){const r=S.cache[sc];if(!r)continue;for(let i=0;i<nr;i++){const v=r[i];if(v<=0)continue;const k=Math.min(1,Math.pow(v/mx,g));if(k<.04)continue;cx.fillStyle=LUT[k*255|0];cx.fillRect(X(sc),PH-(i+1)*rh,cw+.6,rh+.4)}}
  cx.fillStyle='rgba(255,255,255,.05)';cx.fillRect(X(840),0,PW-X(840),PH);cx.fillStyle='rgba(255,255,255,.55)';cx.font='11px system-ui';cx.fillText('last minute: result = average of 60 prices',X(840)-205,PH-6);
  cx.strokeStyle='rgba(230,237,245,.9)';cx.lineWidth=1;cx.beginPath();let st=0;for(let sc=0;sc<N;sc++){const s=D.snaps[sc];if(!s)continue;const x=X(sc)+cw/2;st?cx.lineTo(x,Y(s.mid)):cx.moveTo(x,Y(s.mid));st=1}cx.stroke();
  if(live){cx.strokeStyle='rgba(255,255,255,.35)';cx.beginPath();cx.moveTo(X(nowSec),0);cx.lineTo(X(nowSec),PH);cx.stroke()}
  if(lastS){cx.save();cx.setLineDash([5,4]);const xs=X(lastS.sec)-70;if(lastS.yes_ask!=null){cx.strokeStyle='#f0504a';cx.beginPath();cx.moveTo(xs,Y(lastS.yes_ask));cx.lineTo(xs+70,Y(lastS.yes_ask));cx.stroke()}if(lastS.yes_bid!=null){cx.strokeStyle='#21c577';cx.beginPath();cx.moveTo(xs,Y(lastS.yes_bid));cx.lineTo(xs+70,Y(lastS.yes_bid));cx.stroke()}cx.restore()}
  const rad=t=>Math.min(22,3+Math.sqrt(t.contracts)*1.6);
  for(const t of D.trades){const x=(t.t-D.t0)/1000*cw,y=Y(t.yes_price);if(y<0||y>PH)continue;cx.fillStyle=t.taker==='yes'?'rgba(94,214,196,.5)':'rgba(250,120,130,.5)';cx.strokeStyle=t.taker==='yes'?'rgba(150,240,225,.8)':'rgba(255,170,175,.8)';cx.lineWidth=1;cx.beginPath();cx.arc(x,y,rad(t),0,7);cx.fill();cx.stroke()}
  // side panels
  cx.fillStyle='#101821';cx.fillRect(PW,0,W-PW,H);const cB=new Float32Array(nr),cA=new Float32Array(nr),vb=new Float32Array(nr),vs=new Float32Array(nr);
  if(lastS){for(const [c,n] of lastS.yb)if(c>=lo&&c<=hi)cB[c-lo]+=n;for(const [c,n] of lastS.nb){const yc=100-c;if(yc>=lo&&yc<=hi)cA[yc-lo]+=n}}
  for(const [c,e] of D.vp)if(c>=lo&&c<=hi){vb[c-lo]=e.b;vs[c-lo]=e.s}S.pan={cB,cA,vb,vs};
  const mC=Math.max(1,...cB,...cA),mV=Math.max(1,...vb.map((v,i)=>v+vs[i])),mD=Math.max(1,...vb.map((v,i)=>Math.abs(v-vs[i])));cx.font='10px system-ui';
  ['COB','SVP','SVP DELTA'].slice(0,NP).forEach((tt,k)=>{const x0=PW+AX+k*PNW;cx.fillStyle='#1b2937';cx.fillRect(x0,0,PNW-2,PH);cx.fillStyle='#8da0b8';cx.fillText(tt,x0+3,10);
    for(let i=0;i<nr;i++){const y=PH-(i+1)*rh,h=Math.max(1,rh-1);
      if(k===0){if(cB[i]){cx.fillStyle='#21c577';cx.fillRect(x0,y,cB[i]/mC*(PNW-3),h)}if(cA[i]){cx.fillStyle='#f0504a';cx.fillRect(x0,y,cA[i]/mC*(PNW-3),h)}}
      else if(k===1){if(vb[i]+vs[i]){const a=vb[i]/mV*(PNW-3),b=vs[i]/mV*(PNW-3);cx.fillStyle='#21c577';cx.fillRect(x0,y,a,h);cx.fillStyle='#f0504a';cx.fillRect(x0+a,y,b,h)}}
      else{const d=vb[i]-vs[i];if(d){cx.fillStyle=d>0?'#21c577':'#f0504a';const w=Math.abs(d)/mD*(PNW/2-2);cx.fillRect(d>0?x0+PNW/2:x0+PNW/2-w,y,w,h)}}}
    if(k===2){cx.strokeStyle='#3a516d';cx.beginPath();cx.moveTo(x0+PNW/2,0);cx.lineTo(x0+PNW/2,PH);cx.stroke()}});
  cx.fillStyle='#cfd9e6';cx.font='11px ui-monospace,monospace';const stp=nr>40?10:5;for(let c=Math.ceil(lo/stp)*stp;c<=hi;c+=stp){cx.fillText(c+'¢',PW+4,Y(c)+4);cx.strokeStyle='rgba(255,255,255,.05)';cx.beginPath();cx.moveTo(0,Y(c));cx.lineTo(PW,Y(c));cx.stroke()}
  if(lastS){cx.fillStyle='#e6edf5';cx.fillRect(PW,Y(lastS.mid)-8,AX-2,16);cx.fillStyle='#101821';cx.fillText(lastS.mid.toFixed(1)+'¢',PW+4,Y(lastS.mid)+4)}
  // bottom strips: spot, volume, cvd
  const y1=PH,y2=PH+SPH,y3=y2+VOLH;cx.fillStyle='#131d29';cx.fillRect(0,y1,PW,SPH+VOLH+CVDH);
  const sp=[];for(let sc=0;sc<N;sc++){const s=D.snaps[sc];if(s&&s.spot)sp.push([sc,s.spot])}const T=D.target;
  if(sp.length){let a=Math.min(...sp.map(x=>x[1]),T??1e9),b=Math.max(...sp.map(x=>x[1]),T??0);if(b-a<1e-4){a-=5e-4;b+=5e-4}const ys=v=>y2-4-(v-a)/(b-a)*(SPH-10);
    if(T){cx.save();cx.setLineDash([5,4]);cx.strokeStyle='#fff';cx.beginPath();cx.moveTo(0,ys(T));cx.lineTo(PW,ys(T));cx.stroke();cx.restore()}
    cx.lineWidth=1.5;for(let i=1;i<sp.length;i++){cx.strokeStyle=T&&sp[i][1]<T?'#f0504a':'#21c577';cx.beginPath();cx.moveTo(X(sp[i-1][0])+cw/2,ys(sp[i-1][1]));cx.lineTo(X(sp[i][0])+cw/2,ys(sp[i][1]));cx.stroke()}
    cx.fillStyle='#e6edf5';cx.font='11px ui-monospace,monospace';cx.fillText(fx(sp[sp.length-1][1]),PW+4,y1+30);if(T){cx.fillStyle='#8da0b8';cx.fillText('target',PW+4,y1+14);cx.fillText(fx(T),PW+4,y1+44)}}
  const vB=new Float32Array(N),vS=new Float32Array(N);for(const t of D.trades)t.taker==='yes'?vB[t.sec]+=t.contracts:vS[t.sec]+=t.contracts;
  let mv=1;for(let i=0;i<N;i++)mv=Math.max(mv,vB[i]+vS[i]);cx.strokeStyle='#2a3a4d';cx.beginPath();cx.moveTo(0,y2);cx.lineTo(PW,y2);cx.moveTo(0,y3);cx.lineTo(PW,y3);cx.stroke();
  for(let i=0;i<N;i++){const hb=vB[i]/mv*(VOLH-6),hs=vS[i]/mv*(VOLH-6);if(hb){cx.fillStyle='#21c577';cx.fillRect(X(i),y3-2-hb,Math.max(1.5,cw),hb)}if(hs){cx.fillStyle='#f0504a';cx.fillRect(X(i),y3-2-hb-hs,Math.max(1.5,cw),hs)}}
  let c=0,cmin=0,cmax=0;const cs=new Float32Array(N);for(let i=0;i<N;i++){c+=vB[i]-vS[i];cs[i]=c;cmin=Math.min(cmin,c);cmax=Math.max(cmax,c)}if(cmax-cmin<1){cmax+=1;cmin-=1}
  const yc=v=>y3+CVDH-6-(v-cmin)/(cmax-cmin)*(CVDH-12);cx.strokeStyle='#e6edf5';cx.lineWidth=1.2;cx.beginPath();for(let i=0;i<=Math.min(N-1,nowSec);i++)i?cx.lineTo(X(i)+cw/2,yc(cs[i])):cx.moveTo(X(i)+cw/2,yc(cs[i]));cx.stroke();
  cx.fillStyle='#8da0b8';cx.font='10px system-ui';cx.fillText('XRP PRICE vs TARGET (green above, red below)',6,y1+11);cx.fillText('VOLUME (green UP / red DOWN)',6,y2+11);cx.fillText('CVD (UP rushers minus DOWN rushers)',6,y3+11);
  cx.fillStyle=c>=0?'#21c577':'#f0504a';cx.font='bold 13px ui-monospace,monospace';cx.fillText('CVD',PW+6,y3+16);cx.fillText((c>=0?'+':'−')+fm(Math.abs(c)),PW+6,y3+34);
  cx.fillStyle='#8da0b8';cx.font='11px ui-monospace,monospace';for(let m=0;m<=15;m+=3){const x=Math.min(PW-34,X(m*60));cx.fillText(new Date(D.t0+m*6e4).toLocaleTimeString([],{hour:'2-digit',minute:'2-digit',hour12:false})+(m<15?'':' end'),x,H-5)}
  if($('notes').checked&&lastS)notes({D,PW,PH,lo,hi,nr,rh,Y,X,lastS,live});hover()}
function notes(o){const {D,PW,PH,lo,nr,rh,Y,X,lastS}=o,RED='rgba(224,84,76,.93)',bw=Math.min(300,PW*.4),r0=S.cache[lastS.sec];if(!r0)return;
  let bi=-1,bv=0;for(let i=0;i<nr;i++)if(r0[i]>bv){bv=r0[i];bi=i}
  if(bi>=0&&bv>.5*S.mx&&bv>=+$('whale').value/2){const c=lo+bi,bid=c<lastS.mid,x=X(lastS.sec),y=Y(c);ell(x-40,y,60,Math.max(7,rh*1.4));
    const h=note(`Big pile of ${bid?'UP':'DOWN'} bets waiting at ${c}¢ (${fm(bv)} contracts). ${bid?'This may act as a floor for the YES price.':'This may act as a ceiling for the YES price.'}`,14,14,bw,RED);arrow(14+bw,14+h/2,Math.max(14+bw+10,x-100),y)}
  const f=new Int32Array(nr).fill(-1),l=new Int32Array(nr).fill(-1),mV=new Float32Array(nr);
  for(let sc=0;sc<lastS.sec-8;sc++){const r=S.cache[sc];if(!r)continue;for(let i=0;i<nr;i++)if(r[i]>.5*S.mx&&r[i]>=+$('whale').value/2){mV[i]=Math.max(mV[i],r[i]);if(f[i]<0)f[i]=sc;l[i]=sc}}
  let best=-1;for(let i=0;i<nr;i++){if(f[i]<0||l[i]>=lastS.sec-8||l[i]-f[i]<8||r0[i]>=.2*mV[i])continue;const c=lo+i;let mn=999,mxm=0;for(let sc=f[i];sc<=lastS.sec;sc++){const s=D.snaps[sc];if(s){mn=Math.min(mn,s.mid);mxm=Math.max(mxm,s.mid)}}if((c<mn-1||c>mxm+1)&&(best<0||mV[i]>mV[best]))best=i}
  if(best>=0){const c=lo+best,y=Y(c),x1=X(f[best]),x2=X(l[best]),by=Math.max(70,PH-130);ell((x1+x2)/2,y,(x2-x1)/2+10,Math.max(7,rh*1.4));const h=note(`Orders at ${c}¢ (about ${fm(mV[best])} contracts) disappeared and never traded. They were pulled, not filled. Big piles can be fake.`,14,by,bw,RED);arrow(14+bw/2,y>by?by:by+h,(x1+x2)/2,y>by?y+rh*1.4+4:y-rh*1.4-4)}
  let big=null;for(const t of D.trades)if((o.live?Date.now()-t.t<60000:true)&&(!big||t.contracts>big.contracts))big=t;
  if(big&&big.contracts>=+$('whale').value){const x=(big.t-D.t0)/1000*(PW/N),y=Y(big.yes_price),r=Math.min(22,3+Math.sqrt(big.contracts)*1.6);if(y>0&&y<PH){ell(x,y,r+10,r+10);const w=250,nx=Math.max(10,Math.min(x-w/2,PW-w-10)),ny=y<PH/2?y+r+22:y-r-80;const h=note(`${o.live&&Date.now()-big.t<20000?'Someone just':'Someone'} bet ${big.taker==='yes'?'UP (bought YES)':'DOWN (bought NO)'} aggressively: ${fm(big.contracts)} contracts at ${big.yes_price}¢.`,nx,ny,w,null,19);arrow(nx+w/2,y<PH/2?ny:ny+h,x,y<PH/2?y+r+10:y-r-10)}}}
// ---------- hover
ov.onmousemove=e=>{const r=ov.getBoundingClientRect();S.mouse={x:e.clientX-r.left,y:e.clientY-r.top,cx:e.clientX,cy:e.clientY};hover()};ov.onmouseleave=()=>{S.mouse=null;hover();tip.style.display='none'};
function hover(){ox.clearRect(0,0,S.W,S.H);const m=S.mouse,v=S.v;if(!m||!v)return;const T=t=>showTip(t,m.cx,m.cy),D=v.D;
  if(m.y>v.PH){const y=m.y-v.PH;T(y<v.SPH?'XRP PRICE vs TARGET: the dashed white line is the target. Green = XRP above it (YES is winning right now). Red = below (NO is winning). Watch how the crowd’s YES price reacts when XRP crosses it.':y<v.SPH+v.VOLH?'VOLUME: contracts traded each second. Green = UP bets in a hurry, red = DOWN bets in a hurry.':'CVD: running total of rushed UP bets minus rushed DOWN bets this cycle. Rising = UP rushers. Falling = DOWN rushers.');return}
  const rr=Math.min(v.nr-1,Math.max(0,Math.floor((v.PH-m.y)/v.rh))),c=v.lo+rr;
  if(m.x>v.PW){if(m.x<v.PW+v.AX){T('PRICE SCALE: the YES price in cents. 62¢ ≈ 62% chance of UP.');return}const k=Math.floor((m.x-v.PW-v.AX)/v.PNW),P=S.pan;if(!P||k<0||k>=v.NP)return;ox.strokeStyle='rgba(255,255,255,.4)';ox.beginPath();ox.moveTo(v.PW,m.y);ox.lineTo(S.W,m.y);ox.stroke();
    T(k===0?`COB (waiting right now) at ${c}¢:\nUP bets (bids): ${fm(P.cB[rr])} contracts\nDOWN bets (offers): ${fm(P.cA[rr])} contracts`:k===1?`SVP (traded this cycle) at ${c}¢:\nUP: ${fm(P.vb[rr])} · DOWN: ${fm(P.vs[rr])} contracts\nLong bar = a busy price.`:`SVP DELTA at ${c}¢:\nUP minus DOWN = ${fm(P.vb[rr]-P.vs[rr])} contracts\nGreen/right = UP rushers won here.`);return}
  for(const t of D.trades){const x=(t.t-D.t0)/1000*v.cw,y=v.PH-(t.yes_price-v.lo+.5)/v.nr*v.PH,r=Math.min(22,3+Math.sqrt(t.contracts)*1.6);if(Math.hypot(x-m.x,y-m.y)<=r+3){ox.strokeStyle='#fff';ox.lineWidth=2;ox.beginPath();ox.arc(x,y,r+2,0,7);ox.stroke();T(`${t.taker==='yes'?'Someone BET UP (bought YES)':'Someone BET DOWN (bought NO)'}: ${fm(t.contracts)} contracts at ${t.yes_price}¢\n${new Date(t.t).toLocaleTimeString()} · ${Math.floor(t.tleft/60)}:${String(t.tleft%60).padStart(2,'0')} left\n“In a hurry” = took the price available instead of waiting.`);return}}
  ox.strokeStyle='rgba(255,255,255,.4)';ox.setLineDash([4,4]);ox.beginPath();ox.moveTo(m.x,0);ox.lineTo(m.x,v.PH);ox.moveTo(0,m.y);ox.lineTo(v.PW,m.y);ox.stroke();
  const sc=Math.min(N-1,Math.floor(m.x/v.cw)),r=S.cache[sc],tl=N-sc;let txt=`YES price at mouse: ${c}¢ (about ${c}% chance of UP)\nTime in cycle: ${Math.floor(sc/60)}:${String(sc%60).padStart(2,'0')} · ${Math.floor(tl/60)}:${String(tl%60).padStart(2,'0')} left`;
  if(r){const val=r[rr],s=D.snaps[sc];txt+=`\nContracts waiting here: ${fm(val)}\n${val<=0?'Nothing waiting here.':val/S.mx>.7?(c<s.mid?'🔥 Big UP pile: possible floor.':'🔥 Big DOWN pile: possible ceiling.'):(c<s.mid?'Some UP bets waiting.':'Some DOWN bets waiting.')}`+(s.spot?`\nXRP then: ${fx(s.spot)}`:'')}
  T(txt)}
// ---------- main loop (worker timer keeps ticking in background tabs)
let LOOP=0;function loop(){LOOP++;poll();if(LOOP%2===0)update()}
try{const w=new Worker(URL.createObjectURL(new Blob(['setInterval(()=>postMessage(1),1000)'])));w.onmessage=loop}catch(e){setInterval(loop,1000)}
$('wake').onchange=async e=>{try{if(e.target.checked)S.wl=await navigator.wakeLock.request('screen');else if(S.wl)S.wl.release()}catch(x){e.target.checked=false}};
(async()=>{await dbOpen();try{navigator.storage&&navigator.storage.persist&&navigator.storage.persist()}catch(e){}stats();cycList();size()})();
</script></body></html>
