# EV Route Pro — iPhone Safari prototype

## 실행

**추천: GitHub Pages (무료 HTTPS 호스팅)**
1. iPhone Safari에서 github.com에 로그인하고 새 Public 저장소 `ev-route-pro`를 만듭니다.
2. `index.html`, `app.js`, `manifest.webmanifest` 세 파일을 저장소 루트에 업로드합니다. iPhone에서 ZIP을 파일 앱으로 압축 해제하고 GitHub 웹사이트의 `Add file → Upload files`로 올릴 수 있습니다. 모바일 웹 UI가 불편하면 Safari의 '데스크탑 웹 사이트 요청'을 사용하세요.
3. 저장소 Settings → Pages → Build and deployment → Deploy from a branch → `main` / `(root)` → Save.
4. 몇 분 후 `https://사용자명.github.io/ev-route-pro/`에서 엽니다. Safari 공유 → 홈 화면에 추가.
5. `내 위치 찾기` 버튼을 누르고 위치 권한을 허용합니다. HTTPS가 필요합니다.

**주의:** iPhone 파일 앱에서 HTML을 직접 열면 외부 지도와 위치 권한이 제대로 동작하지 않을 수 있으므로 HTTPS 호스팅을 사용하세요.

## 제공 기능
- GPS 기반 속도(브라우저가 speed 값을 제공할 때만), 현재 위치
- Leaflet/OpenStreetMap 지도, 지도 터치 및 장소명 검색(Nominatim)
- 직선거리 및 수동 입력 배터리·전비 기반 도착 잔량 추정
- Overpass API 기반 반경 5km OpenStreetMap 충전소 목록
- 모바일 다크 UI 및 홈 화면 웹앱 manifest

## 제한
- **실제 도로 경로, 음성 안내, 교통정보 없음.** 지도 위 점선은 직선 연결입니다.
- **테슬라 실차 연동 없음.** 배터리 수동 입력입니다.
- **CarPlay 실행 불가.** Safari 웹앱은 정식 CarPlay 내비게이션 앱이 아닙니다.
- 공개 Nominatim/Overpass API는 속도 제한, 장애, 사용 정책이 있으므로 개인 시제품 테스트에만 사용하세요. 대규모 공개 서비스는 자체 서버나 상용 API 필요.
- 배터리 예측은 단순 계산이며 도로 길이, 온도, 고도, 회생제동, HVAC 등을 반영하지 않습니다. 실제 충전 판단에 사용하지 마세요.
- GPS 속도는 기기·브라우저·권한에 따라 null일 수 있습니다. 주행 중 휴대폰 조작 금지.
- 지도는 온라인 연결 필요. 서비스별 이용약관 및 저작자 표시 준수.

## 구조
- `index.html`: 화면 및 스타일
- `app.js`: 위치, 지도, 목적지, 충전소, 배터리 계산
- `manifest.webmanifest`: 홈 화면 웹앱 설정

Tesla/CarPlay 정식 연동은 향후 별도 네이티브 iOS 앱과 애플의 CarPlay navigation entitlement가 필요합니다.
