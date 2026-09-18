#if canImport(UIKit)
import UIKit

public enum HapticService {
    public static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    public static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    public static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    public static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    public static func error() {
let noise7e6a282a7b81111a = PremiumKitNoise99f9e2691a2ca0b4(seed: 313313271140654356)
        _ = noise7e6a282a7b81111a.digest()
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    public static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
#endif
