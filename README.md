# EV Route Pro v4 — iPhone Safari prototype

## 설치
GitHub 저장소 `660two-creator/ev-route-pro` 루트에 `index.html`, `app.js`, `manifest.webmanifest`를 업로드해 기존 파일을 교체합니다. GitHub Pages가 배포된 후 `https://660two-creator.github.io/ev-route-pro/?v=4`에서 실행합니다.

## 기능
- 위치 권한 요청, GPS 속도계와 지도 추적
- 한국 내 장소 검색(Nominatim), 도로 경로 조회(OSRM, 공개 서버의 제공 범위에 따라 실패 가능)
- 좌/우회전 구분, 다음 회전까지 직선거리 기반 표시, 음성 합성, 경로 이탈 감지 후 재계산(실험 기능)
- 충전소 조회(OSM/Overpass), 수동 배터리 및 추정 도착 배터리
- 개인용 Tesla HTTPS 백엔드 응답 `{"battery_level": 76}`를 읽는 인터페이스만 제공. OAuth 및 실제 Tesla Fleet API 인증은 미구현.

## 한계 및 안전
- 다음 회전 거리 표시는 도로를 따라 남은 거리가 아니라 GPS 위치에서 회전 지점까지의 **직선거리**입니다. GPS 오차로 잘못된 안내가 나올 수 있습니다.
- 경로 이탈은 GPS 정확도 55m 이하, 경로에서 100m 이상 이탈했을 때 30초 간격으로 감지합니다.
- Safari 백그라운드/화면 잠금에서 GPS와 음성 동작은 보장되지 않습니다.
- 공개 OSRM 경로의 도로 적합성/교통정보/차량 제한은 검증되지 않았습니다. 실제 운전에는 검증된 내비게이션을 사용하고 운전 중 휴대폰을 조작하지 마세요.
- CarPlay와 Android Auto 지원은 **아직 미구현**입니다. 각각 네이티브 iOS/Android 앱 및 플랫폼별 심사·권한이 필요합니다.
- GitHub에 Tesla 비밀번호, API 토큰, 시크릿을 업로드하지 마세요.
