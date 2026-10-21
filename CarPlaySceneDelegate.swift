import UIKit
import CarPlay
import MapKit

final class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    private var controller: CPInterfaceController?
    private var mapTemplate: CPMapTemplate?
    private var mapController: CarPlayMapViewController?

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didConnect interfaceController: CPInterfaceController,
                                  to window: CPWindow) {
        controller = interfaceController
        let mapController = CarPlayMapViewController()
        self.mapController = mapController
        window.rootViewController = mapController
        let template = CPMapTemplate()
        template.mapButtons = [
            CPMapButton { [weak mapController] _ in mapController?.centerOnUser() }
        ]
        template.mapButtons[0].image = UIImage(systemName: "location.fill")
        mapTemplate = template
        interfaceController.setRootTemplate(template, animated: false, completion: nil)
        LocationStore.shared.start()
    }

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didDisconnect interfaceController: CPInterfaceController,
                                  from window: CPWindow) {
        window.rootViewController = nil
        controller = nil
        mapTemplate = nil
        mapController = nil
    }
}

final class CarPlayMapViewController: UIViewController {
    private let mapView = MKMapView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
        mapView.mapType = .standard
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    func centerOnUser() { mapView.setUserTrackingMode(.followWithHeading, animated: true) }
}
