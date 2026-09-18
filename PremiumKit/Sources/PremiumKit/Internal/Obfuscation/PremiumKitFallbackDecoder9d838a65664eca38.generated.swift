// Generated authenticated fallback decoder. Regenerate from a clean clone.
import CryptoKit
import Foundation

internal enum PremiumKitFallbackDecoder9d838a65664eca38 {
    private static let headerBytes = 16
    private static let positions: [Int] = [2, 31, 10, 28, 3, 17, 8, 26, 19, 24, 9, 25, 6, 15, 23, 21, 14, 13, 29, 0, 18, 12, 1, 22, 11, 16, 30, 27, 7, 20, 5, 4]
    private static let orders: [[Int]] = [[15, 24, 31, 11, 17, 6, 7, 8, 1, 0, 26, 27, 16, 22, 29, 3, 14, 25, 5, 4, 21, 12, 10, 18, 20, 28, 13, 30, 19, 9, 23, 2], [4, 5, 19, 21, 30, 17, 31, 3, 22, 14, 28, 2, 10, 29, 16, 26, 9, 1, 7, 25, 13, 27, 8, 24, 11, 6, 20, 12, 0, 15, 18, 23], [7, 5, 31, 26, 8, 16, 15, 21, 29, 25, 20, 3, 19, 18, 12, 17, 6, 2, 1, 28, 13, 23, 9, 14, 11, 10, 4, 0, 22, 27, 30, 24], [10, 14, 3, 28, 15, 8, 21, 0, 29, 12, 6, 9, 31, 25, 17, 18, 26, 4, 23, 1, 11, 27, 7, 2, 19, 24, 30, 13, 22, 5, 16, 20], [1, 3, 21, 27, 19, 4, 31, 29, 10, 6, 22, 11, 28, 15, 18, 9, 12, 13, 30, 14, 26, 16, 17, 20, 0, 5, 24, 23, 8, 7, 25, 2], [22, 27, 4, 19, 8, 9, 2, 7, 18, 1, 29, 26, 14, 25, 28, 6, 10, 31, 21, 12, 15, 0, 16, 13, 3, 23, 11, 17, 30, 5, 20, 24], [9, 13, 8, 15, 7, 24, 27, 25, 10, 2, 6, 28, 12, 31, 18, 1, 22, 23, 5, 11, 4, 16, 21, 3, 17, 19, 29, 0, 20, 14, 30, 26], [7, 11, 23, 0, 31, 10, 26, 22, 15, 18, 8, 28, 6, 4, 1, 30, 14, 5, 29, 24, 16, 17, 12, 13, 27, 9, 21, 25, 20, 2, 19, 3]]

    static func decrypt(_ encryptedData: Data) -> Data? {
        guard encryptedData.count > headerBytes else { return nil }
        let payload = encryptedData.subdata(in: headerBytes..<encryptedData.count)
        let fragments: [[UInt8]] = [Segment81a069795fb4573d.nibbles, Segmentb04847b61a765bbb.nibbles, Segment40e85917180f38f3.nibbles, Segment2545904d4c24e078.nibbles, Segmentb203b09dabc49503.nibbles, Segment39eb16b493a0e564.nibbles, Segment0c6567cf3873ea44.nibbles, Segment418b5f72155976ff.nibbles]
        guard fragments.count == orders.count,
              fragments.allSatisfy({ $0.count == positions.count }) else { return nil }
        var permuted = [UInt8](repeating: 0, count: positions.count)
        for pair in stride(from: 0, to: fragments.count, by: 2) {
            var share = [UInt8](repeating: 0, count: positions.count)
            for slot in 0..<positions.count {
                share[orders[pair][slot]] = fragments[pair][slot] << 4
            }
            for slot in 0..<positions.count {
                share[orders[pair + 1][slot]] |= fragments[pair + 1][slot]
            }
            for index in share.indices {
                permuted[index] ^= share[index]
            }
        }
        var keyBytes = [UInt8](repeating: 0, count: positions.count)
        for (position, originalIndex) in positions.enumerated() {
            guard keyBytes.indices.contains(originalIndex) else { return nil }
            keyBytes[originalIndex] = permuted[position]
        }
        let key = SymmetricKey(data: Data(keyBytes))
        guard let sealedBox = try? AES.GCM.SealedBox(combined: payload) else { return nil }
        return try? AES.GCM.open(sealedBox, using: key)
    }
}
