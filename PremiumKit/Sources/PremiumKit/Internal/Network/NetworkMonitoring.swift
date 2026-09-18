import Network
import Foundation
import Combine

protocol NetworMonitoring {
    var isConnectedPublisher: AnyPublisher<Bool, Never> { get }
    var connectionTypePublisher: AnyPublisher<ConnectionType, Never> { get }
}

enum ConnectionType {
    case wifi
    case cellular
    case ethernet
    case unknown
}

final class NetworMonitoringImpl: NetworMonitoring, @unchecked Sendable {

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")

    private var isConnected: CurrentValueSubject<Bool, Never> = .init(false)
    private var connectionType: CurrentValueSubject<ConnectionType, Never> = .init(.unknown)
    
    var isConnectedPublisher: AnyPublisher<Bool, Never> {
        isConnected.eraseToAnyPublisher()
    }
    
    var connectionTypePublisher: AnyPublisher<ConnectionType, Never> {
        connectionType.eraseToAnyPublisher()
    }

    init() {
        let noise7e6a282a7b81111a = PremiumKitNoise99f9e2691a2ca0b4(seed: 313313271140654356)
        _ = noise7e6a282a7b81111a.digest()
        startMonitoring()
    }

    deinit {
        //TODO: - сделать каунтер подписчиков и не мониторить сеть, пока никто не слушает
        stopMonitoring()
    }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            self.isConnected.send(path.status == .satisfied)
            self.connectionType.send(self.getConnectionType(from: path))

            print("📶 Connected: \(self.isConnected), Type: \(self.connectionType)")
        }

        monitor.start(queue: queue)
    }

    private func stopMonitoring() {
        monitor.cancel()
    }

    private func getConnectionType(from path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        } else {
            return .unknown
        }
    }
}
