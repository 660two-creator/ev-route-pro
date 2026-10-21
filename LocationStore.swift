import Foundation
import CoreLocation

final class LocationStore: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationStore()
    @Published private(set) var speedKPH: Double = 0
    @Published private(set) var coordinate: CLLocationCoordinate2D?
    private let manager = CLLocationManager()
    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    func start() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last, latest.horizontalAccuracy >= 0 else { return }
        coordinate = latest.coordinate
        speedKPH = latest.speed >= 0 ? latest.speed * 3.6 : 0
    }
}
