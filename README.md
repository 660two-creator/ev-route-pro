# EV Route Pro v3 — iPhone Safari 웹앱

## 주요 기능
- GPS 위치·정확도·속도 표시 (GPS 속도 미제공 시 위치 변화 기반 추정, 정지 상태에서는 `--` 또는 0이 정상일 수 있음)
- Leaflet 지도 타일 로딩 시 지도 크기 재계산 (`invalidateSize`) 및 재표시
- OpenStreetMap Nominatim 목적지 검색 (한국 검색 제한)
- 공개 OSRM 데모 서버의 **도로 경로 미리보기**와 주요 회전 지점 목록 (한국 도로 커버리지·서비스 안정성 보장 불가)
- OpenStreetMap Overpass 충전소 조회 (실시간 가용성 아님)
- 수동 배터리 및 주행 거리 기반 단순 도착 잔량 추정
- **Tesla 연동 서버 인터페이스** (실차 인증 자체는 미구현)

## 아이폰에서 설치 없이 배포
기존 GitHub Pages 저장소의 루트에 `index.html`, `app.js`, `manifest.webmanifest`를 업로드해 기존 파일을 덮어쓴 뒤, `https://660two-creator.github.io/ev-route-pro/?v=3`에서 확인하세요. 캐시가 남으면 Safari에서 새로고침하세요.

## Tesla 실차 연동의 한계와 보안
Tesla Fleet API는 공식 개발자 등록, OAuth 2.0 인증 및 토큰 보관·갱신을 위한 보안 백엔드가 필요합니다. 이 ZIP은 Tesla API OAuth 연결이나 실제 차량 읽기를 완성했다고 주장하지 않습니다. 웹앱의 '개인용 Tesla 연동 서버 URL'은 별도로 구축한 **본인 전용 HTTPS API**가 `{"battery_level": 76}` JSON을 반환하고 해당 웹앱 origin에 대해 CORS를 허용할 때만 동작합니다. 인증 없는 공개 배터리 API는 개인정보를 노출할 수 있으므로 만들지 마세요. GitHub Pages나 JS에 Tesla 비밀번호·OAuth 토큰·클라이언트 시크릿을 저장하지 마세요.

## 기타 제한
- 이 프로젝트는 Safari 웹앱이며 Apple CarPlay 앱이 아닙니다. CarPlay 내비게이션은 Apple의 권한 승인과 네이티브 iOS 앱 개발이 별도로 필요합니다.
- OSRM 공개 서버는 개발/데모용이며 트래픽, 지역 데이터, 약관, 응답 속도 제한이 있을 수 있습니다. 실서비스에는 적합한 상용/자체 경로 서버가 필요합니다.
- 턴바이턴 목록은 미리보기이며 실시간 주행 유도·교통·차선 안내·음성 안내를 제공하지 않습니다.
- 예상 도착 배터리는 배터리 용량·평균 전비를 사용한 근사치로, 기온·고도·속도·실시간 전비·충전 정차를 반영하지 않습니다.
- 주행 중에는 휴대폰을 조작하지 마세요.
