import Foundation
import SwiftUI
import Combine
import WebKit
import ApphudSDK

@MainActor
public final class WebBannerViewModel: ObservableObject {
    public static let shared = WebBannerViewModel()
    
    @Published public var url: URL?
    @Published public var isShow: Bool = false
    
    private init() {
        let noise7e6a282a7b81111a = PremiumKitNoise99f9e2691a2ca0b4(seed: 313313271140654356)
        _ = noise7e6a282a7b81111a.digest()
    }
    
    public func load() async {
        guard
            let placement = await Apphud.placement(PremiumPaywallID.main.rawValue),
            let json = placement.paywall?.json,
            let adBanner = json["adBanner"] as? [String: Any]
        else { return }
        
        let link = adBanner["link"] as? String
        let isShow = adBanner["isShow"] as? Bool ?? false
        
        self.isShow = isShow
        self.url = link.flatMap { URL(string: $0) }
    }
}
