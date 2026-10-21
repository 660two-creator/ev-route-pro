import Foundation
import MapKit
import Combine

@MainActor final class RouteStore: ObservableObject {
    static let shared = RouteStore()
    @Published var query = ""
    @Published private(set) var matches: [MKMapItem] = []
    @Published private(set) var route: MKRoute?
    @Published private(set) var destination: MKMapItem?
    @Published private(set) var error: String?
    @Published private(set) var loading = false
    private var searchTask: Task<Void, Never>?

    func search() {
        searchTask?.cancel()
        let term = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else { matches = []; return }
        searchTask = Task {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = term
            if let center = LocationStore.shared.coordinate {
                request.region = MKCoordinateRegion(center: center, latitudinalMeters: 60000, longitudinalMeters: 60000)
            }
            do {
                let result = try await MKLocalSearch(request: request).start()
                guard !Task.isCancelled else { return }
                matches = Array(result.mapItems.prefix(8))
                error = matches.isEmpty ? "검색 결과가 없습니다." : nil
            } catch {
                if !Task.isCancelled { self.error = "검색에 실패했습니다: \(error.localizedDescription)" }
            }
        }
    }

    func navigate(to item: MKMapItem) async {
        guard let origin = LocationStore.shared.coordinate else {
            error = "현재 위치를 확인한 후 다시 시도하세요."
            return
        }
        loading = true
        defer { loading = false }
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
        request.destination = item
        request.transportType = .automobile
        do {
            let response = try await MKDirections(request: request).calculate()
            guard let first = response.routes.first else { error = "자동차 경로를 찾지 못했습니다."; return }
            route = first
            destination = item
            matches = []
            error = nil
        } catch { self.error = "경로 계산 실패: \(error.localizedDescription)" }
    }

    func stop() { route = nil; destination = nil }
}
