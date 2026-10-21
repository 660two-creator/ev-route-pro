import UIKit
import SwiftUI
import MapKit

@main final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool { true }
}
final class PhoneSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: scene)
        window.rootViewController = UIHostingController(rootView: PhoneView())
        window.makeKeyAndVisible()
        self.window = window
    }
}

struct PhoneView: View {
    @StateObject private var location = LocationStore.shared
    @StateObject private var routes = RouteStore.shared
    @StateObject private var ble = TeslaBLEScanner()
    @State private var showSearch = false
    @State private var showVehicle = false
    @State private var camera: MapCameraPosition = .automatic
    private let ink = Color(red: 0.045, green: 0.058, blue: 0.085)

    var body: some View {
        GeometryReader { geometry in
            let wide = geometry.size.width > geometry.size.height
            ZStack {
                ink.ignoresSafeArea()
                if wide {
                    HStack(spacing: 0) {
                        informationPanel.frame(width: geometry.size.width * 0.36)
                        mapPanel
                    }
                } else {
                    VStack(spacing: 0) {
                        informationPanel.frame(height: geometry.size.height * 0.39)
                        mapPanel
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { location.start() }
        .onChange(of: routes.route?.distance) { _, _ in
            if let route = routes.route { camera = .rect(route.polyline.boundingMapRect) }
        }
        .sheet(isPresented: $showSearch) { searchSheet }
        .sheet(isPresented: $showVehicle) { vehicleSheet }
    }

    private var informationPanel: some View {
        VStack(spacing: 12) {
            HStack {
                Text("EV ROUTE PRO").font(.caption.bold())
                Spacer()
                Button { showVehicle = true } label: { Image(systemName: "car.side") }
            }
            Text("MODEL Y JUNIPER").font(.caption2).foregroundStyle(.secondary)
            Spacer(minLength: 2)
            if routes.route != nil {
                Text("GPS SPEED").font(.caption).foregroundStyle(.secondary)
                Text("\(Int(location.speedKPH.rounded()))").font(.system(size: 64, weight: .semibold, design: .rounded)).monospacedDigit()
                Text("km/h").foregroundStyle(.secondary)
                Text(routes.destination?.name ?? "목적지").font(.subheadline.bold()).lineLimit(1)
                if let route = routes.route {
                    Text("경로 약 \(String(format: "%.1f", route.distance / 1000)) km · 예상 \(Int(route.expectedTravelTime / 60))분")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Text("경로 미리보기 · 실시간 턴 안내 아님").font(.caption2).foregroundStyle(.orange)
            } else {
                Image(systemName: "car.side.fill").resizable().scaledToFit().frame(maxWidth: 190, maxHeight: 110)
                    .foregroundStyle(.white).accessibilityLabel("차량 이미지 자리 표시자")
                Text("White Model Y · 차량 데이터 미연결").font(.caption).foregroundStyle(.secondary)
            }
            Spacer(minLength: 2)
            HStack {
                Text("외기온 --°")
                Spacer()
                Text("주행거리 -- km")
                Spacer()
                Text("배터리 --%")
            }.font(.caption2).foregroundStyle(.secondary)
            HStack {
                Button("목적지 검색") { showSearch = true }.buttonStyle(.borderedProminent)
                if routes.route != nil { Button("안내 종료") { routes.stop() }.buttonStyle(.bordered) }
            }
        }.padding(14).background(ink)
    }

    private var mapPanel: some View {
        ZStack(alignment: .topTrailing) {
            Map(position: $camera) {
                UserAnnotation()
                if let route = routes.route { MapPolyline(route.polyline).stroke(.cyan, lineWidth: 6) }
                if let destination = routes.destination { Marker(destination.name ?? "목적지", coordinate: destination.placemark.coordinate) }
            }
            .mapStyle(.standard(elevation: .flat, emphasis: .muted))
            .mapControls { MapCompass(); MapUserLocationButton() }
            Text(Date.now, style: .time).font(.caption.bold()).padding(9)
                .background(.ultraThinMaterial, in: Capsule()).padding(14)
        }
    }

    private var searchSheet: some View {
        NavigationStack {
            VStack(spacing: 10) {
                HStack {
                    TextField("장소명 또는 주소", text: $routes.query)
                        .textFieldStyle(.roundedBorder).submitLabel(.search).onSubmit { routes.search() }
                    Button("검색") { routes.search() }
                }.padding(.horizontal)
                if let error = routes.error { Text(error).font(.caption).foregroundStyle(.orange) }
                List(routes.matches, id: \.self) { item in
                    Button {
                        Task { await routes.navigate(to: item); if routes.route != nil { showSearch = false } }
                    } label: {
                        VStack(alignment: .leading) {
                            Text(item.name ?? "장소")
                            Text(item.placemark.title ?? "").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
                if routes.loading { ProgressView("자동차 경로 계산 중") }
            }
            .navigationTitle("목적지 검색")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("닫기") { showSearch = false } } }
        }
    }

    private var vehicleSheet: some View {
        NavigationStack {
            VStack(spacing: 14) {
                Text("Tesla BLE 연결 준비").font(.title3.bold())
                Text("현재는 주변 장치 검색만 가능합니다. 카드키 승인·키 등록·차량 정보 조회는 아직 구현되지 않았습니다.")
                    .font(.subheadline).foregroundStyle(.secondary)
                Text(ble.stateText).font(.caption)
                List(ble.discoveredNames, id: \.self) { Text($0) }
                HStack {
                    Button("BLE 검색") { ble.startScan() }.buttonStyle(.borderedProminent)
                    Button("검색 중지") { ble.stopScan() }
                }
                Spacer()
            }.padding()
                .navigationTitle("차량 등록")
                .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("닫기") { ble.stopScan(); showVehicle = false } } }
        }
    }
}
