import Foundation
import CoreBluetooth

// Discovery-only prototype. This does NOT pair, authenticate, issue commands, or act as a key.
final class TeslaBLEScanner: NSObject, ObservableObject, CBCentralManagerDelegate {
    @Published private(set) var stateText = "검색 대기"
    @Published private(set) var discoveredNames: [String] = []
    private var central: CBCentralManager?
    private var scanRequested = false

    func startScan() {
        scanRequested = true
        if central == nil { central = CBCentralManager(delegate: self, queue: nil) }
        else { beginIfPoweredOn() }
    }
    func stopScan() { scanRequested = false; central?.stopScan(); stateText = "검색 중지" }
    func centralManagerDidUpdateState(_ central: CBCentralManager) { beginIfPoweredOn() }
    private func beginIfPoweredOn() {
        guard scanRequested, let central else { return }
        guard central.state == .poweredOn else { stateText = "Bluetooth 사용 권한 및 활성화 상태 확인 필요"; return }
        discoveredNames = []
        stateText = "주변 BLE 장치 검색 중 (등록 기능 미구현)"
        central.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let name = peripheral.name ?? (advertisementData[CBAdvertisementDataLocalNameKey] as? String) ?? ""
        guard name.localizedCaseInsensitiveContains("Tesla") || name.hasPrefix("S") else { return }
        let label = "\(name) · \(peripheral.identifier.uuidString.prefix(8))"
        if !discoveredNames.contains(label) { discoveredNames.append(label) }
    }
}
