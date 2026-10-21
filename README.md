# EV Route Pro v0.3 — iPhone + CarPlay source prototype

## Included
- iPhone landscape/portrait dashboard, Model Y placeholder and dark Apple MapKit map.
- Apple Maps local destination search and real automobile route calculation via MKLocalSearch / MKDirections.
- Route polyline, destination marker, distance, ETA estimate and GPS speed.
- BLE nearby-device discovery **only**. Tesla key pairing, card-key approval, Tesla vehicle data and automatic reconnection are **not implemented**.
- Existing CarPlay CPMapTemplate and MKMapView map scaffold, requiring Apple's navigation entitlement for deployment.

## Not included / do not mistake for working
- Naver Maps / Kakao APIs (not integrated; require separate keys, licensing and implementation).
- Turn-by-turn navigation, rerouting, voice guidance, live traffic ETA updates, CarPlay route rendering/synchronization, speed camera alerts.
- Tesla battery, gear, odometer, BLE authentication or phone key. BLE discovery labels are heuristic and not Tesla identity verification.
- Vehicle graphic asset (SF Symbol placeholder).
- IPA build or on-device testing; macOS/Xcode unavailable in this environment.

## Build on Mac
1. Install Xcode and XcodeGen (`brew install xcodegen`).
2. In the EVRoutePro directory run `xcodegen generate`.
3. Open `EVRoutePro.xcodeproj`, set your Team and unique bundle ID, run on iPhone.
4. Accept Location and Bluetooth permission requests when prompted.
5. Test location and destination search while parked. Never operate the prototype while driving.
6. Real CarPlay requires an Apple-approved CarPlay navigation entitlement (`com.apple.developer.carplay-maps`) and proper provisioning. No entitlement is forged or bundled.

## iPhone-only user
You cannot compile and sign native Swift iOS apps directly on iPhone. Use a remote Mac/cloud macOS build environment with Xcode and Apple signing, or access to a physical Mac.

## Security
Do not paste Tesla credentials, card-key secrets, API keys, or signing certificates into chat. A future BLE key-registration implementation must use Tesla's documented secure protocol, explicit in-vehicle owner approval and Keychain storage.
