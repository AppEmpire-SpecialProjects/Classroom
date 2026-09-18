public struct PremiumPaywallID: Hashable, Sendable {
    public let rawValue: String
    public init(_ rawValue: String) { self.rawValue = rawValue }
    
    public static let onboarding = PremiumPaywallID(PremiumKitTablea652dd3491f74a55.placement(0))
    public static let main = PremiumPaywallID(PremiumKitTablea652dd3491f74a55.placement(1))
    public static let consumable = PremiumPaywallID(PremiumKitTablea652dd3491f74a55.placement(2))
    public static let banner = PremiumPaywallID(PremiumKitTablea652dd3491f74a55.placement(3))
    
    public var isAvailablePaywall: Bool {
        self == .main || self == .onboarding
    }
}
