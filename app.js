'use strict';
const $=id=>document.getElementById(id);
let map,position=null,target=null,locationMarker=null,targetMarker=null,routeLine=null,watchId=null, gpsRequestId=0;
const fallback=[35.1796,129.0756];
function haversine(a,b){const rad=Math.PI/180,R=6371,dlat=(b[0]-a[0])*rad,dlon=(b[1]-a[1])*rad;const h=Math.sin(dlat/2)**2+Math.cos(a[0]*rad)*Math.cos(b[0]*rad)*Math.sin(dlon/2)**2;return 2*R*Math.asin(Math.sqrt(h));}
function recalc(){const pct=Number($('battery').value),cap=Number($('capacity').value),eff=Number($('efficiency').value);$('batteryValue').textContent=pct;if(!position||!target||!(cap>0)||!(eff>0)){$('distance').textContent='--';$('arrival').textContent='--';$('eta').textContent='경로 미설정';return;}const km=haversine(position,target);$('distance').textContent=km.toFixed(1);$('arrival').textContent=Math.max(0,pct-(km*eff/1000/cap*100)).toFixed(0);$('eta').textContent='직선거리 기준 · 길 안내 아님';}
function redraw(){if(!map)return;if(position){if(locationMarker)locationMarker.setLatLng(position);else locationMarker=L.circleMarker(position,{radius:9,color:'#ffffff',weight:3,fillColor:'#348bff',fillOpacity:1}).addTo(map).bindPopup('현재 위치');}if(target){if(targetMarker)targetMarker.setLatLng(target);else targetMarker=L.marker(target).addTo(map).bindPopup('목적지');}if(routeLine){map.removeLayer(routeLine);routeLine=null;}if(position&&target)routeLine=L.polyline([position,target],{color:'#69a9ff',weight:3,dashArray:'7 8'}).addTo(map);recalc();}
function setTarget(coords){target=coords;redraw();if(position)map.fitBounds([position,target],{padding:[38,38]});else map.setView(target,13);}
function gpsStatus(title, detail, kind=''){
  $('gpsBadge').textContent=title;
  $('gpsDetail').textContent=detail;
  $('gpsDetail').className='gps-detail '+(kind==='error'?'gps-error':kind==='ok'?'gps-ok':'');
  $('gpsConnect').textContent=kind==='ok'?'GPS 다시 연결':'GPS 연결 / 재시도';
}
function onPosition(p){
  position=[p.coords.latitude,p.coords.longitude];
  const s=p.coords.speed;
  $('speed').textContent=s===null||!Number.isFinite(s)?'--':Math.round(Math.max(0,s*3.6));
  const accuracy=Math.round(p.coords.accuracy);
  $('gpsAccuracy').textContent='정확도 약 '+accuracy+'m';
  gpsStatus('GPS 연결','현재 위치 수신 성공 · 정확도 약 '+accuracy+'m','ok');
  $('mapStatus').textContent='현재 위치 수신';
  redraw();if(!target&&map)map.setView(position,14);
}
function gpsError(err){
  const reasons={1:'위치 권한이 거부됐어. Safari 페이지 메뉴 → 웹 사이트 설정 → 위치를 허용한 뒤 재시도해.',2:'위치를 확인할 수 없어. 실외 또는 창가에서 위치 서비스를 켜고 다시 시도해.',3:'GPS 응답 시간이 초과됐어. 하늘이 보이는 곳에서 다시 시도해.'};
  gpsStatus('GPS 오류',reasons[err.code]||'위치 요청 실패: '+err.message,'error');
  $('gpsDebug').textContent='오류 코드: '+err.code+' · '+(err.message||'설명 없음');
  $('mapStatus').textContent='GPS 연결 실패';
}
function stopGps(){
  gpsRequestId++;
  if(watchId!==null){navigator.geolocation.clearWatch(watchId);watchId=null;}
  gpsStatus('GPS 중지','위치 추적을 중지했어. GPS 연결을 누르면 다시 시작해.');
  $('gpsDebug').textContent='추적 중지';
}
function locate(){
  if(!window.isSecureContext){gpsStatus('GPS 오류','HTTPS 연결이 아니어서 GPS를 사용할 수 없어. GitHub Pages HTTPS 주소로 접속해.','error');return;}
  if(!navigator.geolocation){gpsStatus('GPS 미지원','이 브라우저에서는 위치정보 기능을 사용할 수 없어. Safari에서 직접 열어줘.','error');return;}
  if(watchId!==null){navigator.geolocation.clearWatch(watchId);watchId=null;}
  const requestId=++gpsRequestId;
  gpsStatus('GPS 요청 중','아이폰의 위치 권한 및 GPS 신호를 확인하고 있어. 최대 20초 기다려줘.');
  $('gpsDebug').textContent='위치 요청 중 · '+new Date().toLocaleTimeString('ko-KR');
  const options={enableHighAccuracy:true,maximumAge:0,timeout:20000};
  try{
    // getCurrentPosition으로 최초 위치를 요청하고 watchPosition으로 계속 갱신한다.
    navigator.geolocation.getCurrentPosition(p=>{
      if(requestId!==gpsRequestId)return;
      onPosition(p);
      watchId=navigator.geolocation.watchPosition(p=>{
        if(requestId===gpsRequestId)onPosition(p);
      },e=>{if(requestId===gpsRequestId)gpsError(e);},options);
    },e=>{if(requestId===gpsRequestId)gpsError(e);},options);
  }catch(e){gpsStatus('GPS 오류','위치 요청 중 예외가 발생했어: '+e.message,'error');}
}
async function search(){const q=$('destination').value.trim();if(!q)return;const btn=$('search');btn.disabled=true;btn.textContent='검색 중…';try{const res=await fetch('https://nominatim.openstreetmap.org/search?format=json&limit=1&accept-language=ko&q='+encodeURIComponent(q));if(!res.ok)throw Error('검색 서비스 오류');const items=await res.json();if(!items.length)throw Error('검색 결과 없음');setTarget([Number(items[0].lat),Number(items[0].lon)]);$('mapStatus').textContent='목적지 지정 완료';}catch(e){$('mapStatus').textContent=e.message;}finally{btn.disabled=false;btn.textContent='검색해서 목적지 지정';}}
async function chargers(){const list=$('chargers');if(!position){list.replaceChildren();const li=document.createElement('li');li.textContent='먼저 내 위치 찾기를 눌러주세요.';list.append(li);return;}list.textContent='검색 중…';const [lat,lon]=position;const query=`[out:json][timeout:20];node(around:5000,${lat},${lon})["amenity"="charging_station"];out 30;`;try{const res=await fetch('https://overpass.kumi.systems/api/interpreter',{method:'POST',body:new URLSearchParams({data:query})});if(!res.ok)throw Error('충전소 조회 실패');const data=await res.json();const stations=(data.elements||[]).filter(x=>Number.isFinite(x.lat)&&Number.isFinite(x.lon)).map(x=>({...x,km:haversine(position,[x.lat,x.lon])})).sort((a,b)=>a.km-b.km).slice(0,12);list.replaceChildren();if(!stations.length){const li=document.createElement('li');li.textContent='5km 내 등록된 충전소가 없습니다.';list.append(li);}for(const s of stations){const li=document.createElement('li');const name=document.createElement('strong');name.textContent=s.tags?.name||'이름 없는 충전소';const details=document.createElement('span');details.textContent=` · 약 ${s.km.toFixed(1)}km`;const link=document.createElement('a');link.href=`https://www.openstreetmap.org/?mlat=${s.lat}&mlon=${s.lon}#map=17/${s.lat}/${s.lon}`;link.target='_blank';link.rel='noopener noreferrer';link.textContent=' 지도 보기';li.append(name,details,link);list.append(li);}}catch(e){list.textContent='조회 실패: '+e.message+' (잠시 후 재시도)';}}
function init(){if(typeof L==='undefined'){$('mapStatus').textContent='지도 라이브러리 로딩 실패';return;}map=L.map('map').setView(fallback,12);L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',{maxZoom:19,attribution:'© OpenStreetMap contributors'}).addTo(map);map.on('click',e=>setTarget([e.latlng.lat,e.latlng.lng]));$('mapStatus').textContent='지도를 터치해 목적지 지정';$('locate').addEventListener('click',locate);$('gpsConnect').addEventListener('click',locate);$('gpsStop').addEventListener('click',stopGps);$('clear').addEventListener('click',()=>{target=null;if(targetMarker){map.removeLayer(targetMarker);targetMarker=null;}if(routeLine){map.removeLayer(routeLine);routeLine=null;}recalc();});$('search').addEventListener('click',search);$('destination').addEventListener('keydown',e=>{if(e.key==='Enter')search();});$('findChargers').addEventListener('click',chargers);['battery','capacity','efficiency'].forEach(id=>$(id).addEventListener('input',recalc));recalc();}init();
